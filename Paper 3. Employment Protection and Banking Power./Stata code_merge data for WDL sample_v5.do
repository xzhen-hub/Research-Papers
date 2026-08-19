
/*****Project: Wrongful discharge law and banking power*****/
/*****Merge data files to prepare for WDL data sample ****/
/*****Coded by Xinting Zhen**************/
/*****Created date: 4/6/2017*************/
/*****Last updated date: 2/14/2018************/

/***************************************DATA Sample preparation*******************************************************/
/*******Note: in this version, I didn't include the old way to generate data sample (which require continuous 5 year window)****/
/*******files needed:
          statecode: state brief names and 2 digits code
          efflerner: lerner index
          rssdstate: bankid with state names (but doesn't contain 2 digits statecode)
          CBvar7613: all bank characteristics used in the project
          CBzscore_13_test: Z-score

		  CB_st: other control variables(the original file is CBvar, which is too big to use, so just keep necessary variables and save in file "CB_st"

          wrongful_discharge.xlsx
          non_competition index.xlsx
          deregulation.xlsx
          BR_index.xlsx
		  
		  state_region
		  
***************/

/*******************************************************************************************************************/
/*********************Part 1.Generate CB variable files, then merge with Lerner index file *************************/
/*******************************************************************************************************************/
 
                  /********(1) Note: For the process of generating CB variables, 				  
				  See code "stata code_generate CB var_v3"********************/
 
 
clear
cd "D:\Research\Wrongful discharge\data_updated02182017"

/************(2) Prepare WDL variables: Import wrongful_discharge file*****************/
/******the excel file "wrongful_discharge" is sent from professor Wang*******/

import excel "D:\Research\Wrongful discharge\wrongful_discharge.xlsx", firstrow clear
rename st state
save wrongful_discharge, replace


/***********(3) Merge Lerner file with wrongful discharge law by using state code**********/
use "D:\research\lerner index\efflerner.dta", clear
count //371,168
/***Merge with CB variables file*******/
joinby rssd9001 bankyear using "D:\research\CB var\CBvar_all", unm(master)
/***Merge with Wrongful discharge law file************/
joinby state using wrongful_discharge
count /**370,779 instead of 307948**/



/*************************************************************************************************/
/*****************Part 2. Generate dummy variables for wrongful discharge************************/
/************************************************************************************************/

/****followed paper:  Autor et al. (2006)’s Legal Appendix****************/
codebook rssd9001 /*** 21,127 instead of 18318***/

gen C_dummy=(bankyear>=ImpliedcontractC) if !missing(ImpliedcontractC) 
replace C_dummy=0 if statecode==29 & bankyear>1988
replace C_dummy=0 if statecode==4 & bankyear>1984
replace C_dummy=0 if C_dummy==.

gen P_dummy=(bankyear>=PublicpolicyP)  if !missing(PublicpolicyP) 
replace P_dummy=0 if  P_dummy==.

gen G_dummy= (bankyear>=GoodfaithG) if !missing(GoodfaithG)
replace G_dummy=0 if statecode==33 & bankyear>1980
replace G_dummy=0 if statecode==40 & bankyear>1989
replace G_dummy=0 if  G_dummy==.

save CB_lerner_WDL, replace


/***************************************************************************************/
/********************Part3. join with other regulation files***************************/
/***************************************************************************************/

/***************1. join with non competition index******************/
/******import non-competition index****/
///>>>>followed paper:Garmaise, 2011 (ranges from 0 to 9)

import excel "D:\Research\Wrongful discharge\non_competition index.xlsx", firstrow clear
destring statecode, replace
save non_competition_index, replace

/*******merge non-competition index and lerner master file*******/
use CB_lerner_WDL, clear
joinby statecode using non_competition_index
count  //370,779 obs 

replace enforceability_score=9 if statecode==12 & bankyear>=1997
replace enforceability_score=0 if statecode==22 & bankyear==2002 
replace enforceability_score=0 if statecode==22 & bankyear==2003
replace enforceability_score=3 if statecode==48 & bankyear>=1995
save CB_lerner_WDL, replace

/****2. join with deregulation: generate inter_dummy and intra_dummy****/
//>>>>followed paper: Michael Koetter 2012
/******import deregulation file****/
import excel "D:\Research\Wrongful discharge\deregulation.xlsx", firstrow clear
rename compustatstatecode statecode
save deregulation, replace


/*****merge deregulation file and lerner master file***********/
use CB_lerner_WDL,clear
joinby statecode using deregulation

gen afterdereg_intra=bankyear-intra
gen afterdereg_inter=bankyear-inter

gen intra_dummy=(bankyear>=intra)  
gen inter_dummy=(bankyear>=inter) 
save CB_lerner_WDL, replace


/*****************3. Merge with BR_index***************/
/***********import braching restriction index**************/
import excel "D:\Research\Wrongful discharge\BR_index.xlsx", firstrow clear
destring statecode, replace
save BR_index, replace

use CB_lerner_WDL, clear
drop _merge
joinby statecode using BR_index, unm(master)

/***check data:****/
*keep rssd9001 bankyear stnumbr BR_index _merge
sort statecode bankyear

replace BR_index=4 if statecode ==1 & bankyear<1997
replace BR_index=4 if statecode ==2 & bankyear<1994
replace BR_index=4 if statecode ==4 & bankyear<1996
replace BR_index=2 if statecode ==4 & bankyear>=2001
replace BR_index=4 if statecode ==6 & bankyear<1995
replace BR_index=4 if statecode ==8 & bankyear<1997
replace BR_index=4 if statecode ==9 & bankyear<1995
replace BR_index=4 if statecode ==10 & bankyear<1995
replace BR_index=4 if statecode ==11 & bankyear<1996
replace BR_index=4 if statecode ==12 & bankyear<1997
replace BR_index=4 if statecode ==13 & bankyear<1997
replace BR_index=3 if statecode ==13 & bankyear>=2002
replace BR_index=4 if statecode ==15 & bankyear<1997
replace BR_index=0 if statecode ==15 & bankyear>=2001
replace BR_index=4 if statecode ==16 & bankyear<1995
replace BR_index=4 if statecode ==17 & bankyear<1997
replace BR_index=0 if statecode ==17 & bankyear>=2004
replace BR_index=4 if statecode ==18 & bankyear<1997
replace BR_index=1 if statecode ==18 & bankyear>=1998
replace BR_index=4 if statecode ==19 & bankyear<1996
replace BR_index=4 if statecode ==20 & bankyear<1995
replace BR_index=4 if statecode ==21 & bankyear<1997
replace BR_index=3 if statecode ==21 & bankyear>=2000
replace BR_index=4 if statecode ==22 & bankyear<1997
replace BR_index=4 if statecode ==23 & bankyear<1997
replace BR_index=4 if statecode ==24 & bankyear<1995
replace BR_index=4 if statecode ==25 & bankyear<1996
replace BR_index=4 if statecode ==26 & bankyear<1995
replace BR_index=4 if statecode ==27 & bankyear<1997
replace BR_index=4 if statecode ==33 & bankyear<1997
replace BR_index=1 if statecode ==33 & bankyear>=2000
replace BR_index=0 if statecode ==33 & bankyear>=2002
replace BR_index=4 if statecode ==34 & bankyear<1996
replace BR_index=4 if statecode ==35 & bankyear<1996
replace BR_index=4 if statecode ==36 & bankyear<1997
replace BR_index=4 if statecode ==37 & bankyear<1995
replace BR_index=4 if statecode ==38 & bankyear<1997
replace BR_index=1 if statecode ==38 & bankyear>=2003
replace BR_index=4 if statecode ==39 & bankyear<1997
replace BR_index=1 if statecode ==40 & bankyear>=2000
replace BR_index=4 if statecode ==41 & bankyear<1997
replace BR_index=4 if statecode ==42 & bankyear<1995
replace BR_index=4 if statecode ==44 & bankyear<1995
replace BR_index=4 if statecode ==45 & bankyear<1996
replace BR_index=4 if statecode ==46 & bankyear<1996
replace BR_index=4 if statecode ==47 & bankyear<1997
replace BR_index=2 if statecode ==47 & bankyear>=1998
replace BR_index=1 if statecode ==47 & bankyear>=2001
replace BR_index=2 if statecode ==48 & bankyear>=1999
replace BR_index=4 if statecode ==49 & bankyear<1995
replace BR_index=1 if statecode ==49 & bankyear>=2001
replace BR_index=4 if statecode ==50 & bankyear<1996
replace BR_index=0 if statecode ==50 & bankyear>=2001
replace BR_index=4 if statecode ==51 & bankyear<1995
replace BR_index=4 if statecode ==53 & bankyear<1996
replace BR_index=1 if statecode ==53 & bankyear>=2005
replace BR_index=4 if statecode ==54 & bankyear<1997
replace BR_index=4 if statecode ==55 & bankyear<1996
replace BR_index=4 if statecode ==56 & bankyear<1997


save CB_lerner_WDL, replace


/*******(5) Merge with CB_perform that contain several other CB variables might be used later****/
///>>>for example, lev, dep_ta, all_ta, pf_ta
use CB_lerner_WDL, clear
joinby rssd9001 bankyear using "D:\research\Wrongful discharge\CBperform"
drop _merge
save CB_lerner_WDL, replace



/*********************4. Merge with region file****************************/
/******(1) Import regional excel sheet****/
import excel "D:\research\Wrongful discharge\update_v2\state_region.xls", firstrow clear
destring stnumbr region_dummy, replace
rename stnumbr statecode
save "D:\research\Wrongful discharge\update_v2\state_region.dta", replace



/*******(2) Merge with region file***********************/
use CB_lerner_WDL,clear
joinby statecode using "D:\research\Wrongful discharge\update_v2\state_region.dta", unm(master)
save CB_lerner_WDL, replace








