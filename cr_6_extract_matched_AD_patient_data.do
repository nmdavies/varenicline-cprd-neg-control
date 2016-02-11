//Neil Davies 03/12/15
//This extracts all the data from the matched patients prescribed anti-depressants.

cd "/Volumes/SSCM_shared/Studies/MHRA Project/New anti-depressants data/Suicides and anti-depressants2/Raw data/Stata"

fs /**pet_clinical* other*pet_referral* *pet_consultation* */ *pet_therapy*

foreach i in `r(files)' {
	di "`i'"
	use "`i'",clear
	joinby patid using "/Volumes/varenicline_CPRD/7_negative_controls/working_data/temp_matched_ad_patients_ads.dta",unmatched(none)
	save  "/Volumes/varenicline_CPRD/7_negative_controls/working_data/MATCHED_`i'.dta",replace
	}


//Next we need to generate all of the eventlists used in the negative controls study:

cap prog drop extract_events
prog def extract_events
cap ssc install fs
if "`1'"=="med"{
	local files ""
	foreach j in clinical referral test{
		cd "`2'`3'"
		fs "*`j'*"
		foreach f in `r(files)' {
			cd "`2'"
			use "`3'/`f'",clear
			joinby medcode using "/Volumes/varenicline_CPRD/codelists/statalists/`4'.dta" 
			compress
			rename eventdate clinical_eventdate
			keep patid medcode clinical_eventdate
			save "/Users/ecnmd/`f'_eventlist_`4'.dta", replace
			local files : list  f | files
			di "`files'"
			}
		}
	foreach i in `files'{
		append using "/Users/ecnmd/`i'_eventlist_`4'.dta"
		rm "/Users/ecnmd/`i'_eventlist_`4'.dta"
		}
	}
	
if "`1'"=="prod"{

	cd "`2'`3'/"
	local files ""
	foreach j in therapy{
		fs "*`j'*"	
		di "HERE"
		foreach f in `r(files)' {
			cd "`2'"
			use "`3'/`f'",clear
			joinby prodcode using "/Volumes/varenicline_CPRD/codelists/statalists/`4'" 
			compress
			rename eventdate clinical_eventdate
			keep patid prodcode staffid clinical_eventdate
			save "/Users/ecnmd/`f'_eventlist_`4'.dta", replace
			local files : list  f | files		
			}
		}
	foreach i in `files'{
		append using "/Users/ecnmd/`i'_eventlist_`4'.dta"
		rm "/Users/ecnmd/`i'_eventlist_`4'.dta"
		}
	}
duplicates drop

end 

//The syntax of the program is:

//extract_events [med|prod] [main project directory] [raw data directory] [drug type] [event]

//You need to have a stata code list called event.dta in the codelist directory. E.g. in the example below it's "smoke", this extracts all the smoking events.
//In future we may be able to get rid of drug type.

//For this dataset to extract other clinical events, all we need to do is change "smoke" to "dementia"
//To extract other therapy events, all we need to do is change med to prod and "smoke" to "varenicline".

//example* extract_events med "z:/" "old files/raw_mhra_data/"  varenicline smoke
//example* extract_events med "z:/" "old files/raw_mhra_data/"  nrt smoke

//Extract all of the varenicline or NRT events:
 
foreach i in antidepressants antipsyc_stabalis cns_stimulants dementiameds hypnotics_anxiolytics lithium{
	extract_events prod "/Volumes/varenicline_CPRD/" "7_negative_controls/working_data/anti_dep_sample/" `i'
	count
	save "/Volumes/varenicline_CPRD/7_negative_controls/working_data/eventlist/eventlist_anti_dep_prod_`i'.dta",replace
	}

foreach i in /*autism bipolar current_smokers dementia depression	eatingdis hyperkineticdis  learningdis neuroticdis otherbehavdis persondis schizop smoke alcohol_misuse prob_selfharm drug_misuse TEMP_CHARLSON_INDEX TEMP_ALL_PSYCHIATRIC_ILLNESS*/ fractures {
	extract_events med "/Volumes/varenicline_CPRD/" "7_negative_controls/working_data/anti_dep_sample/"  `i'
	save "/Volumes/varenicline_CPRD/7_negative_controls/working_data/eventlist/eventlist_anti_dep_med_`i'.dta",replace
	}
	
