
  /*****************updated date: 07/29/2020*******************************/
/*********************run regression tests***********************************/
set more off
set more on

cd "E:\Research\bank deregulation and cf sensitivity\code and data_xt"

use "E:\Research\bank deregulation and cf sensitivity\code and data_xt\comp7006_v6.dta", clear
duplicates report gvkey cyear
//unique
   
* keep gvkey statecode cyear dinter dintra qcc1   rs_bri rs_year
 drop _merge 
 
 /******replace missing values with the previous values for each statecode year*************/
sort statecode cyear
gen rs_st=rs_bri
by statecode: replace rs_st=rs_st[_n-1] if rs_st==.
/*****replace all missing values before the index year with zero***********/
replace rs_st=4 if  rs_st==.
/*****drop the matched values that only apply to particular year******/
*drop rs_year

 
gen rs_yr=rs_year
by statecode: replace rs_yr=rs_yr[_n-1] if rs_yr==.
 


//drop delaware and south dakota********************
 drop if statecode==10 
 drop if statecode==46
 
 codebook cyear
 
               /**************************test geo diversification*************************************************/
               use "F:\XINTING_research\Banking power and IPO\dataneed\all_div_index.dta" , clear
               keep year stnumbr stname div_index_RSSDst div_index_BHCst
               rename year cyear
               rename stnumbr statecode
			   
			   	bysort statecode cyear: egen geodiv_mean=mean(div_index_BHCst)
			    gen high_geodiv2=(div_index_BHCst>=geodiv_mean)  
		        gen low_geodiv2=(div_index_BHCst<geodiv_mean)

			   
			   
			   
			   duplicates drop stnumbr year, force
               count
               //1180
               save "E:\Research\bank deregulation and cf sensitivity\code and data_xt\div_st.dta", replace

/*** merge with the master file************
joinby statecode cyear using "E:\Research\bank deregulation and cf sensitivity\code and data_xt\div_st.dta", unm(master)
drop _merge
***/
    
                 /***********following Rice and strahan (2010), use the state of the firm to merge our branching restrictions variable to the data set.****************/
	             import delimited "E:\Research\bank deregulation and cf sensitivity\code and data_xt\RS index\brionly_v2.csv", clear
	             *gen cyear=rs_year
	             save "E:\Research\bank deregulation and cf sensitivity\code and data_xt\RS index\brionly_v2.dta", replace	  
		  
		  
/*********merge with the RS index********************/
joinby statecode using "E:\Research\bank deregulation and cf sensitivity\code and data_xt\RS index\brionly_v2.dta", unm(master)
drop _merge


 
 /***********the sample for: bank deregulation and cash flow sensitivity****************/
 /*************************************************************************************/
 
//generate yid, which indicate how many years that each firm has in the data;
// this will use to control the IPO effect on firms, we will including only yid>=5 for one of our subsample robustness check;

//keep the tobin's q from 1 to 10
keep if qcc1>=0 & qcc1<=10
/***11810 dropped during this step****/
*keep if qbp>=0 & qbp<=10
/***18470 dropped during this step****/

                                    /*******Pay attention: when run regression for financial constraint/hedging need, don't run this step*******/
                                    ***drop missed deregulation data**
                                     drop if missing(inter)
                                     drop if missing(intra)
									 
									 count if missing(inter)| missing(intra)
									 
count //69406 if not drop interdrops; l42472, not 14832, not 12693， not 32694

codebook cyear

  replace stockissue=0 if missing(stockissue)
  replace  stockissue2=0 if missing(stockissue2)
  replace ltdebt=0 if missing(ltdebt)
  replace cap_ppent=0 if missing(cap_ppent)
  replace cf_ppent=0 if missing(cf_ppent)
  replace cash=0 if missing(cash)
  
  replace cap_ta=0 if missing(cap_ta)
  replace cf_at=0 if missing(cf_at)
  

//Winsorize all variables by each cyear for all non finicial firms;
  winsor2 at cap_ta ivbp cash cf_at cap_ppent cf_ppent size firm_age qcc1 qcc2 qbp stockissue stockissue2 ltdebt bklev mkt_book, s(w) cut(1 99) by(cyear)
  
rename cap_taw investment1
rename cap_ppentw investment2
rename cf_atw cash_flow1
rename cf_ppentw cash_flow2
rename qcc1w tobin_q1
rename qcc2w tobin_q2
rename qbpw tobin_q3

rename sizew firmsize
rename stockissuew stock_issues
rename stockissue2w stock_issues2
rename ltdebtw lt_debt
rename bklevw bookleverage
rename mkt_bookw markettobook
  
 
 
rename ivbpw invest_rd

centile invest_rd,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)




xtset gvkey cyear
gen ivbp2=(capx+xrd)/l.ppent

centile ivbp2,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 ivbp2, s(w) cut(1 99) by(cyear)

 
 /*******don't run the following codes for baseline***********
egen var1=min(cyear), by(gvkey)
egen var2=max(cyear), by(gvkey)

gen interdrop1=inter-var1
gen interdrop2=var2-inter
gen intradrop1=intra-var1
gen intradrop2=var2-intra
keep if interdrop1>=2 & interdrop2>=2 & intradrop1>=2 & intradrop2>=2

 *************/
  replace atw=0 if atw==.
 replace firmsize=0 if firmsize==.
 replace tobin_q3=0 if tobin_q3==.
/***revise the SU table**********/
tabstat investment1 cash_flow1 investment2 cash_flow2 rs_st dinter dintra atw firmsize cash firm_agew tobin_q3  stock_issues stock_issues2 lt_debt , stat  (n mean sd p25 p50 p75 min max) col(stat)



/*******************different time sample*****************/
gen timesample1=(cyear>=1970 & cyear<1998)
gen timesample2=(cyear>1970 & cyear<=1994)

gen timesample3=(cyear>=1997 & cyear<2007)
gen timesample4=(cyear>=1994 & cyear<2007)


tostring sic_r, replace
gen sic1=substr(sic_r, 1,1)
gen sic2=substr(sic_r, 1,2)
gen sic3=substr(sic_r, 1,3)

destring sic_r sic1 sic2 sic3, replace


tab cyear, gen(YEAR)
global firmcontrol="firmsize tobin_q1 cashw stock_issues lt_debt"
global dummy="YEAR* "

/******baseline regression***********/

/*********Table 2. Baseline regression: *********************************************************************************/
/********pay attention: sclaed by ppent is better than scaling by at********************/


egen var1=min(cyear), by(gvkey)
egen var2=max(cyear), by(gvkey)

gen interdrop1=inter-var1
gen interdrop2=var2-inter
gen intradrop1=intra-var1
gen intradrop2=var2-intra

gen drop=(interdrop1>=2 & interdrop2>=2&   intradrop1>=2 & intradrop2>=2)

/**
gen drop2=(intradrop1>=2 & intradrop2>=2)
gen drop3=(intradrop1>=2)
count if drop==1
**/
gen time1=(cyear>=1997 & cyear<2007)

	

/***use different outreg2 code********/
areg investment2  c.cash_flow2##i.dinter  $firmcontrol  $dummy, vce(cluster gvkey) absorb(gvkey)
outreg2 using table2base0825.xls, excel  dec(4)  replace title(Baseline) ctitle(Inter-1970-2006) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes) adjr2
areg investment2  c.cash_flow2##i.dintra $firmcontrol  $dummy, vce(cluster gvkey) absorb(gvkey)
outreg2 using table2base0825.xls, excel  dec(4)  append title(Baseline) ctitle(Intra-1970-2006) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes) adjr2
areg investment2  c.cash_flow2##c.rs_st   $firmcontrol  $dummy , vce(cluster gvkey) absorb(gvkey)
outreg2 using table2base0825.xls, excel  dec(4)  append title(Baseline) ctitle(BRI-1970-2006) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes) adjr2






/****************Table 3. GMM***************************************/
//EW measuremenst error for Q GMM table
 /********center variables *******************/
 
/***install center package**/
*ssc install center, replace


ssc install center, replace

gen cf_inter=cash_flow2*dinter
gen cf_intra=cash_flow2*dintra
gen cf_bri=cash_flow2*rs_st

bysort gvkey: center investment2 , generate (iv_center)
bysort gvkey: center cash_flow2, generate (cf_center)


bysort gvkey: center tobin_q1, generate (q_center)
bysort gvkey: center cashw, generate (cash_center)
bysort gvkey: center stock_issues2, generate (stock_center)
bysort gvkey: center firmsize, generate (size_center)


bysort gvkey: center lt_debt, generate (ld_center)
bysort gvkey: center dinter, generate (dinter_center)
bysort gvkey: center dintra, generate (dintra_center)

bysort gvkey: center rs_st, generate (rs_center)
bysort gvkey: center cf_bri, generate (cf_bri_center)
bysort gvkey: center cf_inter, generate (cf_inter_center)
bysort gvkey: center cf_intra, generate (cf_intra_center)



gen cf_rs=cf_center*rs_center
gen inter_cf=dinter_center*cf_center
gen intra_cf=dintra_center*cf_center


//create year dummy for GMM using;
xi i.cyear


*bysort gvkey: center _Icyear_1970, gen(_Idmcyear_1970)
bysort gvkey: center _Icyear_1971, gen(_Idmcyear_1971)
bysort gvkey: center _Icyear_1972, gen(_Idmcyear_1972)
bysort gvkey: center _Icyear_1973, gen(_Idmcyear_1973)
bysort gvkey: center _Icyear_1974, gen(_Idmcyear_1974)
bysort gvkey: center  _Icyear_1975, gen(_Idmcyear_1975)
bysort gvkey: center  _Icyear_1976, gen(_Idmcyear_1976)
bysort gvkey: center  _Icyear_1977, gen(_Idmcyear_1977)
bysort gvkey: center  _Icyear_1978, gen(_Idmcyear_1978)
bysort gvkey: center  _Icyear_1979, gen(_Idmcyear_1979)
bysort gvkey: center  _Icyear_1980, gen(_Idmcyear_1980)
bysort gvkey: center  _Icyear_1981, gen(_Idmcyear_1981)
bysort gvkey: center  _Icyear_1982, gen(_Idmcyear_1982)
bysort gvkey: center  _Icyear_1983, gen(_Idmcyear_1983)
bysort gvkey: center  _Icyear_1984, gen(_Idmcyear_1984)
bysort gvkey: center  _Icyear_1985, gen(_Idmcyear_1985)
bysort gvkey: center  _Icyear_1986, gen(_Idmcyear_1986)
bysort gvkey: center  _Icyear_1987, gen(_Idmcyear_1987)
bysort gvkey: center  _Icyear_1988, gen(_Idmcyear_1988)
bysort gvkey: center  _Icyear_1989, gen(_Idmcyear_1989)
bysort gvkey: center  _Icyear_1990, gen(_Idmcyear_1990)
bysort gvkey: center  _Icyear_1991, gen(_Idmcyear_1991)
bysort gvkey: center  _Icyear_1992, gen(_Idmcyear_1992)
bysort gvkey: center  _Icyear_1993, gen(_Idmcyear_1993)
bysort gvkey: center  _Icyear_1994, gen(_Idmcyear_1994)
bysort gvkey: center  _Icyear_1995, gen(_Idmcyear_1995)
bysort gvkey: center  _Icyear_1996, gen(_Idmcyear_1996)
bysort gvkey: center  _Icyear_1997, gen(_Idmcyear_1997)
bysort gvkey: center  _Icyear_1998, gen(_Idmcyear_1998)
bysort gvkey: center  _Icyear_1999, gen(_Idmcyear_1999)
bysort gvkey: center  _Icyear_2000, gen(_Idmcyear_2000)
bysort gvkey: center  _Icyear_2001, gen(_Idmcyear_2001)
bysort gvkey: center  _Icyear_2002, gen(_Idmcyear_2002)
bysort gvkey: center  _Icyear_2003, gen(_Idmcyear_2003)
bysort gvkey: center  _Icyear_2004, gen(_Idmcyear_2004)
bysort gvkey: center  _Icyear_2005, gen(_Idmcyear_2005)
bysort gvkey: center  _Icyear_2006, gen(_Idmcyear_2006)



xi i.statecode

*bysort gvkey: center _Istatecode_1, gen(_Idmstate_1)
*bysort gvkey: center _Istatecode_2, gen(_Idmstate_2)
*bysort gvkey: center _Istatecode_3, gen(_Idmstate_3)
*bysort gvkey: center _Istatecode_4, gen(_Idmstate_4)
bysort gvkey: center _Istatecode_5, gen(_Idmstate_5)
*bysort gvkey: center _Istatecode_6, gen(_Idmstate_6）
*bysort gvkey: center _Istatecode_7, gen(_Idmstate_7）
bysort gvkey: center _Istatecode_8, gen(_Idmstate_8)
bysort gvkey: center _Istatecode_9, gen(_Idmstate_9)

*bysort gvkey: center _Istatecode_10, gen(_Idmstate_10）
*bysort gvkey: center _Istatecode_11, gen(_Idmstate_11）
bysort gvkey: center _Istatecode_12, gen(_Idmstate_12)
bysort gvkey: center _Istatecode_13, gen(_Idmstate_13)
*bysort gvkey: center _Istatecode_14, gen(_Idmstate_14)
bysort gvkey: center _Istatecode_15, gen(_Idmstate_15)
*bysort gvkey: center _Istatecode_16, gen(_Idmstate_16)
bysort gvkey: center _Istatecode_17, gen(_Idmstate_17)
bysort gvkey: center _Istatecode_18, gen(_Idmstate_18)
bysort gvkey: center _Istatecode_19, gen(_Idmstate_19)

bysort gvkey: center _Istatecode_20, gen(_Idmstate_20)
bysort gvkey: center _Istatecode_21, gen(_Idmstate_21)
bysort gvkey: center _Istatecode_22, gen(_Idmstate_22)
bysort gvkey: center _Istatecode_23, gen(_Idmstate_23)
*bysort gvkey: center _Istatecode_24, gen(_Idmstate_24)

bysort gvkey: center _Istatecode_25, gen(_Idmstate_25)
bysort gvkey: center _Istatecode_26, gen(_Idmstate_26)
bysort gvkey: center _Istatecode_27, gen(_Idmstate_27)
bysort gvkey: center _Istatecode_28, gen(_Idmstate_28)
bysort gvkey: center _Istatecode_29, gen(_Idmstate_29)

bysort gvkey: center _Istatecode_30, gen(_Idmstate_30)
bysort gvkey: center _Istatecode_31, gen(_Idmstate_31)
*bysort gvkey: center _Istatecode_32, gen(_Idmstate_32）
bysort gvkey: center _Istatecode_33, gen(_Idmstate_33)
bysort gvkey: center _Istatecode_34, gen(_Idmstate_34)
bysort gvkey: center _Istatecode_35, gen(_Idmstate_35)
bysort gvkey: center _Istatecode_36, gen(_Idmstate_36)
*bysort gvkey: center _Istatecode_37, gen(_Idmstate_37)
bysort gvkey: center _Istatecode_38, gen(_Idmstate_38)
bysort gvkey: center _Istatecode_39, gen(_Idmstate_39)


bysort gvkey: center _Istatecode_40, gen(_Idmstate_40)
bysort gvkey: center _Istatecode_41, gen(_Idmstate_41)
bysort gvkey: center _Istatecode_42, gen(_Idmstate_42)
*bysort gvkey: center _Istatecode_43, gen(_Idmstate_43)
*bysort gvkey: center _Istatecode_44, gen(_Idmstate_44)
*bysort gvkey: center _Istatecode_45, gen(_Idmstate_45)
*bysort gvkey: center _Istatecode_46, gen(_Idmstate_46)
bysort gvkey: center _Istatecode_47, gen(_Idmstate_47)
bysort gvkey: center _Istatecode_48, gen(_Idmstate_48)
bysort gvkey: center _Istatecode_49, gen(_Idmstate_49)

*bysort gvkey: center _Istatecode_50, gen(_Idmstate_50)
bysort gvkey: center _Istatecode_51, gen(_Idmstate_51)
*bysort gvkey: center _Istatecode_52, gen(_Idmstate_52)
bysort gvkey: center _Istatecode_53, gen(_Idmstate_53)
bysort gvkey: center _Istatecode_54, gen(_Idmstate_54)
bysort gvkey: center _Istatecode_55, gen(_Idmstate_55)
bysort gvkey: center _Istatecode_56, gen(_Idmstate_56)

*codebook sic1

xi i.sic1
bysort gvkey: center  _Isic1_1, gen(_Idmsic1_1)
bysort gvkey: center  _Isic1_2, gen(_Idmsic1_2)
bysort gvkey: center  _Isic1_3, gen(_Idmsic1_3)
bysort gvkey: center  _Isic1_4, gen(_Idmsic1_4)
bysort gvkey: center  _Isic1_5, gen(_Idmsic1_5)
*bysort gvkey: center  _Isic1_6, gen(_Idmsic1_6)
bysort gvkey: center  _Isic1_7, gen(_Idmsic1_7)
bysort gvkey: center  _Isic1_8, gen(_Idmsic1_8)
bysort gvkey: center  _Isic1_9, gen(_Idmsic1_9)

/****results are good if not drop missing inter and intra**********/
xtewreg iv_center cf_center   dinter_center  cf_inter_center     q_center size_center  cash_center stock_center  ld_center   _Idmcyear_*, maxdeg(3) no
outreg2 using table3EWgmmforQ_0825.xls, replace dec(4) sdec(4) ctitle(GMM 3-inter) nodepvar drop(_Idmcyear_*) addstat(Rho^2, e(rho)) 


xtewreg iv_center cf_center  dintra_center   intra_cf   q_center size_center cash_center stock_center  ld_center  _Idmcyear_*, maxdeg(3) no
outreg2 using table3EWgmmforQ_0825.xls, append dec(4) sdec(4) ctitle(GMM 3-intra) nodepvar drop(_Idmcyear_*) addstat(Rho^2, e(rho)) 


xtewreg iv_center cf_center   dinter_center  cf_inter_center       q_center size_center  cash_center stock_center  ld_center   _Idmcyear_*, maxdeg(4) no
outreg2 using table3EWgmmforQ_0825.xls, append dec(4) sdec(4) ctitle(GMM 4-inter) nodepvar drop(_Idmcyear_*) addstat(Rho^2, e(rho)) 

xtewreg iv_center cf_center  dintra_center    intra_cf    q_center size_center cash_center stock_center  ld_center  _Idmcyear_*, maxdeg(4) no
outreg2 using table3EWgmmforQ_0825.xls, append dec(4) sdec(4) ctitle(GMM 4-intra) nodepvar drop(_Idmcyear_*) addstat(Rho^2, e(rho)) 



//3. dynamic effects*****/
 drop if missing(inter)
 drop if missing(intra)

 gen yeardiff_inter=cyear-inter
*drop inter_pre3  inter_pre2  inter_pre1 inter_post0 inter_post1 inter_post2 inter_post3
 
gen inter_pre3=(yeardiff_inter==-3)
gen inter_pre2=(yeardiff_inter==-2)
gen inter_pre1=(yeardiff_inter==-1)

gen inter_post0=(yeardiff_inter==0)

gen inter_post1=(yeardiff_inter==1)
gen inter_post2=(yeardiff_inter==2)
gen inter_post3=(yeardiff_inter>=3)

drop window2 
gen window2=(yeardiff_inter>=-6 & yeardiff_inter<=5)
*gen window3=(yeardiff_inter>=-3 & yeardiff_inter<4)
*gen window4=(yeardiff_inter>=-2 & yeardiff_inter<=3)

gen yeardiff_intra=cyear-intra
drop intra_pre3  intra_pre2  intra_pre1 intra_post1 intra_post2 intra_post3
*drop intra_pre3 intra_pre2 intra_pre1 
*intra_post2 intra_post3

gen intra_pre3=(yeardiff_intra==-3)
gen intra_pre2=(yeardiff_intra==-2)
gen intra_pre1=(yeardiff_intra==-1)

gen intra_post1=(yeardiff_intra==1)
gen intra_post2=(yeardiff_intra==2)
gen intra_post3=(yeardiff_intra>=3)

drop window1
gen window1=(yeardiff_intra>=-6 & yeardiff_intra<=5)

gen window=(window1==1 | window2==1)

/*****test for inter and intra separately based on window2 and window1, results are bad!!******/
/****use investement2 as DV, if window2==1: results are good****/
/****use ivbp2w is not good*************/
areg  investment2 c.cash_flow2##c.inter_pre3 $firmcontrol  $dummy if window2==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using tabledym0825.xls, excel  dec(4)  replace ctitle(interpre3) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes) adjr2


areg  investment2 c.cash_flow2##c.inter_pre2 $firmcontrol  $dummy if window2==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using tabledym0825.xls, excel  dec(4)  append ctitle(interpre2) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes) adjr2

areg  investment2 c.cash_flow2##c.inter_pre1 $firmcontrol  $dummy if window2==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using tabledym0825.xls, excel  dec(4)  append ctitle(interpre1) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes) adjr2


areg investment2 c.cash_flow2##c.inter_post1 $firmcontrol  $dummy if window2==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using tabledym0825.xls, excel  dec(4)  append ctitle(interpost1) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes) adjr2

areg investment2 c.cash_flow2##c.inter_post2 $firmcontrol  $dummy if window2==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using tabledym0825.xls, excel  dec(4)  append ctitle(interpost2) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes) adjr2

areg investment2 c.cash_flow2##c.inter_post3 $firmcontrol  $dummy  if window2==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using tabledym0825.xls, excel  dec(4)  append ctitle(interpost3) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes) adjr2




//3. dynamic effects*****/

/***********intra_pre3: positive sig*******
areg investment2 c.cash_flow2##c.intra_pre3 $firmcontrol  $dummy if window1==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using tabledym0825.xls, excel  dec(4)  append ctitle(intrapre3) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes) adjr2
***/

areg investment2  c.cash_flow2##c.intra_pre2 $firmcontrol  $dummy if window1==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using tabledym0825.xls, excel  dec(4)  append ctitle(intrapre2) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes) adjr2

areg investment2 c.cash_flow2##c.intra_pre1 $firmcontrol  $dummy if window1==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using tabledym0825.xls, excel  dec(4)  append ctitle(intrapre1) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes) adjr2


areg investment2 c.cash_flow2##c.intra_post1 $firmcontrol  $dummy if window1==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using tabledym0825.xls, excel  dec(4)  append ctitle(intrapost1) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes) adjr2

areg investment2 c.cash_flow2##c.intra_post2 $firmcontrol  $dummy if window1==1,  vce(cluster gvkey) absorb(gvkey)
outreg2 using tabledym0825.xls, excel  dec(4)  append ctitle(intrapost2) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes) adjr2

areg investment2 c.cash_flow2##c.intra_post3 $firmcontrol  $dummy if window1==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using tabledym0825.xls, excel  dec(4)  append ctitle(intrapost3) nonotes bracket drop(YEAR* sic1* statecode* ) addtext(Firm FE,Yes, Year FE, Yes) adjr2






/*******Table 5. subsample analysis: EFD*********************/
		//oancf: Operating Activities - Net Cash Flow
		//capx: Capital Expenditures\
		*drop efd
		*drop efdw
		replace oancf=0 if missing(oancf)
		replace capx=0 if missing(capx)
		gen efd=(capx-oancf)/capx
	centile efd, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 85 88 89 90 92 94 95 99)
    winsor2 efd, s(w) cut(5 95) by(cyear)
	centile efdw, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 85 88 89 90 92 94 95 99)


		
		*drop efd_median
		*drop high_efd low_efd
		bysort sic1 cyear: egen efd_median=median(efd)
		gen high_efd=(efd>=efd_median)
		gen low_efd=(efd<efd_median)


/**
	    drop if missing(inter)
        drop if missing(intra)
		**/

areg investment2  c.cash_flow2##i.dinter  $firmcontrol  $dummy if low_efd==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using table5EFD.xls, replace dec(4) sdec(4) title(Subsample-EFD) ctitle(low EFD) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2
areg investment2  c.cash_flow2##i.dintra  $firmcontrol  $dummy if low_efd==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using table5EFD.xls, append dec(4) sdec(4) title(Subsample-EFD) ctitle(low EFD) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2

areg investment2   c.cash_flow2##i.dinter $firmcontrol  $dummy if  high_efd==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using table5EFD.xls, append dec(4) sdec(4) title(Subsample-EFD) ctitle(High EFD) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2
areg investment2  c.cash_flow2##i.dintra  $firmcontrol  $dummy if high_efd==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using table5EFD.xls, append dec(4) sdec(4) title(Subsample-EFD) ctitle(High EFD) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2


		
		
		
		
		
/*********robustness check****************/
/*********Table 6. robustness check**********/
*centile ivbp,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
*winsor2 ivbp, replace cuts (5 99)
*rename ivbp invest_rd2

rename ivbpw invest_rd

xtset gvkey cyear
gen ivbp2=(capx+xrd)/l.ppent

centile ivbp2,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 ivbp2, s(w) cut(1 99) by(cyear)


gen manufacture=(sic>=2000 & sic<=3999)

/*******if no dropping, results are good*******/
/*****the results for manufatiruing industry is not good*********/
areg investment2  c.cash_flow2##i.dinter  $dummy $firmcontrol if  manufacture==1 , vce(cluster gvkey) absorb(gvkey)
outreg2 using table7_robustness1.xls, replace dec(4) sdec(4) title(manufacture) ctitle(manufacture) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2

areg investment2  c.cash_flow2##i.dintra  $dummy $firmcontrol if  manufacture==1 , vce(cluster gvkey) absorb(gvkey)
outreg2 using table7_robustness1.xls, append dec(4) sdec(4) title(manufacture) ctitle(manufacture) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2

areg investment2  c.cash_flow2##i.dinter  $dummy $firmcontrol if  manufacture==0 , vce(cluster gvkey) absorb(gvkey)
outreg2 using table7_robustness1.xls, append dec(4) sdec(4) title(manufacture) ctitle(Non-manufacture) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2

areg investment2  c.cash_flow2##i.dintra  $dummy $firmcontrol if  manufacture==0 , vce(cluster gvkey) absorb(gvkey)
outreg2 using table7_robustness1.xls, append dec(4) sdec(4) title(manufacture) ctitle(Non-manufacture) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2








areg ivbp2w  c.cash_flow2##i.dinter   $dummy $firmcontrol , vce(cluster gvkey) absorb(gvkey)
outreg2 using table7_robustness1.xls, append dec(4) sdec(4) ctitle(Investment-R&D) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2
	
areg ivbp2w c.cash_flow2##i.dintra  $dummy $firmcontrol, vce(cluster gvkey) absorb(gvkey)
outreg2 using table7_robustness1.xls, append dec(4) sdec(4) title(Investment-R&D) ctitle(manufacture) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2
	
areg invest_rd  c.cash_flow2##i.dinter   $dummy $firmcontrol , vce(cluster gvkey) absorb(gvkey)
outreg2 using table7_robustness1.xls, append dec(4) sdec(4) ctitle(Investment-R&D) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2
	
areg invest_rd c.cash_flow2##i.dintra  $dummy $firmcontrol, vce(cluster gvkey) absorb(gvkey)
outreg2 using table7_robustness1.xls, append dec(4) sdec(4) title(Investment-R&D) ctitle(manufacture) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2
	
				


/******Table 7. subgroup_location*********/
/***results are different from TY's*******/
*drop _merge
gen gvkey_r=gvkey
		joinby  gvkey_r using "E:\Research\bank deregulation and cf sensitivity\bank deregulation and ICF sensitivity-20190617T021721Z-001\bank deregulation and ICF sensitivity\bd cash flow sensitivity\dist.dta", unm(master)
	    drop _merge
	
gen firmtype1=1 if min12<50
replace firmtype1=2 if min12>=50 & minall<=100
replace firmtype1=3 if minall>100
 
		  
		  
		  
		  /***firmtype1=1:urban
		      firmtype1=2: small
			  firmtype1=3: rural****/
/*********if not dropping, results are worse. so use the dropped sample********/
/*********if dropping inter and intra drop, results are good but not best********************/
/**********use the whole sample, including three together****/
areg investment2 c.cash_flow2##i.dinter  $dummy $firmcontrol if  firmtype1==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using table7_firmtype.xls, replace dec(4) sdec(4) ctitle(urban) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2

areg investment2 c.cash_flow2##i.dintra  $dummy $firmcontrol if  firmtype1==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using table7_firmtype.xls, append dec(4) sdec(4) ctitle(urban) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2

areg investment2  c.cash_flow2##i.dinter   $dummy $firmcontrol if firmtype1==2, vce(cluster gvkey) absorb(gvkey)
outreg2 using table7_firmtype.xls, append dec(4) sdec(4) ctitle(small) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2

areg investment2  c.cash_flow2##i.dintra   $dummy $firmcontrol if firmtype1==2, vce(cluster gvkey) absorb(gvkey)
outreg2 using table7_firmtype.xls, append dec(4) sdec(4) ctitle(small) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2

areg investment2  c.cash_flow2##i.dinter $dummy $firmcontrol if firmtype1==3, vce(cluster gvkey) absorb(gvkey)
outreg2 using table7_firmtype.xls, append dec(4) sdec(4) ctitle(rural) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2

areg investment2  c.cash_flow2##i.dintra $dummy $firmcontrol if firmtype1==3, vce(cluster gvkey) absorb(gvkey)
outreg2 using table7_firmtype.xls, append dec(4) sdec(4) ctitle(rural) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2




		/****************Table 8*******/
		
/******************test for financial constraint sample only****************************/
          joinby gvkey cyear using "E:\Research\control var_code_all\data\finrestric.dta", unm(master)
          drop _merge

		  
*gen cfkz=(ib+dp)/l.ppent
xtset gvkey cyear
gen cfkz=(ib+dp)/l.ppent
drop kzindex
gen kzindex=-1.001909*cfkz+0.2826389*qbp+3.139193*((dltt+np+dd1)/(dltt+np+dd1+pstk+ceq))-39.3678*((dvc+dvp)/l.ppent)-1.314759*(che/l.ppent)


replace kzindex=0 if kzindex==.
replace saindex=0 if saindex==.
*replace struc_index2=0 if struc_index2==.



centile struc_index2,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 struc_index2, replace cuts (1 99)

centile kzindex,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 kzindex, replace cuts (1 99)


centile saindex,  centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 90 92 94 95 96 97 98 99)
winsor2 saindex, replace cuts (1 99)


*drop low_kz high_kz top_kz bottom_kz low_sa high_sa top_sa bottom_sa

*drop low_kz high_kz top_kz bottom_kz 
*low_sa high_sa top_sa bottom_sa
egen low_kz =pctile(kzindex), by (cyear) p(33)
egen high_kz =pctile(kzindex), by (cyear) p(67)

gen top_kz=(kzindex>high_kz) 
gen bottom_kz=(kzindex<low_kz)


egen low_sa =pctile(saindex), by (cyear) p(33)
egen high_sa =pctile(saindex), by (cyear)  p(67)

gen top_sa=(saindex>high_sa)
gen bottom_sa=(saindex<=low_sa)


/********results are insig for structure****************/
egen low_struc=pctile(struc_index2), by (cyear) p(33)
egen high_struc=pctile(struc_index2), by (cyear)  p(67)

gen top_struc=(saindex>high_struc)
gen bottom_struc=(saindex<=low_struc)



count if top_kz==1
count if bottom_kz==1







/********proxy for investment opportunities************/
/************generate industry level RD expense (xrd)****************/
/****Archarya 2007:
we look at the
correlation between a firm’s cash flow from current operations (CashFlow) and its industry-level median of R&D expenditures to assess whether a firm’s availability of internal funds is correlated with
the firm’s demand for investment funds.17 We compute this correlation, firm by firm, identifying the
firm’s industry using its three-digit SIC code. We then partition our sample into firms displaying low
and high correlation between investment demand and supply of internal funds
****/
/**R&D expenditures are measured as COMPUSTAT item #46(xrd) divided by item #6.(total assets) */
/***net cash flow scaled by assets (CashFlow)****/
/**
xtset gvkey cyear
gen asgrowth=(at-l.at)/l.at
gen slgrowth=(sale-l.sale)/l.sale
**/
sort gvkey cyear
gen slgrowth3=(sale-l3.sale)/l3.sale
/**
bysort sic3 cyear: egen slgrowth_sic=median(slgrowth)
centile slgrowth_sic, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 85 88 89 90 92 94 95 99)
*winsor2  slgrowth_sic, replace cuts (5 92)
winsor2 slgrowth_sic , s(w) cut(1 99) by(cyear)
**/

bysort sic3 cyear: egen slgrowth3_sic=median(slgrowth3)
centile slgrowth3_sic, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 85 88 89 90 92 94 95 99)
winsor2 slgrowth3_sic , s(w) cut(1 99) by(cyear)




xtset gvkey cyear

/************generate industry level sales growth****************/
*drop rdexp 
*drop rdexp_sic rdexp_sicw
gen rdexp=xrd/at
bysort sic3 cyear: egen rdexp_sic=median(rdexp)
centile rdexp_sic, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 85 88 89 90 92 94 95 99)
*winsor2 rdexp_sic, s(w) cut(1 99) by(cyear)


/*********firms' cash flow from current operations*************/

centile gross_cf, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 85 88 89 90 92 94 95 99)
winsor2 gross_cf, s(w) cut(1 99) by(cyear)


//use cf_at
centile cf_at, centile(1 2 3 4 5 6 7 8 9 10 12 15 20 22 25 30 40 50 60 70 80 85 88 89 90 92 94 95 99)
winsor2 cf_at, s(w) cut(1 99) by(cyear)


ssc install egenmore

*drop corr1 corr2
sort gvkey 
egen corr1 = corr(cf_at slgrowth3_sicw) , by(gvkey)
egen corr2 = corr(cf_at rdexp_sic) , by(gvkey)

*pwcorr cf_at slgrowth_sic, sig star(.05) obs
*pwcorr cf_at rdexp_sic, sig star(.05) obs

/*********gengerate high and low hedging needs*************
To be precise, recall that our theory has particularly clear implications for cash and debt policies of constrained firms at
the high and low ends of the correlation between cash flows and investment opportunities. Accordingly, 
we assign to the group of “low hedging needs” those firms for which the empirical correlation
between cash flow and industry R&D is above 0.2, and to the group of “high hedging needs” those
firms for which this correlation is below —0.2. We emphasize that although these cut-offs may seem
arbitrary, they ensure that firms in either group have correlation coefficient estimates that are 
statistically reliable.18 Moreover, our results are robust to changes in these cut-offs (e.g., ±0.1 or ±0.3).
*/
*drop high_hedge1 low_hedge1 high_hedge2 low_hedge2
*drop high_hedge2 low_hedge2

gen high_hedge1=(corr1<-0.2)
gen low_hedge1=(corr1>0.2)

gen high_hedge2=(corr2<-0.2)
gen low_hedge2=(corr2>0.2)



*keep if top_kz ==1




	//If no drop:
	/*****after drop, low hedge subsample is more insig***/
areg investment2 c.cash_flow2##i.dinter  $firmcontrol  $dummy if top_kz==1 & high_hedge1==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using table9hedge_subsample0825.xls, replace dec(4) sdec(4) title(hedging needs) ctitle(high_industry sales growth) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2
areg investment2 c.cash_flow2##i.dintra  $firmcontrol  $dummy if top_kz==1 & high_hedge1==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using table9hedge_subsample0825.xls, append dec(4) sdec(4) title(hedging needs) ctitle(high_industry sales growth) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2

/****in low hedge subsample, sig is more obvious***********/
areg investment2 c.cash_flow2##i.dinter  $firmcontrol  $dummy if  top_kz==1 & low_hedge1==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using table9hedge_subsample0825.xls, append dec(4) sdec(4) title(hedging needs) ctitle(low_industry sales growth) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2
/****in low hedge subsample, sig is more obvious***********/
areg investment2 c.cash_flow2##i.dintra  $firmcontrol  $dummy if  top_kz==1 & low_hedge1==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using table9hedge_subsample0825.xls, append dec(4) sdec(4) title(hedging needs) ctitle(low_industry sales growth) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2



areg investment2  c.cash_flow2##i.dinter  $firmcontrol  $dummy if top_kz==1 & high_hedge2==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using table9hedge_subsample0825.xls, append  dec(4) sdec(4) title(hedging needs) ctitle(high_industry R&D) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2
areg investment2  c.cash_flow2##i.dintra  $firmcontrol  $dummy if top_kz==1 & high_hedge2==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using table9hedge_subsample0825.xls, append  dec(4) sdec(4) title(hedging needs) ctitle(high_industry R&D) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2




/****in low hedge subsample, sig is more obvious***********/
areg investment2 c.cash_flow2##i.dinter  $firmcontrol  $dummy if top_kz==1 & low_hedge2==1, vce(robust) absorb(gvkey)
outreg2 using table9hedge_subsample0825.xls, append dec(4) sdec(4) title(hedging needs) ctitle(low_industry R&D) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2
/****in low hedge subsample, sig is more obvious***********/
areg investment2 c.cash_flow2##i.dintra  $firmcontrol  $dummy if top_kz==1 & low_hedge2==1, vce(robust) absorb(gvkey)
outreg2 using table9hedge_subsample0825.xls, append dec(4) sdec(4) title(hedging needs) ctitle(low_industry R&D) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2



/**********************************/
areg investment2  c.cash_flow2##i.dinter  $firmcontrol  $dummy if top_sa==1 & high_hedge1==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using table9hedge_subsample0825.xls, append dec(4) sdec(4) title(hedging needs) ctitle(sa_high_industry sales growth) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2
areg investment2  c.cash_flow2##i.dintra  $firmcontrol  $dummy if top_sa==1 & high_hedge1==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using table9hedge_subsample0825.xls, append dec(4) sdec(4) title(hedging needs) ctitle(sa_high_industry sales growth) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2

/****in low hedge subsample, sig is more obvious***********/
areg investment2 c.cash_flow2##i.dinter  $firmcontrol  $dummy if  top_sa==1 & low_hedge1==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using table9hedge_subsample0825.xls, append dec(4) sdec(4) title(hedging needs) ctitle(sa_low_industry sales growth) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2
/****in low hedge subsample, sig is more obvious***********/
areg investment2 c.cash_flow2##i.dintra  $firmcontrol  $dummy if  top_sa==1 & low_hedge1==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using table9hedge_subsample0825.xls, append dec(4) sdec(4) title(hedging needs) ctitle(sa_low_industry sales growth) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2



areg investment2 c.cash_flow2##i.dinter $firmcontrol  $dummy if top_sa==1 & high_hedge2==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using table9hedge_subsample0825.xls, append  dec(4) sdec(4) title(hedging needs) ctitle(sa_high_industry R&D) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2
areg investment2 c.cash_flow2##i.dintra $firmcontrol  $dummy if top_sa==1 & high_hedge2==1, vce(cluster gvkey) absorb(gvkey)
outreg2 using table9hedge_subsample0825.xls, append  dec(4) sdec(4) title(hedging needs) ctitle(sa_high_industry R&D) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2

/****in low hedge subsample, sig is more obvious***********/
areg investment2  c.cash_flow2##i.dinter  $firmcontrol  $dummy if top_sa==1 & low_hedge2==1, vce(robust) absorb(gvkey)
outreg2 using table9hedge_subsample0825.xls, append dec(4) sdec(4) title(hedging needs) ctitle(sa_low_industry R&D) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2
/****in low hedge subsample, sig is more obvious***********/
areg investment2  c.cash_flow2##i.dintra  $firmcontrol  $dummy if top_sa==1 & low_hedge2==1, vce(robust) absorb(gvkey)
outreg2 using table9hedge_subsample0825.xls, append dec(4) sdec(4) title(hedging needs) ctitle(sa_low_industry R&D) nodepvar drop(i.cyear) addstat(F-test, e(p)) adjr2

		
		
		
		
		
		
	/***************check MA data*********************/
	use "E:\Research\bank deregulation and cf sensitivity\code and data_xt\maindex5", clear

