//Neil Davies 01/12/15
//This extracts all the patient data for the anti-depressants cohort for the negative controls paper.

//Program to convert dates

cap prog drop date
prog def date
foreach k in eventdate sysdate chsdate frd crd tod deathdate uts lcd{
	cap{
		gen `k'2 = date(`k', "DMY")
		format %td `k'2
		drop `k'
		rename `k'2 `k'
		replace `k'=. if `k'>150000
		}
	}
end 


set more off

cd "/Volumes/SSCM_shared/Studies/MHRA Project/New anti-depressants data/Suicides and anti-depressants2/Raw data/Stata"
use ssri2_m_pet_patient001_zipped.dta,clear
fs ssri*pet_patient* other*pet_patient* tca*pet_patient*
foreach f in `r(files)' {
	append using `f'
	}
duplicates drop	

gen pracid =real(substr(string(patid,"%11.0g"),-3,3))

//get the UTS date and last collection date:
joinby pracid using "/Volumes/SSCM_shared/Studies/MHRA Project/New anti-depressants data/Suicides and anti-depressants2/Raw data/stata/ssri3_f_pet_practice001_zipped.dta", unmatched(master)
tab _m
drop _m

//replace to date equal to last collection date if missing:
//patient file - documentation directory

date
drop from_date end_date
replace yob=yob+1800
gen from_date=crd
replace from_date=uts if uts>crd
gen end_date=tod
replace end_date=lcd if end_date==.
keep patid from_date end_date pracid yob deathdate gender
rename gender cov_male
replace cov_male=0 if cov_male==2
replace cov_male=. if cov_male==3
compress
format %td from_date end_date
cd "/Volumes/varenicline_CPRD/"

save  "7_negative_controls/working_data/ANTI_DEPRESS_registration_period.dta",replace

//Need to create a list of events when each patient interacted with their GP from the clinical files:
cd "/Volumes/SSCM_shared/Studies/MHRA Project/New anti-depressants data/Suicides and anti-depressants2/Raw data/Stata"


fs ssri*pet_consultation* other*pet_consultation* tca*pet_consultation*
foreach f in `r(files)' {
	use patid eventdate staffid constype using `f' if constype==1 |constype==9,clear
	joinby patid using "/Volumes/varenicline_CPRD/7_negative_controls/working_data/ANTI_DEPRESS_registration_period.dta",unmatched(master)
	tab _m
	keep patid eventdate constype staffid cov_male-end_date
	compress
	date
	keep if eventdate>from_date & eventdate<end_date
	save "/Volumes/varenicline_CPRD/7_negative_controls/working_data/`f'_temp",replace
	}

fs ssri*pet_consultation* other*pet_consultation* tca*pet_consultation*
foreach f in `r(files)'{
	append using "/Volumes/varenicline_CPRD/7_negative_controls/working_data/`f'_temp",
	}
drop constype
compress
save "/Volumes/varenicline_CPRD/7_negative_controls/working_data/temp_ad_deathdates_consultations",replace

//Next need to exclude patients who were prescribed both a anti-depressant and a smoking cessation medication

preserve

use "/Volumes/varenicline_CPRD/old files/raw_mhra_data_OLD/nrt/patient.dta",clear
append using  "/Volumes/varenicline_CPRD/old files/raw_mhra_data_OLD/varenicline/patient.dta"
keep patid
save "/Volumes/varenicline_CPRD/7_negative_controls/working_data/nrt_patients", replace

restore

joinby patid using "/Volumes/varenicline_CPRD/7_negative_controls/working_data/nrt_patients",unmatched(both)
tab _m
drop if _m==3|_m==2

save "/Volumes/varenicline_CPRD/7_negative_controls/working_data/temp_ad_deathdates_consultations",replace

use "/Volumes/varenicline_CPRD/7_negative_controls/working_data/temp_ad_deathdates_consultations" if eventdate >17044,clear
save "/Users/ecnmd/temp.dta",replace
use  "/Users/ecnmd/temp.dta",clear
//Match in the smoking cessation prescriptions:
foreach i in patid cov_male yob deathdate from_date end_date {
	rename `i' `i'_AD
	}
drop _m
rename eventdate Rx_eventdate

//Need to add a variable to sort each of the patients who are seen on the same day. I order them by their ID.
set seed 12345
gen u=uniform()

//Need to ensure we only have one event per AD patient per day
bys patid Rx_eventdate (u):keep if _n==1
 
bys staffid Rx_eventdate (u): gen n=_n
compress
save "/Users/ecnmd/temp2.dta",replace


preserve

//Next I do the same for the NRT prescriptions (randomly order prescriptions issued on the same day by the same physician).

use "/Volumes/varenicline_CPRD/7_negative_controls/working_data/first_eligible_smoking_cessation_Rx.dta",clear
set seed 12345
gen u=uniform()
bys staffid Rx_eventdate (u): gen n=_n
save "/Volumes/varenicline_CPRD/7_negative_controls/working_data/first_eligible_smoking_cessation_Rx_ordered.dta",replace

restore

joinby staffid Rx_eventdate n using 	"/Volumes/varenicline_CPRD/7_negative_controls/working_data/first_eligible_smoking_cessation_Rx_ordered.dta" ,unmatched(using)

//Drop 32,258 patients who were prescribed NRT on a day when their GP saw insufficent anti-depressant patients.
drop if _m==2
tab _m

//Drop AD patients who died prior to the prescription and the consultation event (data errors)
gen diff=deathdate_AD-Rx_eventdate
drop if diff<0

format %td from_date end_date

//Some patients prescribed anti-depresants were matched to more than one patient prescribed smoking cessation medication. Will randomly keep one AD patient.
bys patid_AD (u): keep if _n==1

gen follow_up_AD=end_date-Rx_eventdate

//One outcome death
foreach i in 3 6 9 12 24 48{
	gen out_dead_`i'=(diff<365.25*`i'/12 & diff!=.) if follow_up_AD>365.25*`i'/12
	}
	
compress

bys staffid (Rx_eventdate patid):gen iv=dr_varenicline[_n-1]
drop u n _m patid prodcode cov_male yob deathdate from_date end_date follow_up history diff 

save  "/Volumes/varenicline_CPRD/7_negative_controls/working_data/temp_matched_ad_patients",replace
keep patid_AD
rename patid patid
save  "/Volumes/varenicline_CPRD/7_negative_controls/working_data/temp_matched_ad_patients_ads",replace


