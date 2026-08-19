

/*****Project: Wrongful discharge law and banking power*****/
/*****Test for baseline regression by using 3 samples that contain three WDLs one at each time****/

/******Sample spanning from 1976 to 2007***********************/
/*****Test for baseline regression by using 3 samples that contain three WDLs one at each time****/
/*****Add region and time dummies: reference paper: RFS2013, WDL and innovation
/****Revise on 9/12/2017: use different method to set year window************/

As in Autor, Donohue, and Schwab (2006), we also control for regional time trends through the interaction
 of region dummies with year dummies (βr ×βt ). We include these region-specific time trends to control for potential sources 
 of endogeneity in the passage ofWDL. First, Autor, Donohue, and Schwab (2004) point out that the Southern states lagged behind the non-Southern 
 states in enacting these laws. Furthermore, over the time period 1940–2000, the Southern states lagged behind non-Southern states in filing patents.
 Second, the adoption of the good-faith exception—the main focus ofour theory and empirical tests—
was more common in the West, particularly the North-Western U.S. region.

****/

/*******created date: 4/3/2017**********/
/*******last updated date: 2/15/2018******/


/****Note: in V5, I include the following controls:log_asset MS sec hhiloan er top enforceability_score **/
/****Include BR_index when I test for the deregualtion effects********/

/*****Need: Add unionization as control variable*********/



set matsize 10000

set more off
clear
cd "D:\research\Wrongful discharge\update_v5"
use "D:\Research\Wrongful discharge\data_updated02182017\CB_lerner_WDL", clear


/***************************************************************************************/
/******************************Winsorize data ***************************/
/***************************************************************************************/

use CB_lerner_WDL, clear
/****(1)*******/
*tabstat log_size, stat(n mean sd min p25 median p75 max) col(stat)
*centile log_size, centile(1 5 10 50 95 99)
winsor2 log_size, replace cuts(1 99)

/****(2)******/
*tabstat llr,stat(n mean sd min p5 p25 median p75 p95 max) col(stat)
*centile llr, centile(1 5 10 50 95 99)
winsor2 llr, replace cuts(1 99)

/****(3)******/
*tabstat er, stat(n mean sd min p25 median p75 max) col(stat)
*centile er, centile(1 5 10 50 95 99)
winsor2 er, replace cuts(1 99)

/****(4)******/
*tabstat inc, stat(n mean sd min p5 p25 median p75 p95 max) col(stat)
*centile inc, centile(1 5 10 50 95 99)
winsor2 inc, replace cuts(1 99)

/****(5)******/
*tabstat llp_totloan, stat(n mean sd min p25 median p75 max) col(stat)
*centile  llp_totloan, centile(1 5 10 50 95 99)
winsor2  llp_totloan, replace cuts(5 95)

/****(6)******/
*tabstat hhiloan, stat(n mean sd min p25 median p75 p95 max) col(stat)
*centile  hhiloan, centile(1 5 10 50  80 85 90 95 99)
winsor2  hhiloan, replace cuts(1 80)

/****(7)******/
*tabstat roa, stat(n mean sd min p25 median p75 max) col(stat)
*centile  roa, centile(1 5 10 50 95 99)
winsor2  roa, replace cuts(1 99)

/****(8)*****/
*tabstat MS, stat(n mean sd min p25 median p75 p95 max) col(stat)
*centile  MS, centile(1 5 10 50 95 96 98 99)
winsor2  MS, replace cuts(1 95)


/******(9) For bank efficiency and lerner *****/
*tabstat CE, stat(n mean sd min p25 median p75 max) col(stat)
*centile CE, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 95 99)
winsor2 CE, replace cuts(1 99)


*tabstat PE, stat(n mean sd min p25 median p75 max) col(stat)
*centile PE, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 95 99)
winsor2 PE, replace cuts(1 99)

*tabstat L_OLS, stat(n mean sd min p5 p25 median p75 p95 max) col(stat)
*centile L_OLS, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 95 99)
winsor2 L_OLS, replace cuts(5 95)

*tabstat L_SFA, stat(n mean sd min p5 p25 median p75 p95 max) col(stat)
*centile L_SFA, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 95 99)
winsor2 L_SFA, replace cuts(5 95)


/*****For other control variables**********/
winsor2 l_ta, replace cuts(1 99)
winsor2 roe, replace cuts(1 99)
winsor2 LLP,  replace cuts(1 99)

winsor2 HHI_loan, replace cuts (1 99)
winsor2 HHI_deposit, replace cuts (1 99)

/*****for labor variables****/
*centile w2, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 95 99)
winsor2 w2, replace cuts (10 99)
*centile x2, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 95 99)
winsor2 w2, replace cuts (10 99)


/*****for risk measures*****/
winsor2 sd_roa, replace cuts (1 99)
winsor2 sd_roe, replace cuts (1 99)
winsor2 chgs_ta, replace cuts (1 99)
winsor2 eq_ta, replace cuts (1 99)
winsor2 pf_tl, replace cuts (1 99)
winsor2 eq_rta, replace cuts (1 99)
winsor2 chdp_ta, replace cuts (1 99)
winsor2 pf_ta, replace cuts (1 99)




/**********keep sample date range*******/
keep if bankyear>=1976 & bankyear<2008
count
//N=278161； 337210 if 【1976 2008】


/***
Add more control variable: 

top=indicator equal to 1 if the bank is among the 100 larget banks measured in total assets in the country in a given year***/
gsort bankyear -totassets 
*keep bankyear rssd9001 totassets
by bankyear: gen top=(_n<=100)


/*****Generate scaled labor costs(x2: number of employees)*****/
gen x2_size=x2/totassets


/************Set Year windows*******************/
bysort rssd9001: egen min_year=min(bankyear)
bysort rssd9001: egen max_year=max(bankyear)

/******for C:***********/
*keep rssd9001 bankyear L_SFA ImpliedcontractC  C_dummy

replace ImpliedcontractC=0 if ImpliedcontractC==.

gen yeardiff_min_C=ImpliedcontractC-min_year
gen yeardiff_max_C=max_year-ImpliedcontractC

/*********choose sample in 5 year window************/
gen window_5year_C=(yeardiff_min_C>=2 & yeardiff_max_C>=2)
count if window_5year_C==1
//198295
gen sample_5yr_window_C=(window_5year_C==1 | ImpliedcontractC==0)
count if sample_5yr_window_C==1 
//239542



/********For G****************/
replace GoodfaithG=0 if GoodfaithG==.

gen yeardiff_min_G=GoodfaithG-min_year
gen yeardiff_max_G=max_year-GoodfaithG

/*********choose sample in 5 year window************/
gen window_5year_G=(yeardiff_min_G>=2 & yeardiff_max_G>=2)
count if window_5year_G==1
//21377
gen sample_5yr_window_G=(window_5year_G==1 | GoodfaithG==0)
count if sample_5yr_window_G==1 



/********For P*****************/

replace PublicpolicyP=0 if PublicpolicyP==.

gen yeardiff_min_P=PublicpolicyP-min_year
gen yeardiff_max_P=max_year-PublicpolicyP

/*********choose sample in 5 year window************/
gen window_5year_P=(yeardiff_min_P>=2 & yeardiff_max_P>=2)
count if window_5year_P==1
//208,017
gen sample_5yr_window_P=(window_5year_P==1 | PublicpolicyP==0)
count if sample_5yr_window_P==1 
// 250,614




/***************Results for v5*************/
/**************Note: test interaction of i.C_dummy##c.enforceability_score： results are insignificant, so don't report***************
*************/

/******Table 1: Summary Statistics *****/
tabstat L_SFA PE CE C_dummy G_dummy P_dummy log_asset MS sec hhiloan er top log_zscore sd_roa sd_roe w2 x2_size roa roe, stat  (n mean sd  p5 median p95  ) col(stat)


/******Table 2: The effects of WDLs on banking power *****/
/******Add enforceability_score************/
global Bankcharacteristics=" log_asset MS sec hhiloan er top enforceability_score "
global dummy="YEAR* statecode"

*column1
areg L_SFA C_dummy  i.region_dummy##i.YEAR* $Bankcharacteristics $dummy  if sample_5yr_window_C==1 ,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable2.xls, excel tstat dec(3) replace ctitle(C_L ) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)

*column2
areg L_SFA G_dummy  i.region_dummy##i.YEAR* $Bankcharacteristics $dummy  if sample_5yr_window_G==1 ,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable2.xls, excel tstat dec(3) append ctitle(G_L ) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)

*column3
areg L_SFA P_dummy  i.region_dummy##i.YEAR* $Bankcharacteristics $dummy  if sample_5yr_window_P==1 ,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable2.xls, excel tstat dec(3) append ctitle(P_L ) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)



/******Table 3: The effects of WDLs on profit efficiency*****/
*column1
areg PE C_dummy   i.region_dummy##i.YEAR* $Bankcharacteristics $dummy if sample_5yr_window_C==1 ,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable3.xls, excel tstat dec(3) replace ctitle(C_PE ) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)
*column2
areg PE G_dummy   i.region_dummy##i.YEAR* $Bankcharacteristics $dummy if sample_5yr_window_G==1 ,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable3.xls, excel tstat dec(3) append ctitle(G_PE ) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)
*column3
areg PE P_dummy   i.region_dummy##i.YEAR* $Bankcharacteristics $dummy if sample_5yr_window_P==1 ,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable3.xls, excel tstat dec(3) append ctitle(P_PE ) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)
*column4
areg CE C_dummy  i.region_dummy##i.YEAR*  $Bankcharacteristics $dummy  if sample_5yr_window_C==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable3.xls, excel tstat dec(3) append ctitle(C_CE ) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)
*column5
areg CE G_dummy  i.region_dummy##i.YEAR*  $Bankcharacteristics $dummy  if sample_5yr_window_G==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable3.xls, excel tstat dec(3) append ctitle(G_CE ) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)
*column6
areg CE P_dummy  i.region_dummy##i.YEAR*  $Bankcharacteristics $dummy  if sample_5yr_window_P==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable3.xls, excel tstat dec(3) append ctitle(P_CE ) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)


/******Table 4: The effects of WDLs on profitabilty*****/

*column1
areg roa C_dummy  i.region_dummy##i.YEAR* $Bankcharacteristics $dummy if sample_5yr_window_C==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable4.xls, excel tstat dec(4) replace ctitle(C_roa) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)
*column2
areg roa G_dummy  i.region_dummy##i.YEAR* $Bankcharacteristics $dummy if sample_5yr_window_G==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable4.xls, excel tstat dec(4) append ctitle(G_roa) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)
*column3
areg roa P_dummy  i.region_dummy##i.YEAR* $Bankcharacteristics $dummy if sample_5yr_window_P==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable4.xls, excel tstat dec(4) append ctitle(P_roa) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)

*column4
areg roe C_dummy  i.region_dummy##i.YEAR* $Bankcharacteristics $dummy if sample_5yr_window_C==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable4.xls, excel tstat dec(4) append ctitle(C_roe) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)
*column5
areg roe G_dummy  i.region_dummy##i.YEAR* $Bankcharacteristics $dummy if sample_5yr_window_G==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable4.xls, excel tstat dec(4) append ctitle(G_roe) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)
*column6
areg roe P_dummy  i.region_dummy##i.YEAR* $Bankcharacteristics $dummy if sample_5yr_window_P==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable4.xls, excel tstat dec(4) append ctitle(P_roe) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)



/******Table 5: The effects of WDLs on labor costs*****/
/***Note: w2 is price of labor per TA: pos sig***/
*column1
areg w2 C_dummy  i.region_dummy##i.YEAR*   $Bankcharacteristics $dummy if sample_5yr_window_C==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable5.xls, excel tstat dec(4) replace ctitle(C_w2) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)
*column2
areg w2 G_dummy  i.region_dummy##i.YEAR*   $Bankcharacteristics $dummy if sample_5yr_window_G==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable5.xls, excel tstat dec(4) append ctitle(G_w2) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)
*column3
areg w2 P_dummy  i.region_dummy##i.YEAR*   $Bankcharacteristics $dummy if sample_5yr_window_P==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable5.xls, excel tstat dec(4) append ctitle(P_w2) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)

*column4
areg  x2_size C_dummy i.region_dummy##i.YEAR* $Bankcharacteristics $dummy if sample_5yr_window_C==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable5.xls, excel tstat dec(4) append ctitle(C_x2_size) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)
*column5
areg  x2_size G_dummy i.region_dummy##i.YEAR* $Bankcharacteristics $dummy if sample_5yr_window_G==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable5.xls, excel tstat dec(4) append ctitle(G_x2_size) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)
*column6
areg  x2_size P_dummy i.region_dummy##i.YEAR* $Bankcharacteristics $dummy if sample_5yr_window_P==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable5.xls, excel tstat dec(4) append ctitle(P_x2_size) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)



/*****Table 6: The effects of WDLs on bank risk taking*****/
*column1
areg log_zscore  C_dummy  i.region_dummy##i.YEAR*  $Bankcharacteristics $dummy if sample_5yr_window_C==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable6.xls, excel tstat dec(4) replace ctitle(C_zscore) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)

*column2
areg log_zscore  G_dummy  i.region_dummy##i.YEAR*  $Bankcharacteristics $dummy if sample_5yr_window_G==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable6.xls, excel tstat dec(4) append ctitle(G_zscore) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)

*column3
areg log_zscore  P_dummy  i.region_dummy##i.YEAR*  $Bankcharacteristics $dummy if sample_5yr_window_P==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable6.xls, excel tstat dec(4) append ctitle(P_zscore) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)

*column4
areg sd_roa C_dummy  i.region_dummy##i.YEAR*  $Bankcharacteristics $dummy if sample_5yr_window_C==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable6.xls, excel tstat dec(4) append ctitle(C_sdroa) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)

*column5
areg  sd_roa G_dummy  i.region_dummy##i.YEAR*  $Bankcharacteristics $dummy if sample_5yr_window_G==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable6.xls, excel tstat dec(4) append ctitle(G_sdroa) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)

*column6
areg sd_roa P_dummy  i.region_dummy##i.YEAR*  $Bankcharacteristics $dummy if sample_5yr_window_P==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable6.xls, excel tstat dec(4) append ctitle(P_sdroa) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)

*column7
areg sd_roe C_dummy   i.region_dummy##i.YEAR*  $Bankcharacteristics $dummy if sample_5yr_window_C==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable6.xls, excel tstat dec(4) append ctitle(C_sdroe) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)

*column8
areg sd_roe G_dummy   i.region_dummy##i.YEAR*  $Bankcharacteristics $dummy if sample_5yr_window_G==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable6.xls, excel tstat dec(4) append ctitle(G_sdroe) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)

*column9
areg sd_roe P_dummy   i.region_dummy##i.YEAR*  $Bankcharacteristics $dummy if sample_5yr_window_P==1,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable6.xls, excel tstat dec(4) append ctitle(P_sdroe) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)



/*****Table 7: The effects of WDLs on banking power *****/
global Bankcharacteristics=" log_asset MS sec hhiloan er top enforceability_score BR_index"
global dummy="YEAR* statecode"


/***********Test the interaction of WDL*deregulation***********/
/****pos sig***/
areg L_SFA i.C_dummy##i.inter_dummy   i.region_dummy##i.YEAR* $Bankcharacteristics $dummy  if sample_5yr_window_C==1 ,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable7.xls, excel tstat dec(3) replace ctitle(C_inter) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)
areg L_SFA i.C_dummy##i.intra_dummy   i.region_dummy##i.YEAR* $Bankcharacteristics $dummy  if sample_5yr_window_C==1 ,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable7.xls, excel tstat dec(3) append ctitle(C_intra) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)
/**
areg CE i.C_dummy##i.inter_dummy   i.region_dummy##i.YEAR* $Bankcharacteristics $dummy  if sample_5yr_window==1 ,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tablebaseC_v5.xls, excel tstat dec(3) append ctitle(CE_G_inter) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)
areg CE i.C_dummy##i.intra_dummy   i.region_dummy##i.YEAR* $Bankcharacteristics $dummy  if sample_5yr_window==1 ,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tablebaseC_v5.xls, excel tstat dec(3) append ctitle(CE_G_intra) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)

areg PE i.C_dummy##i.inter_dummy   i.region_dummy##i.YEAR* $Bankcharacteristics $dummy  if sample_5yr_window==1 ,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tablebaseC_v5.xls, excel tstat dec(3) append ctitle(PE_G_inter) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)
areg PE i.C_dummy##i.intra_dummy   i.region_dummy##i.YEAR* $Bankcharacteristics $dummy  if sample_5yr_window==1 ,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tablebaseC_v5.xls, excel tstat dec(3) append ctitle(PE_G_intra) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)
****/


areg L_SFA i.G_dummy##i.inter_dummy   i.region_dummy##i.YEAR* $Bankcharacteristics $dummy  if sample_5yr_window_G==1 ,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable7.xls, excel tstat dec(3) append ctitle(G_inter) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)
areg L_SFA i.G_dummy##i.intra_dummy   i.region_dummy##i.YEAR* $Bankcharacteristics $dummy  if sample_5yr_window_G==1 ,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable7.xls, excel tstat dec(3) append ctitle(G_intra) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)


areg L_SFA i.P_dummy##i.inter_dummy   i.region_dummy##i.YEAR* $Bankcharacteristics $dummy  if sample_5yr_window_P==1 ,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable7.xls, excel tstat dec(3) append ctitle(P_inter) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)
areg L_SFA i.P_dummy##i.intra_dummy   i.region_dummy##i.YEAR* $Bankcharacteristics $dummy  if sample_5yr_window_P==1 ,  vce(cluster statecode) absorb(rssd9001)
outreg2 using tabletable7.xls, excel tstat dec(3) append ctitle(P_intra) nonotes   bracket drop(YEAR*  ) addtext(Year FE,Yes, State FE, Yes)


/***
global Bankcharacteristics=" log_asset MS sec hhiloan er top enforceability_score "
global dummy="YEAR* statecode"

/****interation:pos sig***/
areg L_SFA i.C_dummy##c.BR_index   i.region_dummy##i.YEAR* $Bankcharacteristics $dummy  if sample_5yr_window_C==1 ,  vce(cluster statecode) absorb(rssd9001)
areg L_SFA i.G_dummy##c.BR_index   i.region_dummy##i.YEAR* $Bankcharacteristics $dummy  if sample_5yr_window_C==1 ,  vce(cluster statecode) absorb(rssd9001)
***/




