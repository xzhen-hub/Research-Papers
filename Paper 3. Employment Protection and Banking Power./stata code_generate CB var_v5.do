/***********Project: Wrongful discharge law and banking power*****/
/***********Generate CB variables that used in the project "WDL and banking power*********************/
/***********Coded by Xinting Zhen*********************************************************************/
/***********Updated date: 2/14/2018*******************************************************************/


/*****1. import file with state brief name of CB*************/
/*****since call report does not have the statecode for states. so need to add the state information by matching bank-year****/
/*****in file rssdstate: 
                        rssd9001: bank ID
						rssd9010:bank name
						rssd9200: state brief name
						rssd9220: zipcode
						rssd9999:date***********************/
/***********Add statecode(2digits) infor to the original call report state short names******/


clear
cd "D:\Research\Wrongful discharge\data_updated02182017"


use "D:\Research\Wrongful discharge\rssdstate", clear  //the file "rssdstate" is downloaded from wrds (contain bankid and state brief name. eg:CA,IL...) for merging with lerner master file by using state brief names
format rssd9999 %12.0g
 gen bankyear=substr(string(rssd9999,"%07.0f"),1,4)
destring bankyear, replace 
duplicates drop rssd9001 bankyear, force
count /**466132**/
drop rssd9220 /**since we don't need zipcode****/
rename rssd9200 state
/******merge with statecode file that contains 2digits state code********/
joinby  state using "D:\Research\Wrongful discharge\statecode" 
save CB_state, replace

/*********2. Generate zscore ************************************/
/***********code used to generate Z-score
            the file "CBzscore_13_test" is from call report but only contains the necessary variables needed to calculate Zscore:
            ROA, ROE, E/A*****/

use "D:\research\CB var\zscore\CBzscore_13_test", clear

ssc install asrol
tsset rssd9001 bankyear
asrol roa, stat(sd) win(4) gen (sd_roa)
gen zscore=(roa+ER)/sd_roa
tabstat zscore, stat(n mean sd min p25 median p75 max)
centile zscore, centile(1 4 5 10 25 50 75 80 90 95 98 99)
ssc install winsor2
winsor2 zscore, replace cuts (5 95)
tabstat zscore, stat(n mean sd min p25 median p75 max)

/****generate volatility of roe*******/
asrol roe, stat(sd) win(4) gen (sd_roe)
gen log_zscore=log(zscore)
save "D:\research\CB var\zscore\CBzscore_13_test", replace
////>>>zscore has already winsorized at (5 99), so don't need to winsorize it again later


/****************3. Generate CB characteristic variables***********************
file "CBvar7613" contains Bank characteristics:hhiloan, logasset, sec, inc, llp_totloan, llr er****/
///////                           Use SAS to regenerate some variables that exist gaps in certain time periods ***********************/	

////////////Explanations of CB charateristic variables:
/***Variables that need to be generated: log(size), SEC LLR ER INC**/
/****SEC (security share): share of securities of total assets*******/
/****LLR(Loan-loss reserve share):loan-loss reserves divided by total loans*******/
/****ER (capital to assets ratio): equity ratio defined as geoss total equity divided by gross total assets***/
/****INC(loan income share): interst and fee income from loans divided by operating income*****/
/****MS (Market share): @state level, defined as rcfd2170/aggregated assets per state in each year*****/

/***********SAS code is saved in file "sas code_CBvar_09302016"********************************************************/
/***********Full data set that contains all the regenerated control variables are saved as "CBvar7613"*****************/
/***********Join CBvar7613 and Zscore and save as file "CBvar_all"****************************************************/


/****Add the variable of "totloan and totassets" from the previous CB variables file****/
/***since the CBvar file is too big, so just use some vairables on it to get the totloan variable***/
use "E:\CB var gen\out\CBvar.dta" , clear
 keep rssd9999 rssd9001 totassets totloans l_ta totliab totdeposit lev 
 gen bankyear=substr(string(rssd9999,"%07.0f"),1,4)
 destring bankyear, replace
joinby rssd9001 bankyear using CB_state, unm(master)
save CB_st, replace

///generate MS=rcfd2170/aggregated assets per state in each year
collapse (sum) sum_asset_state=totassets, by (statecode bankyear)
save collapse_stateasset, replace

use CB_st, clear
joinby statecode bankyear using collapse_stateasset
/*sort stnumbr bankyear*/
gen MS=(totassets/sum_asset_state)*100
save CB_st, replace

collapse (sum) sum_loan_state=totloans, by (statecode bankyear)
save collapse_stateloans, replace

use CB_st, clear
joinby statecode bankyear using collapse_stateloans
gen share_loan=totloans/sum_loan_state
gen share_loan_square=share_loan^2
save CB_st, replace

collapse (sum) sum_shareloan_state= share_loan_square  , by (statecode bankyear)
save collapse_sum_shareloan_state, replace



/****generate totdeposit***/
use "D:\research\CB var\CB_totdeposit_7613", clear
rename rcfd2200 totdeposit
joinby rssd9001 bankyear using CB_state, unm(master)
save CB_deposit, replace

collapse (sum) sum_deposit_state=totdeposit, by (statecode bankyear)
save collapse_statedeposit, replace

use CB_deposit, clear
joinby statecode bankyear using collapse_statedeposit
gen share_deposit=totdeposit/sum_deposit_state
gen share_deposit_square=share_deposit^2

collapse (sum) sum_sharedeposit_state= share_deposit_square  , by (statecode bankyear)
save collapse_sum_sharedeposit_state, replace



use "D:\research\CB var\CBvar7613", clear
gen bankyear=substr(string(rssd9999,"%07.0f"),1,4)
destring bankyear, replace
sort rssd9001 bankyear
count /***439745**/
duplicates drop rssd9001 bankyear, force /** 439,740***/
joinby rssd9001 bankyear using CB_state, unm(master)
count if _merge==3 //438686
drop _merge

joinby rssd9001 bankyear using CB_st
count /***439745***/

///(1) merge with HHI_loan file
joinby statecode bankyear using collapse_sum_shareloan_state
///(2) merge with HHI_deposit file
joinby statecode bankyear using collapse_sum_sharedeposit_state
///(3) merge with Zscore file
joinby rssd9001 bankyear using "D:\research\CB var\zscore\CBzscore_13_test"
count /****439,740***/
rename  sum_sharedeposit_state HHI_deposit 
rename  sum_shareloan_state HHI_loan 
save "D:\research\CB var\CBvar_all", replace
