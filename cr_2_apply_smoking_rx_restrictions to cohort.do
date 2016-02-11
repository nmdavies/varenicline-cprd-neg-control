///UPDATE 18/11/15 Gemma Taylor + Neil Davies 14-10-15
///This .do file checks smoking event files against protocol restrictions

///.do file based on ISAC/BMJ Open protocol restrictions:
/// -Patient was at least aged 18 at time of first smoking rx prescription;
/// -Prescribed smoking cessation medicines from 1st September 2006;
/// -Records from patients classified as acceptable by the CPRD from all up to standard practices at least 18 months prior to date of (registration) entry of each cohort - this is 1st January 2005 in the ISAC protocol, but is March 1 2005 in BMJ Open protocol; should we be using March 1 2005, based on emails from the data-extraction team? Not sure if this restriction matters too much in the data we're using right now as there are no unacceptable patient records in either the NRT or varenicline files.

set more off

use "/Volumes/varenicline_CPRD/old files/raw_mhra_data_OLD/nrt/patient.dta",clear
append using  "/Volumes/varenicline_CPRD/old files/raw_mhra_data_OLD/varenicline/patient.dta"

gen pracid =real(substr(string(patid,"%11.0g"),-3,3))

//get the UTS date and last collection date:
joinby pracid using "/Volumes/varenicline_CPRD/old files/raw_mhra_data_OLD/nrt/practice.dta", unmatched(master)

//replace to date equal to last collection date if missing:
//patient file - documentation directory
gen from_date=crd
replace from_date=uts if uts>crd
gen end_date=tod
replace end_date=lcd if end_date==.
keep patid from_date end_date pracid yob deathdate gender
rename gender cov_male
replace cov_male=0 if cov_male==2
replace cov_male=. if cov_male==3
compress
save  "7_negative_controls/working_data/registration_period.dta",replace

use "7_negative_controls/working_data/eventlist/eventlist_prod_nrt.dta" ,clear

///generate dummy variable for drug type
gen dr_varenicline=0
append using "7_negative_controls/working_data/eventlist/eventlist_prod_varenicline.dta"
replace  dr_varenicline=1 if dr_varenicline==.
label define dr_varenicline 0 "nrt" 1 "varenicline" 2 "bupropion"
label values dr_varenicline dr_varenicline
label variable dr_varenicline "smoking cessation drug"
append using "7_negative_controls/working_data/eventlist/eventlist_prod_buproprion.dta"
replace dr_varenicline=2 if dr_varenicline==.

compress
codebook patid 
**check how many distinct patients there are before and after merge
joinby patid using "7_negative_controls/working_data/registration_period.dta",unmatched(master)
codebook patid
drop if clinical_event==.

///format dates
replace yob= yob+1800
gen min_dob=(yob-1960)*365.25+1
gen max_dob=(yob-1960)*365.25+365.25
format %td min_dob max_dob
gen year_regstart=year(from_date)
gen year_regend=year(end_date) 

///drop patients if their maximum age is 15 at time of prescription
gen max_age_Rx=(clinical_eventdate-min_dob)/365.25
drop if max_age_Rx<16

codebook patid 
**how many patients were dropped? n=

//Drop if patient prescribed after registration period:
drop if clinical_eventdate>end_date

//generate variable indicating if smoking rx occured before registration period, or if the patient was 16/17 at time of prescription
gen exclude =(clinical_eventdate<from_date|max_age_Rx<18) 

//Exclude all prescriptions which occurred before 1st Septemeber 2006:
replace exclude=1 if clinical_eventdate<date("01/09/2006", "DMY")

//Exclude prescriptions when both varenicline and NRT were issued on the same day:
bys patid clinical_eventdate: egen sd=sd(dr_varenicline)
replace exclude=1 if sd!=0 & sd!=.
drop sd

//Check whether the staff memeber issuing the prescription was a GP:
drop _m
joinby staffid using "/Volumes/varenicline_CPRD/old files/raw_mhra_data_OLD/nrt/staff.dta", unmatched(both)
tab _m
drop _m
joinby staffid using "/Volumes/varenicline_CPRD/old files/raw_mhra_data_OLD/varenicline/staff_1.dta", unmatched(both) update
replace exclude=1 if !inlist(role,1,2,5,6,7,8,9,10,47,50)
drop _m role gender

//Check if the most recent ineligible prescription was within 18 months of the first prescription.
//To do this we must create the difference in time between each prescription:
bys patid (clinical_eventdate exclude):gen diff=clinical_eventdate-clinical_eventdate[_n-1]

//Generate follow_up and history
gen follow_up=end_date-clinical_eventdate
gen history=clinical_eventdate-from_date

//Exclude prescriptions with less than a year of historical follow-up prior to prescription
replace exclude=1 if history<365.25

//Exclude patients prescribed bupropion
replace exclude=1 if dr_varenicline==2

//Exclude any prescription which had a prior prescription within 18 months:
replace exclude=1 if diff<365.25*1.5 & diff!=.
tab exclude


//Create variable which indicates the order of the prescription through time, for both the ineligible prescriptions and the eligible prescriptions:
bys patid exclude (clinical_eventdate): gen n=_n

//Drop all the ineligible prescriptions and all but the first eligible prescription
drop if n!=1 | exclude==1

rename clinical_eventdate Rx_eventdate

compress
drop n year_* max_age_Rx exclude diff min_dob max_dob

notes _dta: cohort of patients prescribed varenicline and NRT. Patients not meeting restriction criteria have been dropped from this dataset.
label data "cohort of patients prescribed nrt and varenicline, restictions applied"
save "7_negative_controls/working_data/first_eligible_smoking_cessation_Rx.dta", replace
