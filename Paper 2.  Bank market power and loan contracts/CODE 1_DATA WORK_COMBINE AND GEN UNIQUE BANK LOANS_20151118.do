
/*Project:  Cost of bank Loan and Lerner index ***/


/*****PART 1. generate mean, med, max and weighted average of adjested lerner indes for at facility level; combine with original lernerloan data********/
/*****PART 2. generate SIC-based  total risk, idio risk,  accounting based risk and RD intensity; combine with original lernerloan data**********/
/*****PART 3. combine HHI data to newlernerloan*******/
/*****PART 4. generate number of loans in the past 3 or 5 years from # of unique banks****/
 

/*code by Xinting Zhen*/
/*created: 11/16/2015*/
/*last edited date: 11/19/2015*/
 
 
 

**************************************PART 1. GEN MEAN, MED AND WEIGHTED AVERAGE OF ADJUSTED LERNER****************************************

clear
set more off
 cd "D:\Research\lernerloan\newreg"
use lernerloan
//12115


collapse (mean) ma_l_sfa=l_sfa ma_l_ols=l_ols (max) max_l_sfa=l_sfa max_l_ols=l_ols (median) med_l_sfa=l_sfa med_l_ols=l_ols (sum) sum_l_sfa=l_sfa sum_l_ols=l_ols ,  by (facilityid cyear)
save collapse, replace


use lernerloan
sort facilityid cyear
joinby facilityid cyear using collapse, unm (master)
drop _merge
save newlernerloan, replace

clear
use newlernerloan
sort facilityid cyear
 by facilityid cyear: gen wa_l_sfa=l_sfa/sum_l_sfa
by facilityid cyear: gen wa_l_ols=l_sfa/sum_l_ols

save  newlernerloan, replace




/***set subsample for largest lead share****/
clear
use newlernerloan
collapse (sum) sum_leadshare=bankallocation,  by (facilityid cyear)
save sum_leadshare, replace
duplicates report facilityid cyear

clear
 use newlernerloan
joinby facilityid cyear using sum_leadshare, unm(master)
drop _merge
save newlernerloan, replace

 gen leadshare=bankallocation/sum_leadshare
replace leadshare = 0 if (leadshare >= .)
egen maxleadshare = max(leadshare), by (facilityid cyear)

/*generate dummy variable for the largest share of leadbanks*/
gen largestleadshare = (maxleadshare>0)
save newlernerloan, replace




/*********************PART 2. GEN SIC-BASED total risk, idio risk,  accounting based risk and RD intensity**************/

clear 
use risk_measures
duplicates report gvkey year

clear
use wrds_zip
duplicates report gvkey fyear
duplicates drop gvkey fyear, force
keep gvkey fyear fyr
sort gvkey fyear
/*bysort gvkey fyear: gen gvseq=_n*/
/*drop if gvseq>1*/



gen cyear=fyear
replace cyear=fyear+1 if fyr<6
save gvcyear, replace
///311853 obs

clear 
use risk_measures
duplicates report cusip9 year
/***not unique**/
duplicates report gvkey year
/***not unique**/
count
//506970 obs
codebook gvkey fyear


joinby gvkey fyear using gvcyear, unm (master)
//only 309305 obs matched*/
/*keep gvkey fyear cyear fyr*/
save risk_measures_new, replace
 
 
 /*******************GEN SIC BASED (AND FIRM LEVEL)TOT RISK, IDIO RISK, ACCOUNTING RISK AND OTHER RISKS**********/
clear
use risk_measures_new

/**firm level***/

sort gvkey cyear

collapse (mean) mean2tvxd=tvxd mean2tvdd=tvdd mean2tvxw=tvxw mean2tvdw=tvdw meanriy_rd=riy_rd meanivxd=ivxd_2_J1 ////
  meanivxw=ivxw_2_J1  meanrty_roa=rty_roa meanrty_roe=rty_roe (median) med2tvxd=tvxd med2tvdd=tvdd med2tvxw=tvxw ///
  med2tvdw=tvdw medriy_rd=riy_rd medivxd=ivxd_2_J1  medivxw=ivxw_2_J1 medrty_roa=rty_roa medrty_roe=rty_roe, by (gvkey cyear) cw
duplicates report gvkey cyear
/***gvkey cyear are unique**/
save risk_firm, replace


/***industry level***/
clear
use risk_measures_new

collapse (mean) meantvxd_sic=tvxd meantvdd_sic=tvdd meantvxw_sic=tvxw meantvdw_sic=tvdw meanriy_rd_sic=riy_rd meanivxd_sic=ivxd_2_J1  meanivxw_sic=ivxw_2_J1  meanrty_roa_sic=rty_roa meanrty_roe_sic=rty_roe ///
meanriy_ppe_sic=riy_ppe meanriy_capexp_sic=riy_capexp meanriy_debtmat_sic=riy_debtmat ///
 (median) medtvxd_sic=tvxd medtvdd_sic=tvdd medtvxw_sic=tvxw medtvdw_sic=tvdw medriy_rd_sic=riy_rd medivxd_sic=ivxd_2_J1  medivxw_sic=ivxw_2_J1 medrty_roa_sic=rty_roa medrty_roe_sic=rty_roe ///
medriy_ppe_sic=riy_ppe medriy_capexp_sic=riy_capexp medriy_debtmat_sic=riy_debtmat  , by (siccd cyear) cw


destring siccd, replace
gen str4 siccd4=string(siccd, "%04.0f")
rename siccd4 borrsic4
save risk_sic, replace

clear
 use risk_sic
duplicates report borrsic4 cyear
/////13265 obs, unique for borrsic4 cyear
clear
use newlernerloan
joinby borrsic4 cyear using risk_sic, unm(master)
save newlernerloan_risksic, replace

clear
use newlernerloan_risksic, replace
drop _merge
joinby gvkey cyear using risk_firm, unm(master)
save newlernerloan_risksic, replace


clear
use newlernerloan_risksic, replace
duplicates drop facilityid cyear, force
count
save newlernerloan_dupdrop, replace


/*******************************PART 3. combine HHI data to newlernerloan********************************/
/*****Name combined data as "newlernerloan_hhi"***************/

/****the newest version of combining data*************/

clear
 use newlernerloan_dupdrop
gen zip5=substr(zipcode,1,5)
count
///9981 obs
save newlernerloan_dupdrop, replace


  clear
  use convertlmafipszip
  tostring zip, replace
  /**
  gen zipcode=substr(zip,1,5)
  destring zipcode, replace
  gen str5 zip5=string(zipcode, "%05.0f")
  ***/
  tostring fips,replace
  save lmafipszip, replace
  sort zip5 fips
  duplicates report zip5 fips
  /*54163 obs*/
  /**zip5 fips are unique*/
   keep zip zip5 fips lma st
  sort fips zip5
  save lmafipszip, replace
  
  clear
  use lmafipszip
    duplicates report zip5
	/** duplicates drop zip5, force**/
	 ///41811 obs
	 save lmafipszip, replace
	 //54163
	 
	
  clear
   use newlernerloan_dupdrop
   drop _merge
   joinby zip5 using lmafipszip, unm(master)
   save newlernerloan_fips, replace
   duplicates report zip5 fips
   count
   ///11601 obs**
   ///zip5 fips not unique
   
   
   
   
   clear
set more off
 cd "D:\Research\lernerloan\newreg"
 use stcnty_competition
 sort stcntybr year
 tostring stcntybr, replace
 destring stcntybr, replace
gen str5 fips=string(stcntybr, "%05.0f")
 rename year cyear
 save fipshhi, replace
   
 duplicates report fips cyear
 /*67355 obs*/
 /**fips cyear are unique**/
  
  
  clear
  use newlernerloan_fips
  tostring fips, replace
  drop _merge
  joinby fips cyear using fipshhi, unm(master)
  count
  //**11601**
  
  duplicates drop facilityid cyear, force
  count
  /***9981*/
  save newlernerloan_hhi, replace
  
  
  
  /***********************************PART 4. GENERATE number of loans in the past 3 or 5 years from # of unique banks******/
  
 clear
  cd "D:\Research\lernerloan\newreg\dealscan_need"
  use facility
  codebook facilityid
  duplicates report facilityid
  count
  ///295484
  /****facilityid is unique ****/
  /***file "facility"contains facilityid borrowercompanyid*****/
  
  clear
   cd "D:\Research\lernerloan\newreg\dealscan_need"
  use lendershares
  rename companyid lenderid
  sort facilityid 
  codebook facilityid
   duplicates report facilityid
   count
   ///1619811
    /****facilityid is not unique ****/
  /***file "lendershares" contains facilityid lenderid(shows as companyid in the source***/
  
  
  /*****join lendershares with facility by using unique facilityid in facility*****/
  
 clear
 use lendershares
 joinby facilityid using facility, unm(master)
 count
 ///1619811
  rename companyid lenderid
 keep facilityid lenderid bankallocation leadarrangercredit borrowercompanyid facilitystartdate facilityenddate loantype facilityamt
  save dealscan_BL, replace

  
  
  clear
   cd "D:\Research\lernerloan\newreg\dealscan_need"
   use dealscan_BL
  gen loanyear=year(facilitystartdate)
tostring lenderid, replace
tostring borrowercompanyid, replace
gen BL_id=borrowercompanyid+lenderid
rename loanyear BL_id_date
count
 ///1619811
 save BL_id, replace
sort borrowercompanyid  
 
  
	 clear
  cd "D:\Research\lernerloan\newreg"
	use newlernerloan_hhi
	duplicates report facilityid
	keep facilityid lenderid borrowercompanyid cyear 
	////9981: facilityid is unique****/
	tostring lenderid, replace
    tostring borrowercompanyid, replace
    gen BL_id=borrowercompanyid+lenderid
	save lerner_BL, replace
	
	
	
	
 clear
   cd "D:\Research\lernerloan\newreg"
    use BL_id
   keep facilityid lenderid borrowercompanyid BL_id_date BL_id
   sort facilityid BL_id_date
  /******facilityid is not unique in the dealscan BF combined data****/
  sort borrowercompanyid BL_id_date
  
  duplicates drop borrowercompanyid BL_id_date, force
  ///165440
 /* duplicates drop facilityid BF_id_date, force
  ///291702
  */
  save BL_id_borruniqe, replace
  
  /*****join lernerloan with dealscan BF combination data by using unique borrower****/
  /***since the goal is to see the Bank_firm at borrower level, so should match by using borrowerid****/
  clear
  use lerner_BL
  joinby borrowercompanyid using BL_id_borruniqe , unm(master)
  count
  ///73388
  save lerner_BL_dealscan, replace
  
  
  clear
  use lerner_BL_dealscan
  drop _merge
  
  /*****generate BF combination with 3 year and 5 years window****/
gen BL_id_3yr=BL_id if (abs(BL_id_date-cyear)>=0 & abs(BL_id_date-cyear)<=3)
gen BL_id_5yr=BL_id if (abs(BL_id_date-cyear)>=0 & abs(BL_id_date-cyear)<=5)
save BL_id_yrwindow, replace
sort borrowercompanyid

/****calculate number of loans in the past 3 or 5 years from # of unique banks****/
clear
use BL_id_yrwindow


/****with 3 years window*****/
sort BL_id_3yr
by BL_id_3yr:gen order=_n 
destring BL_id_3yr, replace
replace order=0 if ( BL_id_3yr>= .)

by BL_id_3yr (order), sort:gen uniqueBL_3yr=_n==1
sort borrowercompanyid
by borrowercompanyid: gen n_uniqueBL__3yr=sum(uniqueBL_3yr)


/****with 5 years window*****/
sort BL_id_5yr
by BL_id_5yr:gen order5=_n 
destring BL_id_5yr, replace
replace order5=0 if ( BL_id_5yr>= .)

by BL_id_5yr (order5), sort:gen uniqueBL_5yr=_n==1
sort borrowercompanyid
by borrowercompanyid: gen n_uniqueBL__5yr=sum(uniqueBL_5yr)

save BL_n_uniquel, replace
count
///73388


/*****keep unique facilityid cyear*****/
clear
use  BL_n_uniquel
keep facilityid lenderid borrowercompanyid cyear BL_id BL_id_date n_uniqueBL__3yr n_uniqueBL__5yr

duplicates drop facilityid cyear, force
count
///9981
save lerner_BL_unique, replace


/*****join lerner_BL_unique with lernerloan data**************/
clear
use newlernerloan_hhi
drop _merge
joinby facilityid cyear using lerner_BL_unique, unm(master)
save lernerloan_all, replace

  

  
  
  /***
   use newlernerloan
//***keep if mainsample==1
//***count 
///12115 observations///

/*observe the relaitonship among facilityid, lenderid and borrowercompanyid*/
sort facilityid lenderid
by facilityid (lenderid), sort: gen diff=lenderid[1]!=lenderid[_N]
keep facilityid lenderid borrowercompanyid diff
save lenderborr, replace

  
  ***/
