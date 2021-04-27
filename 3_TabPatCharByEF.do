***** 3_TabPatCharByEF.do *****
frame reset
use Data/cohort.dta, clear
label define ef_prim_ 1 "EF improved 5% or more" 0 "EF not improved", modify

*** Generate table
addtab_setup, frame(table) columnvar(ef_prim)

* N patients
addtab_no, var(id) rowname("Patients, N")

** Patient characteristics
addtab_header, varname(BOLD) rowname("Patient characteristics")
addtab_estimate, est(mean) par(sd) var(pat_age) rowname("Age in years, mean (SD)")

addtab_header, varname(GROUPHEADER) rowname("Sex, n (%)")
addtab_no if pat_sex==1, colpercent var(pat_sex) rowname("- Male")
addtab_no if pat_sex==0, colpercent var(pat_sex) rowname("- Female")

addtab_header, varname(GROUPHEADER) rowname("Diabetes status, n (%)")
addtab_no if pat_dm==1, colpercent var(pat_sex) rowname("- Diabetics")
addtab_no if pat_dm==0, colpercent var(pat_sex) rowname("- Non-diabetics")

addtab_estimate, est(p50) par(iqr) var(pat_bmi) rowname("BMI in kg/m2, median (IQR)")
addtab_estimate, est(p50) par(iqr) var(pat_meanbs) rowname("P-glucose during HEC in mM, median (IQR)")
addtab_estimate, est(p50) par(iqr) var(pat_meangir) rowname("Glucose infusion rate during HEC in mg/kg/min, median (IQR)")


** Cardiac status
addtab_header, varname(BOLD) rowname("Cardiac status")

addtab_header, varname(GROUPHEADER) rowname("Ejection-fraction on echocardiogram in %, mean (SD)")
addtab_estimate, est(mean) par(sd) var(ef_pre) rowname("- Before intervention")
addtab_estimate, est(mean) par(sd) var(ef_post) rowname("- After intervention")

addtab_header, varname(GROUPHEADER) rowname("Types of intervention, n (%)")
addtab_no if itvtype==3, colpercent var(itvtype) rowname("- PCI without CTO")
addtab_no if itvtype==2, colpercent var(itvtype) rowname("- PCI with CTO")
addtab_no if itvtype==1, colpercent var(itvtype) rowname("- CABG")

addtab_header, varname(GROUPHEADER) rowname("Area of intervention, n (%)")
addtab_no if itv_cat==1, colpercent var(itv_cat) rowname("- LAD")
addtab_no if itv_cat==2, colpercent var(itv_cat) rowname("- LCx")
addtab_no if itv_cat==3, colpercent var(itv_cat) rowname("- RCA")
addtab_no if itv_cat==4, colpercent var(itv_cat) rowname("- Multiple areas")


** PET measurements
addtab_header, varname(BOLD) rowname("PET measurements")

addtab_estimate, est(p50) par(iqr) var(pet_scar) rowname("Scar tissue in %, median (IQR)")

addtab_header, varname(GROUPHEADER) rowname("Hibernating tissue, median (IQR)")
addtab_estimate, est(p50) par(iqr) var(pet_hiber_overall) rowname("- Overall in %")
addtab_estimate, est(p50) par(iqr) var(pet_hiber_aoi) rowname("- Area of intervention in counts *")

addtab_header, varname(GROUPHEADER) rowname("Coronary flow reserve, median (IQR)")
addtab_estimate, est(p50) par(iqr) var(pet_cfr_overall) rowname("- Overall")
addtab_estimate, est(p50) par(iqr) var(pet_cfr_aoi) rowname("- Area of intervention")

addtab_header, varname(GROUPHEADER) rowname("Myocardial glucose uptake during in µmol/min/100g tissue, median (IQR)")
addtab_estimate, est(p50) par(iqr) var(pet_mgu_overall) rowname("- Overall")
addtab_estimate, est(p50) par(iqr) var(pet_mgu_remote) rowname("- Remote area")
addtab_estimate, est(p50) par(iqr) var(pet_mgu_aoi) rowname("- Area of intervention")


frame table: save Output/TabPatCharByEF.dta, replace

/*
frame change table
frame drop table
