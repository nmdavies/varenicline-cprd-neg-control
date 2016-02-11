//Neil Davies 27/11/15
//This runs the first stage analysis (association of the instrument and the exposure).

use "7_negative_controls/working_data/analysis_dataset",clear
reg dr_varenicline iv cov_male rx_*, cluster(staffid)

forvalues i=2(1)7{
	bys staffid (Rx_eventdate patid): gen iv_`i'=dr_varenicline[_n-`i']
	}
	
forvalues i=2(1)7{
	reg dr_varenicline iv iv_2-iv_`i' cov_male rx_*, cluster(staffid)

	}
gen iv_1=iv

gen u=uniform()
	
forvalues i=2(1)7{	
	ivreg2 u (dr_varenicline =iv_1 iv_2-iv_`i') rx_year* cov_male ,cluster(staffid) partial(rx_year_* cov_male)
	}
	
	
