//log using "Logs/`c(current_date)'", replace text

***** 0_Master.do *****
/*

The do-file is split in four sections:
1) Stata setup
2) Import patient data and define study variables
3) Analysis
4) Combine report
*/



***** 1) STATA SETUP
/*
This section:
- Clear memory
- Install necessary Stata program
- Define custom programs
- Defines common settings for figures and tables
*/
do 1_Setup.do
do 1_addtab.do
do 1_FigTabLayout.do



***** 2) PREPARE PATIENT DATA
/*
This section:
- Import patient data from a Stata file 
- Define cohort and generate study variables 
*/
do 2_CohortAndVars.do



***** 3) ANALYSIS
/*
This section:
- Makes calculations for text
- Export tables
- Export graphs
- Generate supplementary results
*/

/** Check model assumptions
do 3_Assumptions.do
*/

global expvars = "pet_hiber_overall pet_hiber_aoi pet_scar pet_cfr_overall pet_cfr_aoi pet_mgu_overall pet_mgu_remote pet_mgu_aoi"

** Patient characteristics
do 3_TabPatCharByDM.do
do 3_TabPatCharByEF.do

** Overall performance


** AUC by subgroups

do 3_TabAucByCovars.do

** ROC graphs
do 3_FigROC.do



***** 4) REPORT
/*
This section:
- Add headers and footnotes to graphs and tables
- Combine all documents into FigTablesCombined and ReportCombined
*/
do 4_Report.do


frame reset
file close _all
window manage close graph _all
capture: log close