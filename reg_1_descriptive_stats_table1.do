//Neil Davies 26/11/15
//This creates the descriptive statistics for the nicotine cessation therapy cohort for the negative control paper

use "7_negative_controls/working_data/analysis_dataset",clear

drop rx_year_1

order cov_age cov_male rx_year_2-rx_year_7 

tabstat cov_male cov_age rx_year_* cov_num_cons_12mth cov*_12 if dr_varenicline==1 & iv!=. & cov_male!=., stats(mean sd n min max) c(s) save
matrix table1=r(StatTotal)'
tabstat cov_male cov_age rx_year_* cov_num_cons_12mth  cov*_12 if dr_varenicline==0 & iv!=. & cov_male!=., stats(mean sd n min max) c(s) save
matrix table1=100*(table1,r(StatTotal)')

matrix li table1
	 
