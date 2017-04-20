//Neil Davies 01/07/16
//This simulation demostrates that including random covariates which are not confounders
// you would incorrect conclude that the IV is more biased than conventional regression


set seed 54321
clear
set obs 100000

gen v = rnormal(0,1)
gen w = rnormal(0,1)
gen u = rnormal(0,1)
gen z = rbinomial(1,0.2)
			
forvalues k=1(1)10{
	gen c_`k'=rbinomial(1,0.2)
	}
			
gen x_i = z*0.5+ u+w
sort x_i 
gen id = _n
gen x = 0
replace x=1 if id>(10000-floor(0.2*10000))

gen y = x*0.5+ u +v
keep x y z c_*

//*********************************
//Code to run the GMM hetero tests
//*********************************

//Syntax hetero_test outcome exposure instrument covar1 [covar2.....]

cap prog drop hetero_test
prog def hetero_test

args outcome exposure iv 

macro shift 3
local covar="`*'"

cap drop _const
cap gen _const  = 1

di "outcome=`outcome'"
di "exposure=`exposure'"
di "instrumen=`iv'"
di "covariates=`covar'"

gmm (`outcome' - {xb1:`exposure' `covar' _const})  ///
	(`outcome' - {xb2:`exposure' `covar' _const}) , ///
	instruments(1:`exposure' `covar') ///
	instruments(2:`iv' `covar') ///
	winit(unadjusted,independent) onestep  ///
	deriv(1/xb1 = -1) ///
	deriv(2/xb2 = -1)
drop _const

local outcome2=substr("`outcome'",1,16)
est sto results_`outcome2'

lincom _b[xb1:`exposure']-_b[xb2:`exposure']
local het_p=2*(1-normal(abs(r(estimate)/r(se))))

regsave `exposure' using "results/bias_plots_basic_adjusted_`outcome'_`exposure'", detail(all) pval ci replace addvar(het_p,`het_p')

end

forvalues k=1(1)10{
	hetero_test c_`k' x z 
	}
forvalues k=1(1)10{
	label variable c_`k' "c`k'"	
	}
	
ds c_*	
foreach i in `r(varlist)'{
	
	local var="`i'"
	local name_var: variable label `var'  /* <- save variable label in local `lab' */
	
	di "`name_var'"

	local outcome2=substr("`i'",1,16)
	di "`outcome2'"
	local n=`n'+1
	local reg=`"(results_`outcome2' ,noci keep(xb1:x) ms(S) mc(gs5) offset(0.05) rename(xb1:x="`name_var'"))"'
	local ivreg=`"(results_`outcome2',noci keep(xb2:x) ms(T) mc(gs10) offset(-0.05) rename(xb2:x="`name_var'"))"'
	
	local combined=`"`combined'"'+" "+`"`reg'"'+" "+`"`ivreg'"'
	di `"`combined'"'
	
	}
	
	
di `"`combined'"'
coefplot `"`combined'"' , noci legend(off) xline(0) byopts(yrescale) xlab(-0.3(0.1)0.3) xtitle("Bias component") graphregion(color(white)) 
graph save "results/graph_bias_plot_binary",replace 
graph use  "results/graph_bias_plot_binary"
graph export "results/figure_4_bias_plota.eps", as(eps) replace

ds c_*	
foreach i in `r(varlist)'{
	
	local var="`i'"
	local name_var: variable label `var'  /* <- save variable label in local `lab' */
	
	di "`name_var'"

	local outcome2=substr("`i'",1,16)
	di "`outcome2'"
	local n=`n'+1
	local reg=`"(results_`outcome2' ,keep(xb1:x) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(xb1:x="`name_var'"))"'
	local ivreg=`"(results_`outcome2',keep(xb2:x) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05) rename(xb2:x="`name_var'"))"'
	
	local combined=`"`combined'"'+" "+`"`reg'"'+" "+`"`ivreg'"'
	di `"`combined'"'
	
	}
	
	
di `"`combined'"'
coefplot `"`combined'"' , legend(off) xline(0) byopts(yrescale) xlab(-0.3(0.1)0.3) xtitle("Bias component") graphregion(color(white)) 
graph save "results/graph_bias_plot_binary",replace 
graph use  "results/graph_bias_plot_binary"
graph export "results/figure_4_bias_plotb.eps", as(eps) replace


