***** 3_FigROC.do *****
use Data/cohort.dta, clear
capture: mkdir Output/Roc

foreach expvar of global expvars {
    local label : var label `expvar'
	
	if strpos("`label'", ";") {
	    local title = substr("`label'", 1, strpos("`label'", ";")-1)
		local subtitle = substr("`label'", strpos("`label'", ";")+1, .)
		local title = `" "`title'" "`subtitle'" "'
	}
	else {
	    local title = "`label'"
	}
	
	di `"`expvar' - `label' / `title' "'

	** Primary
	
	qui: roctab ef_prim `expvar' , graph name("Prim_`expvar'", replace) title(`title')
	qui: graph export "Output/Roc/ROC_Prim_`expvar'${exportformat}" $exportoptions
	
	local graphs_prim = "`graphs_prim' Prim_`expvar'"
	
	** Secondary
	qui: roctab ef_sec `expvar' , graph name("Sec_`expvar'", replace) title(`title')
	qui: graph export "Output/Roc/ROC_Sec_`expvar'${exportformat}" $exportoptions
	
	local graphs_sec = "`graphs_sec' Sec_`expvar'"
}

di "`graphs_prim'" _n(2) "`graphs_sec'"

graph combine `graphs_prim', col(3) name(comb_prim, replace) altshrink
graph export "Output/ROC_Prim_Combined${exportformat}" $exportoptions
graph combine `graphs_sec', col(3) name(comb_sec, replace) altshrink
graph export "Output/ROC_Sec_Combined${exportformat}" $exportoptions