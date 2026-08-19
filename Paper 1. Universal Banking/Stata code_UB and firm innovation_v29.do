
/*****Project: Universal bank lending and firm innovation
This file is for UB and innovation-draft v17
adjust sample: merge dealscan and compustat, fill compustat years, so year is continuous for a firm
               for distinct_ub=1, choose the only one ub lending
               for distinct_ub>=2, choose the earliest ub lending  year (note: not the earliest ub formation year)***
               run baseline regression in 5year and 3year window
			   
			   
			  updated on 8/25/17: tried to come up with an idea of using cem for each of the 1st ub lending years and then append them, then restrict the sample
			   within 5 years window, and run diff in diff regression
			   Updated on 9/3/2017: 
			   (1) add variable "number_leadlender1" to proxy for the number of lenders
			   (2) do other tests besides baseline regression
			   Updated on 9/13/2017: 
			   (1) adjust loan factors to use- refer to the other code file
			   (2) summary statistics at the end
			   
			   
			   Updated on 11/3/2017:
			   (1) replace firmsale with salegrowth
			   (2) PSM logistic regression: adjust firm control variabels
			   (3) results are better if using ccm instead of compu
			   (4) delete missing statecode, to make sure the number of observations are consistent for summary statistics and output
			   
			   Updated on 12/14/2017:
			  (1) merge with SA data to check joint R&D
			  1.1 technology alliance
			  1.2 joint innovation
			  1.3 liscense innovation
			  
			  (2)generate financial constriants variables: KZ index, SA index, and structural index
			
coded by Xinting
      created date: 8/23/2017
       last updated date: 2/8/2018************/


	   /********Note: The main file with all the merged files before winsorization is "innovation_ub_control_sdc_v6"*********
	   *********For later tests, may need other file: winsored_v6_base_sa****************/
	   
clear
cd "D:\research\UB and innovation\data"

use link_boc_lender, clear
sort bankyear
codebook bankyear
//[1982 2014]
 sort borrowercompanyid bankyear 
 by borrowercompanyid bankyear: gen leadlender1 = (leadarrangercredit == "Yes" |lenderrole== "Agent"|lenderrole== "Admin agent"|lenderrole=="Arranger"|lenderrole=="Lead manager" |lenderrole=="Lead bank")
count if leadlender1 ==1 
//247834
keep if leadlender1==1 
count

rename companyid lenderid
sort gvkey bankyear

bysort gvkey bankyear: egen number_leadlender1=count(lenderid)
bysort gvkey bankyear: egen boc_loanamt=total(facilityamt)

gen share=facilityamt/boc_loanamt
egen rank = rank(share), by(gvkey bankyear) 
sort gvkey bankyear
egen max=max(rank), by(gvkey bankyear)  
gen largestlead=(rank==max)

/*******keep the lead lender take the largest shares***********/
keep if largestlead==1
count //132350

/******************keep the first largest lead lender if there exsit multiple largest lead lenders****/
egen rank_lender = rank(lenderid), by(gvkey bankyear) 
egen min_lender=min(rank_lender), by(gvkey bankyear)  
gen firstlender=(rank_lender==min_lender)
*bysort gvkey bankyear: egen nlender=total(largestlead)


keep if firstlender==1
//after keep the first lender, there still exist duplicates for gvkey-bankyear that have duplicated same lenders***/
count
duplicates drop gvkey bankyear, force
count
//60856

use ubid, clear
/****************joinby ubid****************/
/*use ubid, clear
duplicates report lenderid ub_year2 //285
*/
joinby lenderid using ubid, unm(master)
count if ub_year1==.
//39084
count if ub_year2==.
count if ub_indicator==1
//21772
codebook gvkey if  ub_indicator==1
//7599

keep lenderid lender number_leadlender1 facilityid lenderrole borrowercompanyid company loantype facilityamt maturity  secured bankyear  bcoid  gvkey   rssdid  ub_year1 ub_year2 ub_indicator
save dealscan_link_ub, replace

use dealscan_link_ub, clear
codebook bankyear 
//[1982,2014] 
saveold  dealscan_link_ub_12, version(12)

use comp_ccm_crsp1, clear
codebook cyear
//[1980,2015] 
saveold  comp_ccm_crsp1_12, version(12)

/********keep number of lead lenders only and match with master file later***/
use dealscan_link_ub, clear
codebook bankyear //  [1982,2014]  
keep gvkey bankyear number_leadlender1
duplicates report gvkey 
duplicates report gvkey bankyear
save numlender, replace


/*********use SAS to merge dealscan_link_ub_12 and  comp_ccm_crsp1_12, then generate new file "dealscan_ccm_ub"********/
use "D:\research\UB and innovation\code and data_v6\dealscan_ccm_ub", clear
codebook gvkey
codebook cyear
/**[1980 2015]**/
/*********choose sample period [1982,2006]*************/
keep if bankyear<2007 & bankyear>=1982
count 
//155,465
count if !missing(facilityid)
//25670
gen dsccm_matched=(!missing(facilityid))
count if dsccm_matched==1
//25670 are matched

duplicates report gvkey cyear
//155465

/******add the information of number of lenders************/
joinby gvkey bankyear using numlender, unm(master)
count
//155465
drop _merge



/***********merge with control variables****************/
joinby gvkey cyear using "D:\Research\control var_code_all\data\control_v4", unm(master)
bysort gvkey: egen min_cyear=min(cyear)
count //155465
keep if _merge==3
count
//149999
codebook cyear
/**1982-2006****/

gen firm_age=bankyear-min_cyear

gen sic1=substr(sic, 1,1)
gen sic2=substr(sic, 1,2)
gen sic3=substr(sic, 1,3)

destring sic sic1 sic2 sic3, replace

count if sic1==6 //37676

/*****keep non-financial firms only in the sample****/
drop if sic1==6
count //21105， not 26540, less than using sich

drop if sic1==4
count
//N=100101


/****follow paper"financing innovation and growth": two-digit SIC industries 28, 35, 36, 37, 38, and 73 contain virtually the entire U.S. high-tech sector***
gen hightech=(sic2==28| sic2==35| sic2==36| sic2==37| sic2==38| sic2==73) 
count if hightech==1
//7185, not 9042****/

/****follow paper"financing innovation and growth": Brown et al 2009:seven high-tech industries with SIC codes 283, 357, 366, 367, 382, 384, and 737***/
gen hightech_sic3=(sic3==283| sic3==357| sic3==366| sic3==367| sic3==382| sic3==384|sic3==737) 
count if hightech_sic3==1
//31601

drop _merge

/*****************4. merge with loan contract terms files*******************/
/*****************4.1 merge with primarypurpose**************************/		
joinby facilityid using "D:\research\dealscan\stata\primarypurpose", unm(master)	
codebook loantype
drop _merge
		
/*****************4.2 merge with number of covenants and collateral**************************/		
joinby facilityid using "D:\research\dealscan\stata\covenant_collateral", unm(master)	
replace numfincovenant=0 if numfincovenant==.
drop _merge
count
//100101

/******generate total number of covenants*************/
gen totalcovenant2=numfincovenant+num_generalcov2
gen totalcovenant1=numfincovenant+num_generalcov

/******generate variable: loan scale*******/
gen facilityamt_mil=facilityamt/1000000
gen loanscale=facilityamt_mil/at


/****************4.3 merge with logspread *************/
joinby facilityid using "D:\research\dealscan\stata\logspread", unm(master)
drop _merge
/**************5. *merge with state code******************/
joinby state using state_region, unm(master)
drop _merge
/*********6. merge with risk measures***************/
joinby gvkey cyear using risk_measures, unm(master)
count
count if _merge==3 //100100, not 17857, not 18589, all firms are matched already
drop _merge


/*********merge with innovation data********/
/***********2. merge dealscan-ccm with innovation data************/
gen appyear=cyear
joinby gvkey appyear using "D:\research\UB and innovation\code and data all_draft_v3\innovation_v3\inno_nodup_gvkey.dta", unm(master)
/****mark for innovative firms only***********/
gen nberonly=(_merge==3)

count 
count if nberonly==1 
//24490
drop _merge

save innovation_ub_control_sdc_v6, replace


use  innovation_ub_control_sdc_v6, clear
/*****CHECK FOR THE SAMPLE: HOW MANY FIRMS ONLY BORROWS ONCE FROM UB?************/
egen tag = tag(ub_year2 gvkey) 
egen distinct_ub = total(tag), by(gvkey)

su distinct_ub  //[0 5]

/******************************************************************/
/**********winsorization: run with old code***********/
/******************************************************************/
/****generate sale growth*********/
gen sale=exp(logsale)

by gvkey: gen lagsale=sale[_n-1]
by gvkey:gen lagsale_2 =logsale[_n-1]

gen salegrowth=sale/lagsale-1 
gen salegrowth_2 = lagsale/lagsale_2 -1    //Sales Growth is the natural log of sales in year t, minus the natural log of sales in year t-1  (JFE1999 CASH HOLDING)
replace salegrowth=0 if salegrowth==.


replace npat_firm_adj1=0 if npat_firm_adj1==.
replace cit_pat_firm1=0 if cit_pat_firm1==.
replace selfcit_pat_firm1=0 if selfcit_pat_firm1==.
replace nonselfcit_pat_firm1=0 if nonselfcit_pat_firm1==.

replace gen_firm=0 if gen_firm==.
replace orig_firm=0 if orig_firm==.

replace rdintensity_1=0 if rdintensity_1==.
replace rdtosale=0 if rdtosale==.

replace bk_equity_at1=0 if bk_equity_at1==.
replace logasset=0 if logasset==.

/**generate log of patents and citations***/
gen ln_pat1=ln(1+npat_firm_adj1)
gen ln_citall1=ln(1+cit_pat_firm1)
gen ln_citself1=ln(1+selfcit_pat_firm1)
gen ln_citnonself1=ln(1+nonselfcit_pat_firm1)
gen ln_originality=ln(1+orig_firm)
gen ln_generality=ln(1+gen_firm)


/***************winsorize for number of patent***********/
centile npat_firm_adj1, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 85 88 89 90 92 94 95 99)
winsor2  npat_firm_adj1, replace cuts (5 92)

*centile selfcit_pat_firm1, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 85 88 90 92 94 95 99)
centile nonselfcit_pat_firm1, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 85 88 89 90 92 94 95 99)
*winsor2 nonselfcit_pat_firm1, replace cuts (1 99)


centile ln_pat1, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 85 88 89 90 92 94 95 99)
winsor2  ln_pat1, replace cuts (1 99)


centile ln_citnonself1 , centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 85 88 89 90 92 94 95 99)
winsor2  ln_citnonself1, replace cuts (1 99)


/***************Winsorization for gen and orig at firm level**************/

centile gen_firm, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 85 88 89 90 92 94 95 99)
winsor2 gen_firm, replace cuts (1 98)

centile orig_firm, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 85 88 89 90 92 94 95 99)
winsor2 orig_firm, replace cuts (1 98)

centile ln_originality, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 85 88 89 90 92 94 95 99)
winsor2 ln_originality, replace cuts (1 99)

centile ln_generality , centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 85 88 89 90 92 94 95 99)
winsor2 ln_generality, replace cuts (1 99)


/***For firm control variables*********/
/***logassetlogsale roa1 cap_exp firm_eff tangibility_2 wkcapital rdtosale at_tangibility bk_equity_at1 rdintensity_1***/
centile logasset, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 logasset, replace cuts (5 90)

centile roa1, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2  roa1, replace cuts (1 99)

centile roa3, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2  roa3, replace cuts (9 99)

centile cap_exp, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2  cap_exp, replace cuts (5 99)

centile firm_eff, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2  firm_eff, replace cuts (5 99)

centile wkcapital, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 wkcapital, replace cuts (5 99)

centile salegrowth, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2  salegrowth, replace cuts (5 99)

centile rdtosale, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 rdtosale, replace cuts (5 99)


/****generate log of R&D expense***********/
replace xrd=0 if xrd==.
gen ln_RD=ln(1+xrd)

centile ln_RD, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 ln_RD, replace cuts (1 99)

centile  rdtoassets, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2  rdtoassets, replace cuts (10 90)

centile  rdintensity_1, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 rdintensity_1, replace cuts (10 90)

centile at_tangibility, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 at_tangibility, replace cuts (10 90)

centile bklev, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 bklev, replace cuts (10 90)

centile firm_age, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 85 88 89 90 92 94 95 99)
winsor2  firm_age, replace cuts (1 99)


/************for capital structure************/

centile bk_equity_at1, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 bk_equity_at1, replace cuts (5 95)

centile equity_dummy, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)

centile sp500indicator, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)

/***********for loan control variables***************/
/******log_maturity  loanscale  termloan collateral num_generalcov2 loanpurpose
log_numleadlender1 log_leadlenderamt1**********************************/

centile  log_maturity, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 log_maturity, replace cuts (1 99)

centile  loanscale, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 loanscale, replace cuts (10 90)


/*******for firm risk measures************/
centile tvxd, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 tvxd, replace cuts (1 99)

centile tvxw, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 tvxw, replace cuts (1 99)

centile tvdd, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 tvdd, replace cuts (1 99)

centile tvdw, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 tvdw, replace cuts (1 99)

centile logspread,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 logspread, replace cuts (1 99)

centile ivxd_2_J1,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 ivxd_2_J1, replace cuts (1 99)




/************************Rename control variables******************************/
/**Firmsize Firmsales Profitability  Capitalexpenditures Firmefficiency Workingcapital Assetstangibility Leverage**/

rename logasset Firmsize
rename logsale Firmsales
rename roa3 Profitability 
rename cap_exp Capitalexpenditures
rename firm_eff Firmefficiency
rename wkcapital Workingcapital
rename at_tangibility Assetstangibility
rename bklev Leverage
rename rdintensity_1 RDintensity

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

rename logspread LnAISD
 
rename rdtosale RDtosale


rename npat_firm_adj1 Patents
rename nonselfcit_pat_firm1 Nonselfcitations
rename cit_pat_firm1 Citations
rename ln_pat1 Ln_patent
rename ln_citnonself1 Ln_nonselfcitation
rename gen_firm Generality
rename orig_firm Originality
rename ln_originality Ln_originality
rename ln_generality Ln_generality



rename tvdd Risk_dailytotalret
rename tvdw Risk_weeklytotalret
rename tvxd Risk_dailyexdivret
rename tvxw Risk_weeklyexdivret
rename ivxd_2_J1 Idiosyncraticrisk
rename Risk_dailyexdivret Market_totalrisk
rename firm_age Firm_age
rename salegrowth Salegrowth
rename sp500indicator debtrating

/*****replace other missing firm controls with zero to avoidtoo many missing value in the sample**********/

replace  debtrating=0 if  debtrating==.
replace  Assetstangibility=0 if   Assetstangibility==.
replace  Leverage=0 if   Leverage==.
replace  Workingcapital=0 if   Workingcapital==.
replace  Firmefficiency=0 if   Firmefficiency==.
replace  Capitalexpenditures=0 if  Capitalexpenditures==.
replace  Firmsales=0 if   Firmsales==.
replace  Profitability=0 if   Profitability==.
replace  Firmsales=0 if Firmsales==.
replace  Loanscale=0 if Loanscale==.

replace xrd=0 if xrd==.
replace rdtoassets=0 if rdtoassets==.


/***********generate dummy to proxy for innovative firms****************/
gen inno_firm=(Ln_patent>0)
count if inno_firm==1 //N=24490

save winsored_v6_2, replace
count 
//100101



/****************************************************************************************************************************/
/**********************************************generate dummy for firms that borrow from UB**********************************/
/****************************************************************************************************************************/

/*********************generate sample**********************/
use winsored_v6_2, clear
rename ub_year1 ub_year1_orig
*keep gvkey cyear bankyear lenderid ub_year2 maturity  Loanmaturity distinct_ub   

/*********for distinct_ub==1************/
bysort gvkey: egen ub_year1=min(ub_year2) if distinct_ub==1
gen yeardiff1=cyear-ub_year1
/****exclude the situation that the firm didn't borrow from ub*********/
replace yeardiff1=. if ub_year2==.
/****exclude the situation that the firm  borrow from ub but the ub hadn't changed to ub at the lending time*********/
replace yeardiff1=. if yeardiff1<0
gen byte miss1 = missing(yeardiff1)
bysort miss gvkey (cyear) : gen byte firstlendub1 = ( _n == 1) & ( miss1 == 0 )
sort gvkey cyear

*gen firstlendub1=(cyear==ub_year1) if !missing(yeardiff1)
*gen year_lendub1=cyear if  ub_post1==1

gen year_lendub1=cyear if firstlendub1==1
bysort gvkey: egen year_1stublend1=min(year_lendub1)

/*****gengerate ub_post dummy**************/
gen after_1stlendyear=cyear-year_1stublend1
gen ub_post1=( after_1stlendyear>=0 & !missing(after_1stlendyear) )



/*********for distinct_ub>=2************/
gen yeardiff2=cyear-ub_year2
replace yeardiff2=. if yeardiff2<0
*bysort gvkey: egen minub2=min(yeardiff2) if distinct_ub>1
*gen firstlendub2=(yeardiff2==minub2) if !missing(yeardiff2)

*bysort gvkey: gen firstlendub2=yeardiff2[1]
gen byte miss = missing(yeardiff2)
bysort miss gvkey (cyear) : gen byte firstlendub2 = ( _n == 1) & ( miss == 0 ) if distinct_ub>1
sort gvkey

gen year_lendub2=cyear if  firstlendub2==1
bysort gvkey: egen year_1stublend2=min(year_lendub2)

gen ub_yeardiff2=(cyear-year_1stublend2)
gen ub_post2=(ub_yeardiff2>=0 & !missing(ub_yeardiff2))
sort gvkey cyear



/****generate new year variable to show the 1st year lending from ub for both cases*********/
*replace ub_year1=0 if ub_year1==.
replace year_1stublend1=0 if year_1stublend1==.
replace year_1stublend2=0 if year_1stublend2==.
*gen ub_1styear_all=ub_year1+year_1stublend2
gen ub_1styear_all=year_1stublend1+year_1stublend2

/****generate dummy for both cases********/
gen ub_post_1stall=ub_post1+ub_post2
tabulate ub_post_1stall

/****how many firms borrow from ub? how many borrow from non-ub?
***/
codebook gvkey if ub_post_1stall==1
/**2796 not 3004**/
codebook gvkey if ub_post_1stall==0
/**10699, not 11979***/
codebook gvkey



/********************************redefine ub-dummy: during loan maturity*********************/
***round the loan maturiy to integer

gen yearmaturity=maturity/12
gen matyear=ceil(yearmaturity)
replace matyear=0 if matyear==.

**generate loanyear_mat to represent 
gen loanyear_mat1=year_lendub1+matyear
gen loanyear_mat2=year_lendub2+matyear

bysort gvkey: egen matyear_firm1=min(loanyear_mat1)
bysort gvkey: egen matyear_firm2=min(loanyear_mat2)

replace matyear_firm1=0 if matyear_firm1==.
replace matyear_firm2=0 if matyear_firm2==.

gen matyear_firm=matyear_firm1+matyear_firm2
drop matyear_firm1 matyear_firm2

replace ub_post_1stall=0 if cyear>matyear_firm
*keep gvkey cyear ub_post_1stall  matyear_firm  matyear  ub_1styear_all 
count if ub_post_1stall ==1
//10924
count
//100101




/*****check the 1st year when firm borrow from a ub**************/
codebook year_1stublend2
//  unique values:  20 

tabulate  ub_1styear_all if ub_post_1stall==1
/***[1988-2006]**/

count if ub_post_1stall ==1


/**********generate yeardiff to select year window sample***********/
*bysort gvkey: egen min_cyear=min(cyear)
bysort gvkey: egen max_cyear=max(cyear)


gen yeardiff_min=ub_1styear_all-min_cyear
gen yeardiff_max=max_cyear-ub_1styear_all

/*********choose sample in 5 year window************/
gen window_5year=(yeardiff_min>=2 & yeardiff_max>=2)
count if window_5year==1
/****30369, not 29705*****/
gen sample_5yr_window=(window_5year==1 | ub_1styear_all==0)
count if sample_5yr_window==1 //90635, not 86250

/*********choose sample in 3 year window************/
gen window_3year=(yeardiff_min>=1 & yeardiff_max>=1)
count if window_3year==1
/****35038, not 32253*****/
gen sample_3yr_window=(window_3year==1 | ub_1styear_all==0)
count if sample_3yr_window==1 //95304, not 88798


/**********check*******
codebook gvkey
// total of 12465 unique firms
codebook gvkey if distinct_ub==1
//2401 unique firms have borrowed from ub once
codebook gvkey if distinct_ub==2
//737 unique firms  have borrowed from ub twice
codebook gvkey if distinct_ub>=3
//227 unique firms  have borrowed from ub more than twice, the largest is 5
codebook gvkey if distinct_ub==0
// 9100 unique firm never borrowed from ub
****/
save winsored_v29_base, replace



/************************************************************************************************************/
/*********************************Table 2. BASELINE REGRESSION*******************************************************/
/************************************************************************************************************/
*use winsored_v6_base_2,clear

use winsored_v29_base, clear
sort gvkey
duplicates report gvkey cyear // 100101 unique
count if !missing(statecode) //89877
keep if !missing(statecode)

/**********check***********/
duplicates report gvkey cyear
codebook lenderid
codebook gvkey if ub_indicator==1



codebook gvkey
// total of 11155， not 12465 unique firms
codebook gvkey if distinct_ub==1
//2242, not 2401 unique firms have borrowed from ub once
codebook gvkey if distinct_ub==2
//693, not 737 unique firms  have borrowed from ub twice
codebook gvkey if distinct_ub>=3
//205, not 227 unique firms  have borrowed from ub more than twice, the largest is 5
codebook gvkey if distinct_ub==0
// 8015, not 9100 unique firm never borrowed from ub


codebook lenderid if ub_indicator==1 //163 unique banks

count
pwcorr Ln_patent Ln_nonselfcitation ub_post_1stall Firmsize salegrowth Firm_age Profitability Capitalexpenditures  Firmefficiency Workingcapital Assetstangibility  Equity_assets debtrating
/***********************Summary statistics*******************************/
tabstat Patents Nonselfcitations , stat  (n mean sd  p25 median p75  ) col(stat)

/****2. for firm control variables(include risk measures)********/
tabstat Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility Equity_assets debtrating  , stat (n mean sd  p25 median p75  ) col(stat)

/****3. for loan control variables********/
*tabstat Loanmaturity  Loanscale Corppurpose Termloan Collateral Generalcovenants , stat(n mean sd  p5 median p95  ) col(stat)
tabstat  ub_post_1stall, stat (n mean sd  p25 median p75  ) col(stat)

pwcorr Firmsize Salegrowth Firm_age Profitability Capitalexpenditures Firmefficiency Workingcapital


/********For presentation************/

tabstat Patents Nonselfcitations ub_post_1stall Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility Equity_assets debtrating , stat  (n mean sd  p5 p95 p75) col(stat)



/*******************Baseline regression****************/
tab bankyear, gen(YEAR)

*xtset gvkey bankyear

global firmcontrol="Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility "
global capstructcontrol="Equity_assets  debtrating "
global dummy="YEAR* statecode"

count if !missing(statecode)
//89877


/****column 1*******/
/***neg sig****/
areg Ln_patent ub_post_1stall $dummy $firmcontrol  $capstructcontrol if sample_5yr_window==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablebase_v29.xls, excel tstat dec(3) replace ctitle(ln_patent) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

/****column 2*******/
areg Ln_nonselfcitation ub_post_1stall $dummy $firmcontrol  $capstructcontrol if sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablebase_v29.xls, excel tstat dec(3) append ctitle(ln_citation) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

*areg LnAISD ub_post_1stall $dummy $firmcontrol  $capstructcontrol,   vce(cluster gvkey) absorb(sic1)




/***************Table 2. DID (see code "stata code_run psm for the whole sample_updated on 0902***************/
clear
cd "D:\research\UB and innovation\data"
use winsored_v6_base_2, clear
keep gvkey cyear ub_1styear_all ub_year2 sic1 sic2 sic3 Firmefficiency salegrowth bk_equity_at2 Risk_weeklyexdivret sp500dummy Firmsales ln_RD rdintensity_2 Capitalexpenditures intaginility_sale bk_equity_at3 Workingcapital Firmsize firm_debt sic1 rty_roa Equity_assets RDintensity ln_RD RDtosale Profitability Leverage Assetstangibility

/**firm_debt Workingcapital distinct_ub firm_debt Firmefficiency Firmsize  Leverage Equity_assets Assetstangibility   **/
gen ub_indicator=(ub_1styear_all>0)

bysort gvkey: egen min_cyear_psm=min(cyear)
bysort gvkey: egen max_cyear_psm=max(cyear)

gen firmyears=max_cyear_psm-min_cyear_psm

/*****keep unique obs for trt firms***/
duplicates drop gvkey if ub_indicator==1, force

/*********generate ubyear for doing cem for both trt(1st ub lending date) and control(cyear)****/
gen ub_year_psm=cyear
replace ub_year_psm=ub_1styear_all if ub_indicator==1


psmatch2 ub_indicator ub_year_psm firmyears sic1 Firmsize Firmsales salegrowth ln_RD  firm_debt  Leverage , logit noreplace 


count  //63270
gen pair = _id if _treated==0 
replace pair = _n1 if _treated==1
bysort pair: egen paircount = count(pair)
drop if paircount !=2
count //6008

keep gvkey cyear ub_year_psm  min_cyear_psm firmyears sic1  _id _n1 pair paircount  Firmsize ub_indicator


/****identify duplicates***********/
duplicates tag gvkey, gen(dup)
sort pair

bysor pair: egen dup_pair=sum(dup)
count if dup_pair==0
//3118
keep if dup_pair==0

codebook gvkey if ub_indicator==1  //1357
codebook gvkey if ub_indicator==0  //1357


replace ub_year_psm=0 if ub_indicator==0
bysort pair: egen ub_cutyear_psm=sum(ub_year_psm)

duplicates report gvkey
//unique 2714, not 2648

keep gvkey cyear ub_indicator ub_year_psm ub_cutyear_psm firmyears pair paircount 
rename ub_indicator ub_trt


save psm_all, replace


/*************join with master file*********/
use winsored_v6_base_2, clear
joinby gvkey using psm_all
count  //30191
keep if !missing(statecode)
count //27466

*keep gvkey cyear ub_trt ub_year_psm ub_cutyear_psm firmyears pair paircount 


/***********generate 5 year window*************/
gen psm_yeardiff=cyear-ub_cutyear_psm
gen psm_ubpost=(psm_yeardiff>=0)
count if psm_ubpost==1
//14577

bysort gvkey: egen min_cyear_psm=min(cyear)
bysort gvkey: egen max_cyear_psm=max(cyear)


gen yeardiff_min_psm=ub_cutyear_psm-min_cyear_psm
gen yeardiff_max_psm=max_cyear_psm-ub_cutyear_psm


gen window_5year_psm=(yeardiff_min_psm>=2 & yeardiff_max_psm>=2)
codebook ub_trt if window_5year_psm==1
count if window_5year_psm==1
//19429 out of 29552


sort gvkey
gen window_3year_psm=(yeardiff_min_psm>=1 & yeardiff_max_psm>=1)
count if window_3year_psm==1
//22521
tabulate ub_trt if window_3year_psm==1







tab bankyear, gen(YEAR)
/*
global firmcontrol="Firmsize salegrowth Firm_age Profitability Capitalexpenditures Firmefficiency Workingcapital  "
global capstructcontrol="Equity_assets debtrating "
global loancontrol=" Loanmaturity Loanscale Termloan Corppurpose Collateral Generalcovenants "
global dummy="YEAR* statecode"
*/

global firmcontrol="Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility "
global capstructcontrol="Equity_assets  debtrating "
global dummy="YEAR* statecode"

/****neg sig at 1% if using rbt, 10% sig if using cluster********/
areg Ln_patent i.ub_trt##i.psm_ubpost $dummy $firmcontrol  $capstructcontrol  if window_5year_psm==1,   vce(robust) absorb(sic1)
outreg2 using tableDID_v18.xls, excel tstat dec(3) replace ctitle(Ln_patent) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)
/**
xtset gvkey  cyear
xtreg Ln_patent i.ub_trt##i.psm_ubpost  $dummy $firmcontrol  $capstructcontrol  if window_5year_psm==1,   vce(robust) 
**/
/*****ub is neg sig, but ubpost and inter is insig***/
areg Ln_nonselfcitation i.ub_trt##i.psm_ubpost $dummy $firmcontrol  $capstructcontrol if window_5year_psm==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tableDID_v18.xls, excel tstat dec(3) append ctitle(Ln_cit) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)



/***********table 3. placebo： insig is good***************/
*use winsored_v6_base_2,clear
use winsored_v29_base, clear
sort gvkey 
*keep ub_year2 bankyear lenderid gvkey ub_dummy

gen t6=ub_1styear_all-6
replace t6=. if t6<0
gen yeardiff_rbt=bankyear-t6

gen ub_dummy_rbt=(yeardiff_rbt>0 & yeardiff_rbt<.)


count if ub_post_1stall ==1
/***19752***/
count if ub_dummy_rbt==1
/***29562**/

gen t1=ub_1styear_all-1
gen t11=ub_1styear_all-11

gen placebotime=(bankyear>t11 & bankyear<t1)

count if placebotime==1
/***13317**/


tab bankyear, gen(YEAR)

global firmcontrol="Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility "
global capstructcontrol="Equity_assets  debtrating "
global dummy="YEAR* statecode"
 

areg Ln_patent ub_dummy_rbt $dummy   $firmcontrol  $capstructcontrol   if placebotime==1,  vce(cluster gvkey) absorb(sic1)
outreg2 using tableplacebo_v29.xls, excel tstat dec(3)  replace ctitle(Ln_patent) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Ln_nonselfcitation  ub_dummy_rbt $dummy   $firmcontrol $capstructcontrol   if placebotime==1,  vce(cluster gvkey) absorb(sic1)
outreg2 using tableplacebo_v29.xls, excel tstat dec(3)  append ctitle(Ln_patent) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)





/***********table 3. Future innovation***************/
/**********Future values of innovation:
follow paper: "Creditor Interventions and Firm Innovation: Evidence from Debt Covenant Violations"
Gu et al. 2014***********/


*use winsored_v6_base_2,clear
use winsored_v29_base, clear



xtset gvkey bankyear
gen pat_f1=F.Ln_patent
gen cit_f1=F.Ln_nonselfcitation
gen gen_f1=F.Ln_generality 
gen orig_f1=F.Ln_originality

gen pat_f2=F2.Ln_patent
gen cit_f2=F2.Ln_nonselfcitation
gen gen_f2=F2.Ln_generality 
gen orig_f2=F2.Ln_originality

gen pat_f3=F3.Ln_patent
gen cit_f3=F3.Ln_nonselfcitation
gen gen_f3=F3.Ln_generality 
gen orig_f3=F3.Ln_originality



tab bankyear, gen(YEAR)
global firmcontrol="Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility "
global capstructcontrol="Equity_assets  debtrating "
global dummy="YEAR* statecode"
 
 

/***results are good for innovation_t+1: all neg sig!!!!***/
areg pat_f1 ub_post_1stall  $dummy $firmcontrol $capstructcontrol if sample_5yr_window==1  ,  vce(cluster gvkey) absorb(sic1)
outreg2 using tabledynamic_fwd_v29.xls, excel tstat dec(3)  replace ctitle(Patent_t1) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)
areg pat_f2 ub_post_1stall  $dummy $firmcontrol $capstructcontrol  if sample_5yr_window==1   ,  vce(cluster gvkey) absorb(sic1)
outreg2 using tabledynamic_fwd_v29.xls, excel tstat dec(3)  append ctitle(Patent_t2) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)
areg pat_f3 ub_post_1stall  $dummy $firmcontrol $capstructcontrol if sample_5yr_window==1  ,  vce(cluster gvkey) absorb(sic1)
outreg2 using tabledynamic_fwd_v29.xls, excel tstat dec(3)  append ctitle(Patent_t3) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

/** * if restrick 5 year window: sig for t+1, but insig for t+2 and t+3********/
/***all neg sig if not restrict 5 year window************/
areg cit_f1 ub_post_1stall $dummy $firmcontrol $capstructcontrol if sample_5yr_window==1  ,  vce(cluster gvkey) absorb(sic1)
outreg2 using tabledynamic_fwd_v29.xls, excel tstat dec(3)  append ctitle(Cit_t1) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)
areg cit_f2 ub_post_1stall  $dummy $firmcontrol $capstructcontrol  if sample_5yr_window==1   ,  vce(cluster gvkey) absorb(sic1)
outreg2 using tabledynamic_fwd_v29.xls, excel tstat dec(3)  append ctitle(Cit_t2) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)
areg cit_f3 ub_post_1stall  $dummy $firmcontrol $capstructcontrol  if sample_5yr_window==1   ,  vce(cluster gvkey) absorb(sic1)
outreg2 using tabledynamic_fwd_v29.xls, excel tstat dec(3)  append ctitle(Cit_t3) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)



/************************Table 4.*use R&D as DV**************/

*use winsored_v6_base_2,clear

use winsored_v29_base, clear

tab bankyear, gen(YEAR)

global firmcontrol="Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility "
global capstructcontrol="Equity_assets  debtrating "
global dummy="YEAR* statecode"


/**significant**/
areg ln_RD ub_post_1stall  $dummy $firmcontrol  $capstructcontrol if sample_5yr_window==1 ,  vce(cluster gvkey) absorb(sic1)
outreg2 using tableRD_v29.xls, excel tstat dec(3)  replace ctitle(lnRD ) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)


areg rdtoassets ub_post_1stall  $dummy $firmcontrol  $capstructcontrol if sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tableRD_v29.xls, excel tstat dec(3)  append ctitle(rdtoassets ) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

 
areg RDtosale ub_post_1stall   $dummy $firmcontrol $capstructcontrol if sample_5yr_window==1,  vce(cluster gvkey) absorb(sic1)
outreg2 using tableRD_v29.xls, excel tstat dec(3) append ctitle(RDtosale ) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)




/*****************************Table 5. innovation scope: see the other Stata code named "stata code_innovation scope_v17"********/


/********
We use a concordance table that connects most USPTO technology classes to two-digit SIC codes constructed in Hsu, Tian, and Xu (2014) to map patents in each technology class to one or multiple two-digit SIC codes. We then compute the number of related patents in a firm’s main two-digit SIC industry by multiplying patent counts with the corresponding mapping weight. We calculate the number of unrelated patents by subtracting the number of related patents from the
total number of patents a firm has in a year.
For example, 63% of USPTO technology class 1 is mapped to two-digit SIC industry 35, 32% of technology
 class 1 is mapped to two-digit SIC industry 36, and 5% of technology class 1 is mapped to two-digit SIC industry 37. 
 USPTO technology class 7 is mapped to ten two-digit SIC industries, with 13% of patents mapped to two-digit SIC industry 35. 
 Suppose that a firm’s main two-digit SIC code is 35, and it has 3 and 5 patents in USPTO technology class 1 and 7, respectively. 
 Then the number of patents that is related to this firm’s main business is calculated as
3*63%+5*13% = 2.54, and the number of patents that are not in its main business is 5.46 (= 3 + 5 – 2.54).*****/

/*******use original innovation file that hasn't delete duplicates to calcualte innovation scope******/


clear
use "D:\research\UB and innovation\code and data all_draft_v3\innovation_v3\innocount_gvkey_yr"
gen cyear=appyear
joinby gvkey cyear using gvkey_sic2
count 
keep gvkey cyear  sic2 cat nclass npat_assg_adj1 cit_adj selfcit_adj gen_pdpass orig_pdpass npat_firm_adj1 nonselfcit_pat_firm1  gen_firm orig_firm


/*************/

sort gvkey nclass

bysort nclass sic2: gen prop = _N if !missing(nclass)
by nclass: gen N=_N if !missing(nclass)
by nclass: gen pctg=prop/N

sort gvkey sic2

gen related_pat=npat_assg_adj1*pctg
replace related_pat=0 if related_pat==.

/*****related nonselfcitations*****/
gen nonself_cit=(cit_adj-selfcit_adj)/npat_assg_adj1
gen related_cit=nonself_cit*pctg
replace related_cit=0 if related_cit==.

bysort gvkey cyear: egen nonself_cit_firm=sum(nonself_cit)
bysort gvkey cyear: egen related_pat_firm=sum(related_pat)
bysort gvkey cyear: egen related_cit_firm=sum(related_cit)

gen unrelated_pat_firm=npat_firm_adj1-related_pat_firm
gen unrelated_cit_firm=nonself_cit_firm-related_cit_firm


gen related_gen=gen_pdpass*pctg
replace related_gen=0 if related_gen==.

gen related_orig=orig_pdpass*pctg
replace related_orig=0 if related_orig==.

bysort gvkey cyear: egen related_gen_firm=mean(related_gen)
bysort gvkey cyear: egen related_orig_firm=mean(related_orig)

gen unrelated_gen_firm= gen_firm-related_gen_firm
gen unrelated_orig_firm= orig_firm-related_orig_firm



/***keep unique-firm obs*****/
drop npat_assg_adj1 cit_adj selfcit_adj gen_pdpass orig_pdpass


duplicates drop gvkey cyear, force

count
//24490
keep gvkey cyear related_pat_firm related_cit_firm related_gen_firm related_orig_firm unrelated_pat_firm unrelated_cit_firm unrelated_gen_firm unrelated_orig_firm
save inno_scope, replace





/************************************************************************************/

clear
cd "D:\research\UB and innovation\data"

*use winsored_v6_base_2,clear
use winsored_v29_base, clear

joinby gvkey cyear using inno_scope, unm(master)
count if _merge==3  //24490 matched
drop _merge

replace related_pat_firm=0 if related_pat_firm==.
replace unrelated_pat_firm=0 if unrelated_pat_firm==.
replace related_cit_firm=0 if related_cit_firm==.
replace unrelated_cit_firm=0 if unrelated_cit_firm==.
replace related_gen_firm=0 if related_gen_firm==.
replace unrelated_gen_firm=0 if unrelated_gen_firm==.



/*****************use number of counts instead of log value****************/

centile related_pat_firm,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 related_pat_firm, replace cuts (1 95)
centile unrelated_pat_firm,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 unrelated_pat_firm, replace cuts (1 99)


centile related_cit_firm ,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 related_cit_firm, replace cuts (0.5 99.5)
centile unrelated_cit_firm,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 unrelated_cit_firm, replace cuts (0.5 99.5)


gen ln_rel_pat=ln(1+related_pat_firm)
gen ln_unrel_pat=ln(1+unrelated_pat_firm)
gen ln_rel_cit=ln(1+related_cit_firm)
gen ln_unrel_cit=ln(1+unrelated_cit_firm)



centile ln_rel_pat,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
centile Ln_patent,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)



/******
global firmcontrol="Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility "
global capstructcontrol="Equity_assets  debtrating "
global dummy="YEAR* statecode sic1"
tab cyear, gen(YEAR)
*use xtreg: results are all insig!*********
xtset gvkey cyear

xtreg ln_rel_pat i.ub_post_1stall $dummy $firmcontrol  $capstructcontrol if sample_5yr_window==1 ,   vce(cluster gvkey) 
xtreg ln_unrel_pat i.ub_post_1stall $dummy $firmcontrol  $capstructcontrol if sample_5yr_window==1 ,   vce(cluster gvkey) 
xtreg ln_rel_cit ub_post_1stall $dummy $firmcontrol  $capstructcontrol if sample_5yr_window==1,   vce(cluster gvkey) 
xtreg ln_unrel_cit i.ub_post_1stall $dummy $firmcontrol  $capstructcontrol if sample_5yr_window==1,   vce(cluster gvkey) 

******/



global firmcontrol="Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility "
global capstructcontrol="Equity_assets  debtrating "
global dummy="YEAR* statecode"
tab cyear, gen(YEAR)
*column 1
areg ln_rel_pat i.ub_post_1stall $dummy $firmcontrol  $capstructcontrol if sample_5yr_window==1,    vce(cluster gvkey) absorb(sic1)
outreg2 using tablescope_v29.xls, excel tstat dec(3)  replace ctitle(Related patent) nonotes bracket drop(sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

*column 2
areg ln_unrel_pat i.ub_post_1stall $dummy $firmcontrol  $capstructcontrol if sample_5yr_window==1,    vce(cluster gvkey) absorb(sic1)
outreg2 using tablescope_v29.xls, excel tstat dec(3)  append ctitle(Related patent) nonotes bracket drop(sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)


*column 3
global firmcontrol="Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility "
global capstructcontrol="Equity_assets  debtrating "
global dummy="YEAR* statecode sic1"
xtset gvkey cyear
xtreg ln_rel_cit i.ub_post_1stall $dummy $firmcontrol  $capstructcontrol if sample_5yr_window==1,    vce(cluster gvkey) 
outreg2 using tablescope_v29.xls, excel tstat dec(3)  append ctitle(Related citation) nonotes bracket drop(sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

*column 4
global firmcontrol="Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility "
global capstructcontrol="Equity_assets  debtrating "
global dummy="YEAR* statecode"
areg  ln_unrel_cit i.ub_post_1stall $dummy $firmcontrol  $capstructcontrol if sample_5yr_window==1,    vce(cluster gvkey) absorb(sic1)
outreg2 using tablescope_v29.xls, excel tstat dec(3)  append ctitle(Related citation) nonotes bracket drop(sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)








/******************************Table 6.Joint venture**********************************/
/***********************************Updated on 12/14/2017*************************************************/
/********************************Merge with SA data to get joint innavation*******************************/
/*********************************************************************************************************/

import delimited "D:\research\UB and innovation\data\SA_Participants.csv",  clear
save sa_participants, replace

*keep sadealnum partcusip
*sort partcusip

clear
use sa_participants, clear 
*duplicates report sadealnum //not unique
count if missing(partcusip)

saveold sa_part_11, version(11)


use winsored_v6_base_2,clear
saveold winsored_v6_base_2_11, version(11)
count
count if missing(cusip_6_ccm)

/*******use the file "sa_all" which is merged file of sa_date, sa_participant, and sa_flag (USE SAS)*************/
use sa_all, clear
duplicates report partcusip sa_announyear//not unique



/************updated on 12/17/2017********************/
/*********use SAS to merge these two files： the merged file is winsored_v6_base_sa***************/

/*********************Note*************************************************************************************
Focusing on technology alliances (those formed for the purposes of joint research or cross-technology transfer)
***************************************************************************************************************/



/******************************Table 6.Joint venture**********************************/
/***********************************Updated on 12/14/2017*************************************************/
/********************************Merge with SA data to get joint innavation*******************************/
/*********************************************************************************************************/

import delimited "D:\research\UB and innovation\data\SA_Participants.csv",  clear
save sa_participants, replace

*keep sadealnum partcusip
*sort partcusip

clear
use sa_participants, clear 
*duplicates report sadealnum //not unique
count if missing(partcusip)

saveold sa_part_11, version(11)


use winsored_v6_base_2,clear
saveold winsored_v6_base_2_11, version(11)
count
count if missing(cusip_6_ccm)

/*******use the file "sa_all" which is merged file of sa_date, sa_participant, and sa_flag (USE SAS)*************/
use sa_all, clear
duplicates report partcusip sa_announyear//not unique



/************updated on 12/17/2017********************/
/*********use SAS to merge these two files： the merged file is winsored_v6_base_sa***************/

/*********************Note*************************************************************************************
Focusing on technology alliances (those formed for the purposes of joint research or cross-technology transfer)
***************************************************************************************************************/

/******Updated on 3/10/2018: redefine SA dummy variables: make sure they are within 5 years window after a firm borrows from an UB***/
use winsored_v6_base_sa, clear

*keep gvkey cyear sa_announyear ub_post_1stall cusip_6_ccm partcusip technology_transfer cross_technology_transfer funding_agreement_flag rd_agreement_flag cross_licensing_agreement exploration_agreement_flag exclusive_licensing_agreement_fl  sadealnum partpsic ln_rd  ln_patent ln_nonselfcitation joint_venture_flag licensing_agreement_flag  strategic_alliance joint_venture_flag   
*keep if !missing(sadealnum)
sort sadealnum cyear
sort gvkey cyear

/****Keep the firms that borrow from UB only*******/
bysort gvkey: egen ubonly=total(ub_post_1stall)
keep if ubonly>=1

/******generate count of partners for each firms**************/
 encode partcusip, generate(part_cusip)
egen partcount=count(part_cusip), by (sadealnum cyear)
codebook partcount // [0,10] 
*egen count_part=count(part_cusip), by (gvkey cyear)
*keep gvkey cyear partcount sadealnum part_cusip joint_venture_flag  strategic_alliance rd_agreement_flag

bysort gvkey cyear: egen firm_partcount=total(partcount)


/*******generate dummy variables to indicate flags************/

gen jointven=(joint_venture_flag=="Yes") 
gen license=(licensing_agreement_flag=="Yes")
gen sa=(strategic_alliance=="Y")
gen cross_license=(cross_licensing_agreement=="Y")
gen cross_tech=(cross_technology_transfer=="Y")
gen techtransfer=(technology_transfer=="Y")
gen explo_flag=(exploration_agreement_flag=="Yes")
gen exclusive_licensing=(exclusive_licensing_agreement_fl=="Yes")
gen funding_flag=(funding_agreement_flag=="Yes")
gen rd_agree=(rd_agreement_flag=="Yes")


/***************************************************************/
bysort gvkey cyear: egen jointven_gvkey=total(jointven)
gen firm_jointven=(jointven_gvkey>=1)

bysort gvkey cyear: egen license_gvkey=total(license)
gen firm_license=(license_gvkey>=1)

bysort gvkey cyear: egen sa_gvkey=total(sa)
gen firm_sa=(sa_gvkey>=1)

bysort gvkey cyear: egen cross_tech_gvkey=total(cross_tech)
gen firm_cross_tech=(cross_tech_gvkey>=1)
bysort gvkey cyear: egen techtransfer_gvkey=total(techtransfer)
gen firm_techtransfer=(techtransfer_gvkey>=1)

bysort gvkey cyear: egen rd_agree_gvkey=total(rd_agree)
gen firm_rd_agree=(rd_agree_gvkey>=1)

bysort gvkey cyear: egen exclusive_licensing_gvkey=total(exclusive_licensing)
gen firm_exclusive_licensing=(exclusive_licensing_gvkey>=1)
bysort gvkey cyear: egen cross_license_gvkey=total(cross_license)
gen firm_cross_license=(cross_license_gvkey>=1)


drop jointven_gvkey license_gvkey  sa_gvkey cross_license_gvkey cross_tech_gvkey techtransfer_gvkey  rd_agree_gvkey exclusive_licensing_gvkey

duplicates drop gvkey cyear, force
count //39835 if keep UBfrims only/100101

count if firm_jointven==1 //4193
count if firm_license==1 //3619
count if firm_sa==1 //9441
*count if firm_cross_license==1  //89
count if firm_cross_tech==1  //1625
count if firm_techtransfer==1  //2595
gen firm_tech=(firm_cross_tech==1 |firm_techtransfer==1 )

*keep gvkey cyear sa_announyear ub_post_1stall cusip_6_ccm partcusip firm_jointven



/********************************redefine ub-dummy: during loan maturity*********************/
***round the loan maturiy to integer
gen yearmaturity=maturity/12
gen matyear=ceil(yearmaturity)

**generate loanyear_mat to represent 
gen loanyear_mat1=year_lendub1+matyear
gen loanyear_mat2=year_lendub2+matyear

bysort gvkey: egen matyear_firm1=min(loanyear_mat1)
bysort gvkey: egen matyear_firm2=min(loanyear_mat2)

replace matyear_firm1=0 if matyear_firm1==.
replace matyear_firm2=0 if matyear_firm2==.

gen matyear_firm=matyear_firm1+matyear_firm2
drop matyear_firm1 matyear_firm2


replace ub_post_1stall=0 if cyear>matyear_firm
*keep gvkey cyear ub_post_1stall  matyear_firm  matyear  ub_1styear_all 
count if ub_post_1stall ==1
//10924
count

/************************Rename control variables******************************/
/**Firmsize Firmsales Profitability  Capitalexpenditures Firmefficiency Workingcapital Assetstangibility Leverage**/

rename firmsize Firmsize
rename profitability Profitability 
rename capitalexpenditures Capitalexpenditures
rename firmefficiency Firmefficiency
rename workingcapital Workingcapital
rename assetstangibility Assetstangibility


rename firm_age Firm_age
rename salegrowth Salegrowth
rename sp500indicator debtrating

/**Equity_assets sp500indicator Public_assets Public_issue**/
rename equity_assets Equity_assets
*rename sp500indicator S&P500indicator


rename ln_patent Ln_patent
rename ln_nonselfcitation Ln_nonselfcitation



/*****replace other missing firm controls with zero to avoidtoo many missing value in the sample**********/
replace  debtrating=0 if  debtrating==.
replace  Assetstangibility=0 if   Assetstangibility==.
replace  Workingcapital=0 if   Workingcapital==.
replace  Firmefficiency=0 if   Firmefficiency==.
replace  Capitalexpenditures=0 if  Capitalexpenditures==.
replace  Profitability=0 if   Profitability==.
replace  Firmsize=0 if   Firmsize==.
replace  Salegrowth=0 if   Salegrowth==.
replace  Equity_assets =0 if   Equity_assets ==.
replace Firm_age=0 if Firm_age==.

keep if !missing(statecode)
//37085


*keep gvkey cyear ub_post_1stall firm_jointven  firm_rd_agree   ub_1styear_all   matyear year_1stublend1 year_1stublend2

/*******generate jv dummy within 5year window after firm firstly borrows from ub***************/
gen add2year= ub_1styear_all+2
gen diff2year=add2year-cyear
gen add2dummy=(diff2year<3 & diff2year>=0)


replace firm_jointven=0 if cyear<ub_1styear_all
replace firm_jointven=1 if add2dummy==1

replace firm_rd_agree=0 if cyear<ub_1styear_all
replace firm_rd_agree=1 if add2dummy==1



/**********generate yeardiff to select year window sample***********/
drop min_cyear max_cyear  yeardiff_min yeardiff_max window_5year sample_5yr_window

bysort gvkey: egen min_cyear=min(cyear)
bysort gvkey: egen max_cyear=max(cyear)

gen yeardiff_min=ub_1styear_all-min_cyear
gen yeardiff_max=max_cyear-ub_1styear_all

/*********choose sample in 5 year window************/
gen window_5year=(yeardiff_min>=2 & yeardiff_max>=2)
count if window_5year==1
gen sample_5yr_window=(window_5year==1 | ub_1styear_all==0)
count if sample_5yr_window==1 //28232



tab cyear, gen(YEAR)

global firmcontrol="Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility "
global capstructcontrol="Equity_assets  debtrating "
global dummy="YEAR* statecode sic1"

/***********************************************************************************************/
/***insig if keep nonmissing; pos sig if using the whole sample; only sig at 10% is using cluster gvkey, sig at 5% when using robust***/
probit firm_jointven  i.ub_post_1stall $dummy $firmcontrol  $capstructcontrol  if sample_5yr_window==1 ,   vce(cluster gvkey) 
outreg2 using tablejoint_v29.xls, excel tstat dec(3) replace ctitle(joint venture) nonotes bracket drop(sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)
*  Pseudo R2         =     0.3777

/*********************************************/
/****insig*****/
probit firm_rd_agree i.ub_post_1stall $dummy $firmcontrol  $capstructcontrol if  sample_5yr_window==1 ,   vce(cluster gvkey) 
outreg2 using tablejoint_v29.xls, excel tstat dec(3) append ctitle(rd agreement) nonotes bracket drop(sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

* Pseudo R2         =     0.3942




/******************************Table 7. Effect of ub on innovation under different levels of financial constraints*********/
/***************Updated on 1/27/2018: followed Lamont Polk 2001, refer to the top 33% of all firms
ranked on the KZ index as "constrained", and the bottom 33% as "unconstrained"************/
*use winsored_v6_base_2,clear

use winsored_v29_base, clear
joinby gvkey cyear using "D:\Research\control var_code_all\data\finrestric", unm(master)

drop _merge
joinby gvkey cyear using altman_z, unm(master)
drop _merge

replace altman_z=0 if altman_z==.
replace kzindex=0 if kzindex==.
replace saindex=0 if saindex==.
replace struc_index2=0 if struc_index2==.



centile struc_index2,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 struc_index2, replace cuts (5 90)

centile kzindex,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 kzindex, replace cuts (5 90)
/***
centile altman_z,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 altman_z, replace cuts (5 90)

centile saindex,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 saindex, replace cuts (5 95)
***/


egen all_kz=sum(kzindex), by (cyear)
gen pct_kz=100*kzindex/all_kz


egen low_kz =pctile(pct_kz), p(33)
egen high_kz =pctile(pct_kz), p(67)

gen top_kz=(pct_kz>=high_kz)
gen bottom_kz=(pct_kz<=low_kz)



tab cyear, gen(YEAR)

global firmcontrol="Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility "
global capstructcontrol="Equity_assets  debtrating "
global dummy="YEAR* statecode "


areg Ln_patent ub_post_1stall $dummy $firmcontrol  $capstructcontrol if top_kz==1 & sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefincon_topbotm_v29.xls, excel tstat dec(3) replace ctitle(Ln_patent_top_kz) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Ln_nonselfcitation ub_post_1stall $dummy $firmcontrol  $capstructcontrol if top_kz==1 & sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefincon_topbotm_v29.xls, excel tstat dec(3) append ctitle(Ln_citation_top_kz) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Ln_patent ub_post_1stall $dummy $firmcontrol  $capstructcontrol if bottom_kz==1 & sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefincon_topbotm_v29.xls, excel tstat dec(3) append ctitle(Ln_patent_bottom_kz) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Ln_nonselfcitation ub_post_1stall $dummy $firmcontrol  $capstructcontrol if bottom_kz==1 & sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefincon_topbotm_v29.xls, excel tstat dec(3) append ctitle(Ln_citation_bottom_kz) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)


/*****
egen all_sa=sum(saindex), by (cyear)
gen pct_sa=100*saindex/all_sa

egen low_sa =pctile(pct_sa), p(33)
egen high_sa =pctile(pct_sa), p(67)

gen top_sa=(pct_sa>=high_sa)
gen bottom_sa=(pct_sa<=low_sa)

areg Ln_patent ub_post_1stall $dummy $firmcontrol  $capstructcontrol if top_sa==1 & sample_5yr_window==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefincon_topbotm_v18.xls, excel tstat dec(3) append ctitle(Ln_patent_top_sa) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)
areg Ln_nonselfcitation ub_post_1stall $dummy $firmcontrol  $capstructcontrol if top_sa==1 & sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefincon_topbotm_v18.xls, excel tstat dec(3) append ctitle(Ln_citation_top_sa) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Ln_patent ub_post_1stall $dummy $firmcontrol  $capstructcontrol if bottom_sa==1 & sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefincon_topbotm_v18.xls, excel tstat dec(3) append ctitle(Ln_patent_bottom_sa) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Ln_nonselfcitation ub_post_1stall $dummy $firmcontrol  $capstructcontrol if bottom_sa==1 & sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefincon_topbotm_v18.xls, excel tstat dec(3) append ctitle(Ln_citation_bottom_sa) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)
*****/


egen all_struc=sum(struc_index2), by (cyear)
gen pct_struc=100*struc_index2/all_struc

egen low_struc =pctile(pct_struc), p(33)
egen high_struc =pctile(pct_struc), p(67)

gen top_struc=(pct_struc>=high_struc)
gen bottom_struc=(pct_struc<=low_struc)


areg Ln_patent ub_post_1stall $dummy $firmcontrol  $capstructcontrol if top_struc==1 & sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefincon_topbotm_v29.xls, excel tstat dec(3) append ctitle(Ln_patent_top_struc) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Ln_nonselfcitation ub_post_1stall $dummy $firmcontrol  $capstructcontrol if top_struc==1 & sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefincon_topbotm_v29.xls, excel tstat dec(3) append ctitle(Ln_citation_top_struc) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Ln_patent ub_post_1stall $dummy $firmcontrol  $capstructcontrol if bottom_struc==1 & sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefincon_topbotm_v29.xls, excel tstat dec(3) append ctitle(Ln_patent_bottom_struc) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Ln_nonselfcitation ub_post_1stall $dummy $firmcontrol  $capstructcontrol if bottom_struc==1 & sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefincon_topbotm_v29.xls, excel tstat dec(3) append ctitle(Ln_citation_bottom_struc) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)








