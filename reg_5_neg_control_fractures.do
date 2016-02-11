//Neil Davies 27/11/15
//This creates the negative control regressions on the UTI negative control outcomes

use "7_negative_controls/working_data/analysis_dataset",clear

//For the actual prescription:

reg  out_uti_3 dr_varenicline rx_year_* cov_male if iv!=., cluster(staffid)
regsave  dr_varenicline using "7_negative_controls/results/negative_controls2_reg",detail(all) pval ci replace t
est store reg_1

local j =3
foreach i in 6 9 12 24 48{
	replace out_uti_`i'=1 if out_uti_`j'==1 
	reg out_uti_`i'  dr_varenicline cov_male rx_year_*  if iv!=., cluster(staffid)
	regsave  dr_varenicline using "7_negative_controls/results/negative_controls2_reg",detail(all) pval ci append t
	est sto reg_`i'
	}

//For the instrument (PPP)

reg  out_uti_3 iv rx_year_* cov_male if iv!=., cluster(staffid)
regsave iv using "7_negative_controls/results/negative_controls2_ivreg",detail(all) pval ci replace t
est store ivreg_1

local j =3
foreach i in 6 9 12 24 48{
	replace out_uti_`i'=1 if out_uti_`j'==1 
	reg out_uti_`i' iv cov_male rx_year_*  if iv!=., cluster(staffid)
	regsave iv using "7_negative_controls/results/negative_controls2_ivreg",detail(all) pval ci append t
	est sto ivreg_`i'
	}
	
use "7_negative_controls/results/negative_controls2_reg",clear

order depvar N coef ci_lower ci_upper pval 
drop pval
gen double pval=(2 * ttail(df_r, abs(tstat))) 
gen n=_n
gsort - n
replace coef=coef*100 if depvar!="cov_num_cons_12mth"&depvar!="cov_age"
replace ci_lower= ci_lower*100 if depvar!="cov_num_cons_12mth"&depvar!="cov_age"
replace  ci_upper= ci_upper*100 if depvar!="cov_num_cons_12mth"&depvar!="cov_age"
keep depvar N coef ci_lower ci_upper pval
save "7_negative_controls/working_data/temp",replace

use "7_negative_controls/results/negative_controls2_ivreg",clear

order depvar N coef ci_lower ci_upper pval 
drop pval
gen double pval=(2 * ttail(df_r, abs(tstat))) 
gen n=_n
gsort - n
replace coef=coef*100 if depvar!="cov_num_cons_12mth"&depvar!="cov_age"
replace ci_lower= ci_lower*100 if depvar!="cov_num_cons_12mth"&depvar!="cov_age"
replace  ci_upper= ci_upper*100 if depvar!="cov_num_cons_12mth"&depvar!="cov_age"
keep depvar N coef ci_lower ci_upper pval
save "7_negative_controls/working_data/temp",replace


order depvar N-pval 

//Create figure

coefplot (reg_1 ,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="3 months")) (ivreg_1,keep(iv) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(iv = "3 months")) ///
		 (reg_6,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="6 months")) (ivreg_6,keep(iv) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(iv = "6 months")) /// 
		 (reg_9,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="9 months")) (ivreg_9,keep(iv) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(iv = "9 months")) /// 
		 (reg_12,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="12 months")) (ivreg_12,keep(iv) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(iv = "12 months")) /// 
		 (reg_24,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="24 months")) (ivreg_24,keep(iv) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(iv = "24 months")) /// 
		 (reg_48,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="48 months")) (ivreg_48,keep(iv) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(iv = "48 months")) /// 
		  , legend(off) xline(0) byopts(yrescale)  xtitle("Absolute risk difference in incidence") graphregion(color(white))

