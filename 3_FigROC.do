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
	global rocopts = `"title(`title', size(3) alignment(top))"'
	
	** Primary
	qui: roctab ef_prim `expvar' , graph name("Prim_`expvar'", replace) $rocopts
	qui: graph export "Output/Roc/ROC_Prim_`expvar'${exportformat}" $exportoptions
	
	local graphs_prim = "`graphs_prim' Prim_`expvar'"
	
	** Secondary
	qui: roctab ef_sec `expvar' , graph name("Sec_`expvar'", replace) $rocopts
	qui: graph export "Output/Roc/ROC_Sec_`expvar'${exportformat}" $exportoptions
	
	local graphs_sec = "`graphs_sec' Sec_`expvar'"
}

di "`graphs_prim'" _n(2) "`graphs_sec'"

*** Combine primary 
twoway (), name(empty, replace)

foreach outcome in Prim Sec {
	* Row 1-3
	local Graphs_Dynamic	= subinstr("pet_mgu_overall pet_mgu_aoi pet_mgu_remote", "pet_", "`outcome'_pet_", .)
	local Graphs_Static 	= subinstr("pet_hiber_overall pet_hiber_aoi pet_scar", "pet_", "`outcome'_pet_", .)
	local Graphs_Perfusion	= subinstr("pet_cfr_overall pet_cfr_aoi empty", "pet_", "`outcome'_pet_", .)
	
	foreach cat in Dynamic Static Perfusion {
		graph combine `Graphs_`cat'' ///
			, row(1) l1title("`cat'") name(`cat', replace) 
	}
	
	graph combine Dynamic Static Perfusion, col(1) iscale(0.6)
	graph export "Output/ROC_`outcome'_Combined${exportformat}" $exportoptions
}