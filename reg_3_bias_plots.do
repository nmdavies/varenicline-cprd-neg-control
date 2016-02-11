//Neil Davies 27/11/15
//This creates the Swanson bias plots for the negative control outcomes in the varenicline study

use "7_negative_controls/working_data/analysis_dataset",clear

order cov_smokemed_12 rx_year_1

reg cov_male dr_varenicline rx_year_* if iv!=., cluster(staffid)
est sto reg_cov_male
ivreg2 cov_male (dr_varenicline=iv) rx_year_*, cluster(staffid) endog(dr_varenicline) partial(rx_year_*)
est sto iv_cov_male

reg cov_age dr_varenicline cov_male rx_year_* if iv!=., cluster(staffid)
est sto reg_cov_age
ivreg2 cov_age (dr_varenicline=iv) cov_male rx_year_*, cluster(staffid) endog(dr_varenicline) partial( cov_male rx_year_*)
est sto iv_cov_age

ds  rx_year_2-rx_year_7
foreach i in `r(varlist)'{
	cap{
		reg `i' dr_varenicline cov_male  if iv!=., cluster(staffid)
		est sto reg_`i'
		ivreg2 `i' (dr_varenicline=iv)  cov_male , cluster(staffid) endog(dr_varenicline) partial( cov_male )
		est sto iv_`i'
		}
	}

//Shorten some of the variable names:

rename cov_antipsyc_stabalis_12 cov_antipsyc_12	
rename cov_TEMP_ALL_PSYC_ILL_12 cov_TP_ALL_PSYC_ILL_12 	
rename cov_hypnotics_anxiolytics_12  cov_hypnotics_12 
	
ds  cov_num_cons_12mth cov*_12
foreach i in `r(varlist)'{
	cap{
		reg `i' dr_varenicline cov_male rx_year_* if iv!=., cluster(staffid)
		est sto reg_`i'
		ivreg2 `i' (dr_varenicline=iv)  cov_male rx_year_*, cluster(staffid) endog(dr_varenicline) partial( cov_male rx_year_*)
		est sto iv_`i'
		}
	}
	
//Plot the regression results for gender and year of first prescription:

coefplot (reg_cov_male ,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Male")) (iv_cov_male,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Male")) ///
		 (reg_rx_year_3,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Prescribed in 2008")) (iv_rx_year_3,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Prescribed in 2008")) /// 
		 (reg_rx_year_4,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Prescribed in 2009")) (iv_rx_year_4,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Prescribed in 2009")) /// 
		 (reg_rx_year_5,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Prescribed in 2010")) (iv_rx_year_5,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Prescribed in 2010")) /// 
		 (reg_rx_year_6,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Prescribed in 2011")) (iv_rx_year_6,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Prescribed in 2011")) /// 
		 (reg_rx_year_7,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Prescribed in 2012")) (iv_rx_year_7,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Prescribed in 2012")) /// 
		  , legend(off) xline(0) byopts(yrescale)  xtitle("Difference in absolute risk of outcome") graphregion(color(white))

coefplot (reg_cov_num_cons_12mth ,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Number of consultations")) (iv_cov_num_cons_12mth,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Number of consultations")) ///
		 (reg_cov_age,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Age")) (iv_cov_age,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Age")) /// 
		  , legend(off) xline(0) byopts(yrescale)  xtitle("Mean differences in outcome") graphregion(color(white))

coefplot (reg_cov_autism_12 ,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Autism")) (iv_cov_autism_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Autism")) ///
		 (reg_cov_bipolar_12,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Bipolar")) (iv_cov_bipolar_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Bipolar")) /// 
		 (reg_cov_current_smokers_12,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Current smoker")) (iv_cov_current_smokers_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Current smoker")) /// 
		 (reg_cov_dementia_12,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Dementia")) (iv_cov_dementia_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Dementia")) /// 
		 (reg_cov_depression_12,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Depression")) (iv_cov_depression_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Depression")) /// 
		 (reg_cov_eatingdis_12,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Eating disorders")) (iv_cov_eatingdis_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Eating disorders")) /// 
		 (reg_cov_hyperkineticdis_12,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Hyperkinetic disorder")) (iv_cov_hyperkineticdis_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Hyperkinetic disorder")) /// 
		 (reg_cov_learningdis_12,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Learning disorder")) (iv_cov_learningdis_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Learning disorder")) /// 
		 (reg_cov_neuroticdis_12,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Neurotic disorder")) (iv_cov_neuroticdis_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Neurotic disorder")) /// 
		 (reg_cov_otherbehavdis_12,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Other behavioural disorder")) (iv_cov_otherbehavdis_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Other behavioural disorder")) /// 
		 (reg_cov_persondis_12,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Personality disorder")) (iv_cov_persondis_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Personality disorder")) /// 
		 (reg_cov_schizop_12,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Schizophrenia")) (iv_cov_schizop_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Schizophrenia")) /// 
		 (reg_cov_alcohol_misuse_12,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Alcohol misuse")) (iv_cov_alcohol_misuse_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Alcohol misuse")) /// 
		 (reg_cov_prob_selfharm_12,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Probable self-harm")) (iv_cov_prob_selfharm_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Probable self-harm")) /// 
		 (reg_cov_drug_misuse_12,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Drug misuse")) (iv_cov_drug_misuse_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Drug misuse")) /// 
		 (reg_cov_fractures_12,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Fracture")) (iv_cov_fractures_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Fracture")) /// 
		 (reg_cov_TP_ALL_PSYC_ILL_12,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Any psychiatric illness")) (iv_cov_TP_ALL_PSYC_ILL_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Any psychiatric illness")) /// 
		 (reg_cov_TEMP_CHARLSON_12,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Chronic disease")) (iv_cov_TEMP_CHARLSON_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Chronic disease")) /// 
		 ,legend(off) xline(0) byopts(yrescale)  xtitle("Absolute risk differences in outcome") graphregion(color(white))



coefplot (reg_cov_antidepressants_12 ,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Antidepressants")) (iv_cov_antidepressants_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Antidepressants")) ///
		 (reg_cov_antipsyc_12 ,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Antipsychotics")) (iv_cov_antipsyc_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Antipsychotics")) ///
		 (reg_cov_cns_stimulants_12 ,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="CNS stimulants")) (iv_cov_cns_stimulants_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "CNS stimulants")) ///
		 (reg_cov_dementiameds_12 ,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Dementia medication")) (iv_cov_dementiameds_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Dementia medication")) ///
		 (reg_cov_hypnotics_12 ,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Hypnotic anxiolytic")) (iv_cov_hypnotics_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Hypnotic anxiolytic")) ///
		 (reg_cov_lithium_12 ,keep(dr_varenicline) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(dr_varenicline="Lithium")) (iv_cov_lithium_12,keep(dr_varenicline) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(dr_varenicline = "Lithium")) ///
		 , legend(off) xline(0) byopts(yrescale)  xtitle("Absolute risk differences in outcome") graphregion(color(white))
 

 
 
 
 
 
 


 
 
 



		 
		 
