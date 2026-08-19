read.dta("D:/XINTING_research/ub and innovation/MF referee oct 2018/data/dealscan_ccm_ub.dta")
##simulate individual level-

install.packages("matchingMarkets")
library(matchingMarkets)

##Follow the JF 2007 paper :a two-sided matching model of venture capital
##(1) Structural model includes two components: outcome equation: estimation of this equation alone yields inconsistent estimates
##(2) second part controls for sorting and it is based on a two-sided matching model (college admissions model)
##this model forms tha bsis for an empirical model of market sorting. it is a discrete model that generalized existing models.
##the model allows for interactions among the choices made.

## two parts are analogous to the two stages of the two-stage estimator in the Heckman selection model. 
##Bayesian estimation using Gibbs sampling is a feasible estimation method. 
## it uses the empirical matching model to control for endogeneity rather than the multinormial probit model, which is unable to capture the sorting 

##the benefit of using this model:
## solves the problem of missing instruments; 


##the model is a static equilibrium model from cooeporative game theory. 
college admissions model (Gale and  Shapley 1962)

##Main assumptions:
##1. the college admissions model is a one-to-many matching model. each bank can match with several firms, but each firm can only match with a single bank. 
a bank can match with multiple firms. 
the set of all potential loans (also called matches), is given by Mt=It*Jt. a matching, ut, is a set of matches such that (i,j) belongs to ut if and only if bank i and firm j are matched in market t. 



MCMCregress(bwt~age+lwt+as.factor(race) + smoke + ht, data=birthwt, b0=c(2700, 0, 0, -500, -500, -500, -500), B0=c(1e-6, .01, .01, 1.6e-5, 1.6e-5, 1.6e-5, 1.6e-5), c0=10, d0=4500000, marginal.likelihood="Chib95", mcmc=10000)

#updated on 12/6/2018
# input stata file

library(foreign)
read.dta("Z:/Research/UB and innovation/MF RR/winsored_v31_base_12.dta")
install.packages("MCMCpack")

library(MCMCpack)

#MCMCregress(Ln_patent~ub_post_1stall+largebank+salary_exp+Equity_ta+cash_ta+Firmsize+Salegrowth+Capitalexpenditures+Workingcapital+Firm_age+Profitability+Firmefficiency+
#Assetstangibility+Equity_assets+debtrating+statecode,  burnin=1000, mcmc=10000, thin=1, verbose=0, seed=NA, data=winsored_v31_base_12, beta.start = NA, b0=0, B0=0, c0=0.001, d0=0.001, marginal.likelihood="Chib95")

MCMCregress(Ln_patent~ub_post_1stall+largebank+salary_exp+Equity_ta+cash_ta+Firmsize+Salegrowth+Capitalexpenditures+Workingcapital+Firm_age+Profitability+Firmefficiency+Assetstangibility+Equity_assets+debtrating+statecode, data = null, burnin = 1000, mcmc = 10000,thin = 1, verbose = FALSE, seed = NA, beta.start = NA, b0 = 0, B0 = 0, c0 = 0.001, d0 = 0.001) 






