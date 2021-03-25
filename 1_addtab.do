***** 1_addtab.do *****
/* Program for making custom baseline tables with combinations of n (%), median (iqr), mean(sd) etc. Table presents total values and results stratified by columnvar

addtab_setup:
	generate a new frame, stores labels and create necessary variables (varname rowname col_total col_1 col_2 etc)

addtab_header:
	adds new row with a header and no data

addtab_estimate:
	adds new row with mean (SD), median (IQR) or other combinations from "su var, detail" output

addtab_no:	
	adds new row with N nonmissing. 
	N can optionally be combined with an if-statement (for subgroups) and calculate % of total nonmissing in column
*/

*** Setup new table
capture: program drop addtab_setup
program define addtab_setup
syntax, frame(string) columnvar(varname)

** Store values for addtab_ commands 
* Frame name
global addtab_frame = "`frame'"

* Column var, categories and labels
global addtab_columnvar = "`columnvar'" 
qui: levelsof `columnvar'
global addtab_columncats = "total `r(levels)'"

* Column var labels
foreach cat in `r(levels)' {
	global addtab_vallab_`cat' : label (`columnvar') `cat'
	di "Column_`cat': ${addtab_vallab_`cat'}"
}
global addtab_vallab_total = "Total"

** Generate empty frame
capture: frame drop $addtab_frame
frame create $addtab_frame
frame $addtab_frame {
	newrow
	qui: gen varname = ""
	qui: gen rowname = ""
	format %-5s varname rowname
	foreach cat of global addtab_columncats {
		qui: gen col_`cat' = "${addtab_vallab_`cat'}" if _n==1
		label var col_`cat' "${addtab_vallab_`cat'}"
	}
}

end

*** Add header without data
capture: program drop addtab_header
program define addtab_header
syntax, [varname(string) rowname(string)]

* Missing optional options 
if mi("`varname'") {
	local varname = "header"
}

* Add new row 
frame $addtab_frame {
	newrow
	qui: replace varname = "`varname'" if _n==_N
	qui: replace rowname = "`rowname'" if _n==_N
}

end

*** Estimate and SD/IQR by column 
capture: program drop addtab_estimate
program define addtab_estimate
syntax, var(varname) rowname(string) [format(string) ESTimate(string) PARenthesis(string)]

* Missing optional vars
if mi("`format'") {
	local format = `", 0.1), "%4.1f" "'
}

if mi("`estimate'") {
	di as error "estimate() is missing. Must be mean, p50 or any other r() output from:" _n "summarize `var', detail"
	error 
}

* Add new row
frame $addtab_frame {
	newrow
	qui: replace varname = "`var'" if _n==_N
	qui: replace rowname = "`rowname'" if _n==_N
}

* Summarize total/by colum
di _col(25) "`estimate' `parenthesis'"
foreach cat of global addtab_columncats {
	if "`cat'"=="total" {
		qui: su `var', detail
	}
	else {
		qui: su `var' if $addtab_columnvar==`cat', detail
	}
	
	* Estimate
	local result = string(round(`r(`estimate')' `format') 
	
	* Parenthesis
	if !mi("`parenthesis'") {
		* IQR 
		if "`parenthesis'"=="iqr" {
			local result = "`result' (" ///
				+ string(round(`r(p25)' `format') ///
				+ "-" ///
				+ string(round(`r(p75)' `format') ///
				+ ")"
		}
		* Other parenthesis
		else {
			local result = "`result' (" ///
				+ string(round(`r(`parenthesis')' `format') ///
				+ ")"
		}
	}
	
	di _col(3) "${addtab_vallab_`cat'}" _col(25) "`result'" _col(40) "(N=`r(N)')"
	
	qui frame $addtab_frame: replace col_`cat' = "`result'" if _n==_N
}

end

*** N and % 
capture: program drop addtab_no
program define addtab_no
syntax [if], var(varname) rowname(string) [format(string) COLPercent]

* Missing optional vars
if mi("`format'") {
	local format = `", 0.1), "%4.1f" "'
}

* If subgroup
if !mi("`if'") {
	local if2 = "& (" + subinstr("`if'", "if ", "", 1) + ")"
	di "if ... `if2'"
}

* Add new row
frame $addtab_frame {
	newrow
	qui: replace varname = "`var'" if _n==_N
	qui: replace rowname = "`rowname'" if _n==_N
}

* Summarize total/by column
di _col(25) "N `colpercent'"
foreach cat of global addtab_columncats {
	if "`cat'"=="total" {
		* N
		qui: count if !mi(`var') `if2'
		local n = `r(N)'
		* For %
		qui: count if !mi(`var')
		local total = `r(N)'
	}
	else {
		* N
		qui: count if $addtab_columnvar==`cat' `if2'
		local n = `r(N)'
		* For %
		qui: count if !mi(`var') & $addtab_columnvar==`cat'
		local total = `r(N)'
	}
	
	* Estimate
	local result = string(`n') 
	* Parenthesis
	if !mi("`colpercent'") {
		local percent = 100*`n'/`total'
		local result = "`result' (" ///
			+ string(round(`percent' `format') ///
			+ ")"
	}
	
	di _col(3) "${addtab_vallab_`cat'}" _col(25) "`result'" _col(40) "`n'/`total'"
	
	qui frame $addtab_frame: replace col_`cat' = "`result'" if _n==_N
}

end