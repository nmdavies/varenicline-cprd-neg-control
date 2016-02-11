//Neil Davies 18/11/15
//This merges in the covariates and outcomes:

//Program to merge in the events:
cap prog drop merge_events
prog def merge_events
use "7_negative_controls/working_data/first_eligible_smoking_cessation_Rx.dta",clear
joinby patid using "7_negative_controls/working_data/eventlist/eventlist_`1'_`2'",unmatched(master)

//Number of days inbetween first prescription and diagnosis date
gen diff=clinical_eventdate-Rx_eventdate

//Create actual outcomes within 3, 6, 9, 12, 24 and 48 months of first prescription
local j 3
foreach i in 3 6 9 12 24 48{
	gen out_`2'_`i'=(diff<`i'*365.25/12 & diff>0 & diff!=.) if follow_up>`i'*365.25/12
	bys patid: egen X=max(out_`2'_`i') if follow_up>`i'*365.25/12 
	replace out_`2'_`i'=X
	drop X
	replace out_`2'_`i'=1 if out_`2'_`j'==1
	local j=`i'
	}
	
//Create the negative control outcomes (which occur prior to exposure)
foreach i in 3 6 9 12 24 48 300{
	gen cov_`2'_`i'=(diff>-`i'*365.25/12 & diff<0 & diff!=.)
	bys patid: egen X=max(cov_`2'_`i')
	replace cov_`2'_`i'=X
	drop X
	}
	
drop _merge  clinical_eventdate diff
cap drop medcode
cap drop prodcode
duplicates drop
compress
save "7_negative_controls/working_data/outcome_`2'",replace
end

foreach i in /*autism bipolar current_smokers dementia depression eatingdis hyperkineticdis  learningdis neuroticdis otherbehavdis persondis schizop smoke alcohol_misuse prob_selfharm drug_misuse TEMP_CHARLSON TEMP_ALL_PSYC_ILL fractures*/ uti{
	merge_events med `i'
	}
foreach i in  smokemed antidepressants antipsyc_stabalis cns_stimulants dementiameds hypnotics_anxiolytics lithium{
	merge_events prod `i'
	}	
	
//Number of consultations
use  "old files/raw_mhra_data_OLD/nrt/clinical_1",clear

forvalues i =2(1)6{
	append using "old files/raw_mhra_data_OLD/nrt/clinical_`i'",force
	cap:append using "old files/raw_mhra_data_OLD/varenicline/clinical_`i'",force	
	}

bys patid eventdate:keep if _n==1

joinby patid using "7_negative_controls/working_data/first_eligible_smoking_cessation_Rx.dta", unmatched(using)

//Create actual outcomes within 3, 6, 9, 12, 24 and 48 months of first prescription
foreach i in 3 6 9 12 24 48{
	gen out_num_cons_`i'mth=(eventdate-Rx_eventdate<`i'*365.25/12&eventdate-Rx_eventdate>0) if follow_up>`i'*365.25/12 
	bys patid: egen X=total(out_num_cons_`i'mth) 
	replace out_num_cons_`i'mth=X
	drop X
	}
	
//Create the negative control outcomes (which occur prior to exposure)
foreach i in 3 6 9 12 24 48{
	gen cov_num_cons_`i'mth=(eventdate-Rx_eventdate>-`i'*365.25/12&eventdate-Rx_eventdate<0) if history>`i'*365.25/12 
	bys patid: egen X=total(cov_num_cons_`i'mth)
	replace cov_num_cons_`i'mth=X
	drop X
	}

bys patid: keep if _n==1

foreach i in 3 6 9 12 24 48{
	replace out_num_cons_`i'=. if follow_up<=`i'*365.25/12 
	replace cov_num_cons_`i'=. if history<=`i'*365.25/12 
	}

keep patid out_* cov_* 
compress
save "7_negative_controls/working_data/outcome_num_cons",replace

	//Mortality outcomes
	use "7_negative_controls/working_data/first_eligible_smoking_cessation_Rx",clear
	gen diff=deathdate-Rx_eventdate
	foreach i in 3 6 9 12 24 48{
		gen out_died_`i'=(diff<`i'*365.25/12 & diff>0 & diff!=.) if follow_up>`i'*365.25/12
		bys patid: egen X=max(out_died_`i') if follow_up>`i'*365.25/12 
		replace out_died_`i'=X
		drop X
		replace out_died_`i'=1 if out_died_`j'==1
		local j=`i'
		}		
	drop diff

	//Age at first prescription
	gen cov_age=year(Rx_eventdate)-yob

	drop yob
	compress

	foreach i in autism bipolar current_smokers dementia depression eatingdis hyperkineticdis  learningdis neuroticdis otherbehavdis persondis schizop alcohol_misuse prob_selfharm drug_misuse num_cons fractures TEMP_ALL_PSYC_ILL TEMP_CHARLSON ///
	 smokemed antidepressants antipsyc_stabalis cns_stimulants dementiameds hypnotics_anxiolytics lithium uti{
		joinby patid using "7_negative_controls/working_data/outcome_`i'",unmatched(master)
		drop _m
		}

	//Generate indicators for year of first prescription
	gen rx_year=year(Rx_eventdate)
	tab rx_year, gen(rx_year_)

	bys staffid (Rx_eventdate patid): gen iv=dr_varenicline[_n-1]

	compress

	save "7_negative_controls/working_data/analysis_dataset",replace
