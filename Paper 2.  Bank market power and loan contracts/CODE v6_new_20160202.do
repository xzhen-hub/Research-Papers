
/*********************************Table 4: nonprice term**************************************/
 clear
cd "D:\Research\lernerloan\newreg"
use lernerloan_all_winsor
  winsor2 loansize, replace cuts (1 99) 
 
***column 1: 
global Loancharacteristics="logmaturity  loansize collateral"
global Dummies="termloan loanpurpose1-loanpurpose37 typeloan1-typeloan49 loanyear* withdebtrate  "
global Firmcharacteristics=" logasset profitability bookleverage  tangibility coverage roaq_sd3  "
 
areg logspread ma_l_sfa $Loancharacteristics  $Firmcharacteristics $Dummies if mainsample1==1,vce(robust) absorb(borrsic1)
outreg2 using tablenonprice_v6new.xls, excel asterisk(se) dec(2) replace ctitle(spread) nonotes  bracket drop(typeloan* loanpurpose*  loanyear* termloan withdebtrate)  addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, with debt rate, Yes, Term loan FE, Yes)

 
 /***column 2**/
 ***multivariate test of collateral
  clear
cd "D:\Research\lernerloan\newreg"
cd "F:\Dropbox_Sync\Dropbox\Xinting Zhen\2015 Project banking power and loan contraccts\V6 data and code"
use lernerloan_all_winsor, clear 

global Loancharacteristics="logmaturity loansize loanconcentration "
global Dummies="termloan loanpurpose1-loanpurpose37 typeloan1-typeloan49 loanyear* withdebtrate "
global Firmcharacteristics="  mtb2  bookleverage tangibility  "
/**
areg collateral ma_l_sfa  $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 ,vce(robust) absorb(borrsic1)
**/

destring borrsic1, replace
probit collateral ma_l_sfa  $Firmcharacteristics $Loancharacteristics $Dummies i.borrsic1 if mainsample1==1 ,vce(robust) 

outreg2 using tablenonprice_v6new.xls, excel asterisk(se) dec(2) append ctitle(collateral overall) nonotes   bracket drop(typeloan* loanpurpose*  loanyear* termloan withdebtrate)  addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, with debt rate, Yes, Term loan FE, Yes)

/***column 3**/
**multivariate test of logmaturity
  clear
cd "D:\Research\lernerloan\newreg"
use lernerloan_all_winsor
global Loancharacteristics="loansize collateral "
global Dummies="termloan loanpurpose1-loanpurpose37 typeloan1-typeloan49 loanyear* withdebtrate "
global Firmcharacteristics=" logasset profitability  logassetmaturity bookleverage "

areg logmaturity ma_l_sfa  $Firmcharacteristics $Loancharacteristics $Dummies  if mainsample1==1 ,vce(robust) absorb(borrsic1)
outreg2 using tablenonprice_v6new.xls, excel asterisk(se) dec(2) append ctitle(Logmaturity overall) nonotes   bracket drop(typeloan* loanpurpose*  loanyear* termloan withdebtrate)  addtext(Industry FE, Yes, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, with debt rate, Yes, Term loan FE, Yes)

/***column 4-6**/ 
 /***simultaneous equation**/
//Table 3: nonprice term-3SLS
  clear
cd "D:\Research\lernerloan\newreg"
use lernerloan_all_winsor
global Loancharacteristics="logmaturity collateral loansize"
global Dummies="termloan loanpurpose1-loanpurpose37 typeloan1-typeloan49  loanyear* withdebtrate "
global Firmcharacteristics=" logasset profitability bookleverage tangibility coverage roaq_sd3  "

outreg2 using tablenonprice_v6new.xls, excel asterisk(se) dec(2) append ctitle(IV) nonotes bracket drop( typeloan* loanpurpose*  loanyear*  withdebtrate) addtext(Industry FE, No, Year FE,Yes, Loan purpose, Yes, Loan type, Yes, with debt rate, Yes, Term loan FE, Yes)

 