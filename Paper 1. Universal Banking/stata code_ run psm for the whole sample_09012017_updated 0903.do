
/********The code is to do CEM for the whole sample***************/
/********created date: 09012017
         most updted date: 09032017
		 determine the most appropriate psm matching facotr to use: it's acceptable if - insig -. should combined with placebo 
		 *****************************/
		 
		 
		/***insig if using:  psmatch2 ub_indicator ub_year_psm min_cyear_psm firmyears sic1 Firmsize  firm_debt Leverage  , logit noreplace 

		                     psmatch2 ub_indicator ub_year_psm min_cyear_psm firmyears sic1 Firmsize Profitability firm_debt Assetstangibility , logit noreplace 

		                     psmatch2 ub_indicator ub_year_psm min_cyear_psm firmyears sic1 Firmsize Profitability firm_debt  , logit noreplace 
		                     psmatch2 ub_indicator ub_year_psm min_cyear_psm firmyears sic1 Firmsize Profitability Leverage Equity_assets Assetstangibility , logit noreplace 
psmatch2 ub_indicator ub_year_psm min_cyear_psm firmyears sic1 Firmsize Profitability RDtosale  Leverage Equity_assets Assetstangibility , logit noreplace 
psmatch2 ub_indicator ub_year_psm  firmyears sic1 Firmsize Profitability RDtosale  Leverage Equity_assets Assetstangibility , logit noreplace 
psmatch2 ub_indicator ub_year_psm  firmyears sic1 Firmsize Profitability RDtosale  Equity_assets Assetstangibility , logit noreplace 
psmatch2 ub_indicator ub_year_psm  firmyears  Firmsize Profitability RDtosale  Equity_assets Assetstangibility , logit noreplace 
psmatch2 ub_indicator ub_year_psm  firmyears  Firmsales Profitability RDtosale  Equity_assets Assetstangibility , logit noreplace 
psmatch2 ub_indicator ub_year_psm  firmyears Firmsize Profitability RDtosale intaginility_sale Equity_assets Assetstangibility , logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales Capitalexpenditures Workingcapital Assetstangibility RDtosale Profitability  Equity_assets firm_debt Leverage, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales Firmefficiency  Capitalexpenditures Workingcapital Assetstangibility RDtosale Profitability  Equity_assets Leverage, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic3 firmyears Firmsize Firmsales  Capitalexpenditures RDtosale Workingcapital Equity_assets  Profitability firm_debt  Leverage, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales  ln_RD Capitalexpenditures Profitability Equity_assets Leverage  firm_debt , logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales Assetstangibility  RDtosale Capitalexpenditures Profitability Equity_assets Leverage  firm_debt , logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales Assetstangibility  RDtosale Capitalexpenditures  Equity_assets Leverage  , logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales Assetstangibility  RDtosale  Equity_assets Leverage  , logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales  Capitalexpenditures  Assetstangibility  RDintensity Equity_assets firm_debt , logit noreplace 

the inter is insig if using the following and robust:
psmatch2 ub_indicator ub_year_psm  firmyears  Firmsize Profitability RDtosale  Equity_assets Leverage , logit noreplace 
psmatch2 ub_indicator ub_year_psm  firmyears  Firmsize Profitability RDtosale firm_debt Equity_assets Leverage , logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales Assetstangibility ln_RD Firmefficiency Capitalexpenditures    Equity_assets firm_debt , logit noreplace 

only the inter is sig:
psmatch2 ub_indicator ub_year_psm  firmyears Firmsize Profitability RDtosale  Equity_assets Assetstangibility , logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales Capitalexpenditures Assetstangibility Profitability ln_RD  Equity_assets  firm_debt, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales Capitalexpenditures Assetstangibility ln_RD  Equity_assets  firm_debt, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales  Capitalexpenditures ln_RD Workingcapital  Profitability firm_debt  Leverage, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales Firmefficiency Capitalexpenditures RDtosale Workingcapital Equity_assets  Profitability firm_debt  Leverage, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales  Capitalexpenditures Workingcapital Assetstangibility Equity_assets Profitability  Equity_assets firm_debt Leverage, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales  Capitalexpenditures Workingcapital Assetstangibility Equity_assets Profitability  Equity_assets firm_debt , logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales  RDtosale Capitalexpenditures Equity_assets Assetstangibility   firm_debt , logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales Assetstangibility  ln_RD Capitalexpenditures Profitability Equity_assets Leverage  firm_debt , logit noreplace 

only the trt is sig:
psmatch2 ub_indicator ub_year_psm  firmyears Firmsize Firmsales Profitability ln_RD Equity_assets Leverage , logit noreplace 
psmatch2 ub_indicator ub_year_psm  firmyears Firmsize Firmsales Capitalexpenditures Assetstangibility RDtosale Profitability  Equity_assets  firm_debt, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales  Capitalexpenditures Assetstangibility  Profitability firm_debt Equity_assets Leverage, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales  Capitalexpenditures Assetstangibility RDtosale Profitability firm_debt Equity_assets Leverage, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic2 firmyears Firmsize Firmsales sp500dummy Capitalexpenditures ln_RD Workingcapital bk_equity_at3 Profitability firm_debt  Leverage, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales sp500dummy Capitalexpenditures Workingcapital Assetstangibility Equity_assets Profitability  Equity_assets firm_debt Leverage, logit noreplace 

only post is insig the other two are sig:
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales Assetstangibility Profitability ln_RD Equity_assets Leverage , logit noreplace 
(positive, bad) psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales Capitalexpenditures Assetstangibility Profitability ln_RD Equity_assets Leverage firm_debt, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales  Capitalexpenditures  Assetstangibility RDtosale Profitability  Equity_assets Leverage, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales  Capitalexpenditures Workingcapital Assetstangibility ln_RD Profitability firm_debt Equity_assets Leverage, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales  Capitalexpenditures ln_RD Workingcapital  Profitability firm_debt bk_equity_at3 Leverage, logit noreplace 

Some positive sig:
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales  Capitalexpenditures  ln_RD Profitability firm_debt Equity_assets Leverage, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales sp500dummy Capitalexpenditures ln_RD Workingcapital  Profitability firm_debt Equity_assets Leverage, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales Capitalexpenditures Workingcapital Assetstangibility ln_RD Profitability  Equity_assets firm_debt Leverage, logit noreplace 


A little sig for the following by using 3 year window:
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales Capitalexpenditures Workingcapital Assetstangibility RDtosale Profitability  Equity_assets  Leverage, logit noreplace 

All sig, but the single term are positive!
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales  Capitalexpenditures Workingcapital Assetstangibility ln_RD Profitability  Equity_assets Leverage, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales  Capitalexpenditures Assetstangibility ln_RD Profitability firm_debt Equity_assets Leverage, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales Capitalexpenditures rdintensity_2 Workingcapital  Profitability firm_debt Equity_assets Leverage, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales sp500dummy Capitalexpenditures rdintensity_2 Workingcapital  Profitability firm_debt Equity_assets Leverage, logit noreplace 
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales bk_equity_at3  Capitalexpenditures  Assetstangibility   firm_debt , logit noreplace 


all sig but the inter is positive:
psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales  Capitalexpenditures Workingcapital Assetstangibility   Equity_assets firm_debt , logit noreplace 

********/
		 
		 
		 
clear
cd "D:\research\UB and innovation\data"
use winsored_v6_base, clear
keep gvkey cyear ub_1styear_all ub_year2 sic1 sic2 sic3 Firmefficiency Firm_age bk_equity_at2 Risk_weeklyexdivret sp500dummy Firmsales ln_RD rdintensity_2 Capitalexpenditures intaginility_sale bk_equity_at3 Workingcapital Firmsize firm_debt sic1 rty_roa Equity_assets RDintensity ln_RD RDtosale Profitability Leverage Assetstangibility

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


*cem Firmsize  min_cyear_cem  ub_year_cem sic1(#0) Leverage,  treatment(ub_indicator) 
*replace sp500dummy=0 if sp500dummy==.

* results is complex: psmatch2 ub_indicator ub_year_psm sic1 Firmsize Firmsales ln_RD Profitability Capitalexpenditures Leverage  Equity_assets firm_debt Workingcapital , logit noreplace 
*psmatch2 ub_indicator ub_year_psm sic1 Firmsize Firmsales RDtosale Profitability Capitalexpenditures Leverage  Equity_assets firm_debt Workingcapital , logit noreplace 
*- + -, but insig for orig : psmatch2 ub_indicator ub_year_psm sic1 Firmsize Firmsales ln_RD Capitalexpenditures Equity_assets firm_debt  Assetstangibility Leverage , logit noreplace 

*insig: psmatch2 ub_indicator ub_year_psm sic1 Firmsize sp500dummy Firmsales ln_RD Capitalexpenditures Equity_assets firm_debt  Assetstangibility Leverage  , neighbor(1)  noreplace 



*can use:( - insig -)  :
*psmatch2 ub_indicator ub_year_psm sic1 Firmsize sp500dummy Firmsales ln_RD Capitalexpenditures Equity_assets firm_debt  Assetstangibility Leverage  , logit noreplace 

*psmatch2 ub_indicator ub_year_psm sic1 Firmsize Firmsales ln_RD Capitalexpenditures Equity_assets firm_debt , logit noreplace 

*can't use: insig for trt :psmatch2 ub_indicator ub_year_psm sic1 Firmsize Firmsales ln_RD Capitalexpenditures Equity_assets  , logit noreplace 
*can't use: psmatch2 ub_indicator ub_year_psm sic1 Firmsize Firmsales ln_RD Equity_assets firm_debt  , logit noreplace 
*can't use: psmatch2 ub_indicator ub_year_psm sic1 Firmsize Firmsales ln_RD Equity_assets Leverage , logit noreplace 
*can't use: psmatch2 ub_indicator ub_year_psm firmyears sic1 Firmsize Firmsales ln_RD Capitalexpenditures bk_equity_at2,  logit noreplace 
*psmatch2 ub_indicator ub_year_psm firmyears sic1 Firmsize  Firmsales ln_RD,  logit noreplace 


/***this one seems provides the most consistent: - insig -, and insig for citation******/
psmatch2 ub_indicator ub_year_psm firmyears sic1 Firmsize Firmsales ln_RD Equity_assets Leverage , logit noreplace 
/***********delete firm sales and rerun (updated on 11/2/2017***********************/
psmatch2 ub_indicator ub_year_psm Firmsize sic1 firmyears Profitability Capitalexpenditures Firmefficiency Workingcapital Assetstangibility Leverage, logit noreplace 









*only post is insig the other two are sig:
*psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales Assetstangibility Profitability ln_RD Equity_assets Leverage , logit noreplace 

*psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales  Capitalexpenditures  Assetstangibility RDtosale Profitability  Equity_assets Leverage, logit noreplace 

*no for cluster: psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales  Capitalexpenditures Workingcapital Assetstangibility ln_RD Profitability firm_debt Equity_assets Leverage, logit noreplace 

*no for cluster: psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales  Capitalexpenditures ln_RD Workingcapital  Profitability firm_debt bk_equity_at3 Leverage, logit noreplace 






/***it's consistent too ( for orig and gen: insig, + -)
psmatch2 ub_indicator ub_year_psm firmyears sic1 Firmsize  ln_RD  Equity_assets,  logit noreplace 
**/

/****it's odd: + + -
psmatch2 ub_indicator ub_year_psm firmyears sic1 Firmsize  RDtosale  Equity_assets Leverage ,  logit noreplace 
***/

*insig: psmatch2 ub_indicator ub_year_psm firmyears Firmsize  RDtosale  Equity_assets firm_debt Profitability Leverage ,  logit 

/**
findit pscore
pscore ub_indicator ub_year_psm firmyears Firmsize  RDtosale  Equity_assets firm_debt Profitability Leverage, pscore(myscore) blockid(myblock) comsup
psmatch2 ub_indicator , pscore(myscore) n(2) cal(0.20)

********************************************
The balancing property is not satisfied 

Try a different specification of the propensity score 
***/


*psmatch2 ub_indicator, mahal(ub_year_psm firmyears Firmsize  RDtosale  Equity_assets firm_debt Profitability Leverage) cal(0.10)

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
use winsored_v6_base, clear
joinby gvkey using psm_all
//29552

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

global firmcontrol="Firmsize Firm_age Profitability Capitalexpenditures Firmefficiency Workingcapital Assetstangibility Leverage"
global capstructcontrol="Equity_assets sp500indicator equity_dummy "
*global loancontrol=" Loanmaturity Loanscale Termloan Corppurpose Collateral Generalcovenants "
global dummy="YEAR* statecode"


/****insig if using 1:1 matching********/
areg Ln_patent i.ub_trt##i.psm_ubpost $dummy $firmcontrol  $capstructcontrol  if window_5year_psm==1,   vce(robust) absorb(sic1)
outreg2 using tableDID_v6.xls, excel tstat dec(3) replace ctitle(Ln_patent) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Ln_nonselfcitation i.ub_trt##i.psm_ubpost $dummy $firmcontrol  $capstructcontrol if window_5year_psm==1,   vce(robust) absorb(sic1)
outreg2 using tableDID_v6.xls, excel tstat dec(3) append ctitle(Ln_cit) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Ln_originality i.ub_trt##i.psm_ubpost $dummy $firmcontrol  $capstructcontrol if window_5year_psm==1,   vce(robust) absorb(sic1)
outreg2 using tableDID_v6.xls, excel tstat dec(3) append ctitle(Ln_orig) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)

areg Ln_generality i.ub_trt##i.psm_ubpost $dummy $firmcontrol  $capstructcontrol if window_5year_psm==1,   vce(robust) absorb(sic1)
outreg2 using tableDID_v6.xls, excel tstat dec(3) append ctitle(Ln_gen) nonotes bracket drop(bankyear* sic1* statecode* )  addtext(Year FE,Yes, State FE, Yes, Industry FE, Yes)





/*****report kind of consistent result: - insig -
psmatch2 ub_indicator ub_year_psm sic1 Firmsize sp500dummy Firmsales ln_RD Capitalexpenditures Equity_assets firm_debt  Assetstangibility Leverage , logit noreplace 
**/





/***the best result can get so far:

psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales sp500dummy  Capitalexpenditures Workingcapital Assetstangibility ln_RD Profitability  Equity_assets firm_debt Leverage, logit noreplace 

areg Ln_patent i.ub_trt##i.psm_ubpost $dummy $firmcontrol  $capstructcontrol if window_5year_psm==1,   vce(robust) absorb(sic1)
---------------------------------------------------------------------------------
                    |               Robust
          Ln_patent |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
--------------------+----------------------------------------------------------------
           1.ub_trt |  -.1438368   .0385681    -3.73   0.000    -.2194343   -.0682393
       1.psm_ubpost |    .093931   .0524455     1.79   0.073    -.0088676    .1967296
                    |
  ub_trt#psm_ubpost |
               1 1  |  -.2181459   .0568166    -3.84   0.000    -.3295124   -.1067794
   
   
   
   
   
psmatch2 ub_indicator ub_year_psm sic1 Firmsize Firmsales ln_RD Profitability Capitalexpenditures  Assetstangibility   Equity_assets firm_debt Leverage, logit noreplace 
areg Ln_patent i.ub_trt##i.psm_ubpost $dummy $firmcontrol  $capstructcontrol if window_5year_psm==1,   vce(robust) absorb(sic1)

-------------------------------------------------------------------------------------
                    |               Robust
          Ln_patent |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
--------------------+----------------------------------------------------------------
           1.ub_trt |  -.0609404   .0341762    -1.78   0.075    -.1279286    .0060479
       1.psm_ubpost |   .0903983   .0474461     1.91   0.057       -.0026    .1833966
                    |
  ub_trt#psm_ubpost |
               1 1  |  -.1937132   .0513562    -3.77   0.000    -.2943756   -.0930508
                    |

   
   
 psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales ln_RD  Capitalexpenditures  Assetstangibility   Equity_assets firm_debt , logit noreplace 
 areg Ln_patent i.ub_trt##i.psm_ubpost $dummy $firmcontrol  $capstructcontrol if window_5year_psm==1,   vce(robust) absorb(sic1)

   
                 |               Robust
          Ln_patent |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
--------------------+----------------------------------------------------------------
           1.ub_trt |  -.0760159   .0355606    -2.14   0.033    -.1457184   -.0063135
       1.psm_ubpost |  -.0263626   .0487608    -0.54   0.589    -.1219387    .0692135
                    |
  ub_trt#psm_ubpost |
               1 1  |  -.1369853   .0523665    -2.62   0.009    -.2396289   -.0343416

   
   psmatch2 ub_indicator ub_year_psm sic1  Firmsize Firmsales ln_RD  Capitalexpenditures  Assetstangibility   Equity_assets firm_debt , logit noreplace 
 
   -----------------------------------------------------------------------------------
                    |               Robust
          Ln_patent |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
--------------------+----------------------------------------------------------------
           1.ub_trt |  -.0900021   .0353584    -2.55   0.011    -.1593075   -.0206968
       1.psm_ubpost |   .0157354    .048624     0.32   0.746    -.0795716    .1110425
                    |
  ub_trt#psm_ubpost |
               1 1  |  -.2377645   .0522491    -4.55   0.000    -.3401771   -.1353519

   
   
 psmatch2 ub_indicator ub_year_psm sic1 firmyears Firmsize Firmsales  ln_RD Capitalexpenditures Equity_assets Leverage  firm_debt , logit noreplace 
  
   areg Ln_patent i.ub_trt##i.psm_ubpost $dummy $firmcontrol  $capstructcontrol if window_5year_psm==1,   vce(robust) absorb(sic1)

   
-------------------------------------------------------------------------------------
                    |               Robust
          Ln_patent |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
--------------------+----------------------------------------------------------------
           1.ub_trt |  -.0927658   .0351874    -2.64   0.008    -.1617367    -.023795
       1.psm_ubpost |   .0842763   .0474078     1.78   0.075    -.0086476    .1772002
                    |
  ub_trt#psm_ubpost |
               1 1  |  -.2367624   .0520914    -4.55   0.000    -.3388667   -.1346582
                    |

   
   
   
   
   
   |
***/









