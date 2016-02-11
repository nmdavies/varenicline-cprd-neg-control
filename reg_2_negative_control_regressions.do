//Neil Davies 26/11/15
//This runs the analysis for Table 2 of the negative control paper.

//This estimates the effects of varenilcine on negative control outcomes.
//The negative controls are defined in terms of outcomes prior to first prescription.

/* Code for GMM test of relative bias from Frank Windmeijer:

/*Merging Sample1 and Sample2 data on identifier id*/
use sample13.dta, clear
qui merge 1:1 id using sample23.dta

drop if x1==.


gen const  = 1
local reg  = "x3 x1 const"
gmm (y - {xb1:`reg'})  ///
	(y - {xb2:`reg'}), ///
	instruments(1:x3 x1) ///
	instruments(2:z1 x1) ///
	winit(unadjusted,independent) onestep  ///
	deriv(1/xb1 = -1) ///
	deriv(2/xb2 = -1)

lincom _b[xb1:x3]-_b[xb2:x3]


*/


cap prog drop gmm_balance_test
prog def gmm_balance_test, rclass
	
	args outcome exp iv
	macro shift 3 
	local cov="`*'"
	
	di "Outcome=`outcome'"
	di "Exposure=`exp'"
	di "Instrument=`iv'"
	di "Covariates=`cov'"

cap gen const=1	
	
gmm (`outcome' - {xb1:`exp' `cov' const})  ///
	(`outcome' - {xb2:`exp' `cov'  const}), ///
	instruments(1:`exp' `cov') ///
	instruments(2:`iv' `cov') ///
	winit(unadjusted,independent) onestep  ///
	deriv(1/xb1 = -1) ///
	deriv(2/xb2 = -1) vce(cluster staffid)

lincom _b[xb1:`exp']-_b[xb2:`exp']	

ret li

local p=1-chi2(1,(r(estimate)/r(se))^2)

return scalar p =`p'
drop const
end

gmm_balance_test cov_male dr_varenicline iv rx_year_*
ret li



use "7_negative_controls/working_data/analysis_dataset",clear

order cov_smokemed_12 rx_year_1

reg cov_male dr_varenicline rx_year_* if iv!=., cluster(staffid)
regsave  dr_varenicline using "7_negative_controls/results/negative_controls1_reg",detail(all) pval ci replace t
gmm_balance_test cov_male dr_varenicline iv rx_year_* 
local p=r(p)
ivreg2 cov_male (dr_varenicline=iv) rx_year_*, cluster(staffid) endog(dr_varenicline) partial(rx_year_*)
regsave dr_varenicline using "7_negative_controls/results/negative_controls1_iv",detail(all) pval ci replace t addlabel(p_test,`p')

reg cov_age dr_varenicline cov_male rx_year_* if iv!=., cluster(staffid)
regsave  dr_varenicline using "7_negative_controls/results/negative_controls1_reg",detail(all) pval ci append t
gmm_balance_test cov_age dr_varenicline iv rx_year_* cov_male
local p=r(p)
ivreg2 cov_age (dr_varenicline=iv) cov_male rx_year_*, cluster(staffid) endog(dr_varenicline) partial(cov_male rx_year_*)
regsave dr_varenicline using "7_negative_controls/results/negative_controls1_iv",detail(all) pval ci  append t  addlabel(p_test,`p')

ds  cov_num_cons_12mth cov*_12
foreach i in `r(varlist)'{
	cap{
		reg `i' dr_varenicline cov_male rx_year_* if iv!=., cluster(staffid)
		regsave dr_varenicline using "7_negative_controls/results/negative_controls1_reg",detail(all) pval ci append t
		gmm_balance_test `i' dr_varenicline iv rx_year_* cov_male
		local p=r(p)
		ivreg2 `i' (dr_varenicline=iv)  cov_male rx_year_*, cluster(staffid) endog(dr_varenicline) partial( cov_male rx_year_*)
		regsave dr_varenicline using "7_negative_controls/results/negative_controls1_iv",detail(all) pval ci append	t  addlabel(p_test,`p')
		}
	}
	
use "7_negative_controls/results/negative_controls1_reg",clear
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

use "7_negative_controls/results/negative_controls1_iv",clear
drop pval estatp
gen double pval=2*normal(-abs(tstat))
gen double estatp=1-chi2(1,abs(estat))
order depvar N coef ci_lower ci_upper pval idstat estatp 
gen n=_n
gsort - n
replace coef=coef*100 if depvar!="cov_num_cons_12mth"&depvar!="cov_age"
replace ci_lower= ci_lower*100 if depvar!="cov_num_cons_12mth"&depvar!="cov_age"
replace  ci_upper= ci_upper*100 if depvar!="cov_num_cons_12mth"&depvar!="cov_age"

foreach i in  N coef ci_lower ci_upper pval idstat estatp p_test{
	rename `i' iv_`i'
	}
keep depvar iv_*

joinby depvar using "7_negative_controls/working_data/temp",unmatched(master)

order depvar N-pval iv_N-iv_estatp
drop _m iv_N
