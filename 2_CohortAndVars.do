***** 2_CohortAndVars.do *****
use "Input/Viabdyn_131patients_TVL 2021-01-14.dta", clear


*** Define and restrict to cohort
putdocx clear
putdocx begin
putdocx paragraph, style(Heading2)
putdocx text ("Patient flow")
putdocx paragraph

count
putdocx text ("`r(N)' patients in Viabdyn dataset")

drop if itv==0
putdocx text ("`r(N_drop)' excluded as they did not undergo an intervention")
drop itv 

drop if mi(preEKKOEF) | mi(postEKKOEF)
putdocx text ("`r(N_drop)' excluded as pre or post echo-EF was missing")

count
putdocx text ("Final cohort was `r(N)' patients")

putdocx save Output/TextPatientFlow, replace



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



*** Define PET measures (exposures)
** Scar tissue 
rename arvæv pet_scar
label var pet_scar "Scar tissue in %"

** Hibernating tissue
describe *hiber*
* Overall (in %)
rename hibernation pet_hiber_overall
label var pet_hiber_overall "Hibernating tissue in %;Overall"

* By area (in counts)
rename tpdhibernationantalsegmenter hibersegment

* In AoI (in counts)

drop hibersegment


** Coronary flow reserve
describe *cfr*
* Overall
rename cfrtotal pet_cfr_overall
label var pet_cfr_overall "Coronary flow reserve;Overall"

* AoI


** Myocardial glucose uptake
describe *mgu*
* Overall
rename mgupatlakave pet_mgu_overall 
label var pet_mgu_overall "Myocardial glucose uptake durnig HEC in µmol/min/100g tissue;Overall"

* Remote area
rename mgupatlak pet_mgu_remote 
label var pet_mgu_remote "Myocardial glucose uptake durnig HEC in µmol/min/100g tissue;Remote area"

* AoI


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
