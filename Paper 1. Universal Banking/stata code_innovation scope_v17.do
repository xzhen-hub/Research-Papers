


/*****Project: Universal bank lending and firm innovation
      this code is  for draft v17
	  (1) to generate innovation scope
	  (2) test the effect of universal bank lending on innovation scope
	  
	  Updated: 2/8/2018
	  Coded by Xinting Zhen
	 
	  *****************/


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

use winsored_v6_base_2,clear
joinby gvkey cyear using inno_scope, unm(master)
count if _merge==3  //24490 matched
drop _merge

replace related_pat_firm=0 if related_pat_firm==.
replace unrelated_pat_firm=0 if unrelated_pat_firm==.
replace related_cit_firm=0 if related_cit_firm==.
replace unrelated_cit_firm=0 if unrelated_cit_firm==.
replace related_gen_firm=0 if related_gen_firm==.
replace unrelated_gen_firm=0 if unrelated_gen_firm==.



global firmcontrol="Firmsize salegrowth  Firm_age Profitability Capitalexpenditures Firmefficiency Workingcapital Assetstangibility Leverage"
global capstructcontrol="Equity_assets sp500indicator equity_dummy "
global dummy="YEAR* statecode"


tab cyear, gen(YEAR)

/*****************use number of counts instead of log value****************/

centile related_pat_firm,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 related_pat_firm, replace cuts (1 95)
centile unrelated_pat_firm,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 unrelated_pat_firm, replace cuts (1 95)


centile related_cit_firm ,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 related_cit_firm, replace cuts (1 99)
centile unrelated_cit_firm,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 unrelated_cit_firm, replace cuts (1 99)


/**************************************************************************************/
/****consistent with TX2013 (bank intervention.....)*******/
/***both are neg sig if winsored at (1 95)****/
/***insig if winsored at (1 99)***/
areg related_pat_firm ub_post_1stall $dummy $firmcontrol  $capstructcontrol,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablescope1.xls, excel tstat dec(3)  replace ctitle(Related patent) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

/***neg sig if winsored at (1 95)***/
areg unrelated_pat_firm ub_post_1stall $dummy $firmcontrol  $capstructcontrol,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablescope1.xls, excel tstat dec(3)  append ctitle(Unrelated patent) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

/****insig if not winsor**/
/***insig if winsored at (1 99)***/
areg related_cit_firm ub_post_1stall $dummy $firmcontrol  $capstructcontrol,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablescope.xls, excel tstat dec(3)  append ctitle(Related citation) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

/****neg sig if not winsor**/
/***neg sig if winsored at (1 99)***/
areg unrelated_cit_firm ub_post_1stall $dummy $firmcontrol  $capstructcontrol,   vce(cluster gvkey) absorb(sic1)
outreg2 using tablescope.xls, excel tstat dec(3)  append ctitle(Unrelated citation) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)


