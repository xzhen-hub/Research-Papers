

/**************************redo the regrssion analysis by cleaning up winsor2 process*********/
/**************************revise date: 10/6/2024: robust tests (EFD, subsamples based on credit rating, alt risk measures**************************/

clear
set more off
cd "C:\Users\xzhen\Desktop\research folder2020-now\New project_Bank MA and customer_2020\newdata_2021"

	
	
/***use the file "all_div_index" keep it unique at state year level and merged it with the master file*/
			use "C:\Users\xzhen\Desktop\research folder2020-now\New project_Bank MA and customer_2020\geo div\all_div_index", clear
			rename stnumbr statecode
			rename rssdid rssd9001
			rename year cyear
			duplicates drop statecode cyear, force
	
	
			bysort cyear: egen geodiv_mean1=mean(div_index_RSSDst)
			gen highgeodiv1=(div_index_RSSDst>=geodiv_mean)
			bysort cyear: egen geodiv_median1=median(div_index_RSSDst)
			gen highgeodiv2=(div_index_RSSDst>=geodiv_median)
	
	
			egen pc75geodiv =pctile(div_index_RSSDst), by (cyear) p(75)
			egen pc25geodiv =pctile(div_index_RSSDst), by (cyear) p(25)

				gen highgeodiv3=(div_index_RSSDst>=pc75geodiv)
				gen lowgeodiv3=(div_index_RSSDst<=pc25geodiv)

			save "C:\Users\xzhen\Desktop\research folder2020-now\New project_Bank MA and customer_2020\geo div\all_div_index_unique", replace
	
	
	
		              /**********************************************************************/
		              /**********************************************************************/
		              /**********************************************************************/
		              /**********process of generate the file "link_boc_lender"**************/
	                
	              /***(1) import dealscan linktable***/
	              import delimited "D:\research\dealscan\documentation_link\linktable.csv",  clear
	              codebook bcoid
	               duplicates report facid //unique 121366 obs
 	              /***generate bankyear***/
 	              destring facstartdate, replace
	              	              /**  gen bankyear=substr(string(facstartdate,"%07.0f"),-4,4)
	               gen bankyear  = real(substr(string(facstartdate),-4,4)) **/
 	              gen bankyear=substr(facstartdate,-4,4)
 	              rename facid facilityid
	               destring bankyear, replace
	               save linktable, replace

 
 	               /****(2) merge lendershares and facility by using facilityid****/
 
	               use "D:\research\dealscan\dealscan_need\lendershares.dta" , clear
 	              joinby facilityid using "D:\research\dealscan\dealscan_need\facility", unm(master)
 	              count
 	              count if _merge==3 //1619811-all merged
	               keep facilityid companyid lender lenderrole bankallocation agentcredit leadarrangercredit packageid borrowercompanyid ticker facilitystartdate facilityenddate company loantype facilityamt maturity secured bankyear
	               save boc_lender_facid1, replace
 	              
  	              /****generate the total facility amount at borrower-year level
 	              collapse (sum) sumfacilityamt=facilityamt, by (borrowercompanyid bankyear)
	              save sumfacilityamt, replace*****/
 
 	              	              /****(3) merge lender, facility with linktable****/
 	              use boc_lender_facid1, clear
 	              joinby facilityid  using linktable //756006 obs
 	              save link_boc_lender, replace
	
	
	
	
	
				* use "H:\XINTING_research\ub and innovation\data\link_boc_lender", clear
				* save link_boc_lender, replace
				 
				 
				 use link_boc_lender, clear
				 duplicates report facilityid bankyear  /*not unique*/
				 duplicates report gvkey bankyear  /*not unique*/
**# 1 seems the same no matter how to sort
				 sort borrowercompanyid bankyear 
 				 by borrowercompanyid bankyear: gen leadlender1 = (leadarrangercredit == "Yes" |lenderrole== "Agent"|lenderrole== "Admin agent"|lenderrole=="Arranger"|lenderrole=="Lead manager" |lenderrole=="Lead bank")
				 /***keep all lenderid while mark the leadlenders as an indicator***********/
				 count if leadlender1 ==1 
				 
**# 2
				 
						 sort facilityid bankyear 
		 				 by facilityid bankyear: gen leadlender2 = (leadarrangercredit == "Yes" |lenderrole== "Agent"|lenderrole== "Admin agent"|lenderrole=="Arranger"|lenderrole=="Lead manager" |lenderrole=="Lead bank")
				 /***keep all lenderid while mark the leadlenders as an indicator***********/
				 count if leadlender2 ==1 
		 
				 
				 /*****mark the largest lead lenders that contribute most******/

				 rename companyid lenderid
				 sort gvkey bankyear

				 bysort gvkey bankyear: egen number_leadlender1=count(lenderid)
				 bysort gvkey bankyear: egen boc_loanamt=total(facilityamt)

				 gen share=facilityamt/boc_loanamt
				 egen rank = rank(share), by(gvkey bankyear) 
				 sort gvkey bankyear
				 egen max=max(rank), by(gvkey bankyear)  
				 gen largestlead=(rank==max)

				 keep lenderid lender leadlender1 largestlead number_leadlender1 facilityid lenderrole borrowercompanyid company loantype facilityamt maturity  secured bankyear  bcoid  gvkey  
                 save ds_gvkey_link, replace





                /************check the ds-rssd link table, Jan Keil (2018) ***/
                use rssd_lenderid, clear
                sort lenderid year
                count if best_match==1
                duplicates drop lenderid year, force
				count
                rename year cyear, replace
                save rssd_lenderid_unique1, replace

				/**
				use rssd_lenderid_unique1,clear
				count /***24769***/
				use rssd_lenderid_unique,clear
				count /***24363***/
**/
				
				/****************************************************************************/
				/****************************************************************************/
				/****************************************************************************/
				/*****add bank loan data (from dealscan)******/

		use ds_gvkey_link, clear
		*duplicates report facilityid bankyear		/****not unique***/
		
/*****************4. merge with loan contract terms files*******************/
/*****************4.1 merge with primarypurpose**************************/		
joinby facilityid using primarypurpose, unm(master)	
codebook loantype
drop _merge
		
/*****************4.2 merge with number of covenants and collateral**************************/		
joinby facilityid using covenant_collateral, unm(master)	
replace numfincovenant=0 if numfincovenant==.
drop _merge
count
//756400

/******generate total number of covenants*************/
**# Bookmark #1
gen totalcovenant2=numfincovenant+num_generalcov2
gen totalcovenant1=numfincovenant+num_generalcov

/******generate variable: loan scale*****
gen facilityamt_mil=facilityamt/1000000
gen loanscale=facilityamt_mil/at**/


/****************4.3 merge with logspread *************/
joinby facilityid using logspread, unm(master)
drop _merge
count		//756400
				
				
				
		/*generate new variables that are needed
gen AISU=commitmentfee+facilityfee
gen totdebt=bookleverage*at
gen loansize=exp(logloansize)
 
gen loanconcentration=loansize/(loansize+totdebt)
gen logaverageaisd=log((allindrawn[_n-6]+allindrawn[_n-5]+allindrawn[_n-4]+allindrawn[_n-3]+allindrawn[_n-2]+allindrawn[_n-1])/6)
gen distance=log(1+ddsic1_b)
				*/
			
				
				/****************************************************************************/
				/****************************************************************************/
				/****************************************************************************/

/***********merge the master file with ds_rssd link tabble********************/
*use ds_gvkey_link, clear
gen cyear=bankyear
*duplicates report lenderid cyear  /*not unique***/
 **merge m:1 lenderid cyear using rssd_lenderid_unique1
 //762449
 joinby lenderid cyear using rssd_lenderid_unique1, unm(master)
 count if _merge==3
 /**629544**/
keep if _merge==3
drop _merge


 
gen yearmaturity=maturity/12
gen matyear=ceil(yearmaturity)
replace matyear=0 if matyear==.


/********merge with tgt bank data***********/
                  /********merge with bank MA data*********************/
                  use tgt_yr, clear
                  duplicates report rssd9001 cyear //not unique
                  duplicates drop rssd9001 cyear, force
                  save tgt_yr_uni, replace
		
rename rssd rssd9001		
joinby rssd9001 cyear using tgt_yr_uni, unm(master)
count /**629544***/
count if _merge==3
//15440, not 11039
*duplicates report gvkey cyear
*duplicates drop gvkey cyear, force


count if largestlead==1
/*365977 out of 629544*/

/*******keep the lead lender take the largest shares***********/
*keep if largestlead==1

/******************keep the first largest lead lender if there exsit multiple largest lead lenders****/
*drop rank_lender min_lender firstlender
egen rank_lender = rank(lenderid), by(gvkey bankyear) 
egen min_lender=min(rank_lender), by(gvkey bankyear)  
gen firstlender=(rank_lender==min_lender)

*keep if firstlender==1
//after keep the first lender, there still exist duplicates for gvkey-bankyear that have duplicated same lenders***/
*count /*61104*/
*duplicates drop gvkey bankyear, force
*count /*58955*/


/****IMPORTANT: check mayear to generate IV*****/
*keep gvkey bcoid rssd9001 bankyear cyear non_id surv_id mayear largestlead rank_lender min_lender firstlender
duplicates drop gvkey cyear, force
count /*59422*/

/***it's possible one firm borrows from multiple tgt banks during the same year. Keep the 1st. then duplicates drop gvkey cyear*****************/
/*****CHECK FOR THE SAMPLE: HOW MANY FIRMS ONLY BORROWS ONCE FROM tgt?************/
*replace mayear=. if mayear==0
*replace mayear=0 if missing(mayear)
*drop mayr
bysort gvkey: egen mayr=min(mayear)

*egen tag = tag(mayr gvkey) 
*egen distinct_tgt = total(tag), by(gvkey)
*su distinct_tgt  //[0 1]
*drop tag distinct_tgt
*drop yeardiff
sort gvkey cyear 
gen yeardiff=cyear-mayr

gen tgt_post=( yeardiff>=0 )
replace tgt_post=0 if yeardiff==.

codebook gvkey if tgt_post==1
codebook gvkey if tgt_post==0


codebook gvkey cyear /***15396 firms, [1982 2014]***/


/***generate loansize based on firm-year level*********/
bysort gvkey cyear: gen loanamt=sum(facilityamt)
gen loansize=ln(loanamt)


/*********merge with control****************/

                           use "E:\Research\control var_code_all\data\control_v4", clear
                           duplicates report gvkey cyear
                           /***unique****/
                           save firmcontrol4, replace
						   
						   
drop _merge
joinby gvkey cyear using firmcontrol, unm(master)
drop _merge
codebook cyear
/** [1982,2014] ***/


/***********add statecode****************/
joinby gvkey cyear using gvkey_cyear_state, unm(master)
/*59442*/
codebook cyear if !missing(statecode)

/*****[1982,2013]  ***/

                 /***added 11/21/2021: merge with risk data and run simple test***********/
                 use "C:\Users\xzhen\Desktop\bank MA and firm risk-2024-literature\Risk Measures\risk_measures", clear
                 gen cyear=year
                 *keep cyear gvkey tvxd tvdd tvxw tvdw  riy_leverage  riy_debtmat riy_rd riy_ppe riy_capexp riy_mb rty_roa rty_roe ivxd_2_J1 ivxd_3_J1 ivxw_2_J1 ivxw_3_J1 ivxw_8_J1 ivxw_12_J1

                 rename tvdd Risk_dailytotalret
                 rename tvdw Risk_weeklytotalret
                 rename tvxd Risk_dailyexdivret
                 rename tvxw Risk_weeklyexdivret
                 rename ivxd_2_J1 Idiosyncraticrisk
                 rename Risk_dailyexdivret Market_totalrisk
                 *rename firm_age Firm_age
                 *rename salegrowth Salegrowth
                 *rename sp500indicator debtrating

                 destring gvkey, replace
                 save risk_measures, replace 




/*****merge ith risk data***/
drop _merge
joinby gvkey cyear using risk_measures, unm(master)
drop _merge


joinby gvkey cyear using roa_vol, unm(master)
drop _merge


/***************reg test********************/
bysort gvkey: egen min_cyear=min(cyear)
gen firm_age=cyear-min_cyear


/***using the following:***this step has been generated in file "roa_vol"
/*********gen sic2*********/
tostring sich, replace
gen sic1=substr(sich, 1,1)
gen sic2=substr(sich, 1,2)
gen sic3=substr(sich, 1,3)

destring sich sic1 sic2 sic3, replace
*****************/

count if sic1==6 //3982
/*****keep non-financial firms only in the sample****/
drop if sic1==6
count //
drop if sic1==4
count  //53194, not 53137

/****follow paper"financing innovation and growth": Brown et al 2009:seven high-tech industries with SIC codes 283, 357, 366, 367, 382, 384, and 737***/
gen hightech_sic3=(sic3==283| sic3==357| sic3==366| sic3==367| sic3==382| sic3==384|sic3==737) 
count if hightech_sic3==1  //4873
				
			
	
/**********generate yeardiff to select year window sample***********/
*bysort gvkey: egen min_cyear=min(cyear)
bysort gvkey: egen max_cyear=max(cyear)

*drop  yeardiff_min yeardiff_max
gen yeardiff_min=mayr-min_cyear
gen yeardiff_max=max_cyear-mayr


*drop window_5year
/*********choose sample in 5 year window************/
gen window_5year=(yeardiff_min>=2 & yeardiff_max>=2)
count if window_5year==1
/***49980, not 40484, not 44636*****/
*gen sample_5yr_window=(window_5year==1 | ub_1styear_all==0)
*count if sample_5yr_window==1 //90635, not 86250

/*********choose sample in 3 year window************/
gen window_3year=(yeardiff_min>=1 & yeardiff_max>=1)
count if window_3year==1
/****50445, not 41704, not 45727*****/
*gen sample_3yr_window=(window_3year==1 | ub_1styear_all==0)
*count if sample_3yr_window==1 //95304, not 88798			
				
				
			/****************************************************************/
  			/****************************************************************/
			/****************************************************************/
				
				/***rename control variables***********/
				
*rename logasset Firmsize
rename logasset firm_size
rename logsale Firmsales
rename roa3 Profitability 
rename cap_exp Capitalexpenditures
rename firm_eff Firmefficiency
rename wkcapital Workingcapital
rename at_tangibility Assetstangibility
rename bklev Leverage
*rename RDintensity_1 RDintensity
	
by gvkey: gen lagsale=sale[_n-1]
gen salegrowth=sale/lagsale-1 
			    
		 
gen loanconcentration=loanamt/(loanamt+firm_debt)
gen logaverageaisd=log((allindrawn[_n-6]+allindrawn[_n-5]+allindrawn[_n-4]+allindrawn[_n-3]+allindrawn[_n-2]+allindrawn[_n-1])/6)
	  
	
			  
			/****************************************************************/
  			/****************************************************************/
			/****************************************************************/
*drop _merge
/***add lma info***/
joinby gvkey using gvkey_lma_uni, unm(master)
drop if statecode==.
/*******29042 left*/

/*****merge deregulation data********
drop _merge
joinby statecode using deregulation, unm(master)***/


/****merge with financial restricion data************/
drop _merge
joinby gvkey cyear using finrestric, unm(master)

/*****add lma info and add market overlap index************/
drop _merge
*drop year
*gen year=cyear
joinby lma year using maindex7, unm(master)
count if _merge==3
/**22881, not 22856, not 19774, not 20243**/
			 
			 
/**merge with sp500dummy; variable is sp500indicator*****/
drop _merge
joinby gvkey cyear using "C:\Users\xzhen\Desktop\research folder2020-now\data-all\control var_code_all\data\sp500dummy.dta", unm(master)		  
			  

			  
/**merge with debt rating; variable is debtrating_firmyr****/
drop _merge
joinby gvkey cyear using  "C:\Users\xzhen\Desktop\research folder2020-now\data-all\control var_code_all\data\debtrating_firmyr_nodup.dta", unm(master)
			  
save all_v4, replace	  




/**********************************************************************/	
/**********************************************************************/	
/**********************************************************************/	
/**********************************************************************/	
/**********************************************************************/	

use all_v4, clear		  

                   /*********merge with bank characteristic files************************/
drop _merge
joinby facilityid cyear using call_ds, unm(master)
count if _merge==3
/**1073**/

drop _merge
joinby rssd9001 cyear using cbvar_add, unm(master)


/***generate bigbank_dummy (Berger and Black, 2011, bank gross total asset >$1billion)***/
/***Note: Total assets are total assets, unweighted by risk (RCFD2170 from the Call Report), measured in units of $1 billion as of June
2004.  Lang, Mester and Vermilyea(2005)***/
* Large bank, in excess of US$10bln
/*  Laeven, Ratnovsk and tong (JBF 2016): Our main analysis also focuses on large institutions that are more likely
to be systemically important, limiting the sample to institutions with assets in excess of US$ 10 billion at the end of 2006
***/

replace ta=0 if ta==.
gen largebank=(ta>=1000000)
count if largebank==1 //222

/***generate lnsize (RFS dominant bank effect, log of loan principal*****/
gen ln_banksize=ln(ta)
count
replace ln_banksize=0 if ln_banksize==.
tabstat ln_banksize, stat (n mean sd  p25 median p75  ) col(stat)


/***generate the 2nd measure of lnsize (RFS dominant bank effect, log of loan principal*****/
gen ln_banksize2=ln(1+ta)
count
/*29001**/
replace ln_banksize2=0 if ln_banksize2==.


/***********generate more bank variables***********/
*1. salaries-expense 
**salaries and benefits/total operating expense; ALMOST ALL ARE ZERO

gen salary=x2*w2*100
gen salary_exp=salary/operexp
replace salary_exp=0 if salary_exp==.

tabstat salary_exp, stat (n mean sd  p25 median p75  ) col(stat)

gen salary1=x2*w2
gen salary_exp1=salary1/operexp
replace salary_exp1=0 if salary_exp1==.

tabstat salary_exp1, stat (n mean sd  p25 median p75  ) col(stat)


*2. capital-assets
**total equitycapital/toal assets
gen Equity_ta=z/ta*100
replace Equity_ta=0 if Equity_ta==.
tabstat Equity_ta, stat (n mean sd  p25 median p75  ) col(stat)


*3. cash-ta
** cash to total assets
gen cash_ta=cash/totassets*100
replace cash_ta=0 if cash_ta==.
tabstat cash_ta, stat (n mean sd  p25 median p75  ) col(stat)

              
			/****************************************************************/
  			/****************************************************************/
			/****************************************************************/
/****try ICFS***********/
/*****merge with ICFS and bank deregulation data*************/
drop _merge
joinby gvkey cyear using cashsens_derg, unm(master)

count if _merge==3
/****too many missing data*****/
*rename st statecode
drop _merge
joinby statecode using deregulation, unm(master)
/***all merged***/
drop dinter dintra

gen interpost=cyear-inter
gen dinter=(interpost>=1)
		      
gen intrapost=cyear-intra
gen dintra=(intrapost>=1)
*gen dinter=(cyear>=inter)
*gen dintra=(cyear>=intra)

count if dinter==1
count if dintra==1


/******winsor control var****************/
  replace stockissue=0 if missing(stockissue)
  replace  stockissue2=0 if missing(stockissue2)
  replace ltdebt=0 if missing(ltdebt)
  replace cap_ppent=0 if missing(cap_ppent)
  replace cf_ppent=0 if missing(cf_ppent)
  replace cash=0 if missing(cash)
  
  replace cap_ta=0 if missing(cap_ta)
  replace cf_at=0 if missing(cf_at)
  

//Winsorize all variables by each cyear for all non finicial firms;
  *winsor2 at cap_ta ivbp cash cf_at cap_ppent cf_ppent size  qcc1 qcc2 qbp stockissue stockissue2 ltdebt bklev mkt_book, s(w) cut(1 99) by(cyear)
  
winsor2 at cap_ta ivbp cash cf_at cap_ppent cf_ppent size  qcc1 qcc2 qbp stockissue stockissue2 ltdebt bklev, s(w) cut(1 99) by(cyear)

rename cap_taw investment1
rename cap_ppentw investment2
rename cf_atw cash_flow1
rename cf_ppentw cash_flow2
*rename qcc1w tobin_q1
*rename qcc2w tobin_q2
rename qbpw tobin_q3

rename sizew firmsize
rename stockissuew stock_issues
rename stockissue2w stock_issues2
rename ltdebtw lt_debt
rename bklevw bookleverage
*rename mkt_bookw markettobook
rename ivbpw invest_rd


*gen ivbp2=(capx+xrd)/l.ppent
 replace atw=0 if atw==.
 replace firmsize=0 if firmsize==.
 replace tobin_q3=0 if tobin_q3==.

replace bookleverage=0 if bookleverage==.
replace leverage_tot=0 if leverage_tot==.		  
replace salegrowth=0 if salegrowth==.
			  
			 
replace Market_totalrisk=0 if Market_totalrisk==.
replace Idiosyncraticrisk=0 if Idiosyncraticrisk==.
replace firmsize=0 if firmsize==.
replace  mkt_book=0 if  mkt_book==.
replace roa1=0 if roa1==.
replace Capitalexpenditures=0 if Capitalexpenditures==.
replace leverage_tot=0 if leverage_tot==.
replace loansize=0 if loansize==.
replace collateral=0 if collateral==.
replace log_maturity=0 if log_maturity==.
	  
replace Workingcapital=0 if Workingcapital==.

replace tobin_q1=0 if tobin_q1==.
replace tobin_q2=0 if tobin_q2==.
replace tobin_q3=0 if tobin_q3==.



			  
/**************************winsor var*****************/
			  
centile Market_totalrisk,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
centile Idiosyncraticrisk,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
    
winsor2 Market_totalrisk Idiosyncraticrisk, s(w) cut(1 99) by(cyear)

centile Workingcapital,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 Workingcapital,  s(w) cut(1 99) by(cyear)

  
centile mkt_book,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 mkt_book,  s(w) cut(1 99) by(cyear)

centile roa1,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 roa1,  s(w) cut(1 99) by(cyear)

centile Capitalexpenditures,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 Capitalexpenditures,  s(w) cut(1 99) by(cyear)

centile saletoasset,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 saletoasset,  s(w) cut(1 99) by(cyear)

*drop salegrowthw
centile salegrowth,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 salegrowth,  s(w) cut(1 99) by(cyear)


centile firm_age,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 firm_age,  s(w) cut(1 99) by(cyear)

/*
centile nwc,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2  nwc,  s(w) cut(1 99) by(cyear)
*/
centile leverage_tot,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2  leverage_tot,  s(w) cut(1 99) by(cyear)

*save all_v3_forpsm, replace




/***********One-to-one match based on PSM matching method to choose firms in the control group***********************
clear
set more off

use all_v3_forpsm, clear
rename tgt_post posttgtlending

keep gvkey cyear rssd9001 non_id mayear mayr  sic1 sic2 sic3 xrd posttgtlending firm_debt  stock_issues invest_rd firmsize Firmsales roa1w roa2  cap_ta cap_ppent  RDtoSale riy_leverage RDintensity_1 bookleverage RDintensity_2 tangibility_2 roe2 firm_agew mkt_bookw Capitalexpendituresw saletoassetw salegrowthw Assetstangibility Workingcapitalw leverage_totw

*keep gvkey cyear rssd9001 non_id mayear mayr  
gen tgt_1styear_all=(!missing(mayr))
gen tgt_indicator=(tgt_1styear_all>0)


bysort gvkey: egen min_cyear_psm=min(cyear)
bysort gvkey: egen max_cyear_psm=max(cyear)

gen firmyears=max_cyear_psm-min_cyear_psm


/*****keep unique obs for trt firms***/
codebook gvkey
count
duplicates drop gvkey if tgt_indicator==1, force
count

*********generate ubyear for doing cem for both trt(1st ub lending date) and control(cyear)*
gen tgt_year_psm=cyear
replace tgt_year_psm=mayr if tgt_indicator==1
***

replace RDtoSale=0 if RDtoSale==.
replace RDintensity_1=0 if RDintensity_1==.
*replace Profitability=0 if Profitability==.
replace roa2=0 if roa2==.
replace saletoasset=0 if saletoasset==.
*replace MtB1=0 if MtB1==.

replace  xrd=0 if xrd==.
gen ln_rd=ln(1+xrd)

****/


psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears  firmsize   firm_debt , logit noreplace    /*finally!!!!!!!pos sigbut only at 10%*/

*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears  firmsize  firm_debt, logit noreplace    /*insig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears  firmsize Capitalexpendituresw   firm_debt, logit noreplace    /*insig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears  firmsize  tangibility_2 firm_debt, logit noreplace    /*in
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears  firmsize roa2 firm_debt, logit noreplace    /*insig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears  firmsize ln_rd firm_debt, logit noreplace    /*insig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears  firmsize  mkt_bookw firm_debt, logit noreplace    /*insig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears  firmsize   mkt_bookw firm_debt, logit noreplace    /*insig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears  firmsize saletoassetw Workingcapitalw  firm_debt, logit noreplace    /*insig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears  firmsize saletoassetw  firm_debt, logit noreplace  /*insig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears  firmsize    ln_rd leverage_totw, logit noreplace    /*insig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears  firmsize   ln_rd Workingcapital leverage_totw, logit noreplace     /*insig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears  firmsize mkt_book saletoasset ln_rd  leverage_totw, logit noreplace     /*insig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears  firmsize saletoasset  leverage_totw, logit noreplace     /*neg sig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1  firmsize saletoasset ln_rd leverage_totw, logit noreplace     /*neg sig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears firmsize saletoasset leverage_totw, logit noreplace     /*neg sig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears firmsize cap_ta ln_rd leverage_totw, logit noreplace     /*insig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears firmsize  mkt_book ln_rd leverage_totw, logit noreplace     /*insig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears firmsize cap_ta  Firmsales  invest_rd leverage_totw, logit noreplace     /*insig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears firmsize cap_ta  invest_rd leverage_totw, logit noreplace   /*sig neg*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears firmsize cap_ta stock_issues invest_rd ln_rd leverage_totw, logit noreplace   /*insig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears firmsize cap_ta ln_rd leverage_totw, logit noreplace   /*pos insig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears firmsize cap_ta salegrowth  leverage_totw, logit noreplace   /*pos insig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears firmsize cap_ta salegrowth ln_rd leverage_totw, logit noreplace  /*pos insig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears firmsize  salegrowth ln_rd leverage_totw, logit noreplace  /*pos insig*/
*psmatch2 tgt_indicator tgt_year_psm  sic1 firmyears firmsize  saletoasset ln_rd leverage_totw, logit noreplace  /*neg insig*/
*psmatch2 tgt_indicator tgt_year_psm  firmsize  firm_agew leverage_totw, logit noreplace  /*neg sig*/


/*********/
*psmatch2 tgt_indicator tgt_year_psm firmsize firmyears Firmsales roa1w mkt_bookw leverage_totw , logit noreplace
*psmatch2 tgt_indicator tgt_year_psm firmsize roe2 mkt_bookw leverage_totw , logit noreplace //1590
*psmatch2 tgt_indicator tgt_year_psm sic1 firmyears firmsize roa1w mkt_bookw leverage_totw , logit noreplace ////1688
*psmatch2 tgt_indicator tgt_year_psm sic1 firmyears firmsize Firmsales leverage_totw , logit noreplace /*psm test pos but insig*/
*psmatch2 tgt_indicator tgt_year_psm sic1 firmyears firmsize  saletoassetw salegrowthw leverage_totw , logit noreplace /*psm test pos but insig*/
*psmatch2 tgt_indicator tgt_year_psm sic1 firmyears firmsize salegrowthw  RDintensity_1  leverage_totw , logit noreplace /*psm test pos but insig*/
*psmatch2 tgt_indicator tgt_year_psm sic1 firmyears firmsize   mkt_bookw leverage_totw , logit noreplace /*neg insig*/


/***
count  //29042
gen pair = _id if _treated==0 
replace pair = _n1 if _treated==1
bysort pair: egen paircount = count(pair)
drop if paircount !=2
count //1688

keep gvkey cyear tgt_year_psm  min_cyear_psm firmyears sic1  _id _n1 pair paircount  firmsize tgt_indicator


/****identify duplicates***********/
duplicates tag gvkey, gen(dup)
sort pair

bysor pair: egen dup_pair=sum(dup)
count if dup_pair==0
//1770

keep if dup_pair==0

codebook gvkey if tgt_indicator==1  //885
codebook gvkey if tgt_indicator==0  //885


replace tgt_year_psm=0 if tgt_indicator==0
bysort pair: egen tgt_cutyear_psm=sum(tgt_year_psm)

duplicates report gvkey
//unique 116

keep gvkey cyear tgt_indicator tgt_year_psm tgt_cutyear_psm  pair paircount 
rename tgt_indicator tgt_trt

save psm_all, replace


/******************merge with the main file to run reg************/
use all_v3_forpsm, clear
drop _merge
joinby gvkey using psm_all, unm(master)


/***********generate 5 year window*************/
gen psm_yeardiff=cyear-tgt_cutyear_psm
gen psm_tgtpost=(psm_yeardiff>=0)
count if psm_tgtpost==1
//14577

bysort gvkey: egen min_cyear_psm=min(cyear)
bysort gvkey: egen max_cyear_psm=max(cyear)


gen yeardiff_min_psm=tgt_cutyear_psm-min_cyear_psm
gen yeardiff_max_psm=max_cyear_psm-tgt_cutyear_psm


gen window_5year_psm=(yeardiff_min_psm>=2 & yeardiff_max_psm>=2)
codebook tgt_trt if window_5year_psm==1
count if window_5year_psm==1
//28853


sort gvkey
gen window_3year_psm=(yeardiff_min_psm>=1 & yeardiff_max_psm>=1)
count if window_3year_psm==1
//28898
tabulate tgt_trt if window_3year_psm==1

*keep gvkey cyear ub_trt psm_ubpost window_5year_psm yeardiff_min_psm yeardiff_max_psm largebank salary_exp  cash_ta  statecode sic1

drop if tgt_trt==.
count /*510*/

tab cyear, gen(YEAR)
/**v1:***/
/***firmefficiency is the same as saletoasset***/

*drop YEAR1
*drop YEAR3 YEAR4 YEAR5 
*drop YEAR6

drop YEAR3 YEAR5 YEAR4 YEAR6

global firmcontrol="firmsize  roa1w firm_agew mkt_bookw Capitalexpendituresw saletoassetw salegrowthw Workingcapitalw leverage_totw "
global loancontrol="loansize collateral  log_maturity"
global bankcontrol="largebank cash_ta"
global bankder="dinter dintra"
global dummy="YEAR* statecode"
*rename tgt_post posttgtlending


areg Market_totalriskw i.tgt_trt##i.psm_tgtpost $dummy $bankcontrol $firmcontrol $loancontrol $bankder  if window_5year_psm==1,   vce(robust) absorb(gvkey)
outreg2 using tableDID_firmFE.xls, excel tstat dec(4) replace ctitle(Market_totalriskw) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Idiosyncraticriskw i.tgt_trt##i.psm_tgtpost $dummy $bankcontrol $firmcontrol $loancontrol $bankder  if window_5year_psm==1,   vce(robust) absorb(gvkey)
outreg2 using tableDID_firmFE.xls, excel tstat dec(4) append ctitle(Idiosyncraticriskw) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)


areg Market_totalriskw i.tgt_trt##i.psm_tgtpost $dummy $bankcontrol $firmcontrol $loancontrol  if window_5year_psm==1,   vce(robust) absorb(gvkey)
outreg2 using tableDID_firmFE.xls, excel tstat dec(4) append ctitle(Market_totalriskw) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Idiosyncraticriskw i.tgt_trt##i.psm_tgtpost $dummy $bankcontrol $firmcontrol $loancontrol   if window_5year_psm==1,   vce(robust) absorb(gvkey)
outreg2 using tableDID_firmFE.xls, excel tstat dec(4) append ctitle(Idiosyncraticriskw) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)


*areg Market_totalriskw i.tgt_trt##i.psm_tgtpost  if window_5year_psm==1,   vce(robust) absorb(gvkey)

/*
xtset gvkey cyear
xtreg  Market_totalriskw i.tgt_trt##i.psm_tgtpost , fe


xtset gvkey cyear
xtreg Market_totalriskw i.tgt_trt##i.psm_tgtpost  $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year_psm==1, fe
outreg2 using tableDID_PSM.xls, excel tstat dec(3) replace ctitle(Ln_patent) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)
*/

**********/


/*******************************************************************/
/******************************BASELINE REGRESSION*****************/

*use all_v3_forpsm, clear
drop _merge
joinby gvkey cyear using roa_vol, unm(master)

	/*******************Baseline regression****************/

/**v1:***/
/***firmefficiency is the same as saletoasset***/
/***the following results are good: P=0.000****
global firmcontrol="firmsize  roa1w mkt_bookw Capitalexpendituresw  nwcw leverage_tot "
global firmcontrol="firmsize  roa1w firm_agew mkt_bookw Capitalexpendituresw saletoassetw salegrowthw nwcw leverage_tot "

*/

*global bankcontrol="ln_banksize salary_exp1 Equity_ta  cash_ta"
/***this control set works best for market total risk (merged with control-v1)
firmsize markettobook roa1 Capitalexpenditures lt_debt***/

tab cyear, gen(YEAR)
global firmcontrol="firmsize  roa1w firm_agew mkt_bookw Capitalexpendituresw saletoassetw salegrowthw Workingcapitalw leverage_totw "
global loancontrol="loansize collateral  log_maturity"
global bankcontrol="largebank cash_ta"

global bankder="dinter dintra"
global dummy="YEAR* statecode"
rename tgt_post posttgtlending


/***Table 1. Summary statistics****/
*tabstat Market_totalriskw Idiosyncraticriskw posttgtlending largebank salary_exp  cash_ta firmsize markettobookw roa1 Capitalexpenditures  leverage_tot loansize collateral  log_maturity dinter dintra, stat(n mean sd min p5 median p95) col(stat)

tabstat Market_totalriskw Idiosyncraticriskw posttgtlending   firmsize  roa1w firm_agew mkt_bookw Capitalexpendituresw saletoassetw salegrowthw Workingcapitalw leverage_totw loansize collateral  log_maturity  largebank salary_exp1  cash_ta, stat(n mean sd p25 median p75) col(stat)

estpost tabstat Market_totalriskw Idiosyncraticriskw posttgtlending   firmsize  roa1w firm_agew mkt_bookw Capitalexpendituresw saletoassetw salegrowthw Workingcapitalw leverage_totw loansize collateral  log_maturity  largebank salary_exp1  cash_ta, stat(n mean sd p25 median p75) col(stat)


 

*RDtoSale saletoasset
/*****Table 2. main regression******************/
/***pos sig****/
/**
/****can't add bookleverage as control!!!!!************/
**# use v1 as firm control
areg Market_totalriskw posttgtlending $dummy $bankcontrol $firmcontrol   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table2base.xls, excel  dec(4)  replace title(Baseline) ctitle(market total risk) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

areg Idiosyncraticriskw posttgtlending $dummy $bankcontrol $firmcontrol    if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table2base.xls, excel  dec(4)  append title(Baseline) ctitle(Idiosyncraticrisk) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2
**/
areg Market_totalriskw posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table2base.xls, excel  dec(4)  replace title(Baseline) ctitle(market total risk) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

areg Idiosyncraticriskw posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table2base.xls, excel  dec(4)  append title(Baseline) ctitle(Idiosyncraticrisk) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2


areg Market_totalriskw posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol  if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table2base.xls, excel  dec(4)  append title(Baseline) ctitle(market total risk) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

areg Idiosyncraticriskw posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol  if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table2base.xls, excel  dec(4)  append title(Baseline) ctitle(Idiosyncraticrisk) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/** using sp500dummy as sc looks strange****
count if sp500dummy==1 /**3050**/
count if sp500dummy==0 /**20245***/
/****check the switching cost (SP500 firms have low SC)*******************/
/*change to insig if doing this: replace sp500dummy=0 if sp500dummy==.*/
areg Market_totalriskw i.posttgtlending##i.sp500dummy $dummy  $firmcontrol $bankcontrol $loancontrol  if window_5year==1 ,   vce(robust) absorb(sic1)
outreg2 using tableswitchingcost.xls, excel  dec(4)  replace title(Baseline) ctitle(market total risk) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

areg Idiosyncraticriskw i.posttgtlending##i.sp500dummy $dummy  $firmcontrol $bankcontrol $loancontrol  if window_5year==1 ,   vce(robust) absorb(sic1)
outreg2 using tableswitchingcost.xls, excel  dec(4)  append title(Baseline) ctitle(Idio risk) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2
**/

*areg rty_roa posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)

*areg roa1_adj_sd4 posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)

replace roa1_meanadj_sd4=0 if roa1_meanadj_sd4==.
*drop roa1_meanadj_sd4w
centile roa1_meanadj_sd4,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 roa1_meanadj_sd4,  s(w) cut(1 99) by(cyear)

replace roe_adj_sd4=0 if roe_adj_sd4==.
centile roe_adj_sd4,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 roe_adj_sd4,  s(w) cut(1 99) by(cyear)
/*sd of roe_adj in a 4  periods rol. wind.*/
/*
centile roa2_meanadj_sd4,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 roa2_meanadj_sd4,  s(w) cut(2 98) by(cyear)

centile roa3_meanadj_sd4,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 roa3_meanadj_sd4,  s(w) cut(1 99) by(cyear)

centile roe_meanadj_sd4,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 roe_meanadj_sd4,  s(w) cut(1 99) by(cyear)
*/

areg roa1_meanadj_sd4 posttgtlending $dummy $firmcontrol $bankcontrol  $loancontrol  if window_5year==1 ,   vce(robust) absorb(sic1)
outreg2 using tableAltrisk.xls, excel  dec(4)  replace title(Baseline) ctitle(roa vol) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/***IV reg weekly exdiv ret***/
replace ivxw_1_J3=0 if ivxw_1_J3==.
areg ivxw_1_J3 posttgtlending $dummy  $firmcontrol $bankcontrol $loancontrol  if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using tableAltrisk.xls, excel  dec(4)  append title(Baseline) ctitle(IV reg weekly exdiv ret) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2


save for2sm, replace

/*
/***insig****/
areg rty_roe posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(robust) absorb(sic1)
areg ivxd_4_J3 posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(robust) absorb(sic1)
areg ivxd_4_J1 posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol  if window_5year==1 ,   vce(robust) absorb(sic1)
areg Risk_weeklyexdivret posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol  if window_5year==1 ,   vce(robust) absorb(sic1)
areg Risk_dailytotalret posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol  if window_5year==1 ,   vce(robust) absorb(sic1)
areg ivxd_1_J1 posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol  if window_5year==1 ,   vce(robust) absorb(sic1)
areg ivdd_2_J1 posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol  if window_5year==1 ,   vce(robust) absorb(sic1)
areg r2xd_1 posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol  if window_5year==1 ,   vce(robust) absorb(sic1)
areg r2dd_4 posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol  if window_5year==1 ,   vce(robust) absorb(sic1)
areg ivdw_14_J3 posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol  if window_5year==1 ,   vce(robust) absorb(sic1)
areg ivxw_5_J3 posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol  if window_5year==1 ,   vce(robust) absorb(sic1)


/***al insig:***/
 ivxd_3_J1 ivxw_2_J1 ivxw_3_J1 ivxw_8_J1 ivxw_12_J1
areg Risk_weeklytotalret posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(robust) absorb(sic1)
areg ivxw_12_J1 posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(robust) absorb(sic1)
areg ivxw_8_J1 posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(robust) absorb(sic1)
areg ivxw_3_J1 posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(robust) absorb(sic1)
areg ivxw_2_J1 posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(robust) absorb(sic1)
areg ivxd_3_J1 posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(robust) absorb(sic1)
replace roe_adj_sd4=0 if roe_adj_sd4==.
areg roe_adj_sd4 posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol  if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
replace  roe_meanadj_sd4=0 if roe_meanadj_sd4==.
areg roe_meanadj_sd4 posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol  if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)


*areg roe_adj_sd4 posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
*outreg2 using tableAlt.xls, excel  dec(4)  replace title(Baseline) ctitle(roe vol) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/**the following are all insig**
areg riy_leverage posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
areg riy_debtmat posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
areg riy_rd posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
areg riy_ppe posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
areg riy_capexp posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
 areg riy_mb posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
***/

/*
centile rty_roa,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 rty_roa,  s(w) cut(1 99) by(cyear)
areg rty_roa posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
*/
*/


/*********Appendix: define firms as bank dependet if they are not covered by SP credit ratings************************
areg Market_totalriskw posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol  if window_5year==1 & sp500dummy==0,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablebankdep.xls, excel  dec(4)  replace title(High bank dependent) ctitle(market total risk) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

areg Market_totalriskw posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol  if window_5year==1 & sp500dummy==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablebankdep.xls, excel  dec(4)  append title(Low bank dependent) ctitle(market total risk) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2


areg Idiosyncraticriskw posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol  if window_5year==1 & sp500dummy==0,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablebankdep.xls, excel  dec(4)  append title(High bank dependent) ctitle(Idiosyncraticrisk) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

areg Idiosyncraticriskw posttgtlending $dummy $bankcontrol $firmcontrol $loancontrol  if window_5year==1 & sp500dummy==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablebankdep.xls, excel  dec(4)  append title(Low bank dependent) ctitle(Idiosyncraticrisk) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

***/



areg Market_totalriskw posttgtlending $dummy  $firmcontrol $bankcontrol $loancontrol  if window_5year==1 & debtrating_firmyr==0,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablebankdep.xls, excel  dec(4)  replace title(High bank dependent) ctitle(market total risk) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

areg Market_totalriskw posttgtlending $dummy $firmcontrol $bankcontrol $loancontrol  if window_5year==1 & debtrating_firmyr==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablebankdep.xls, excel  dec(4)  append title(Low bank dependent) ctitle(market total risk) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

areg Idiosyncraticriskw posttgtlending $dummy  $firmcontrol $bankcontrol $loancontrol  if window_5year==1 & debtrating_firmyr==0,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablebankdep.xls, excel  dec(4)  append title(High bank dependent) ctitle(Idiosyncraticrisk) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

areg Idiosyncraticriskw posttgtlending $dummy  $firmcontrol $bankcontrol $loancontrol  if window_5year==1 & debtrating_firmyr==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablebankdep.xls, excel  dec(4)  append title(Low bank dependent) ctitle(Idiosyncraticrisk) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2






/********Table 3. subsample analysis: EFD**************/

ssc install tsegen, replace

		//oancf: Operating Activities - Net Cash Flow
		//capx: Capital Expenditures\
		
		*replace oancf=0 if missing(oancf)
		*replace capx=0 if missing(capx)
		*gen efd=(capx-oancf)/capx
		
	centile efd, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 85 88 89 90 92 94 95 99)
    winsor2 efd, s(w) cut(5 95) by(cyear)
	centile efdw, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 85 88 89 90 92 94 95 99)


		
		*drop efd_median
		drop high_efd low_efd
		bysort sic1 cyear: egen efd_median=median(efd)
		gen high_efd=(efd>efd_median)
		gen low_efd=(efd<=efd_median)
		
		
         /*drop high_efd low_efd
        bysort sic1 cyear: egen efd_mean=mean(efd)
		gen high_efd=(efd>=efd_mean)
		gen low_efd=(efd<efd_mean)
*/
		
		  bysort sic1 cyear: egen kz_mean=median(kzindex)
		gen high_kz2=(kzindex>=kz_mean)
		gen low_kz2=(kzindex<kz_mean)
		
		 bysort sic1 cyear: egen sa_mean=median(saindex)
		gen high_sa2=(saindex>=sa_mean)
		gen low_sa2=(saindex<sa_mean)
		
		

/********subsample analysis: EFD**************/
/********xternalfinancialdependence(EFD),respectively.Ahigh(low)EFDsubsamplehasindustryEFDabove(below)thesamplemedian****/
/***************************/

/***insig****/
areg Market_totalriskw posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol  if window_5year==1 & low_kz2==1, vce(cluster gvkey) absorb(sic1)
outreg2 using table3efdsubsample.xls, excel  dec(4)  replace title(Baseline) ctitle(mktrisk Low kz) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/**pos sig***/
areg Market_totalriskw posttgtlending $firmcontrol $bankcontrol $dummy $loancontrol  if window_5year==1 & high_kz2==1, vce(cluster gvkey) absorb(sic1)
outreg2 using table3efdsubsample.xls, excel  dec(4)  append title(Baseline) ctitle(mktrisk High kz) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

areg Idiosyncraticriskw posttgtlending $firmcontrol $bankcontrol $dummy $loancontrol  if window_5year==1 & low_kz2==1, vce(cluster gvkey) absorb(sic1)
outreg2 using table3efdsubsample.xls, excel  dec(4)  append title(Baseline) ctitle(idiorisk Low kz) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2
areg Idiosyncraticriskw posttgtlending $firmcontrol $bankcontrol $dummy $loancontrol  if window_5year==1 & high_kz2==1, vce(cluster gvkey) absorb(sic1)
outreg2 using table3efdsubsample.xls, excel  dec(4)  append title(Baseline) ctitle(idiorisk High kz) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2


/***results are good for sa: insig for low-sa, sig for high_sa****/
areg Market_totalriskw posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol  if window_5year==1 & low_sa2==1, vce(cluster gvkey) absorb(sic1)
outreg2 using table3efdsubsample.xls, excel  dec(4)  append title(Baseline) ctitle(mktrisk Low EFD) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

areg Market_totalriskw posttgtlending $firmcontrol $bankcontrol $dummy $loancontrol  if window_5year==1 & high_sa2==1, vce(cluster gvkey) absorb(sic1)
outreg2 using table3efdsubsample.xls, excel  dec(4)  append title(Baseline) ctitle(mktrisk High EFD) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

areg Idiosyncraticriskw posttgtlending $firmcontrol $bankcontrol $dummy $loancontrol  if window_5year==1 & low_sa2==1, vce(cluster gvkey) absorb(sic1)
outreg2 using table3efdsubsample.xls, excel  dec(4)  append title(Baseline) ctitle(idiorisk Low EFD) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2
areg Idiosyncraticriskw posttgtlending $firmcontrol $bankcontrol $dummy $loancontrol  if window_5year==1 & high_sa2==1, vce(cluster gvkey) absorb(sic1)
outreg2 using table3efdsubsample.xls, excel  dec(4)  append title(Baseline) ctitle(idiorisk High EFD) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2


/*both are sig and high-efd has stronger effects*/
areg Market_totalriskw posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol  if window_5year==1 & low_efd==1, vce(cluster gvkey) absorb(sic1)
outreg2 using table3efdsubsample.xls, excel  dec(4)  append title(Baseline) ctitle(mktrisk Low EFD) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

areg Market_totalriskw posttgtlending $firmcontrol $bankcontrol $dummy $loancontrol  if window_5year==1 & high_efd==1, vce(cluster gvkey) absorb(sic1)
outreg2 using table3efdsubsample.xls, excel  dec(4)  append title(Baseline) ctitle(mktrisk High EFD) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/*both are sig and high-efd has stronger effects*/
areg Idiosyncraticriskw posttgtlending $firmcontrol $bankcontrol $dummy $loancontrol  if window_5year==1 & low_efd==1, vce(cluster gvkey) absorb(sic1)
outreg2 using table3efdsubsample.xls, excel  dec(4)  append title(Baseline) ctitle(idiorisk Low EFD) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2
areg Idiosyncraticriskw posttgtlending $firmcontrol $bankcontrol $dummy $loancontrol  if window_5year==1 & high_efd==1, vce(cluster gvkey) absorb(sic1)
outreg2 using table3efdsubsample.xls, excel  dec(4)  append title(Baseline) ctitle(idiorisk High EFD) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2





/****Placebo tests and dynamic tests: all insig!!!!!!!!!!!!!***********/
/**********placebo test and future risk********************/
sort gvkey 
*drop t6
*drop yeardiff_rbt
*drop tgtlend_dummy_rbt
bysort gvkey: egen mayr2=min(mayear)
gen t6=mayr2-6
*replace t6=. if t6<0
gen yeardiff_rbt=cyear-t6

gen tgtlend_dummy_rbt=(yeardiff_rbt>0 & yeardiff_rbt<.)


*count if ub_post_1stall ==1
/***19752***/
count if tgtlend_dummy_rbt==1
/***4140, not 29562**/

gen t1placebo=mayr2-1
gen t11placebo=mayr2-11

gen placebotime=(cyear>t11placebo & cyear<t1placebo)

count if placebotime==1
/*3100*/

areg Market_totalriskw tgtlend_dummy_rbt $firmcontrol  $bankcontrol $dummy $loancontrol   if placebotime==1, vce(cluster gvkey) absorb(sic1)
outreg2 using tableplacebo.xls, excel tstat dec(4)  replace ctitle(Market_totalriskw) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Idiosyncraticriskw tgtlend_dummy_rbt $firmcontrol  $bankcontrol $dummy $loancontrol  if placebotime==1, vce(cluster gvkey) absorb(sic1)
outreg2 using tableplacebo.xls, excel tstat dec(4)  append ctitle(Idiosyncraticriskw) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)




*keep gvkey cyear non_id mayear mayr Market_totalriskw Idiosyncraticriskw posttgtlending rssd9001

/****check dynamic effect: future risk level in 1 year, 2 years and 3 years*****/
/****results are bad****/
xtset gvkey cyear

gen posttgtlendingl1=l.posttgtlending


gen mkttotrisk1=F.Market_totalriskw
*count if !missing(mkttotrisk1)
*replace mkttotrisk1=0 if mkttotrisk1==.

*drop mkttotrisk2
gen mkttotrisk2=F2.Market_totalriskw
*replace mkttotrisk2=0 if mkttotrisk2==.
gen mkttotrisk3=F3.Market_totalriskw
*replace mkttotrisk3=0 if mkttotrisk3==.

gen idiorisk1=F.Idiosyncraticriskw
gen idiorisk2=F2.Idiosyncraticriskw
gen idiorisk3=F3.Idiosyncraticriskw

/***results are good: sig for F1 and F2, insig for F3****/
*areg mkttotrisk1 posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol   , vce(cluster gvkey) absorb(sic1)
areg mkttotrisk1 posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol   if window_5year==1, vce(cluster gvkey) absorb(sic1)
outreg2 using tabledynamic_fwd.xls, excel tstat dec(4)  replace ctitle(mkttotrisk1) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg mkttotrisk2 posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol   if window_5year==1, vce(cluster gvkey) absorb(sic1)
outreg2 using tabledynamic_fwd.xls, excel tstat dec(4)  append ctitle(mkttotrisk2) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg mkttotrisk3 posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol   if window_5year==1, vce(cluster gvkey) absorb(sic1)
outreg2 using tabledynamic_fwd.xls, excel tstat dec(4)  append ctitle(mkttotrisk3) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg idiorisk1 posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol   if window_5year==1, vce(cluster gvkey) absorb(sic1)
outreg2 using tabledynamic_fwd.xls, excel tstat dec(4)  append ctitle(idiorisk1) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg idiorisk2 posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol   if window_5year==1, vce(cluster gvkey) absorb(sic1)
outreg2 using tabledynamic_fwd.xls, excel tstat dec(4)  append ctitle(idiorisk2) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg idiorisk3 posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol   if window_5year==1, vce(cluster gvkey) absorb(sic1)
outreg2 using tabledynamic_fwd.xls, excel tstat dec(4)  append ctitle(idiorisk3) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)





/***********************join with maindex original one**************************/
use all_v3_forpsm, clear
drop _merge

joinby year lma using "C:\Users\xzhen\Desktop\research folder2020-now\New project_Bank MA and customer_2020\newdata_2021\maindex.dta", unm(master)
	
tab cyear, gen(YEAR)
global firmcontrol="firmsize  roa1w firm_agew mkt_bookw Capitalexpendituresw saletoassetw salegrowthw Workingcapitalw leverage_totw "
global loancontrol="loansize collateral  log_maturity"
global bankcontrol="largebank cash_ta"

global bankder="dinter dintra"
global dummy="YEAR* lma"
rename tgt_post posttgtlending



replace outmktw_large_large1=0 if outmktw_large_large1==.
replace outmktw_large_small1=0 if outmktw_large_small1==.
replace outmktw_small_small1=0 if outmktw_small_small1==.

replace inmktw_large_large1=0 if inmktw_large_large1==.
replace inmktw_large_small1=0 if inmktw_large_small1==.
replace inmktw_small_small1=0 if inmktw_small_small1==.

*drop inmktw_large_large1w
centile inmktw_large_large1,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 inmktw_large_large1,  s(w) cut(1 95) by(cyear)


replace outmkt_indexta=0 if outmkt_indexta==.
replace inmkt_indexta=0 if inmkt_indexta==.
replace inmktw_large2=0 if inmktw_large2==.
replace inmktw_small2=0 if inmktw_small2==.

replace outmkt_indexla=0 if outmkt_indexla==.
replace outmkt_indexsm=0 if outmkt_indexsm==.
replace inmkt_indexla=0 if inmkt_indexla==.
replace inmkt_indexsm=0 if inmkt_indexsm==.

/***all insig below*******

areg Market_totalriskw outmkt_indexta $firmcontrol  $bankcontrol $dummy $loancontrol    if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
areg Market_totalriskw inmkt_indexta $firmcontrol  $bankcontrol $dummy $loancontrol    if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
areg Market_totalriskw inmktw_large2 $firmcontrol  $bankcontrol $dummy $loancontrol    if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
areg Market_totalriskw inmktw_small2 $firmcontrol  $bankcontrol $dummy $loancontrol    if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
****/

/*insig
areg Market_totalriskw outmkt_indexla $firmcontrol  $bankcontrol $dummy $loancontrol    if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
areg Market_totalriskw outmkt_indexsm $firmcontrol  $bankcontrol $dummy $loancontrol    if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
areg Market_totalriskw inmkt_indexla $firmcontrol  $bankcontrol $dummy $loancontrol    if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
areg Market_totalriskw inmkt_indexsm $firmcontrol  $bankcontrol $dummy $loancontrol    if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
*/
/*insig
replace outmkt=0 if outmkt==.
areg Market_totalriskw outmkt $firmcontrol  $bankcontrol $dummy $loancontrol $bankder    if window_5year==1 ,   vce(cluster gvkey) absorb(lma)
*/


/**pos sig 10%**/
*areg Market_totalriskw inmkt_indexta $firmcontrol  $bankcontrol $dummy $loancontrol $bankder    if window_5year==1 ,   vce(cluster gvkey) absorb(lma)

/***************************NEW table***************************/

areg Market_totalriskw i.posttgtlending##c.outmktw_large_large1 $firmcontrol  $bankcontrol $dummy $loancontrol    if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table7mktoverlap.xls, excel  dec(4)  replace title(Baseline) ctitle(mkt outmkt_large_large1) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/**pos sig 1%**/
areg Market_totalriskw i.posttgtlending##c.outmktw_large_small1 $firmcontrol  $bankcontrol $dummy $loancontrol   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table7mktoverlap.xls, excel  dec(4)  append title(Baseline) ctitle(mkt outmkt_large_small) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2
/**pos sig**/
areg Market_totalriskw i.posttgtlending##c.outmktw_small_small1 $firmcontrol  $bankcontrol $dummy $loancontrol   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table7mktoverlap.xls, excel  dec(4)  append title(Baseline) ctitle(mkt outmkt_small_small) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/**neg sig**/
areg Market_totalriskw i.posttgtlending##c.inmktw_large_large1 $firmcontrol  $bankcontrol $dummy $loancontrol    if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table7mktoverlap.xls, excel  dec(4)  append title(Baseline) ctitle(mkt inmkt_large_large1) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2
/*insig**/
areg Market_totalriskw i.posttgtlending##c.inmktw_large_small1 $firmcontrol  $bankcontrol $dummy $loancontrol     if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table7mktoverlap.xls, excel  dec(4)  append title(Baseline) ctitle(mkt inmkt_large_small) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2
areg Market_totalriskw i.posttgtlending##c.inmktw_small_small1 $firmcontrol  $bankcontrol $dummy $loancontrol    if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table7mktoverlap.xls, excel  dec(4)  append title(Baseline) ctitle(mkt inmkt_small_small) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2



areg Idiosyncraticriskw outmktw_large_large1 $firmcontrol  $bankcontrol $dummy $loancontrol    if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table7mktoverlap.xls, excel  dec(4)  append title(Baseline) ctitle(mkt outmkt_large_large1) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/**pos sig 1%**/
areg Idiosyncraticriskw outmktw_large_small1 $firmcontrol  $bankcontrol $dummy $loancontrol   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table7mktoverlap.xls, excel  dec(4)  append title(Baseline) ctitle(mkt outmkt_large_small) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2
/**pos sig**/
areg Idiosyncraticriskw outmktw_small_small1 $firmcontrol  $bankcontrol $dummy $loancontrol   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table7mktoverlap.xls, excel  dec(4)  append title(Baseline) ctitle(mkt outmkt_small_small) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/**neg sig**/
areg Idiosyncraticriskw inmktw_large_large1 $firmcontrol  $bankcontrol $dummy $loancontrol   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table7mktoverlap.xls, excel  dec(4)  append title(Baseline) ctitle(mkt inmkt_large_large1) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2
/*insig**/
areg Idiosyncraticriskw inmktw_large_small1 $firmcontrol  $bankcontrol $dummy $loancontrol    if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table7mktoverlap.xls, excel  dec(4)  append title(Baseline) ctitle(mkt inmkt_large_small) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2
areg Idiosyncraticriskw inmktw_small_small1 $firmcontrol  $bankcontrol $dummy $loancontrol     if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table7mktoverlap.xls, excel  dec(4)  append title(Baseline) ctitle(mkt inmkt_small_small) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2





/****************************old table***************************/

/****Table 4. market overlap: results good****/
/*******9/8/24: results are usable***************/
/********THE FOLLOWING RESULTS ARE ok BASED ON MAINDEX7 (021023)*********************************/
/**insig**/
*areg Market_totalriskw high_mktoverlap $dummy   if window_5year==1,   vce(cluster gvkey) absorb(sic1)

centile inmktw_large2,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 inmktw_large2, s(w) cut(1 99) by(cyear)

/*** results are most sig for inmarket-small*****/
/*least pos sig*/
areg Market_totalriskw posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol    if window_5year==1 & outmkt==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table4mktoverlap_inout.xls, excel  dec(4)  replace title(Baseline) ctitle(mkt outmkt) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/*most pos sig*/
areg Market_totalriskw posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol     if window_5year==1 & inmkt_large==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using table4mktoverlap_inout.xls, excel  dec(4)  append title(Baseline) ctitle(mkt inmkt_large) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/*less pos sig*/
areg Market_totalriskw posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol   if window_5year==1 & inmkt_small==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table4mktoverlap_inout.xls, excel  dec(4)  append title(Baseline) ctitle(mkt inmkt_small) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/*least pos sig*/
areg Idiosyncraticriskw posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol    if window_5year==1 & outmkt==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table4mktoverlap_inout.xls, excel  dec(4)  append title(Baseline) ctitle(idio outmkt) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/*less pos sig*/
areg Idiosyncraticriskw posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol     if window_5year==1 & inmkt_large==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table4mktoverlap_inout.xls, excel  dec(4)  append title(Baseline) ctitle(idio inmkt_large) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/*most pos sig*/
areg Idiosyncraticriskw posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol    if window_5year==1 & inmkt_small==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table4mktoverlap_inout.xls, excel  dec(4)  append title(Baseline) ctitle(idio inmkt_small) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2




/***Table 5. CF sensitivity; result are bad****/
/***insig****/

/*************************************************************************************************************/
/*************************************************************************************************************/
/*************************************************************************************************************/		  
/*************************************************************************************************************/
/****NOTE: variables have already been winsorized at 1% level*****************/	  
centile investment1,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 investment1,  s(w) cut(5 95) by(cyear)

centile tobin_q3,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 tobin_q3,  s(w) cut(1 99) by(cyear)

centile cash_flow1,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 cash_flow1,  s(w) cut(5 95) by(cyear)

*drop cash_flow2w
centile cash_flow2,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 cash_flow2,  s(w) cut(1 98) by(cyear)

centile investment2,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 investment2,  s(w) cut(1 99) by(cyear)


/*************************************************************************************************************/
/*************************************************************************************************************/
/*************************************************************************************************************/
/*************************************************************************************************************/
/*************************************************************************************************************/



/******tgt banks might increase corporate risk by tightening credit constraints when firms borrow from them. sensitivity of investment to cash flow increases when firms borrow from tgt banks*******/
/******interaction enters positively and sigfnificantly at 1% level, indicating that firms capital expenditure become more sensitive to its cash flows after borrowing from target banks. are more financially constrained ****/
/******REASON: when banks borrow from a bank and later the bank became a target bank, the target bank need to revise financing constraints by following a more rigorous condition as part of the financial conglomerate, therefre 
they are more likely to restrict financing contratints, making lending more difficult. when firms face more financial constraints, these shocks would force firms to make inefficient investment and employment decision to
boost firm risk. ********/
/*****postdummy is neg sig; cf is pos sig; interaction is pos sig**************/
/**results are better for cash_flow2***/
areg investment1 i.posttgtlending##c.cash_flow1 $firmcontrol  $bankcontrol $dummy $loancontrol  tobin_q3 if window_5year==1 ,   vce(robust) absorb(sic1)
outreg2 using table5finconstraint.xls, excel  dec(4)  replace title(cfs) ctitle(investment1) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2


areg investment2w i.posttgtlending##c.cash_flow2w $firmcontrol  $bankcontrol $dummy $loancontrol  tobin_q2 if window_5year==1 ,   vce(robust) absorb(sic1)
outreg2 using table5finconstraint.xls, excel  dec(4)  append title(cfs) ctitle(investment2) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/*insig*/
areg investment2 i.posttgtlending##c.cash_flow2 $firmcontrol  $bankcontrol $dummy $loancontrol  tobin_q3 if window_5year==1 ,   vce(robust) absorb(sic1)

*rename ivbp invest_rd
gen capx=cap_ppent*ppent
xtset gvkey cyear
gen ivbp2=(capx+xrd)/l.ppent
replace ivbp2=0 if ivbp2==.
centile ivbp2,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
 *drop ivbp2w
winsor2 ivbp2, s(w) cut(1 99) by(cyear)

centile invest_rd,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 invest_rd, s(w) cut(1 99) by(cyear)

/**insig***/
areg ivbp2w  c.cash_flow2##i.posttgtlending  $firmcontrol  $bankcontrol $dummy $loancontrol tobin_q3 if window_5year==1, vce(robust) absorb(sic1)
outreg2 using table7_robustness1.xls, append dec(4) sdec(4) ctitle(Investment-R&D) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2

/***the following invest_rdw is good***/
areg invest_rdw  c.cash_flow2##i.posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol tobin_q3  if window_5year==1, vce(robust) absorb(sic1)
outreg2 using tableicfs.xls, replace dec(4) sdec(4) ctitle(Investment-R&D) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2
	
	
	
	
/**************************************************************************************************************************************/	
/**************************************************************************************************************************************/		
/**************************************************************************************************************************************/	
	
	


/*****************test different firm types***********************/
drop _merge
gen gvkey_r=gvkey
	joinby  gvkey_r using "C:\Users\xzhen\Desktop\research folder2020-now\Bank deregu and ICFS-All\ICFS and bank dereg-updated code and results-0823-09102020\dist.dta", unm(master)
	    *drop _merge
	
gen firmtype1=1 if min12<50
replace firmtype1=2 if min12>=50 & minall<=100
replace firmtype1=3 if minall>100
	
		  
		  /***firmtype1=1:urban
		      firmtype1=2: small
			  firmtype1=3: rural****/
areg invest_rdw  c.cash_flow2##i.posttgtlending  $dummy $firmcontrol if  firmtype1==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using table7_firmtype.xls, replace dec(4) sdec(4) ctitle(urban) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2

	
	areg Market_totalriskw posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol    if window_5year==1 & firmtype1==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefirmtype.xls, excel  dec(4)  replace title(Baseline) ctitle(urban) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes, Industry FE, Yes ) adjr2

	areg Market_totalriskw posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol    if window_5year==1 & firmtype1==2,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefirmtype.xls, excel  dec(4)  append title(Baseline) ctitle(small) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

	areg Market_totalriskw posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol    if window_5year==1 & firmtype1==3,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefirmtype.xls, excel  dec(4)  append title(Baseline) ctitle(rural) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2



areg invest_rdw  c.cash_flow2##i.posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol tobin_q3  if window_5year==1, vce(robust) absorb(sic1)
outreg2 using tableicfs.xls, replace dec(4) sdec(4) title(Investment-R&D) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes, Industry FE, Yes ) adjr2
	
	/**insig***/
areg invest_rdw  c.cash_flow2##i.posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol tobin_q3  if window_5year==1& firmtype1==1, vce(robust) absorb(sic1)
outreg2 using tableicfs.xls, append dec(4) sdec(4) title(Investment-R&D) ctitle(urban) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes, Industry FE, Yes ) adjr2
	/**insig***/	
areg invest_rdw  c.cash_flow2##i.posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol tobin_q3  if window_5year==1& firmtype1==2, vce(robust) absorb(sic1)
outreg2 using tableicfs.xls, append dec(4) sdec(4) title(Investment-R&D)  ctitle(small) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes, Industry FE, Yes ) adjr2
/*inter sig***/
areg invest_rdw  c.cash_flow2##i.posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol tobin_q3  if window_5year==1& firmtype1==3, vce(robust) absorb(sic1)
outreg2 using tableicfs.xls, append dec(4) sdec(4) title(Investment-R&D) ctitle(rural) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes, Industry FE, Yes ) adjr2

	
	
	
	
	

/***Table 6. Geo diversification: ****/
/************09/08/24: subsample test: banks operate in state with high geodiv have stronger effects********/
/*****merge with div_index file***********/
drop _merge
joinby statecode cyear using "C:\Users\xzhen\Desktop\research folder2020-now\New project_Bank MA and customer_2020\geo div\all_div_index_unique", unm(master)


/**pos sig ***/
areg Market_totalriskw posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol   if window_5year==1 & highgeodiv3==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using table6sub-geodiv.xls, excel  dec(4)  replace title(mkt highgeodiv) ctitle(high geo div) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/****insig***/
areg Market_totalriskw posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol   if window_5year==1 & lowgeodiv3==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using table6sub-geodiv.xls, excel  dec(4)  append title(mkt lowgeodiv) ctitle(low geo div) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/**pos sig ***/
areg Idiosyncraticriskw posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol   if window_5year==1 & highgeodiv3==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using table6sub-geodiv.xls, excel  dec(4)  append title(idio highgeodiv) ctitle(high geo div) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/****insig***/
areg Idiosyncraticriskw posttgtlending $firmcontrol  $bankcontrol $dummy $loancontrol   if window_5year==1 & lowgeodiv3==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using table6sub-geodiv.xls, excel  dec(4)  append title(idio lowgeodiv) ctitle(low geo div) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2


/**************change DV to RD: RDtoSale ; invest_rd are insig*****
areg invest_rd  posttgtlending  $firmcontrol  $bankcontrol $dummy $loancontrol   if window_5year==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tableRD_v29.xls, excel tstat dec(3)  replace ctitle(lnRD ) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)
*****************/


/**************************test effects of MA on banking power**********/
/*****************results are BAD**************************/

/***********************join with maindex original one**************************/
use all_v3_forpsm, clear
drop _merge

sort rssd9001 bankyear

joinby rssd9001 bankyear using lernerindex, unm(master)
count if _merge==3  /**only 871, not 956***/

*keep rssd9001 bankyear L_SFA gvkey


replace L_SFA=0 if L_SFA==.
replace L_OLS=0 if L_OLS==.


tab cyear, gen(YEAR)
global firmcontrol="firmsize  roa1w firm_agew mkt_bookw Capitalexpendituresw saletoassetw salegrowthw Workingcapitalw leverage_totw "
global loancontrol="loansize collateral  log_maturity"
global bankcontrol="largebank cash_ta"

global bankder="dinter dintra"
global dummy="YEAR* statecode"
rename tgt_post posttgtlending

/***NEG, HARD TO EXPLAIN***/
areg Market_totalrisk i.posttgtlending##c.L_SFA $dummy $firmcontrol   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
areg Idiosyncraticrisk i.posttgtlending##c.L_SFA $dummy $firmcontrol   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)

/***all insig****/
areg L_SFA posttgtlending  $firmcontrol  $bankcontrol $dummy $loancontrol   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
areg L_OLS posttgtlending $dummy $firmcontrol   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)

/****doen't make sense:***********/
bysort  cyear: egen LSFA_mean=median(L_SFA)
		gen high_LSFA=(L_SFA>=LSFA_mean)
		gen low_LSFA=(L_SFA<LSFA_mean)
		count if low_LSFA==1 /**Only 15 obs***/
		
		
areg Market_totalriskw posttgtlending  $firmcontrol  $bankcontrol $dummy $loancontrol   if window_5year==1 & high_LSFA==1,   vce(cluster gvkey) absorb(sic1)
areg Market_totalriskw posttgtlending  $firmcontrol  $bankcontrol $dummy $loancontrol   if window_5year==1 & low_LSFA==1,   vce(cluster gvkey) absorb(sic1)


/****controls are insig*/
areg Market_totalriskw posttgtlending $firmcontrol  $bankcontrol L_SFA $dummy $loancontrol   if window_5year==1,   vce(cluster gvkey) absorb(sic1)
areg Market_totalriskw posttgtlending $firmcontrol  $bankcontrol L_OLS $dummy $loancontrol   if window_5year==1,   vce(cluster gvkey) absorb(sic1)



