/***Project: The effects of bank M&A on firm risk**********/
/***Created date: 11/23/2021-VERSION 2; ****/ 
/***Revised date: 12/02/2021; coded by xt************/




/*************update innovation data
              Follow paper: Kogan, Leonid, Dimitris Papanikolaou, Amit Seru, and Noah Stoffman. 2017. Technological
Innovation, Resource Allocation and Growth. Quarterly Journal of Economics 132: 665–
712. ***/

import delimited "E:\Innovation-update to 2020\Patent-xi\firm_innovation\firm_innovation_v2",  clear
save "E:\Innovation-update to 2020\Patent-xi\firm_innovation", replace

clear
import delimited "E:\Innovation-update to 2020\Patent-xi\Patents_xi\Patents_xi",  clear
save "E:\Innovation-update to 2020\Patent-xi\patent_xi", replace

clear
import delimited "E:\Innovation-update to 2020\Patent-xi\cites\cites",  clear
save "E:\Innovation-update to 2020\Patent-xi\cites", replace



/***********check Bhaven Sampar's data***/

use "E:\Innovation-update to 2020\Harvard database\dataverse_files\basicbib.dta",clear
duplicates report patent
/***unique***/
merge 1:m patent using "E:\Innovation-update to 2020\Harvard database\dataverse_files\uscites.dta"

bysort patent:egen ncited_patent=count(cited)
duplicates drop patent, force
drop _merge
/***the generated ncited_patent is the same with n_bcites***/
*drop patnum

/****add permno data to patent data*****/
*gen patnum=real(patent)
gen patnum=patent
merge 1:m patnum using "E:\Innovation-update to 2020\Patent-xi\patent_xi"

save "E:\Innovation-update to 2020\patent__cit_permno", replace


use "E:\Innovation-update to 2020\patent__cit_permno", clear








use "E:\Innovation-update to 2020\Patent-xi\firm_innovation",clear
/***unique at permno-year level***/

clear
use "E:\Innovation-update to 2020\Patent-xi\patent_xi"
/****it contains permno and patnum****/
tostring patnum, replace
duplicates report patnum
/***not unique*****/
save "E:\Innovation-update to 2020\Patent-xi\patent_xi", replace

use clear

/*********merge innovation data with comp_ccm_crsp*********/
use "E:\Innovation-update to 2020\comp_ccm_crsp", clear
keep gvkey cyear permno ipodate  prc altprc ret retx  vwretd  vwretx  ewretd ewretx  sprtrn
duplicates drop gvkey cyear, force
count /***211057***/
gen year=cyear
joinby permno year using "E:\Innovation-update to 2020\Patent-xi\firm_innovation", unm(master)
count if _merge==3
/***36272/211057 matched***/
drop _merge
save "E:\Innovation-update to 2020\gvkey_patent_2610", replace

/*************check citation data*************/
use "E:\Innovation-update to 2020\Harvard database\dataverse_files\uscites.dta" , clear


/****create dummy variables for self citation if citing  is equal to cited ***/
gen pat=real(patent)
*gen self_dummy=(pat==cited)


use "E:\Innovation-update to 2020\gvkey_patent_2610", clear




                 /**redo the data merge by including all matched not just best match***************/
clear
set more off
cd "E:\Research_2020_2021\New project_Bank MA and customer_2020\newdata_2021"

				 
				 
				 
				 
				 
				 
				 use "H:\XINTING_research\ub and innovation\data\link_boc_lender", clear
				 save link_boc_lender, replace
				 
				 
				 use link_boc_lender, clear
				 duplicates report facilityid bankyear  /*not unique*/
				 duplicates report gvkey bankyear  /*not unique*/
				 sort borrowercompanyid bankyear 
 				 by borrowercompanyid bankyear: gen leadlender1 = (leadarrangercredit == "Yes" |lenderrole== "Agent"|lenderrole== "Admin agent"|lenderrole=="Arranger"|lenderrole=="Lead manager" |lenderrole=="Lead bank")
				 /***keep all lenderid while mark the leadlenders as an indicator***********/
				 count if leadlender1 ==1 
				 
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

				 keep lenderid lender leadlender1 number_leadlender1 facilityid lenderrole borrowercompanyid company loantype facilityamt maturity  secured bankyear  bcoid  gvkey  
                 save ds_gvkey_link, replace





                /************check the ds-rssd link table***/
                use rssd_lenderid, clear
                sort lenderid year
                keep if best_match==1
                duplicates drop lenderid year, force
                rename year cyear, replace
                save rssd_lenderid_unique, replace

				
				
				
				/****************************************************************************/
				/****************************************************************************/
				/****************************************************************************/
				/*****add bank loan data (from dealscan)******/

use ds_gvkey_link, clear
		*duplicates report facilityid bankyear		/****not unique***/
		
/*****************4. merge with loan contract terms files*******************/
/*****************4.1 merge with primarypurpose**************************/		
joinby facilityid using "E:\Research\dealscan\stata\primarypurpose", unm(master)	
codebook loantype
drop _merge
		
/*****************4.2 merge with number of covenants and collateral**************************/		
joinby facilityid using "E:\Research\dealscan\stata\covenant_collateral", unm(master)	
replace numfincovenant=0 if numfincovenant==.
drop _merge
count
//100101

/******generate total number of covenants*************/
gen totalcovenant2=numfincovenant+num_generalcov2
gen totalcovenant1=numfincovenant+num_generalcov

/******generate variable: loan scale*****
gen facilityamt_mil=facilityamt/1000000
gen loanscale=facilityamt_mil/at**/


/****************4.3 merge with logspread *************/
joinby facilityid using "E:\Research\dealscan\stata\logspread", unm(master)
drop _merge
				
				
				
				
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
 merge m:1 lenderid cyear using rssd_lenderid_unique
keep if _merge==3
drop _merge
*duplicates report gvkey cyear  /*not unique***/

 
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
joinby rssd9001 cyear using tgt_yr, unm(master)
count /**626668***/
count if _merge==3
*duplicates report gvkey cyear
*duplicates drop gvkey cyear, force


/**need to refill mayear missing with mayear at gvkey year level*/
replace mayear=0 if missing(mayear)
bysort gvkey: egen mayr=max(mayear)

replace mayr=. if mayr==0

codebook gvkey cyear /***15387 firms, [1982 2014]***/

/***it's possible one firm borrows from multiple tgt banks during the same year. Keep the obs that has the highest frequency. then duplicates drop gvkey cyear*****************/

/***check data*********/
*keep lenderid gvkey rssd9001 cyear matyear mayear mayr non_id surv_id leadlender1 number_leadlender1
sort gvkey cyear
egen rank = rank(non_id), by(gvkey cyear) 
sort gvkey cyear
egen max=max(rank), by(gvkey cyear)  
gen largesttgt=(rank==max & !missing(max))
*drop nontgtlend1
*gen nontgtlend1=(mayr==.)
count /*626668*/

*drop nontgtlend2
by gvkey: gen nontgtlend=(max==.)


 keep if nontgtlend==1 | largesttgt==1
 count /*514974, not 624780*/
duplicates drop gvkey cyear, force
count
/***59360***/
     
*drop posttgtlending
bysort gvkey: gen posttgtlending=(cyear>=mayr)

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

/****
joinby gvkey cyear using "E:\Research\control var_code_all\data\debtrating_firmyr_nodup", unm(master)
drop _merge
****/

/***********add statecode****************/
joinby gvkey cyear using "E:\Research\control var_code_all\data\gvkey_cyear_state", unm(master)

codebook cyear if !missing(statecode)
/*****[1982,2013]  ***/

                 /***added 11/21/2021: merge with risk data and run simple test***********/
                 use "E:\Research_2020_2021\New project_Bank MA and customer_2020\newdata_2021\Risk Measures\risk_measures", clear
                 gen cyear=year
                 keep cyear gvkey tvxd tvdd tvxw tvdw  riy_leverage  riy_debtmat riy_rd riy_ppe riy_capexp riy_mb rty_roa rty_roe ivxd_2_J1

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




/*****merge ith risk data*/
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
count //54298

drop if sic1==4
count  //48669

/****follow paper"financing innovation and growth": Brown et al 2009:seven high-tech industries with SIC codes 283, 357, 366, 367, 382, 384, and 737***/
gen hightech_sic3=(sic3==283| sic3==357| sic3==366| sic3==367| sic3==382| sic3==384|sic3==737) 
count if hightech_sic3==1  //4265
				
				
		
	
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
/***21046*****/
*gen sample_5yr_window=(window_5year==1 | ub_1styear_all==0)
*count if sample_5yr_window==1 //90635, not 86250

/*********choose sample in 3 year window************/
gen window_3year=(yeardiff_min>=1 & yeardiff_max>=1)
count if window_3year==1
/****45757*****/
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
	  
			  
			  
			  
			 /***
/**Equity_assets sp500indicator Public_assets Public_issue**/
rename bk_equity_at1 Equity_assets
*rename sp500indicator S&P500indicator

/** Loanmaturity Loanscale Termloan Corpurpose Colletral Generalcovenants**/
rename log_maturity Loanmaturity
rename loanscale Loanscale
rename termloan Termloan
rename corpurpose Corppurpose
rename collateral Collateral
rename num_generalcov2 Generalcovenants
 
			  **/
			  
			  /****
//Levarage
gen leverage_tot= dt / at    // total book leverage
gen firm_debt=dltt+dlc   //calculate firm's debt= total long-term debt+total debt in current liabilities used by jfe cash holding
gen mktlev=firm_debt/firm_debt //market-debt ratio  used by jfe 1999 cash holding
gen bklev=firm_debt/at      //book-debt ratio 
****/
			  
			/****************************************************************/
  			/****************************************************************/
			/****************************************************************/

/***add lma info***/
joinby gvkey using gvkey_lma_uni, unm(master)
drop if statecode==.
/*******only 25504 not 26,207 left*/

/*****merge deregulation data********
drop _merge
joinby statecode using deregulation, unm(master)***/


/****merge with financial restricion data************/
drop _merge
joinby gvkey cyear using finrestric, unm(master)

/*****add lma info and add market overlap index************/
drop _merge
*drop year
gen year=cyear
joinby lma year using maindex5, unm(master)
count if _merge==3
/**22856, not 19774, not 20243**/
			  
			/****************************************************************/
  			/****************************************************************/
			/****************************************************************/
/****try ICFS***********/
/*****merge with ICFS and bank deregulation data*************/
drop _merge
joinby gvkey cyear using cashsens_derg, unm(master)
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
  winsor2 at cap_ta ivbp cash cf_at cap_ppent cf_ppent size  qcc1 qcc2 qbp stockissue stockissue2 ltdebt bklev mkt_book, s(w) cut(1 99) by(cyear)
  
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
rename mkt_bookw markettobook
rename ivbpw invest_rd




*gen ivbp2=(capx+xrd)/l.ppent
 replace atw=0 if atw==.
 replace firmsize=0 if firmsize==.
 replace tobin_q3=0 if tobin_q3==.

replace bookleverage=0 if bookleverage==.
	replace leverage_tot=0 if leverage_tot==.		  
			
			  
			  /**************************winsor var*****************/
			  
centile Market_totalrisk,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)

centile Idiosyncraticrisk,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
     
winsor2 Market_totalrisk Idiosyncraticrisk, s(w) cut(1 99) by(cyear)


	  


/**
centile roa1_adj_sd4,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 roa1_adj_sd4, replace cuts (1 99)

centile roe_adj_sd4,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 roe_adj_sd4, replace cuts (1 99)


winsor2 roa3_meanadj_sd4, replace cuts (1 99)
***/
/***
centile firmsize,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 firmsize, replace cuts (1 99)

centile Capitalexpenditures,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 Capitalexpenditures, replace cuts (1 99)

centile markettobook,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 markettobook, replace cuts (1 99)

centile Profitability,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 Profitability, replace cuts (1 99)

centile lt_debt,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 lt_debt, replace cuts (1 99)

centile stock_issues2,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 stock_issues2, replace cuts (5 95)
***/
/***
centile Leverage, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 Leverage, replace cuts (1 99)
	  
	 /****previously calculated leverage leads to insig; regenerate leverage: still insig!!!!!*********/ 
	  gen bkleverage=firm_debt/at
	  replace bkleverage=0 if bkleverage==.
	  
	 centile bkleverage, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 bkleverage, replace cuts (1 99)
 
	  ****/
	  
	  
	  
	/*******************Baseline regression****************/
tab cyear, gen(YEAR)

*xtset gvkey bankyear
*global firmcontrol="firmsize Capitalexpenditures markettobook Profitability saletoasset lt_debt "
*global firmcontrol="firmsize Capitalexpenditures markettobook Profitability "

/****this combination is bad*
global firmcontrol="firmsize markettobook roa1 Capitalexpenditures  leverage_tot Workingcapital"**/



global firmcontrol="firmsize markettobook roa1 Capitalexpenditures  leverage_tot"

global firmcontrol="firmsize markettobook roa1 Capitalexpenditures  stock_issues2 lt_debt"
global firmcontrol="mkt_book size bklev"


*global firmcontrol="firm_size markettobook roa1 Capitalexpenditures bk_equity_at1"

global loancontrol="loansize collateral  log_maturity"



/***this control set works best for market total risk (merged with control-v1)
firmsize markettobook roa1 Capitalexpenditures lt_debt
***/

global bankder="dinter dintra"
global dummy="YEAR* statecode"



/***pos sig****/
/****can't add bookleverage as control!!!!!************/
areg Market_totalrisk posttgtlending $dummy $firmcontrol $loancontrol $bankder  if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table2base.xls, excel  dec(4)  replace title(Baseline) ctitle(market total risk) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

areg Idiosyncraticriskw posttgtlending $dummy $firmcontrol $loancontrol $bankder  if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table2base.xls, excel  dec(4)  append title(Baseline) ctitle(Idiosyncraticrisk) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

areg Market_totalriskw posttgtlending $dummy  $firmcontrol $bankder if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table2base.xls, excel  dec(4)  append title(Baseline) ctitle(market total risk) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

areg Idiosyncraticriskw posttgtlending $dummy $firmcontrol $bankder if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table2base.xls, excel  dec(4)  append title(Baseline) ctitle(Idiosyncraticrisk) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2



firmsize markettobook roa1 Capitalexpenditures lt_debt stock_issues2 leverage_tot
/******the following results are bad****************
/****neg sig***/
areg roa1_adj_sd4 posttgtlending $dummy $firmcontrol $loancontrol $bankder if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
/***insig****/
areg roe_adj_sd4 posttgtlending $dummy $firmcontrol $loancontrol if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)

/***insig****/
areg roa2_adj_sd4 posttgtlending $dummy $firmcontrol $loancontrol if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
/***insig****/
areg roa3_adj_sd4 posttgtlending $dummy $firmcontrol $loancontrol if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)

/***insig for roamean1-3****/
areg roa3_meanadj_sd4  posttgtlending $dummy $firmcontrol $loancontrol if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)


/***insig***/
areg rty_roa posttgtlending $dummy $firmcontrol   ,   vce(cluster gvkey) absorb(sic1)

*************/

areg Risk_dailytotalret posttgtlending $dummy $firmcontrol   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
areg Risk_weeklytotalret  posttgtlending $dummy $firmcontrol   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)


ssc install tsegen, replace



/***********try subsample**************/


/********subsample analysis: EFD**************/
/********xternalfinancialdependence(EFD),respectively.Ahigh(low)EFDsubsamplehasindustryEFDabove(below)thesamplemedian****/
/********pos sig only for high_efd subsample********************/
areg Market_totalrisk posttgtlending $firmcontrol  $dummy $loancontrol leverage_tot if window_5year==1 & low_efd==1, vce(cluster gvkey) absorb(sic1)
outreg2 using table3efdsubsample.xls, excel  dec(4)  replace title(Baseline) ctitle(Low EFD) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

areg Market_totalrisk posttgtlending $firmcontrol  $dummy $loancontrol $bankder if window_5year==1 & high_efd==1, vce(cluster gvkey) absorb(sic1)
outreg2 using table3efdsubsample.xls, excel  dec(4)  append title(Baseline) ctitle(High EFD) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

areg Idiosyncraticrisk posttgtlending $firmcontrol  $dummy $loancontrol $bankder if window_5year==1 & low_efd==1, vce(cluster gvkey) absorb(sic1)
outreg2 using table3efdsubsample.xls, excel  dec(4)  append title(Baseline) ctitle(Low EFD) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2
areg Idiosyncraticrisk posttgtlending $firmcontrol  $dummy $loancontrol $bankder if window_5year==1 & high_efd==1, vce(cluster gvkey) absorb(sic1)
outreg2 using table3efdsubsample.xls, excel  dec(4)  append title(Baseline) ctitle(High EFD) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2




/********subsample analysis: fin restriction**************/
/***POS SIG****/
areg Market_totalrisk posttgtlending $firmcontrol  $dummy $loancontrol $bankder if window_5year==1 & top_kz==1, vce(cluster gvkey) absorb(sic1)
outreg2 using table4kzsubsample.xls, excel  dec(4)  replace title(Subsample: Fin restriction) ctitle(Market_totalrisk Top kz) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/***INSIG***/
areg Market_totalrisk posttgtlending $firmcontrol  $dummy $loancontrol $bankder if window_5year==1 & bottom_kz==1, vce(cluster gvkey) absorb(sic1)
outreg2 using table4kzsubsample.xls, excel  dec(4)  append title(Subsample: Fin restriction) ctitle( Market_totalrisk Bottom kz) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/***POS SIG****/
areg Idiosyncraticrisk posttgtlending $firmcontrol  $dummy $loancontrol $bankder if window_5year==1 & top_kz==1, vce(cluster gvkey) absorb(sic1)
outreg2 using table4kzsubsample.xls, excel  dec(4)  append title(Subsample: Fin restriction) ctitle( Idiosyncraticrisk Top kz) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/***INSIG***/
areg Idiosyncraticrisk posttgtlending $firmcontrol  $dummy $loancontrol $bankder if window_5year==1 & bottom_kz==1, vce(cluster gvkey) absorb(sic1)
outreg2 using table4kzsubsample.xls, excel  dec(4)  append title(Subsample: Fin restrictione) ctitle(Idiosyncraticrisk Bottom kz) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2



/*************NEED TO RECHECK THE MARKET OVERLAP MEASUREA AND APPLICATION!!!!!!!!!!!!**********************/
/*****simple reg test: interaction term*********/
/***insig**
areg Market_totalrisk i.posttgtlending##c.inmkt_indexla $dummy $firmcontrol   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
areg Market_totalrisk i.posttgtlending##c.outmkt_indexta $dummy $firmcontrol   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
**/
/****single effects are both pos, while interaction term is negative********/


firmsize markettobook roa1 Capitalexpenditures lt_debt stock_issues2


centile inmktw_large2,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 inmktw_large2, s(w) cut(1 99) by(cyear)


areg Market_totalriskw i.posttgtlending##c.inmktw_large2 $dummy $firmcontrol  $loancontrol $bankder   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table5mktoverlap.xls, excel  dec(4)  replace title(mktoverlap) ctitle(Market_totalrisk inmkt_large) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2


/***interaction is insig***/
areg Market_totalriskw i.posttgtlending##c.inmktw_small2 $dummy $firmcontrol  $loancontrol $bankder if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table5mktoverlap.xls, excel  dec(4)  append title(mktoverlap) ctitle(Market_totalrisk inmkt_small) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/****single effects are both pos, while interaction term is negative********/
areg Idiosyncraticriskw i.posttgtlending##c.inmktw_large2 $dummy $firmcontrol  $loancontrol $bankder if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table5mktoverlap.xls, excel  dec(4)  append title(mktoverlap) ctitle(Idiosyncraticrisk inmkt_large) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/***interaction is insig***/
areg Idiosyncraticriskw i.posttgtlending##c.inmktw_small2 $dummy $firmcontrol $loancontrol $bankder  if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table5mktoverlap.xls, excel  dec(4)  append title(mktoverlap) ctitle(Idiosyncraticrisk inmkt_small) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/***insig****/
areg Market_totalriskw i.posttgtlending##c.outmkt_indexla $dummy $firmcontrol $loancontrol $bankder  if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table5mktoverlap.xls, excel  dec(4)  append title(mktoverlap) ctitle(Market_totalrisk  outmkt_large) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/**insig******/
areg Market_totalriskw i.posttgtlending##c.outmkt_indexsm $dummy $firmcontrol $loancontrol $bankder  if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table5mktoverlap.xls, excel  dec(4)  append title(mktoverlap) ctitle(Market_totalrisk  outmkt_small) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/**insig******/
areg Idiosyncraticriskw  i.posttgtlending##c.outmkt_indexla $dummy $firmcontrol $loancontrol $bankder  if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table5mktoverlap.xls, excel  dec(4)  append title(mktoverlap) ctitle(Idiosyncraticrisk outmkt_large) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2

/**interaction is pos sig, but index is insig******/
areg Idiosyncraticriskw  i.posttgtlending##c.outmkt_indexsm $dummy $firmcontrol  $loancontrol $bankder if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using table5mktoverlap.xls, excel  dec(4)  append title(mktoverlap) ctitle(Idiosyncraticrisk outmkt_small) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes, State FE, Yes) adjr2



/**********use the 2nd set of measures: Under different market overlap, differentiate M&A types based on acquirer size (follow Francis JBF2008)***/
/*** following three are all insig: for both risk measures******/
areg Idiosyncraticrisk i.posttgtlending##c.inmkt_indexla $dummy $firmcontrol   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
areg Idiosyncraticrisk i.posttgtlending##c.inmkt_indexsm $dummy $firmcontrol   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
areg Idiosyncraticrisk i.posttgtlending##c.outmkt_indexla $dummy $firmcontrol   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
/**only this interaction is pos sig, but index is insig*****/
areg Idiosyncraticrisk i.posttgtlending##c.outmkt_indexsm $dummy $firmcontrol   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)



***
*tab cyear, gen(YEAR)
*global firmcontrol="firmsize Capitalexpenditures Workingcapital bookleverage markettobook roa1"
*global dummy="YEAR* statecode"
***

****results are bad:*******
/****if use ICFS control:post dummy neg sig; cash flow neg sig; interaction pos sig***/

/*****postdummy is neg sig; cf is pos sig; interaction is pos sig**************/
areg investment2 i.posttgtlending##c.cash_flow2 $dummy $firmcontrol  $loancontrol $bankder  if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
areg investment1 i.posttgtlending##c.cash_flow1 $dummy  $firmcontrol if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
**




/****results are bad when using sa**
areg Market_totalrisk posttgtlending $firmcontrol  $dummy if window_5year==1 & top_sa==1, vce(cluster gvkey) absorb(sic1)
/***INSIG***/
areg Market_totalrisk posttgtlending $firmcontrol  $dummy if window_5year==1 & bottom_sa==1, vce(cluster gvkey) absorb(sic1)
**/
/***both are pos sig, hard to explain*
areg Market_totalrisk posttgtlending $firmcontrol  $dummy if window_5year==1 & top_struc==1, vce(cluster gvkey) absorb(sic1)
areg Market_totalrisk posttgtlending $firmcontrol  $dummy if window_5year==1 & bottom_struc==1, vce(cluster gvkey) absorb(sic1)
**/



/************************************************************************************/
/************************************************************************************/
/************************************************************************************/


/*****try with innovation data (to 2006)*****/

                                        /************merge with innovation data**********************/		
	                  drop _merge
					  tostring gvkey, replace
	                 
	                  joinby gvkey cyear using "E:\Innovation-update to 2020\gvkey_patent_2610", unm(master)
					  
					  count if _merge==3
					  /***2199***/
					  /****to many obs dropped!!!!***********/
					  
	                  keep if _merge==3
	                  count
	                  drop _merge
					  replace npats=0 if npats==.
					  gen log_pt=ln(1+npats)
					  
					drop if cyear>=2011
					count
					  
/***sig neg; it should be pos sig to make sense***/
areg log_pt posttgtlending  $dummy $firmcontrol  $loancontrol $bankder  if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)




/***pos sig****/
areg ln_cit_firm posttgtlending $dummy $firmcontrol  $loancontrol $bankder  if window_3year==1 ,   vce(cluster gvkey) absorb(sic1)



                                /***********Mechasim: ma increases banking power**************/
                                use "H:\XINTING_research\Lerner Index code and results\lerner calculation results\efflerner", clear
                                keep rssd9001 bankyear L_OLS L_SFA  IE CE PI PE
                                save lernerindex,replace
drop _merge
joinby rssd9001 bankyear using lernerindex, unm(master)
count if _merge==3  /**only 956***/
*replace L_SFA=0 if L_SFA==.
/***NEG, HARD TO EXPLAIN***/
areg Market_totalrisk i.posttgtlending##c.L_SFA $dummy $firmcontrol   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)
areg Idiosyncraticrisk i.posttgtlending##c.L_SFA $dummy $firmcontrol   if window_5year==1 ,   vce(cluster gvkey) absorb(sic1)




/**********************************************************************************************************/
/**********************************************************************************************************/
/**************************NEED TO CHECK THE FOLLOWING DATA FOR FUTURE TESTS*******************************/
use "F:\XINTING_research\Banking power and IPO\dataneed\all_div_index.dta" , clear
               keep year stnumbr stname div_index_RSSDst div_index_BHCst
               rename year cyear
               rename stnumbr statecode
			   
			   	bysort statecode cyear: egen geodiv_mean=mean(div_index_BHCst)
			    gen high_geodiv2=(div_index_BHCst>=geodiv_mean)  
		        gen low_geodiv2=(div_index_BHCst<geodiv_mean)

			   duplicates drop stnumbr year, force
               count
               //1180
               save "E:\Research\bank deregulation and cf sensitivity\code and data_xt\div_st.dta", replace
/**********************************************************************************************************/
/**********************************************************************************************************/



areg Market_totalrisk posttgtlending $dummy $firmcontrol   if window_5year==1 & high_geodiv2==1,   vce(cluster gvkey) absorb(sic1)


