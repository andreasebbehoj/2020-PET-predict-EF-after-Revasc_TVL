***** 2_CohortAndVars.do *****
use "Input/Viabdyn_131patients_TVL 2021-04-05.dta", clear



*** General formatting
* Var names in lower case
qui: ds
foreach var in `r(varlist)' {
	local name = lower("`var'")
	capture: rename `var' `name'
}
format %d dato skanningsdato datodød censurdato

rename preekkoef ef_pre
rename postekkoef ef_post

*** Correct errors
* Date problem due to Excel conversion
gen diff = skanningsdato - dato // should have been the same date (diff=0)
su diff // diff=21916
replace skanningsdato=skanningsdato-21916
replace censurdato=censurdato-21916
replace datodød=datodød-21916

rename skanningsdato date_scan
rename censurdato date_cens
rename datodød date_death
rename failure death
drop diff failuredate entrydate exitdate hændelse1 hændelse2 indlæggelse1 indlæggelse2 outcomedød

*** Exclude special cases
gen excl = 1 if inlist(id, 106) // One patient with failed intervention
recode excl (.=2) if inlist(id, 60) // One patient with intervention before PET

label define excl_ 1 "Intervention failed" 2 "Intervention was done before PET scan"
label value excl excl_

* Remove information on excluded
foreach var in lad lcx rca {
    replace itv_`var'=. if !mi(excl) 
}
replace ef_post = . if !mi(excl)


*** Dates in string
* Date of intervention
order behdato
gen datepos = strpos(behdato, "/") if itv==1, after(behdato)
gen datestring = substr(behdato, datepos-2, 10) if datepos==3, after(behdato) // DD/MM/YYYY
replace datestring = subinstr(substr(behdato, 1, 10), ".", "/", 2) if datepos==0 // DD.MM.YYYY
replace datestring = "0" + substr(behdato, 1, 2) + "0" + substr(behdato, 3, 6) if datepos==2 // D/M/YYYY
gen date_itv = date(datestring, "DMY"), after(behdato)
format %d date_itv 
drop datestring datepos

*** Define patients vars
* Intervention (inclu or excluded)
label var itv "Intervention"
label define itv_ 0 "No intervention" 1 "Intervention"
label value itv itv_

* Age
rename alder pat_age
label var pat_age "Age in years"

qui: su pat_age, detail
gen pat_age_median = pat_age>=`r(p50)'
label var pat_age_median "Age" 
label define pat_age_median_ 0 "Below median age" 1 "Median age or above"
label value pat_age_median pat_age_median_

* Sex
gen pat_sex = 0 if lower(sex)=="kvinde"
replace pat_sex = 1 if lower(sex)=="mand"
label var pat_sex "Sex"
label define pat_sex_ 0 "Women" 1 "Men"
label value pat_sex pat_sex_
drop sex

* BMI
replace højde = 172 if højde==72 // One patient with wrong height 
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

* Area of intervention
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

* Types of intervention
foreach pro in cabg cto pci {
    gen itvtype_`pro' = 1 if strpos(lower(behdato), "`pro'") & itv==1
}

gen itvtype = 1 if itvtype_cabg==1 
recode itvtype (.=2) if itvtype_cto==1
recode itvtype (.=3) if itvtype_pci==1
label var itvtype "Type of intervention"
label define itvtype_ 1 "CABG" 2 "PCI with CTO" 3 "PCI without CTO"
label value itvtype itvtype_
drop itvtype_*

* Diabetes
gen pat_dm = 1 if diabetes=="Diabetes"
recode pat_dm (.=0) if diabetes=="Non-diabetic"
label define pat_dm_ 0 "No diabetes" 1 "Diabetes"
label value pat_dm pat_dm_
label var pat_dm "Diabetes status"
drop diabetes*



*** Define cardiac outcomes (outcomes)
gen ef_diff = ef_post-ef_pre
label var ef_diff "Change in echo-EF pre/post intervention"

recode ef_diff (5/max=1 "Yes") (min/4.99=0 "No"), gen(ef_prim) label(ef_prim_) 
label var ef_prim "EF improved 5% or more after intervention"

recode ef_diff (10/max=1 "Yes") (min/9.99=0 "No"), gen(ef_sec) label(ef_sec_) 
label var ef_sec "EF improved 10% or more after intervention"

* Pre intervention EF as covar
qui: su ef_pre, detail
gen ef_pre_median = ef_pre>=`r(p50)' if !mi(ef_pre)
label var ef_pre_median "Pre-intervention EF"
label define ef_pre_median_ 0 "Below median EF" 1 "Median EF or above"
label value ef_pre_median ef_pre_median_



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
rename tpdhibernationantalsegmenter pet_hibersegments
replace pet_hibersegments = itrim(trim(pet_hibersegments))
foreach area in LAD LCx RCA {
  	local varname = lower("`area'")
	gen pet_hiberseg_n_`varname' = real(substr(pet_hibersegments, strpos(pet_hibersegments, "`area'")+4, 1))
}

* In AoI (in % counts of maximum, averaged across AoIs)
gen hiberitv_lad = pet_hiberseg_n_lad if itv_lad==1
gen hiberitv_lcx = pet_hiberseg_n_lcx if itv_lcx==1
gen hiberitv_rca = pet_hiberseg_n_rca if itv_rca==1

egen sum = rowtotal(hiberitv_*), missing
gen pet_hiber_aoi = sum/itv_n
label var pet_hiber_aoi "Hibernating tissue in n;Area of intervention *"
drop sum pet_hibersegments hiberitv_*


** Coronary flow reserve (stress-flow/rest-flow, has no unit)
describe *cfr* // 8 patients wo. CFR, since they could not tolerate adenosis-induced stress-flow
* Overall
rename cfrtotal pet_cfr_overall
label var pet_cfr_overall "Coronary flow reserve;Overall"

* AoI
foreach area in lad lcx rca {
	gen cfritv_`area' = cfr`area' if itv_`area'==1
}
egen sum = rowtotal(cfritv_*), missing
gen pet_cfr_aoi = sum/itv_n
label var pet_cfr_aoi "Coronary flow reserve;Area of intervention #"
drop sum cfritv_*


** Myocardial glucose uptake
describe *mgu*
* Overall
rename mgupatlakave pet_mgu_overall 
label var pet_mgu_overall "MGU during HEC in µmol/min/100g tissue;Overall"

* Remote area
rename mgupatlak pet_mgu_remote 
label var pet_mgu_remote "MGU during HEC in µmol/min/100g tissue;Remote area"

* AoI
foreach area in lad lcx rca {
	gen mguitv_`area' = mgupatlak`area' if itv_`area'==1
}
egen sum = rowtotal(mguitv_*), missing
gen pet_mgu_aoi = sum/itv_n
label var pet_mgu_aoi "MGU during HEC in µmol/min/100g tissue;Area of intervention §"
drop sum mguitv_*



*** Export full data
* Remove irrelevant vars
drop navn cpr nodash dato 

* Sort and reorder
sort id
order _all, alpha
order id excl pat_* ef_* itv* pet_* date_* death

* Save
save Data/cohort_wexcl.dta, replace


*** Export cohort data
drop alderkat-Årsag2

* Patient flow
putdocx clear
putdocx begin
putdocx paragraph, style(Heading2)
putdocx text ("Patient flow")
putdocx paragraph

count
putdocx text ("`r(N)' patients in Viabdyn dataset"), linebreak

drop if itv==0 & mi(excl)
putdocx text ("`r(N_drop)' excluded as they did not undergo an intervention"), linebreak
drop itv 

count if !mi(excl)
putdocx text ("`r(N)' who underwent an intervention were excluded due to:"), linebreak
qui: levelsof excl
foreach grp in `r(levels)' {
    local label : label (excl) `grp'
	di "`label'"
	drop if excl==`grp'
	putdocx text ("- `r(N_drop)' `label'"), linebreak
}
drop excl 
count
putdocx text ("Final cohort was `r(N)' patients")

putdocx save Output/TextPatientFlow, replace

* Save
save Data/cohort.dta, replace