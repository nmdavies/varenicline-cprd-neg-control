//Neil Davies 03/12/15
//This creates Table 5, the association between the index prescription and mortality of patients who visit the GP on the same day as they issued a NRT prescription.

cd "/Volumes/varenicline_CPRD/"

use  "/Volumes/varenicline_CPRD/7_negative_controls/working_data/temp_matched_ad_patients",clear

gen Rx_year=year(Rx_eventdate)
tab Rx_year,gen(rx_year_)

reg  out_dead_3 iv rx_year_* cov_male if iv!=., cluster(staffid)
regsave iv using "7_negative_controls/results/negative_controls3_reg",detail(all) pval ci replace t
est store reg_1

local j =3
foreach i in 6 9 12 24 48{
	replace out_dead_`i'=1 if out_dead_`j'==1 
	reg out_dead_`i' iv cov_male rx_year_*  if iv!=., cluster(staffid)
	regsave iv using "7_negative_controls/results/negative_controls3_reg",detail(all) pval ci append t
	est sto reg_`i'
	local j =`i'
	}

use "7_negative_controls/results/negative_controls3_reg",clear

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
drop _m iv_N
