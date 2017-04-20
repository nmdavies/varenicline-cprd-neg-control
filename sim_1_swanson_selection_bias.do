//Neil Davies 01/07/16
//This investigates the bias caused by selection into treatment as reported by Swanson et al.

//Results from a simulation with a dichotomous instrument Z, a trichotomous treatment X, and a dichotomous outcome Y. 
//We generated 1,000 samples of 20,000 patients such that Zi ∼ bernoulli(0.5), Ui ∼ bernoulli(0.2), Yi ∼ bernoulli(0.1 + 0.3Ui),
// and Xi ∼ multinom(0.5 − 0.1Zi − 0.4Zi Ui , 0.4 + 0.05Zi + 0.05Zi Ui , 0.1 + 0.05Zi + 0.35Zi Ui). Results are shown for the distribution of 
// the bias across the simulations in the standard instrumental variable numerator in the entire population (mean bias = 0) (A) and 
// in analyses restricted to observations with X = 1 or X = 2 (mean bias = −0.02) (B). In estimating the treatment effect on the risk difference scale, 
// the mean bias from our simulations based on a crude treatment effect estimate was 0.03 (C), while the mean bias from the instrumental variable analysis
// was −0.15 (D)


set seed 54321
clear
set obs 200000

gen z = rbinomial(1,0.5)
gen u = rbinomial(1,0.2)
gen y = rbinomial(1,0.1+0.3*u)

//First create the treated or not indicator:

gen untreated = rbinomial(1, 0.1) if  z==0 
replace untreated = rbinomial(1, 0.5) if z==1 & u==1
replace untreated = rbinomial(1, 0.15) if z==1 & u==0

gen x = rbinomial(1, 0.4/0.9) if z==0
replace x= 1 if z==1 & u==1
replace x= rbinomial(1, 0.45/0.85) if z==1 & u==0

replace x=2 if untreated==1

reg y z if x!=2
reg y x if x!=2
ivreg2 y (x=z) if x!=2

//Alternatively we could include an interaction for the confounder:

gen i_z_u=z*u
ivreg2 y (x=z i_z_u) u if x!=2

//Or include the entire sample
ivreg2 y (x=z)


//However, if we have a different scenario then there we don't see this bias:
//The following has no difference in the rate of untreated (all patients get switched to tratment 2).

set seed 54321
clear
set obs 200000

gen z = rbinomial(1,0.5)
gen u = rbinomial(1,0.2)
gen y = rbinomial(1,0.1+0.3*u)

//First create the treated or not indicator:

gen untreated = rbinomial(1, 0.1) if  z==0 
replace untreated = rbinomial(1, 0.15) if z==1 & u==1
replace untreated = rbinomial(1, 0.15) if z==1 & u==0

gen x = rbinomial(1, 0.4/0.9) if z==0
replace x= 1 if z==1 & u==1
replace x= rbinomial(1, 0.45/0.85) if z==1 & u==0

replace x=2 if untreated==1

reg y z if x!=2
reg y x if x!=2
ivreg2 y (x=z) if x!=2


//However, if we have a different scenario then there we don't see this bias:
//The following has no difference in the rate of untreated (all patients get switched to tratment 2).

set seed 54321
clear
set obs 200000

gen z = rbinomial(1,0.5)
gen u = rbinomial(1,0.2)
gen y = rbinomial(1,0.1+0.3*u)

//First create the treated or not indicator:

gen untreated = rbinomial(1, 0.1) if  z==0 
replace untreated = rbinomial(1, 0.1) if z==1 & u==1
replace untreated = rbinomial(1, 0.1) if z==1 & u==0

gen x = rbinomial(1, 0.4/0.9) if z==0
replace x= 1 if z==1 & u==1
replace x= rbinomial(1, 0.45/0.85) if z==1 & u==0

replace x=2 if untreated==1

reg y z if x!=2
reg y x if x!=2
ivreg2 y (x=z) if x!=2


//Demostrating that even a proxy confounder which is weakly associated with the true confounder can detect this bias.
set seed 54321
clear
set obs 200000

gen z = rbinomial(1,0.5)
gen u = rbinomial(1,0.2)
gen y = rbinomial(1,0.1+0.3*u)

//Generate proxy confounder
gen u_proxy=u+rbinomial(1,0.2)*10

//First create the treated or not indicator:

gen untreated = rbinomial(1, 0.1) if  z==0 
replace untreated = rbinomial(1, 0.1) if z==1 & u==1
replace untreated = rbinomial(1, 0.1) if z==1 & u==0

gen x = rbinomial(1, 0.4/0.9) if z==0
replace x= 1 if z==1 & u==1
replace x= rbinomial(1, 0.45/0.85) if z==1 & u==0

replace x=2 if untreated==1

reg y x if x!=2
ivreg2 y (x=z) if x!=2, endog(x)

reg u x if x!=2
ivreg2 u (x=z) if x!=2, endog(x)

reg u_proxy x if x!=2
ivreg2 u_proxy (x=z) if x!=2, endog(x)

