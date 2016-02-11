//Neil Davies 04/12/12
//This creates the cohort for the anti-depressant patient negative controls

//Convert dates:

cap prog drop date
prog def date

gen `1'2 = date(`1', "DMY")
format %td `1'2
drop `1'
rename `1'2 `1'
replace `1'=. if `1'>150000

end 

cap prog drop merge_events
prog def merge_events

use  "/Volumes/varenicline_CPRD/7_negative_controls/working_data/temp_matched_ad_patients",clear
rename patid patid
joinby patid using "/Volumes/varenicline_CPRD/7_negative_controls/working_data/eventlist/`1'",unmatched(master)

di "`1'"

date clinical_eventdate

//Number of days inbetween first prescription and diagnosis date
gen diff=clinical_eventdate-Rx_eventdate

//Need to create local variable for name
local k=subinstr("`1'","eventlist_anti_dep_med_","",1)
local k=subinstr("`k'","eventlist_anti_dep_prod_","",1)
local k=subinstr("`k'",".dta","",1)

di "`k'"

if "`k'"=="TEMP_ALL_PSYCHIATRIC_ILLNESS"{
	local k="all_psyc"
	}

di "`k'"
	
//Create actual outcomes within 3, 6, 9, 12, 24 and 48 months of first prescription
local j 3
foreach i in 3 6 9 12 24 48{
	gen out_`k'_`i'=(diff<`i'*365.25/12 & diff>0 & diff!=.) if follow_up>`i'*365.25/12
	bys patid: egen X=max(out_`k'_`i') if follow_up>`i'*365.25/12 
	replace out_`k'_`i'=X
	drop X
	replace out_`k'_`i'=1 if out_`k'_`j'==1
	local j=`i'
	}
	
//Create the negative control outcomes (which occur prior to exposure)
foreach i in 3 6 9 12 24 48 300{
	gen cov_`k'_`i'=(diff>-`i'*365.25/12 & diff<0 & diff!=.)
	bys patid: egen X=max(cov_`k'_`i')
	replace cov_`k'_`i'=X
	drop X
	}
	
drop _merge  clinical_eventdate diff
cap drop medcode
cap drop prodcode
duplicates drop
compress
save "/Volumes/varenicline_CPRD/7_negative_controls/working_data/outcome_anti_dep_`1'",replace
end

cd "/Volumes/varenicline_CPRD/7_negative_controls/working_data/eventlist/"
fs eventlist_anti_dep*
foreach i in `r(files)'{
	merge_events `i' 
	}

//Finally merge all of the outcomes into one analysis dataset:
use  "/Volumes/varenicline_CPRD/7_negative_controls/working_data/temp_matched_ad_patients",clear
rename patid patid

//Age at first prescription
gen cov_age=year(Rx_eventdate)-yob

drop yob
compress

fs "/Volumes/varenicline_CPRD/7_negative_controls/working_data/outcome_anti_dep_*"
foreach i in `r(files)'{
	joinby patid using "/Volumes/varenicline_CPRD/7_negative_controls/working_data/`i'",unmatched(master)
	drop _m
	}

//Generate indicators for year of first prescription
gen rx_year=year(Rx_eventdate)
tab rx_year, gen(rx_year_)

compress

save "/Volumes/varenicline_CPRD/7_negative_controls/working_data/analysis_anti_dep_dataset",replace

//Create number of consultations

cd "/Volumes/filestore/Studies/MHRA Project/New anti-depressants data/Suicides and anti-depressants2/Raw data/Stata"

fs *consultation*

foreach i in `r(files)'{
	use patid eventdate constype if constype==1|constype==9 using `i',clear
	date eventdate
	drop if year(eventdate)<2004
	save "/Volumes/varenicline_CPRD/7_negative_controls/working_data/`i'",replace
	}
	
fs "/Volumes/varenicline_CPRD/7_negative_controls/working_data/*consultation*"
foreach i in `r(files)'{
	append using "/Volumes/varenicline_CPRD/7_negative_controls/working_data/`i'"
	}
compress
save "/Volumes/varenicline_CPRD/7_negative_controls/working_data/ecnmd/consultations",replace

use patid Rx_eventdate follow_up using "/Volumes/varenicline_CPRD/7_negative_controls/working_data/analysis_anti_dep_dataset",clear
joinby patid using  "/Users/ecnmd/consultations",unmatched(master)

//Create actual outcomes within 3, 6, 9, 12, 24 and 48 months of first prescription
foreach i in 3 6 9 12 24 48{
	gen out_num_cons_`i'mth=(eventdate-Rx_eventdate<`i'*365.25/12&eventdate-Rx_eventdate>0) if follow_up>`i'*365.25/12 
	bys patid: egen X=total(out_num_cons_`i'mth) 
	replace out_num_cons_`i'mth=X
	drop X
	}

bys patid: keep if _n==1

foreach i in 3 6 9 12 24 48{
	replace out_num_cons_`i'=. if follow_up<=`i'*365.25/12 
	}
keep patid out_num_cons_*
compress
save "/Volumes/varenicline_CPRD/7_negative_controls/working_data/AD_num_consultations",replace

use  "/Volumes/varenicline_CPRD/7_negative_controls/working_data/analysis_anti_dep_dataset",clear
joinby patid using "/Volumes/varenicline_CPRD/7_negative_controls/working_data/AD_num_consultations",unmatched(master)
drop _m
save "/Volumes/varenicline_CPRD/7_negative_controls/working_data/analysis_anti_dep_dataset",replace
fs "/Users/ecnmd/*consultation*"
foreach i in `r(files)'{
	rm  "/Users/ecnmd/`i'"
	}
