/*Project:  Cost of bank Loan and Lerner index ***/


/****REGRESSION TEST*****/
/*code by Xinting Zhen*/
/*created: 11/18/2015*/
/*last edited date: 11/19/2015*/
 


 clear
  cd "D:\Research\lernerloan\newreg"
 use lernerloan_all_winsor
 
 /************************************table 1: sample destribution**************************/
 
  
 /************************************* Table 2: summary statistics***************************/
/****loan characteristics****/
tabstat  ma_l_sfa  med_l_sfa  logspread commitmentfee facilityfee lcfee upfrontfee AISU logmaturity logloansize collateral nrel_b nlenders nlead_b leadbank_b ///
distance logfincov  logcov loggencov fincovenant_tot fincovenant_dum gencovenant_tot  gencovenant_dum , ///
stat(n mean sd min p25 median p75 max) col(stat)

/*borrower characteristics*/
tabstat logasset profitability bookleverage tangibility roaq_sd3 totdebt loanconcentration   ///
meanivxw_sic meanivxd_sic meantvdd_sic meantvdw_sic ///
meantvxd_sic  meantvxw_sic meanriy_rd_sic  meanrty_roa_sic  meanrty_roe_sic meanriy_ppe_sic meanriy_capexp_sic meanriy_debtmat_sic  ///
 cntytop3dp cntyhhidp , stat(n mean sd min p25 median p75 max) col(stat)

/**correlation table**/
  pwcorr ma_l_sfa  med_l_sfa  logspread commitmentfee facilityfee lcfee upfrontfee AISU logmaturity logloansize collateral nrel_b nlenders nlead_b leadbank_b ///
distance logfincov  logcov loggencov fincovenant_tot fincovenant_dum gencovenant_tot  gencovenant_dum  ///
logasset profitability bookleverage tangibility roaq_sd3 totdebt loanconcentration  ///
meanivxw_sic meanivxd_sic meantvdd_sic meantvdw_sic ///
meantvxd_sic  meantvxw_sic meanriy_rd_sic  meanrty_roa_sic  meanrty_roe_sic meanriy_ppe_sic meanriy_capexp_sic meanriy_debtmat_sic  ///
 cntytop3dp cntyhhidp ,   star(0.01)
  

  
  
 /***************************table3: baseline regression + IV test**********************/
 clear
  cd "D:\Research\lernerloan\newreg"
 use lernerloan_all_winsor
 
 /***************Add FE and characteristics for baseline reg****************/
 
  /**results are OK: pos sig at 5% for overall, single and nonsingle insig for wa_l_sfa**/
  

global Loancharacteristics="logmaturity  logloansize"
global Dummies=" termloan  loanpurpose1-loanpurpose10  loanyear* creditspread  termspread"
global Firmcharacteristics=" logasset profitability  roaq_sd3 bookleverage tangibility "
  
***column 1:
areg logspread ma_l_sfa $Loancharacteristics  $Firmcharacteristics $Dummies if mainsample1==1,vce(cluster borrowercompanyid) absorb(borrsic1)
outreg2 using tableleadnonlead.xls, excel tstat dec(2) replace ctitle(overall) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
***column 2:
areg logspread ma_l_sfa  $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & nlead_b==1 ,vce(cluster borrowercompanyid) absorb(borrsic1)
outreg2 using tableleadnonlead.xls, excel tstat dec(2) append ctitle(single lead) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
***column 3:
areg logspread ma_l_sfa  $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & nlead_b>1,vce(cluster borrowercompanyid) absorb(borrsic1)
outreg2 using tableleadnonlead.xls, excel tstat dec(2) append ctitle(multiple lead) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)

***column 4:
regress ma_l_sfa  distance $Firmcharacteristics $Loancharacteristics $Dummies if mainsample1==1,vce(cluster borrowercompanyid) 
est sto one
***column 5:
ivregress 2sls logspread $Firmcharacteristics $Loancharacteristics $Dummies (ma_l_sfa= distance) if mainsample1==1,  vce(cluster borrowercompanyid) first
est sto two
outreg2 [one two] using tableleadnonlead.xls, excel tstat dec(2) append ctitle(iv overall) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread )addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)

***column 6:
regress ma_l_sfa  distance $Firmcharacteristics $Loancharacteristics $Dummies if mainsample1==1,vce(cluster borrowercompanyid) 
est sto one
***column 7:
ivregress 2sls logspread $Firmcharacteristics $Loancharacteristics $Dummies (ma_l_sfa= distance) if mainsample1==1 & nlead_b==1,  vce(cluster borrowercompanyid) first
est sto two
outreg2 [one two] using tableleadnonlead.xls, excel tstat dec(2) append ctitle(iv singlelead) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread )addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)

***column 8:
regress ma_l_sfa  distance $Firmcharacteristics $Loancharacteristics $Dummies if mainsample1==1,vce(cluster borrowercompanyid) 
est sto one
***column 9:
ivregress 2sls logspread $Firmcharacteristics $Loancharacteristics $Dummies (ma_l_sfa= distance) if mainsample1==1 & nlead_b>1,  vce(cluster borrowercompanyid) first
est sto two
outreg2 [one two] using tableleadnonlead.xls, excel tstat dec(2) append ctitle(iv multiplelead) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread )addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)

 
/*********************************table 4: nonprice term**************************************/
   clear
  cd "D:\Research\lernerloan\newreg"
 use lernerloan_all_winsor
 
 /***column 1**/
 ***multivariate test of collateral
  global Loancharacteristics="logmaturity logloansize loanconcentration "
global Dummies=" termloan loanpurpose1-loanpurpose10  loanyear* "
global Firmcharacteristics=" mtb2 tangibility bookleverage "

areg collateral ma_l_sfa  $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 ,vce(robust) absorb(borrsic1)
outreg2 using tablenonprice.xls, excel tstat dec(2) replace ctitle(collateral overall) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* withdebtrate ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes)

/***column 2**/
**multivariate test of logmaturity
global Loancharacteristics="logloansize collateral "
global Dummies=" termloan loanpurpose1-loanpurpose10  loanyear* "
global Firmcharacteristics=" mtb2 logassetmaturity  bookleverage"

areg logmaturity ma_l_sfa  $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 ,vce(robust) absorb(borrsic1)
outreg2 using tablenonprice.xls, excel tstat dec(2) append ctitle(Logmaturity overall) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* withdebtrate) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes)

/***column 3**/ 
***multivariate test of collateral
 
global Loancharacteristics="logmaturity logloansize loanconcentration "
global Dummies=" termloan loanpurpose1-loanpurpose10  loanyear* "
global Firmcharacteristics=" mtb2 tangibility bookleverage "

areg collateral ma_l_sfa  $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & nlead_b==1,vce(robust) absorb(borrsic1)
outreg2 using tablenonprice.xls, excel tstat dec(2) append ctitle(collateral single) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* withdebtrate ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes)

/***column 4**/
**multivariate test of logmaturity
global Loancharacteristics="logloansize collateral "
global Dummies=" termloan loanpurpose1-loanpurpose10  loanyear* "
global Firmcharacteristics=" mtb2 logassetmaturity  bookleverage"

areg logmaturity ma_l_sfa  $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & nlead_b==1 ,vce(robust) absorb(borrsic1)
outreg2 using tablenonprice.xls, excel tstat dec(2) append ctitle(Logmaturity single) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* withdebtrate ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes )

/***column 5**/ 
***multivariate test of collateral 
global Loancharacteristics="logmaturity logloansize loanconcentration "
global Dummies="termloan loanpurpose1-loanpurpose10  loanyear* "
global Firmcharacteristics=" mtb2 tangibility bookleverage "

areg collateral ma_l_sfa  $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & nlead_b>1,vce(robust) absorb(borrsic1)
outreg2 using tablenonprice.xls, excel tstat dec(2) append ctitle(collateral multiplelead) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* withdebtrate) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes)

/***column 6**/ 
**multivariate test of logmaturity
global Loancharacteristics="logloansize collateral"
global Dummies=" termloan loanpurpose1-loanpurpose10  loanyear* "
global Firmcharacteristics=" mtb2 logassetmaturity bookleverage"

areg logmaturity ma_l_sfa  $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & nlead_b>1 ,vce(robust) absorb(borrsic1)
outreg2 using tablenonprice.xls, excel tstat dec(2) append ctitle(Logmaturity multiplelead) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* withdebtrate ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes)

/***column 7-9**/ 
 /***simultaneous equation**/
 global control=" termloan loanpurpose1-loanpurpose10  loanyear* "

reg3 (logspread ma_l_sfa defaultloan  collateral logmaturity $control) (logmaturity ma_l_sfa logassetmaturity termspread collateral $control )(collateral ma_l_sfa loanconcentration logmaturity $control), endog(logspread collateral logmaturity ) exog(defaultloan  logassetmaturity termspread loanconcentration)
outreg2 using tablenonprice.xls, excel tstat dec(2) append ctitle(IV overall) nonotes bracket drop( typeloan* loanpurpose*  loanyear*  ) addtext(Industry FE, No, Year FE,Yes, Loan purpose, Yes, Loan type, Yes)


/***column 10-12**/
/***insig for the 1st equation***/
clear
use lernerloan_all_winsor
keep if (nlead_b==1)
  ////7276
  global control=" termloan loanpurpose1-loanpurpose10  loanyear* "

reg3 (logspread ma_l_sfa defaultloan  collateral logmaturity $control) (logmaturity ma_l_sfa logassetmaturity termspread collateral $control )(collateral ma_l_sfa loanconcentration logmaturity $control), endog(logspread collateral logmaturity ) exog(defaultloan  logassetmaturity termspread loanconcentration)
outreg2 using tablenonprice.xls, excel tstat dec(2) append ctitle(IV single) nonotes bracket drop( typeloan* loanpurpose*  loanyear*  ) addtext(Industry FE, No, Year FE,Yes, Loan purpose, Yes, Loan type, Yes)
 


 
 /*********************************Table 5: banking power and covenants*************************************/
clear
use lernerloan_all_winsor
gen totcov=fincovenant_tot+gencovenant_tot


global Loancharacteristics="logmaturity logloansize "
global Dummies=" termloan  loanpurpose1-loanpurpose10  loanyear* creditspread  termspread"
global Firmcharacteristics=" logasset profitability  mtb2 tangibility currentratio"
/***result of "robust" is better than that of "cluster borrowerid"***/
/***for overall sample**/
/***column 1**/ 
nbreg logcov ma_l_sfa $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1,vce(robust)
outreg2 using tablecovenants.xls, excel tstat dec(2)  replace  ctitle(logcov overall) nonotes  eqdrop(lnalpha)  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/***column 2**/ 
nbreg logfincov ma_l_sfa $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1,vce(robust)
outreg2 using  tablecovenants.xls, excel tstat dec(2) append ctitle(logfincovoverall) nonotes eqdrop(lnalpha) bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/***column 3**/ 
/**insig**/
probit gencovenant_dum ma_l_sfa $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 ,vce(robust)
outreg2 using tablecovenants.xls, excel tstat dec(2) append ctitle(gencovdummy overall) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/***column 4 **/ 
probit fincovenant_dum ma_l_sfa $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 ,vce(robust)
outreg2 using tablecovenants.xls, excel tstat dec(2) append ctitle(fincovdummy  overall) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/****column5**/
areg fincovenant_tot ma_l_sfa  $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 ,vce(robust)  absorb(borrsic1)
outreg2 using tablecovenants.xls, excel tstat dec(2) append ctitle(numfin overall) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/****column6**/
/**insig**/
areg gencovenant_tot ma_l_sfa  $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 ,vce(robust)  absorb(borrsic1)
outreg2 using  tablecovenants.xls, excel tstat dec(2) append ctitle(numgen overall) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/****column7**/
/**insig**/
areg totcov ma_l_sfa  $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 ,vce(robust)  absorb(borrsic1)
outreg2 using  tablecovenants.xls, excel tstat dec(2) append ctitle(numtot overall) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)

/***for single lead bank***/
/***results are better than overall sample**/
/***column 8**/ 
nbreg logcov ma_l_sfa $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & nlead_b==1,vce(robust)
outreg2 using  tablecovenants.xls, excel tstat dec(2) append ctitle(logcovsingle) nonotes eqdrop(lnalpha)  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/***column 9**/ 
nbreg logfincov ma_l_sfa $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & nlead_b==1,vce(robust)
outreg2 using  tablecovenants.xls, excel tstat dec(2) append ctitle(logfincovsingle) nonotes eqdrop(lnalpha) bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)

/***column 10**/ 
probit gencovenant_dum ma_l_sfa $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & nlead_b==1,vce(robust)
outreg2 using tablecovenants.xls, excel tstat dec(2) append ctitle(gencovdummy single) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/***column 11*/ 
probit fincovenant_dum ma_l_sfa $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & nlead_b==1,vce(robust)
outreg2 using tablecovenants.xls, excel tstat dec(2) append ctitle(fincovdummy single) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)

/****column12**/
areg fincovenant_tot ma_l_sfa  $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1& nlead_b==1 ,vce(robust)  absorb(borrsic1)
outreg2 using  tablecovenants.xls, excel tstat dec(2) append ctitle(numfin single) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/****column13**/
/**insig**/
areg gencovenant_tot ma_l_sfa  $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & nlead_b==1,vce(robust)  absorb(borrsic1)
outreg2 using  tablecovenants.xls, excel tstat dec(2) append ctitle(numgen single) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/****column14**/
areg totcov ma_l_sfa  $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & nlead_b==1,vce(robust)  absorb(borrsic1)
outreg2 using  tablecovenants.xls, excel tstat dec(2) append ctitle(numtot overall) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)



  /*********************************Table 6: infor opacity************************************/
  /***insignificant for R&D, withdebtrate*****/
  /***need to find more proxies for infor opacity****/
  
clear
use lernerloan_all_winsor

  /*****another proxy for infor opacity: bigpayer: bigplayer=0; if sale>sale75 then bigplayer=1****/
  /***microstructure proxies (bid-ask spreads....)**/
  
  /****In related literature, it has been measure using the variance of the idyosicratic risk standardized by firms total variance. ///
  A higher proportion of firm-specific risk indicates investors have more information about the firm and depend less on the behaviour of the overall market, ///
  is more "trasparent".
  ***/
  
  /***
  Another standard proxy for information asymmetry is the bid-ask spread for the stock prices. ///
  spread: If the investor is willing (bidding) to pay an amount that is less than what the owner is asking to sell it for, ///
  it must be because the owner/seller and the potential buyer/shareholder have different information endowments. ///
  This leads to information asymmetry.
  ***/
  
  
  
  
  global Loancharacteristics="logmaturity logloansize "
global Firmcharacteristics="profitability mtb2 bookleverage "
global Dummies=" termloan  loanpurpose1-loanpurpose10  loanyear*  creditspread termspread "


/***column1***/
areg logspread c.ma_l_sfa##c.logasset $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 ,vce(robust) absorb(borrsic1)
outreg2 using tableinforopacity_rbt.xls, excel tstat dec(2) replace ctitle(logasset) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)

/***column2***/
/**insig**/
areg logspread c.ma_l_sfa##i.withdebtrate $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 ,vce(robust) absorb(borrsic1)
outreg2 using tableinforopacity_rbt.xls, excel tstat dec(2) append ctitle(withdebtrate) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)

/***column3***/
areg logspread c.ma_l_sfa##i.sp500firm $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 ,vce(robust) absorb(borrsic1)
outreg2 using tableinforopacity_rbt.xls, excel tstat dec(2) append ctitle(sp500) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)

/***column4***/
areg logspread c.ma_l_sfa##i.bigplayer $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 ,vce(robust) absorb(borrsic1)
outreg2 using tableinforopacity_rbt.xls, excel tstat dec(2) append ctitle(bigplayer) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)

/***column5***/
/***insig for bid-ask spread***/
/***
If Closing Price of Bid/Ask Average is zero and Spread between Bid and Ask is negative, the spread represents a Bid or Low Price.
If Closing Price or Bid/Ask Average is zero and Spread between Bid and Ask is positive, Spread Between Bid and Ask represents an Ask or High Price.
**/  
areg logspread c.ma_l_sfa##c.spread $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 ,vce(robust) absorb(borrsic1)
outreg2 using tableinforopacity_rbt.xls, excel tstat dec(2) append ctitle(spread) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)


 
/***********************************Table 7. interaction of sc and lerner **********************************/
 
/****SIG FOR: meanivxw_sic meanivxd_sic meantvdd_sic meantvdw_sic***/


global Loancharacteristics="logmaturity logloansize  "
global Dummies=" termloan  loanpurpose1-loanpurpose10  loanyear* creditspread termspread "
global Firmcharacteristics=" logasset profitability   "

/**column1**/
areg logspread c.ma_l_sfa##c.meantvdd_sic $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 ,vce(robust) absorb(borrsic1)
outreg2 using tablesc_rbt.xls, excel tstat dec(2) replace ctitle(totalrisk 1) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/**column2**/
areg logspread c.ma_l_sfa##c.meantvdw_sic $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 ,vce(robust) absorb(borrsic1)
outreg2 using tablesc_rbt.xls, excel tstat dec(2) append ctitle(totalrisk 2) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/**column3**/
areg logspread c.ma_l_sfa##c.meanivxd_sic $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 ,vce(robust) absorb(borrsic1)
outreg2 using tablesc_rbt.xls, excel tstat dec(2) append ctitle(idiorisk 1) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/**column4**/
 areg logspread c.ma_l_sfa##c.meanivxw_sic $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 ,vce(robust) absorb(borrsic1)
outreg2 using tablesc_rbt.xls, excel tstat dec(2) append ctitle(idiorisk 2) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)

/**column5**/
/**insig**/
 areg logspread c.ma_l_sfa##c.n_uniqueBL__3yr $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 ,vce(robust) absorb(borrsic1)
outreg2 using tablesc_rbt.xls, excel tstat dec(2) append ctitle(uniquebankloan_3yr) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/**column6**/
/**insig**/
 areg logspread c.ma_l_sfa##c.n_uniqueBL__5yr $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 ,vce(robust) absorb(borrsic1)
outreg2 using tablesc_rbt.xls, excel tstat dec(2) append ctitle(uniquebankloan_5yr) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
 



/*****Note: results are insig for lerner*HHI interaction ******/ 
/*****Note: results are insig for lerner*sc interaction in HHI subsample******/ 
  

/***********************************Table 8. effect of lernerindex on loan rates in HHI subsample*******************************/
clear
use lernerloan_all_winsor
global Loancharacteristics="logmaturity logloansize  n_uniqueBL__3yr "
global Dummies=" termloan  loanpurpose1-loanpurpose10  loanyear* creditspread termspread"
global Firmcharacteristics=" logasset  profitability mtb2 currentratio rdintensity  meanrty_roa_sic"

/**column1**/
areg logspread ma_l_sfa $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & highhhi3==1  ,vce(robust) absorb(borrsic1)
outreg2 using tablesc_HHI.xls, excel tstat dec(2) replace ctitle(1) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/**column2**/
areg logspread ma_l_sfa $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & highhhi3==1  ,vce(robust) absorb(borrsic1)
outreg2 using tablesc_HHI.xls, excel tstat dec(2) append ctitle(2) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/**column3**/
areg logspread ma_l_sfa  $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 &  highhhi3==0 ,vce(robust) absorb(borrsic1)
outreg2 using tablesc_HHI.xls, excel tstat dec(2) append ctitle(3) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/**column4**/
areg logspread ma_l_sfa $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1  & highhhi3==0 ,vce(robust) absorb(borrsic1)
outreg2 using tablesc_HHI.xls, excel tstat dec(2) append ctitle(4) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)

 /**note: results changes if add rdintensity  meanrty_roa_sic as IV: neg sig for ma_l_sfa in low HHI subsample*/ 
  
  
 /* ****results are bad for the interaction
 /*****interaction for high HHI and low HHI*******/
global Loancharacteristics="logmaturity logloansize  "
global Dummies=" termloan  loanpurpose1-loanpurpose10  loanyear* creditspread termspread "
global Firmcharacteristics=" logasset profitability   "

/**column1**/
areg logspread c.ma_l_sfa##c.meantvdd_sic $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & highhhi3==1,vce(robust) absorb(borrsic1)
outreg2 using tablesc_lerner_hhi.xls, excel tstat dec(2) replace ctitle(totalrisk 1) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/**column2**/
areg logspread c.ma_l_sfa##c.meantvdw_sic $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & highhhi3==1,vce(robust) absorb(borrsic1)
outreg2 using tablesc_lerner_hhi.xls, excel tstat dec(2) append ctitle(totalrisk 2) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/**column3**/
areg logspread c.ma_l_sfa##c.meanivxd_sic $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & highhhi3==1 ,vce(robust) absorb(borrsic1)
outreg2 using tablesc_lerner_hhi.xls, excel tstat dec(2) append ctitle(idiorisk 1) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/**column4**/
 areg logspread c.ma_l_sfa##c.meanivxw_sic $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & highhhi3==1,vce(robust) absorb(borrsic1)
outreg2 using tablesc_lerner_hhi.xls, excel tstat dec(2) append ctitle(idiorisk 2) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)

/**column5**/
/**insig**/
 areg logspread c.ma_l_sfa##c.n_uniqueBL__3yr $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & highhhi3==1,vce(robust) absorb(borrsic1)
outreg2 using tablesc_lerner_hhi.xls, excel tstat dec(2) append ctitle(uniquebankloan_3yr) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/**column6**/
/**insig**/
 areg logspread c.ma_l_sfa##c.n_uniqueBL__5yr $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & highhhi3==1,vce(robust) absorb(borrsic1)
outreg2 using tablesc_lerner_hhi.xls, excel tstat dec(2) append ctitle(uniquebankloan_5yr) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
 
/**column7**/
areg logspread c.ma_l_sfa##c.meantvdd_sic $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & highhhi3==0,vce(robust) absorb(borrsic1)
outreg2 using tablesc_lerner_hhi.xls, excel tstat dec(2) append ctitle(totalrisk 1) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/**column8**/
areg logspread c.ma_l_sfa##c.meantvdw_sic $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & highhhi3==0,vce(robust) absorb(borrsic1)
outreg2 using tablesc_lerner_hhi.xls, excel tstat dec(2) append ctitle(totalrisk 2) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/**column9**/
areg logspread c.ma_l_sfa##c.meanivxd_sic $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & highhhi3==0 ,vce(robust) absorb(borrsic1)
outreg2 using tablesc_lerner_hhi.xls, excel tstat dec(2) append ctitle(idiorisk 1) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/**column10**/
 areg logspread c.ma_l_sfa##c.meanivxw_sic $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & highhhi3==0,vce(robust) absorb(borrsic1)
outreg2 using tablesc_lerner_hhi.xls, excel tstat dec(2) append ctitle(idiorisk 2) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)

/**column11**/
/**insig**/
 areg logspread c.ma_l_sfa##c.n_uniqueBL__3yr $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & highhhi3==0,vce(robust) absorb(borrsic1)
outreg2 using tablesc_lerner_hhi.xls, excel tstat dec(2) append ctitle(uniquebankloan_3yr) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
/**column12**/
/**insig**/
 areg logspread c.ma_l_sfa##c.n_uniqueBL__5yr $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 & highhhi3==0,vce(robust) absorb(borrsic1)
outreg2 using tablesc_lerner_hhi.xls, excel tstat dec(2) append ctitle(uniquebankloan_5yr) nonotes  bracket drop( typeloan* loanpurpose*  loanyear* creditspread termspread ) addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, Credit spread, Yes, Term spread, Yes)
   */
 
 
  
  
  
  
/*  
  tabstat termloan, stat(n mean sd min p25 median p75 max) col(stat)///n=9981
  tabstat  creditspread, stat(n mean sd min p25 median p75 max) col(stat)///n=9981
  tabstat termspread, stat(n mean sd min p25 median p75 max) col(stat)///n=9981
  tabstat ma_l_sfa, stat(n mean sd min p25 median p75 max) col(stat)///9981
  tabstat logspread, stat(n mean sd min p25 median p75 max) col(stat)///n=8944
  tabstat currentratio, stat(n mean sd min p25 median p75 max) col(stat)////8444

  count if (mainsample1==1)
  ///9291
   count if (mainsample1==1& nlead_b==1)
  ///6879
  
 /*** borrsic1 :represent different industries****/
*/
