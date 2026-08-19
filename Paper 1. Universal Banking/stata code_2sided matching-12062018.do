

/***Stata code: adjust based on the MF referee's comments***/
/**Note: deadline is Nov 3 2018**********/
/***1. add lender size effect: big bank effects**/
/***2. add a covariate balance analysis for the treatment and control firms******/
/***3. Self-selection????????? further explore the potential effect of self-selection to convince the reader that self-selection is not a serious concern for inference*/
/***Created date: 10/18/2018******/
/***Last updated:            *****/



clear
cd "D:\XINTING_research\ub and innovation\MF referee oct 2018\data/revise"

/***think about: join link with callreport firstly***/
use "D:\XINTING_research\LernerLoan_2015-2016_Economic notes\COMBINED DATA\lernerloan_all_winsor", clear
keep facilityid rssd9001 cyear lenderid
/****it is unique at facility level***/
duplicates report rssd9001 cyear
/**not unique***/
duplicates report facilityid cyear
/**it's unique at facility-year level*/
*duplicates drop rssd9001 cyear, force
*gen companyid=lenderid
save namematch, replace
count 
/**9981 if not drop duplicates rssd9001 cyear1752**/

use "D:\XINTING_research\call report_cleaned\efflerner", clear
gen cyear=bankyear
*gen lenderid=rssd9001
duplicates report rssd9001 cyear 
/**unique **/
save efflerner_ta, replace


use namematch, clear
joinby rssd9001 cyear using efflerner_ta, unm(master)
count
/***9981 if keep the master file; 5001 of keep the inner join, not 1267***/

duplicates report facilityid, cyear
save call_ds, replace
/**1267 unique***/
/**Note: lenderid is not rssd9001, should merge with linktable by using facid****/


/***  TEST
/**Note: the file "link_boc_lender" is the merged file of dealscan lender infor and charva roberts linktable***/
use "D:\XINTING_research\ub and innovation\MF referee oct 2018\data\old work\link_boc_lender", clear
*duplicates report facilityid bankyear
/***not unique****/
count
/**756400***/
gen cyear=bankyear
joinby facilityid cyear using call_ds, unm(master)
count if _merge==3
/***2542***/
*****/



use call_ds, clear
gen rssdid=rssd9001
drop YEAR*
drop _merge
save call_ds, replace


/**********************************************************************************************************************/
/******updated on 12/6/2018: generate more bank variables**/
use "D:\XINTING_research\CB var gen\out\CBvar", clear

keep totassets operexp rssd9001 rssd9999 cash 

duplicates report rssd9001 rssd9999
 gen cyear=substr(string(rssd9999,"%07.0f"),1,4)
destring cyear, replace
gen rssdid=rssd9001
duplicates drop rssdid cyear, force
save cbvar_add, replace






/****use facilityid cyear to connect call_ds and link table***/
use "D:\XINTING_research\ub and innovation\MF referee oct 2018\v29\winsored_v29_base", clear
joinby facilityid cyear using call_ds, unm(master)
count if _merge==3
/**810, not 160**/
drop _merge
count
duplicates report gvkey cyear

joinby rssd9001 cyear using cbvar_add, unm(master)


sort gvkey
duplicates report gvkey cyear // 100101 unique
count if !missing(statecode) //89877
keep if !missing(statecode)
count
drop _merge

tab bankyear, gen(YEAR)



/***generate bigbank_dummy (Berger and Black, 2011, bank gross total asset >$1billion)***/
/***Note: Total assets are total assets, unweighted by risk (RCFD2170 from the Call Report), measured in units of $1 billion as of June
2004.  Lang, Mester and Vermilyea(2005)***/
* Large bank, in excess of US$10bln
/*  Laeven, Ratnovsk and tong (JBF 2016): Our main analysis also focuses on large institutions that are more likely
to be systemically important, limiting the sample to institutions with assets in excess of US$ 10 billion at the end of 2006
***/

replace ta=0 if ta==.
gen largebank=(ta>=1000000)
count if largebank==1 //134, not 70

/***generate lnsize (RFS dominant bank effect, log of loan principal*****/
gen ln_banksize=ln(ta)
count
/*89877**/
replace ln_banksize=0 if ln_banksize==.



/***generate the 2nd measure of lnsize (RFS dominant bank effect, log of loan principal*****/
gen ln_banksize2=ln(1+ta)
count
/*89877**/
replace ln_banksize2=0 if ln_banksize2==.



/***********generate more bank variables***********/
*1. salaries-expense 
**salaries and benefits/total operating expense

gen salary=x2*w2
gen salary_exp=salary/operexp
replace salary_exp=0 if salary_exp==.


*2. capital-assets
**total equitycapital/toal assets
gen Equity_ta=z/ta
replace Equity_ta=0 if Equity_ta==.

*3. cash-ta
** cash to total assets
gen cash_ta=cash/totassets
replace cash_ta=0 if cash_ta==.


tabstat largebank, stat (n mean sd  p25 median p75  ) col(stat)

save winsored_v31_base, replace

use winsored_v31_base, clear
saveold winsored_v31_base_12, version(12)



/***************test************/
keep cyear rssdid facilityid gvkey operexp Ln_patent ub_post_1stall


count if !missing(operexp)
count if !missing(rssdid)
/**5471**/




global bankcontrol="largebank salary_exp Equity_ta cash_ta"
global firmcontrol="Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility "
global capstructcontrol="Equity_assets  debtrating "
global dummy="YEAR* statecode"


/***run regression for pair regression: regress banksize on firm characteristic, regress firmsize on bank characteristic****/
*insig if include all bank characteristics

*sig if include only 2 variables: larger bank are intending to lend to large firms
global bankcontrol="ln_banksize salary_exp Equity_ta cash_ta"
regress  Firmsize ln_banksize salary_exp $dummy

*pos sig: larger firms intend to lend from larger banks
regress ln_banksize Firmsize Capitalexpenditures $dummy


/******************************************************************************************************************************/
***up to now (12/6/2018, the above sig results satisfy the pre-assumption, now it is good to run MCMC ******
***Jiawei Chen page 268: the coefficients on bank's and firm's size are both positive and significant, indicating that there is indeed positive assortative matching of sizes. 




global bankcontrol="largebank salary_exp Equity_ta cash_ta"
global firmcontrol="Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility "
global capstructcontrol="Equity_assets  debtrating "
global dummy="YEAR* statecode"

/***sig**/
areg Ln_patent ub_post_1stall $bankcontrol $dummy $firmcontrol  $capstructcontrol if sample_5yr_window==1 ,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablebase_v30.xls, excel tstat dec(3) replace ctitle(ln_patent) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)


areg Ln_nonselfcitation ub_post_1stall  $dummy $firmcontrol  $capstructcontrol if sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablebase_v30.xls, excel tstat dec(3) append ctitle(ln_citation) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)



*use winsored_v6_base_2,clear
use winsored_v30_base, clear



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




global firmcontrol="Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility "
global capstructcontrol="Equity_assets  debtrating "
global dummy="YEAR* statecode largebank "
 

/***results are good for innovation_t+1: all neg sig!!!!***/
areg pat_f1 ub_post_1stall  $dummy $firmcontrol $capstructcontrol if sample_5yr_window==1  ,  vce(cluster gvkey) absorb(sic1)
outreg2 using tabledynamic_fwd_v30.xls, excel tstat dec(3)  replace ctitle(Patent_t1) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)
areg pat_f2 ub_post_1stall  $dummy $firmcontrol $capstructcontrol  if sample_5yr_window==1   ,  vce(cluster gvkey) absorb(sic1)
outreg2 using tabledynamic_fwd_v30.xls, excel tstat dec(3)  append ctitle(Patent_t2) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)
areg pat_f3 ub_post_1stall  $dummy $firmcontrol $capstructcontrol if sample_5yr_window==1  ,  vce(cluster gvkey) absorb(sic1)
outreg2 using tabledynamic_fwd_v30.xls, excel tstat dec(3)  append ctitle(Patent_t3) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

/** * if restrick 5 year window: sig for t+1, but insig for t+2 and t+3********/
/***all neg sig if not restrict 5 year window************/
areg cit_f1 ub_post_1stall $dummy $firmcontrol $capstructcontrol if sample_5yr_window==1  ,  vce(cluster gvkey) absorb(sic1)
outreg2 using tabledynamic_fwd_v30.xls, excel tstat dec(3)  append ctitle(Cit_t1) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)
areg cit_f2 ub_post_1stall  $dummy $firmcontrol $capstructcontrol  if sample_5yr_window==1   ,  vce(cluster gvkey) absorb(sic1)
outreg2 using tabledynamic_fwd_v30.xls, excel tstat dec(3)  append ctitle(Cit_t2) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)
areg cit_f3 ub_post_1stall  $dummy $firmcontrol $capstructcontrol  if sample_5yr_window==1   ,  vce(cluster gvkey) absorb(sic1)
outreg2 using tabledynamic_fwd_v30.xls, excel tstat dec(3)  append ctitle(Cit_t3) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)




/************************Table 4.*use R&D as DV**************/


use winsored_v30_base, clear



global firmcontrol="Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility "
global capstructcontrol="Equity_assets  debtrating "
global dummy="YEAR* statecode largebank "
 


/**significant**/
areg ln_RD ub_post_1stall  $dummy $firmcontrol  $capstructcontrol if sample_5yr_window==1 ,  vce(cluster gvkey) absorb(sic1)
outreg2 using tableRD_v30.xls, excel tstat dec(3)  replace ctitle(lnRD ) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)


areg rdtoassets ub_post_1stall  $dummy $firmcontrol  $capstructcontrol if sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tableRD_v30.xls, excel tstat dec(3)  append ctitle(rdtoassets ) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

 
areg RDtosale ub_post_1stall   $dummy $firmcontrol $capstructcontrol if sample_5yr_window==1,  vce(cluster gvkey) absorb(sic1)
outreg2 using tableRD_v30.xls, excel tstat dec(3) append ctitle(RDtosale ) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)



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

use winsored_v30_base, clear
drop _merge
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



global firmcontrol="Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility "
global capstructcontrol="Equity_assets  debtrating "
global dummy="YEAR* statecode largebank "

*column 1
areg ln_rel_pat i.ub_post_1stall $dummy $firmcontrol  $capstructcontrol if sample_5yr_window==1,    vce(cluster gvkey) absorb(sic1)
outreg2 using tablescope_v30.xls, excel tstat dec(3)  replace ctitle(Related patent) nonotes bracket drop(sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

*column 2
areg ln_unrel_pat i.ub_post_1stall $dummy $firmcontrol  $capstructcontrol if sample_5yr_window==1,    vce(cluster gvkey) absorb(sic1)
outreg2 using tablescope_v30.xls, excel tstat dec(3)  append ctitle(Related patent) nonotes bracket drop(sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)


*column 3
global firmcontrol="Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility "
global capstructcontrol="Equity_assets  debtrating "
global dummy="YEAR* statecode largebank "
xtset gvkey cyear
xtreg ln_rel_cit i.ub_post_1stall $dummy $firmcontrol  $capstructcontrol if sample_5yr_window==1,    vce(cluster gvkey) 
outreg2 using tablescope_v30.xls, excel tstat dec(3)  append ctitle(Related citation) nonotes bracket drop(sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

*column 4
global firmcontrol="Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility "
global capstructcontrol="Equity_assets  debtrating "
global dummy="YEAR* statecode largebank "
areg  ln_unrel_cit i.ub_post_1stall $dummy $firmcontrol  $capstructcontrol if sample_5yr_window==1,    vce(cluster gvkey) absorb(sic1)
outreg2 using tablescope_v30.xls, excel tstat dec(3)  append ctitle(Related citation) nonotes bracket drop(sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)




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

/***********************************Updated on 12/14/2017*************************************************/
/********************************Merge with SA data to get joint innavation*******************************/
/*********************************************************************************************************/

import delimited "D:\research\UB and innovation\data\SA_Participants.csv",  clear
save sa_participants, replace


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

count
//37085

/*******merge with lendersize information************/
joinby facilityid cyear using call_ds, unm(master)
count if _merge==3
/**160**/

sort gvkey
duplicates report gvkey cyear // 100101 unique
count if !missing(statecode) //89877
keep if !missing(statecode)

replace ta=0 if ta==.
gen largebank=(ta>=1000000)
count if largebank==1 //70

/***generate lnsize (RFS dominant bank effect, log of loan principal*****/
gen ln_banksize=ln(ta)
count
/*89877**/

tabstat largebank, stat (n mean sd  p25 median p75  ) col(stat)


tab cyear, gen(YEAR)



global firmcontrol="Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility "
global capstructcontrol="Equity_assets  debtrating "
global dummy="YEAR* statecode sic1 largebank"

/***********************************************************************************************/
/***insig if keep nonmissing; pos sig if using the whole sample; only sig at 10% is using cluster gvkey, sig at 5% when using robust***/
probit firm_jointven  i.ub_post_1stall $dummy $firmcontrol  $capstructcontrol  if sample_5yr_window==1 ,   vce(cluster gvkey) 
outreg2 using tablejoint_v30.xls, excel tstat dec(3) replace ctitle(joint venture) nonotes bracket drop(sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)
*  Pseudo R2         =     0.3777

/*********************************************/
/****insig*****/
probit firm_rd_agree i.ub_post_1stall $dummy $firmcontrol  $capstructcontrol if  sample_5yr_window==1 ,   vce(cluster gvkey) 
outreg2 using tablejoint_v30.xls, excel tstat dec(3) append ctitle(rd agreement) nonotes bracket drop(sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

* Pseudo R2         =     0.3942





/******************************Table 7. Effect of ub on innovation under different levels of financial constraints*********/
/***************Updated on 1/27/2018: followed Lamont Polk 2001, refer to the top 33% of all firms
ranked on the KZ index as "constrained", and the bottom 33% as "unconstrained"************/

use winsored_v30_base, clear
drop _merge
joinby gvkey cyear using finrestric, unm(master)

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




global firmcontrol="Firmsize Salegrowth Capitalexpenditures Workingcapital  Firm_age Profitability Firmefficiency Assetstangibility "
global capstructcontrol="Equity_assets  debtrating "
global dummy="YEAR* statecode largebank"


areg Ln_patent ub_post_1stall $dummy $firmcontrol  $capstructcontrol if top_kz==1 & sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefincon_topbotm_v30.xls, excel tstat dec(3) replace ctitle(Ln_patent_top_kz) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Ln_nonselfcitation ub_post_1stall $dummy $firmcontrol  $capstructcontrol if top_kz==1 & sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefincon_topbotm_v30.xls, excel tstat dec(3) append ctitle(Ln_citation_top_kz) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Ln_patent ub_post_1stall $dummy $firmcontrol  $capstructcontrol if bottom_kz==1 & sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefincon_topbotm_v30.xls, excel tstat dec(3) append ctitle(Ln_patent_bottom_kz) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Ln_nonselfcitation ub_post_1stall $dummy $firmcontrol  $capstructcontrol if bottom_kz==1 & sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefincon_topbotm_v30.xls, excel tstat dec(3) append ctitle(Ln_citation_bottom_kz) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)



egen all_struc=sum(struc_index2), by (cyear)
gen pct_struc=100*struc_index2/all_struc

egen low_struc =pctile(pct_struc), p(33)
egen high_struc =pctile(pct_struc), p(67)

gen top_struc=(pct_struc>=high_struc)
gen bottom_struc=(pct_struc<=low_struc)


areg Ln_patent ub_post_1stall $dummy $firmcontrol  $capstructcontrol if top_struc==1 & sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefincon_topbotm_v30.xls, excel tstat dec(3) append ctitle(Ln_patent_top_struc) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Ln_nonselfcitation ub_post_1stall $dummy $firmcontrol  $capstructcontrol if top_struc==1 & sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefincon_topbotm_v30.xls, excel tstat dec(3) append ctitle(Ln_citation_top_struc) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Ln_patent ub_post_1stall $dummy $firmcontrol  $capstructcontrol if bottom_struc==1 & sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefincon_topbotm_v30.xls, excel tstat dec(3) append ctitle(Ln_patent_bottom_struc) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Ln_nonselfcitation ub_post_1stall $dummy $firmcontrol  $capstructcontrol if bottom_struc==1 & sample_5yr_window==1,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablefincon_topbotm_v30.xls, excel tstat dec(3) append ctitle(Ln_citation_bottom_struc) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)




