 /*Project:  Cost of bank Loan and Lerner index ***/

/****winsorize data*****/
/*code by Xinting Zhen*/
/*created: 11/18/2015*/
/*last edited date: 11/19/2015*/


 /****************************************winsorize data************************************/
 clear
 set more off
 cd "D:\Research\lernerloan\newreg"
 use lernerloan_all
 
 
gen AISU=commitmentfee+facilityfee
gen totdebt=bookleverage*at
gen loansize=exp(logloansize)
 
gen loanconcentration=loansize/(loansize+totdebt)
gen distance=log(1+ddsic1_b)
save newlernerloan_all, replace

/**winsorize and replace negative value as zero**/
replace ma_l_sfa=0 if ma_l_sfa<0
replace  logloansize=0 if logloansize<0
  ////set benchmark for loansize
replace  logasset=0 if logasset<0

replace max_l_sfa=0 if max_l_sfa<0
replace med_l_sfa=0 if med_l_sfa<0
replace wa_l_sfa=0 if wa_l_sfa<0

save lernerloan_all, replace

/*****check distrbutions for variables*****/
clear
use lernerloan_all

ssc install winsor2

***(1)***
tabstat logasset, stat(n mean sd min p25 median p75 max) col(stat)
/**min:0, mean: 6.35, max:13, n:8960**/
centile logasset, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 95)
/*****centile 10: 3.47**/
/*****centile 40: 5.97**/

/***set benchmark for logasset: only keep asset that's larger than 1000000**/
winsor2 logasset, replace cuts(40 99)
tabstat logasset, stat(n mean sd min p25 median p75 max) col(stat)
/****min:5.97 mean:7.01 max:10***/
save lernerloan_all_winsor, replace

***(2)***
tabstat profitability, stat(n mean sd min p25 median p75 max) col(stat)
/**profitability=ebitda/at **/
/***min:-126, mean:0.09, max:0.93***/
centile profitability, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 95 98 99 100)
/***centile 1: -0.5***/
winsor2 profitability, replace cuts(1 99) 
tabstat profitability, stat(n mean sd min p25 median p75 max) col(stat)
/***min:-.5, mean:0.12, max:0.42, n:8882***/
save lernerloan_all_winsor, replace

***(3)***
tabstat bookleverage, stat(n mean sd min p25 median p75 max) col(stat)
/**bookleverage=(dltt+dlc)/at**/
/***min: 0, mean:0.34, max:8.38, n:8929***/
centile bookleverage, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 95 98 99 100)
/***centile 4:change from zero to 0.0013**/
/***centile 99: 1.13***/
/***centile 98: 0.96***/
winsor2 bookleverage, replace cuts(3 98) 
tabstat bookleverage, stat(n mean sd min p25 median p75 max) col(stat)
/***min: 0, mean:0.34, max:0.95, n:8929***/
save lernerloan_all_winsor, replace

***(4)***
tabstat roaq_sd3, stat(n mean sd min p25 median p75 max) col(stat)
/***min: 0, mean:0.02, max:27, n:8953***/
centile roaq_sd3, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 95 98 99 100)
/***centile 99: 0.26; centile100:27****/
winsor2 roaq_sd3, replace cuts(1 99)
tabstat roaq_sd3, stat(n mean sd min p25 median p75 max) col(stat)
/***min: 0, mean:0.02, max:0.26, n:8953***/
save lernerloan_all_winsor, replace



****(5)****

tabstat AISU, stat(n mean sd min p25 median p75 max) col(stat)
centile  AISU, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40  41 42 45 50 95 98 99 100)
/****below centile41:0,centile42:2.5**/
centile facilityfee, centile(1 2 3 4 5 6 7 8 9 10 40 50 55 60 70 72 74 75 78 80 95 98 99 100)
/****below centile78:0,centile80:4**/
centile upfrontfee, centile(1 2 3 4 5 6 7 8 9 10 40 50 55 60 70 72 74 75 78 80 95 98 99 100)
/****below centile74:0,centile75:5**/

****(6)*****
tabstat spread, stat(n mean sd min p25 median p75 max) col(stat)
centile spread, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40  41 42 45 50 95 98 99 100)
/***min: 0, mean:-50, max:1300, n:9981***/
winsor2 spread, replace cuts (10 95)

****(7)winsor for other variables*****
 winsor2 logspread, replace cuts(1 99)
  winsor2 logmaturity, replace cuts(1 99) 
  winsor2  collateral, replace cuts(1 99) 
  winsor2 logloansize, replace cuts(1 99) 



  winsor2 tangibility , replace cuts(1 99) 
  winsor2 currentratio, replace cuts(1 99)
  winsor2 mtb2, replace cuts(1 99) 
  winsor2 nlead_b, replace cuts(1 99) 
  winsor2 maxleadshare, replace cuts (1 99) 
  winsor2 relloan_amt_b, replace cuts (1 99) 
  winsor2 termspread, replace cuts (1 99) 
  winsor2 ma_l_sfa, replace cuts (1 99) 
  winsor2 max_l_sfa, replace cuts (1 99) 
  winsor2 med_l_sfa, replace cuts (1 99) 
  winsor2 wa_l_sfa, replace cuts (1 99) 
  winsor2 facilityfee, replace cuts (1 99) 
  winsor2 lcfee, replace cuts (1 99) 
  winsor2 upfrontfee, replace cuts (1 99) 
  winsor2 AISU, replace cuts (1 99) 
  winsor2 totdebt, replace cuts (1 99) 
  winsor2 loanconcentration, replace cuts (1 99)

  
  winsor2 meanrty_roa, replace cuts (1 99) 
  winsor2 meanrty_roe, replace cuts (1 99) 
  winsor2 medrty_roa, replace cuts (1 99) 
  winsor2 medrty_roe, replace cuts (1 99) 
  winsor2 med2tvdd , replace cuts (1 99) 
  winsor2 med2tvdw, replace cuts (1 99) 
  winsor2 mean2tvdd, replace cuts (1 99) 
  winsor2 mean2tvdw, replace cuts (1 99) 
  winsor2 meanivxd, replace cuts (1 99)
  winsor2 meanivxw, replace cuts (1 99) 
  winsor2 medivxd, replace cuts (1 99) 
  winsor2 medivxw, replace cuts (1 99) 
  winsor2 medriy_rd, replace cuts (1 99) 
  winsor2 meanriy_rd, replace cuts (1 99) 
  

    winsor2 meantvxd_sic, replace cuts (1 99) 
    winsor2 meantvdd_sic, replace cuts (1 99) 
    winsor2  meantvxw_sic, replace cuts (1 99) 
    winsor2 meantvdw_sic, replace cuts (1 99) 
    winsor2 meanriy_rd_sic, replace cuts (1 99) 
    winsor2 meanivxd_sic, replace cuts (1 99) 
    winsor2 meanivxw_sic, replace cuts (1 99)
    winsor2 meanrty_roa_sic, replace cuts (1 99) 
    winsor2 meanrty_roe_sic, replace cuts (1 99) 
    winsor2 meanriy_ppe_sic, replace cuts (1 99) 
    winsor2 meanriy_capexp_sic, replace cuts (1 99) 
    winsor2 meanriy_debtmat_sic, replace cuts (1 99) 
 
    winsor2 medtvxd_sic, replace cuts (1 99) 
    winsor2 medtvdd_sic, replace cuts (1 99)
    winsor2 medtvxw_sic, replace cuts (1 99) 
    winsor2 medtvdw_sic, replace cuts (1 99) 
    winsor2 medriy_rd_sic, replace cuts (1 99) 
    winsor2 medivxd_sic, replace cuts (1 99) 
    winsor2 medivxw_sic, replace cuts (1 99) 
    winsor2 medrty_roa_sic, replace cuts (1 99) 
    winsor2 medrty_roe_sic, replace cuts (1 99) 
 
    winsor2 medriy_ppe_sic, replace cuts (1 99) 
    winsor2 medriy_capexp_sic, replace cuts (1 99) 
    winsor2 medriy_debtmat_sic, replace cuts (1 99) 
 
 
   winsor2  cntyhhidp, replace cuts (1 99) 
   winsor2 cntytop3dp, replace cuts (1 99) 
  
  
  save lernerloan_all_winsor, replace
  count
  /**9981**/
  duplicates report facilityid cyear
  /***facilityid cyear is unique***/
  
  
  
/******set cutoff point for high hhi and low hhi******/
  clear
  use lernerloan_all_winsor

  /*****generate dummy for high hhi and low hhi*******/
  tabstat cntytop3dp cntyhhidp, stat (n mean sd min p25 median p75 max) col(stat)
  /**
  med of cntytop3dp:.5629886
  med of cntyhhidp:.1530753
  **/
  replace cntytop3dp = 0 if (cntytop3dp >= .)
  replace cntyhhidp = 0 if (cntyhhidp >= .)
   gen highhhi1=(cntytop3dp>.5629886)
   gen highhhi2=(cntyhhidp>.1530753)
   gen lowhhi1=(cntytop3dp<.5629886)
   gen lowhhi2=(cntyhhidp<.1530753)
   gen highhhi3=(cntytop3dp>.18)
    gen lowhhi3=(cntytop3dp<.18)
	
  save lernerloan_all_winsor, replace

  
  
  /****
  
  tabstat  ma_l_sfa  med_l_sfa wa_l_sfa logspread commitmentfee facilityfee lcfee upfrontfee AISU logmaturity logloansize collateral nrel_b nlenders nlead_b leadbank_b ///
distance hhi_lstatshare_nb hhi_lstatshare_amtb hhi_lstatshare_nl hhi_lstatshare_amtl hhi_lsic4share_nl hhi_lsic4share_nb hhi_lsic4share_amtb hhi_lsic4share_amtl cntytop3dp, ///
stat(n mean sd min p25 median p75 max) col(stat)

/*borrower characteristics*/
tabstat logasset profitability bookleverage tangibility roaq_sd3 totdebt loanconcentration logaverageaisd mean2tvdd med2tvdd mean2tvdw med2tvdw meanrty_roa medrty_roa meanrty_roe medrty_roe ///
meanriy_rd  meanivxd meanivxw medriy_rd medivxd medivxw cntytop3dp cntyhhidp , stat(n mean sd min p25 median p75 max) col(stat)

/**correlation table**/
  pwcorr logspread ma_l_sfa commitmentfee facilityfee lcfee upfrontfee AISU logmaturity logloansize collateral nrel_b nlenders nlead_b logasset ///
  profitability bookleverage tangibility roaq_sd3 totdebt loanconcentration logaverageaisd mean2tvdd med2tvdd mean2tvdw med2tvdw meanrty_roa medrty_roa meanrty_roe medrty_roe ///
  meanriy_rd  meanivxd meanivxw medriy_rd medivxd medivxw cntytop3dp cntyhhidp ///
  hhi_lstatshare_nb hhi_lstatshare_amtb hhi_lstatshare_nl hhi_lstatshare_amtl hhi_lsic4share_nl hhi_lsic4share_nb hhi_lsic4share_amtb hhi_lsic4share_amtl cntytop3dp ///
  ,  star(0.01)


  
  
  ****/
