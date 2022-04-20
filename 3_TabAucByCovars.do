***** 3_TabAucByCovars.do *****
frame reset
use Data/cohort.dta, clear

*** Find cutoff points
/*
For ROC curves higher values must indicate higher risk (of EF-improvement in this case). 
lroc, determines this automatically, but does not show markers of the actual cutoffs. 
roctab can show markers and cutoffs but does not automatically change the direction of exposure to reflect higher risk. 
Therefore, the code below provides cutoff values, to manually add to the lroc curves.
*/
/*
capture: mkdir Output/RocCutoff
capture: log close

log using "Output/RocCutoff/Cutoffs_results.smcl", replace

di "PRIMARY OUTCOME (EF >=5)"
foreach expvar of global expvars {
	local label : var label `expvar'
	di _n(3) "`expvar' - `label' on primary outcome"
	
	*gen `expvar'_lab = ustrunescape("\u2265") + string(`expvar')
	*qui: replace `expvar'=`expvar'*-1
	
	roctab ef_prim `expvar', detail label // graph name("`expvar'", replace) title("`label'") mlabel(`expvar'_lab) 
	*qui: graph export Output/RocCutoff/Roc_Prim_`expvar'$exportformat $exportoptions
}

di _n(6) "SECONDARY OUTCOME (EF >=10)"
foreach expvar of global expvars {
	local label : var label `expvar'
	di _n(3) "`expvar' - `label' on secondary outcome"

	roctab ef_prim `expvar', detail label // name("`expvar'", replace) title("`label'") mlabel(`expvar'_lab) 
	*qui: graph export Output/RocCutoff/Roc_Sec_`expvar'$exportformat $exportoptions
}

log close
translate "Output/RocCutoff/Cutoffs_results.smcl" "Output/RocCutoff/Cutoffs_results.pdf", translator(smcl2pdf)

*/

*** Setup layout of table
** Generate table
addtab_setup, frame(table) columnvar(pat_dm)

** Add headers
addtab_header, varname("!mi(id)") rowname("Overall")

* Pat char
addtab_header, varname(BOLD) rowname("Patient characteristics")

addtab_header, varname(GROUPHEADER) rowname("Sex")
addtab_header, varname("pat_sex==1") rowname("- Men")
addtab_header, varname("pat_sex==0") rowname("- Women")

addtab_header, varname(GROUPHEADER) rowname("Diabetes")
addtab_header, varname("pat_dm==1") rowname("- Yes")
addtab_header, varname("pat_dm==0") rowname("- No")

* Cardiac status
addtab_header, varname(BOLD) rowname("Cardiac status")

addtab_header, varname(GROUPHEADER) rowname("Pre-intervention EF")
addtab_header, varname("ef_pre_median==0") rowname("- Below median")
addtab_header, varname("ef_pre_median==1") rowname("- Above median")

addtab_header, varname(GROUPHEADER) rowname("Area of intervention, n (%)")
addtab_header, varname("itv_cat==1") rowname("- LAD")
addtab_header, varname("itv_cat==2") rowname("- LCx")
addtab_header, varname("itv_cat==3") rowname("- RCA")
addtab_header, varname("itv_cat==4") rowname("- Multiple areas")

* Hibernation status
addtab_header, varname(BOLD) rowname("Hibernation")

addtab_header, varname(GROUPHEADER) rowname("Hibernation above/below median")
addtab_header, varname("pet_hiber_bin==1") rowname("- Above")
addtab_header, varname("pet_hiber_bin==0") rowname("- Median or below")

addtab_header, varname(GROUPHEADER) rowname("Hibernation above/below 5")
addtab_header, varname("pet_hiber_bin2==1") rowname("- 5 or above")
addtab_header, varname("pet_hiber_bin2==0") rowname("- Below 5")


** Modify headers in table
frame table: drop col_*
frame table: gen no = "N EF improved_P/N total" if _n==1
foreach expvar of global expvars {
	local label : var label `expvar'
	local label = subinstr("`label'", ";", "_p", 1)
	qui frame table: gen `expvar' = "`label'" if _n==1
}


*** Calculate AUC by covar
local format = `", 0.01), "%4.2f" "'

foreach row in "!mi(id)" "pat_sex==1" "pat_sex==0" "pat_dm==1" "pat_dm==0" "ef_pre_median==0" "ef_pre_median==1" "itv_cat==1" "itv_cat==2" "itv_cat==3" "itv_cat==4" "pet_hiber_bin==1" "pet_hiber_bin==0" "pet_hiber_bin2==1" "pet_hiber_bin2==0" {
	di "`row'"
	* N
	qui: count if `row' & ef_prim==1
	local n_improv = `r(N)'
	qui: count if `row' 
	local n_total = `r(N)'
	di "`n_improv'/`n_total'"
	qui frame table: replace no = "`n_improv'/`n_total'" if varname=="`row'"
	
	* AUC
	foreach expvar of global expvars {
		qui: roctab ef_prim `expvar' if `row'
		local result = string(round(`r(area)' `format') ///
				+ "_p(" ///
				+ string(round(`r(lb)' `format') ///
				+ "-" ///
				+ string(round(`r(ub)' `format') ///
				+ ")"
		di _col(5) "`expvar'" _col(25) "`result'"
		qui frame table: replace `expvar' = "`result'" if varname=="`row'"
	}
}

frame table: save Output/TabAucByCovars.dta, replace
/*
frame change table
frame drop table
