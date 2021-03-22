***** 2_CohortAndVars.do *****
use "Input/Viabdyn_131patients_TVL 2021-01-14.dta", clear

*** General formatting
* Var names in lower case
qui: ds
foreach var in `r(varlist)' {
	local name = lower("`var'")
	capture: rename `var' `name'
}


*** Define patients vars
* Age
rename alder pat_age
label var pat_age "Age in years"

* Sex
gen pat_sex = 0 if lower(sex)=="kvinde"
replace pat_sex = 1 if lower(sex)=="mand"
label var pat_sex "Sex"
label define pat_sex_ 0 "Women" 1 "Men"
label value pat_sex pat_sex_
drop sex

* BMI
gen pat_bmi = vægt/(højde/100)^2
label var pat_bmi "BMI in kg/m2"
drop højde vægt

* Mean glucose during HEC
rename meanbs pat_meanbs 
label var pat_meanbs "P-glucose during HEC in mM"
drop meanBs bs*

* GIR
rename meangir pat_meangir
label var pat_meangir "Glucose infusion rate during HEC in mg/kg/min"
drop gir* Gir*

* Intervention (groups)
recast int itv*
format %10.0g itv*

egen itv_n = rowtotal(itv_*)
label var itv_n "N areas of intervention"

gen itv_cat = 4 if inrange(itv_n, 2, 3) // multiple
recode itv_cat (.=1) if itv_lad==1
recode itv_cat (.=2) if itv_lcx==1
recode itv_cat (.=3) if itv_rca==1

label define itv_cat_ 1 "LAD" 2 "LCX" 3 "RCA" 4 "Multiple areas"
label value itv_cat itv_cat_
label var itv_cat "Area of intervention"



*** Define cardiac outcomes (outcomes)
rename preekkoef ef_pre
rename postekkoef ef_post

gen ef_diff = ef_post-ef_pre
label var ef_diff "Change in echo-EF pre/post intervention"

recode ef_diff (5/max=1 "Yes") (min/4.99=0 "No"), gen(ef_prim) label(ef_prim_) 
label var ef_prim "EF improved 5% or more after intervention"

recode ef_diff (10/max=1 "Yes") (min/9.99=0 "No"), gen(ef_sec) label(ef_sec_) 
label var ef_sec "EF improved 10% or more after intervention"



*** Define exposures


*** Define other variables


*** Define and restrict to cohort
** Report
putdocx clear
putdocx begin
putdocx paragraph, style(Heading2)
putdocx text ("Patient flow")
putdocx paragraph
putdocx text ("Final cohort was")
putdocx save Output/TextPatientFlow, replace


*** Export data
* Remove irrelevant vars

* Sort and reorder

* Save
save Data/cohort.dta, replace
