





libname in "D:\research\UB and innovation\code and data_v6";run;


proc import out=in.comp_ccm_crsp1 datafile="D:\research\UB and innovation\data\comp_ccm_crsp1_12.dta"; run;

proc import out=in.dealscan_link_ub datafile="D:\research\UB and innovation\data\dealscan_link_ub_12.dta"; run;







PROC SQL;
CREATE TABLE in.dealscan_ccm_ub as
SELECT *
FROM in.comp_ccm_crsp1 AS a left join in.dealscan_link_ub  AS b
on a.gvkey =b.gvkey & a.cyear=b.bankyear ;
QUIT;

 proc sort data= in.dealscan_ccm_ub ;by gvkey cyear; run;




proc export
  data=in.dealscan_ccm_ub
  dbms=dta
  outfile="D:\research\UB and innovation\code and data_v6\dealscan_ccm_ub.dta"
  replace;
run;




libname cm "D:\research\LINK TABLE";run;



proc export
  data=cm.mydata2
  dbms=dta
  outfile="D:\research\LINK TABLE\ccm.dta"
  replace;
run;
