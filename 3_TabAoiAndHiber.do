***** 3_TabAoiAndHiber.do *****
use Data/cohort_wexcl.dta, clear


*** Prepary intervention and hibernating group vars

** Hibernation
su pet_hiberseg_n_*

* Gen indicator vars
foreach var in LAD LCx RCA {
	local lower = lower("`var'")
	recode pet_hiberseg_n_`lower' (1/7=1 "`var'" ) (0=0 " " ), gen(hiberany_`lower') label(hiberany_`lower'_)
}

* Combine to group var
gen hiber_group = 8 		if hiberany_lad==0 & hiberany_lcx==0 & hiberany_rca==0 // None 
recode hiber_group (.=1) 	if hiberany_lad==1 & hiberany_lcx==0 & hiberany_rca==0 // LAD
recode hiber_group (.=2) 	if hiberany_lad==0 & hiberany_lcx==1 & hiberany_rca==0 // LCx
recode hiber_group (.=3) 	if hiberany_lad==0 & hiberany_lcx==0 & hiberany_rca==1 // RCA

recode hiber_group (.=4) 	if hiberany_lad==1 & hiberany_lcx==1 & hiberany_rca==0 // LAD+LCx
recode hiber_group (.=5) 	if hiberany_lad==1 & hiberany_lcx==0 & hiberany_rca==1 // LAD+RCA
recode hiber_group (.=6) 	if hiberany_lad==0 & hiberany_lcx==1 & hiberany_rca==1 // LCx+RCA

recode hiber_group (.=7) 	if hiberany_lad==1 & hiberany_lcx==1 & hiberany_rca==1 // LAD+LCx+RCA

label define hiber_group_ ///
		1 "LAD" ///
		2 "LCx" ///
		3 "RCA" ///
		4 "LAD LCx" ///
		5 "LAD RCA" ///
		6 "LCx RCA" ///
		7 "LAD LCx RCA" ///
		8 "None" ///
		, replace
label value hiber_group hiber_group_		 


** Intervention
su itv_lad itv_lcx itv_rca

* Combine to group var
gen itv_group = 8 		if itv_lad==0 & itv_lcx==0 & itv_rca==0 | itv_n==0 // None 
recode itv_group (.=1) 	if itv_lad==1 & itv_lcx==0 & itv_rca==0 // LAD
recode itv_group (.=2) 	if itv_lad==0 & itv_lcx==1 & itv_rca==0 // LCx
recode itv_group (.=3) 	if itv_lad==0 & itv_lcx==0 & itv_rca==1 // RCA

recode itv_group (.=4) 	if itv_lad==1 & itv_lcx==1 & itv_rca==0 // LAD+LCx
recode itv_group (.=5) 	if itv_lad==1 & itv_lcx==0 & itv_rca==1 // LAD+RCA
recode itv_group (.=6) 	if itv_lad==0 & itv_lcx==1 & itv_rca==1 // LCx+RCA

recode itv_group (.=7) 	if itv_lad==1 & itv_lcx==1 & itv_rca==1 // LAD+LCx+RCA

label define itv_group_ ///
		1 "LAD" ///
		2 "LCx" ///
		3 "RCA" ///
		4 "LAD_LCx" ///
		5 "LAD_RCA" ///
		6 "LCx_RCA" ///
		7 "LAD_LCx_RCA" ///
		8 "None" ///
		, replace
label value itv_group itv_group_		 


*** Gen empty obs for non-observed categories (for contract)
foreach var in hiber_group itv_group {
	forvalues cat = 1/8 {
		qui: count if `var'==`cat'
		if `r(N)'==0 {
		    local label : label (`var') `cat'
			di "`var':" _col(15) "`label' (n=`r(N)')"
			newrow
			recode `var' (.=`cat') if _n==_N
		}
	}
}


*** Contract and reshape
contract itv_group hiber_group, zero freq(_)
drop if mi(hiber_group) | mi(itv_group) // empty obs generated above

decode itv_group, gen(col)
drop itv_group
reshape wide _, i(hiber_group) j(col) string


*** Format to table
gen sort = _n, before(hiber_group)
newrow
recode sort (.=0)
sort sort

* Rowname
decode hiber_group, gen(rowname)
order sort hiber_group rowname

* Column names
ds _*
foreach var in `r(varlist)' {
	* Remove leading _
	local newvar = substr("`var'", 2, .)
	rename `var' `newvar'
	
	* Tostring and colname
	tostring `newvar', replace
	replace `newvar' = subinstr("`newvar'", "_", " ", .) if sort==0
}


order LAD LCx RCA LAD_LCx LAD_RCA LCx_RCA LAD_LCx_RCA, after(rowname)

* Headers
newrow
recode sort (.=-1)
sort sort
replace rowname = "Areas of hibernation" if sort==-1
replace LAD = "Areas of intervention" if sort==-1

* Export
save Output/TabAoiAndHiber.dta, replace