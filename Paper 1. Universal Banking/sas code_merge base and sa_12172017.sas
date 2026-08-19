

libname in "D:\research\UB and innovation\data";run;



PROC SQL;
CREATE TABLE in.winsored_v6_base_sa as
SELECT *
FROM in.winsored_v6_base_2 AS a left join in.sa_all  AS b
on a.cusip_6_ccm =b.partcusip & a.cyear=b.sa_announyear ;
QUIT;




proc export
  data=in.winsored_v6_base_sa
  dbms=dta
  outfile="D:\research\UB and innovation\data\winsored_v6_base_sa.dta"
  replace;
run;
