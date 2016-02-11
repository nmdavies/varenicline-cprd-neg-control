//Neil Davies 11/12/15
//This runs the analysis for the negative control paper

cd "/Volumes/varenicline_CPRD"

//First Table 5: Mortality of patients ever prescribed anti-depressants. 



use "/Volumes/varenicline_CPRD/7_negative_controls/working_data/analysis_anti_dep_dataset",clear






reg cov_male iv rx_year_* if iv!=. & follow_up>365.25, cluster(staffid)
regsave  iv using "/Volumes/varenicline_CPRD/7_negative_controls/results/negative_controls3_reg",detail(all) pval ci replace t

ds cov_age out_num_cons_12mth  out_autism_12 out_bipolar_12 out_smoke_12 out_dementia_12 out_depression_12 out_eatingdis_12 out_hyperkineticdis_12 out_learningdis_12 out_neuroticdis_12 out_otherbehavdis_12 out_persondis_12 out_schizop_12 out_alcohol_misuse_12 out_prob_selfharm_12 out_drug_misuse_12 out_fractures_12 out_all_psyc_12 out_TEMP_CHARLSON_INDEX_12 out_antidepressants_12 out_antipsyc_stabalis_12 out_cns_stimulants_12 out_dementia_12 out_hypnotics_anxiolytics_12 out_lithium_12 
foreach i in `r(varlist)'{
	cap{
		reg `i' iv cov_male  rx_year_* if iv!=. & follow_up>365.25, cluster(staffid)
		regsave iv using "/Volumes/varenicline_CPRD/7_negative_controls/results/negative_controls3_reg",detail(all) pval ci append t
		}
	}

use "/Volumes/varenicline_CPRD/7_negative_controls/results/negative_controls3_reg",clear

order depvar N coef ci_l ci_u pval 
gen n=_n
gsort - n

foreach i in coef ci_l ci_u{
	replace `i'=`i'*100
	}
