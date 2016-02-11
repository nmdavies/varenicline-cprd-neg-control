//Neil Davies 13/11/15
//This cleans the varenicline therapy files to get all the varenicline prescription events:
//THIS USES THE OLD MHRA DATA.
//We did this because we wanted to use patients prescribed anti-depressants as negative controls.
//We do not have patients prescribed anti-depressants in the new data.
 
cap prog drop extract_events
prog def extract_events
cap ssc install fs
if "`1'"=="med"{
	local files ""
	foreach j in clinical referral test{
		cd "`2'`3'"
		fs "`j'*"		
		foreach f in `r(files)' {
			cd "`2'"
			use "`3'/`f'",clear
			joinby medcode using "codelists/statalists/`4'.dta" 
			compress
			rename eventdate clinical_eventdate
			keep patid medcode clinical_eventdate
			save "tempdata/`f'_eventlist_`4'.dta", replace
			local files : list  f | files
			di "`files'"
			}
		}
	foreach i in `files'{
		append using "tempdata/`i'_eventlist_`4'.dta"
		rm "tempdata/`i'_eventlist_`4'.dta"
		}
	}
	
if "`1'"=="prod"{
	cd "`2'`3'/
	local files ""
	foreach j in therapy{
		fs "`j'*"	
		
		foreach f in `r(files)' {
			cd "`2'"
			use "`3'/`f'",clear
			joinby prodcode using "codelists/statalists/`4'" 
			compress
			rename eventdate clinical_eventdate
			keep patid prodcode staffid clinical_eventdate
			save "tempdata/`f'_eventlist_`4'.dta", replace
			local files : list  f | files		
			}
		}
	foreach i in `files'{
		append using "tempdata/`i'_eventlist_`4'.dta"
		rm "tempdata/`i'_eventlist_`4'.dta"
		}
	}
duplicates drop
save "tempdata/eventlist_`1'_`4'_`5'.dta", replace
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

foreach i in nrt /* smokemed varenicline  buproprion  antidepressants antipsyc_stabalis cns_stimulants dementiameds hypnotics_anxiolytics lithium */ {
	extract_events prod "/Volumes/varenicline_CPRD/" "old files/raw_mhra_data_OLD/nrt" `i' nrt
	extract_events prod "/Volumes/varenicline_CPRD/" "old files/raw_mhra_data_OLD/varenicline" `i' varenicline
	append using "tempdata/eventlist_prod_`i'_nrt.dta"
	save "7_negative_controls/working_data/eventlist/eventlist_prod_`i'.dta",
	rm "tempdata/eventlist_prod_`i'_nrt.dta"
	rm "tempdata/eventlist_prod_`i'_varenicline.dta"
	}

//There are no buproprion prescriptions in the varenicline data therefore I will manually create the buproprion eventlists:

use "tempdata/eventlist_prod_buproprion_nrt.dta",clear
save "7_negative_controls/working_data/eventlist/eventlist_prod_buproprion.dta",replace
rm "tempdata/eventlist_prod_buproprion_nrt.dta"
	
foreach i in /* autism bipolar current_smokers dementia depression	eatingdis hyperkineticdis  learningdis neuroticdis otherbehavdis persondis schizop smoke alcohol_misuse prob_selfharm drug_misuse TEMP_CHARLSON_INDEX TEMP_ALL_PSYCHIATRIC_ILLNESS fractures*/ uti{
	extract_events med "/Volumes/varenicline_CPRD/" "old files/raw_mhra_data_OLD/nrt"  `i' nrt
	extract_events med "/Volumes/varenicline_CPRD/" "old files/raw_mhra_data_OLD/varenicline"  `i' varenicline
	
	append using "tempdata/eventlist_med_`i'_nrt.dta"
	save "7_negative_controls/working_data/eventlist/eventlist_med_`i'.dta",replace
	rm "tempdata/eventlist_med_`i'_nrt.dta"
	rm "tempdata/eventlist_med_`i'_varenicline.dta"
	}
	
//Move the temporary lists for Charlson index and any psychiatric events
!mv "7_negative_controls/working_data/eventlist/eventlist_med_TEMP_ALL_PSYCHIATRIC_ILLNESS.dta" "7_negative_controls/working_data/eventlist/eventlist_med_TEMP_ALL_PSYC_ILL.dta"
!mv "7_negative_controls/working_data/eventlist/eventlist_med_TEMP_CHARLSON_INDEX.dta" "7_negative_controls/working_data/eventlist/eventlist_med_TEMP_CHARLSON.dta"
