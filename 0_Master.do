log using "Logs/`c(current_date)'", replace text

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
- Clears memory
- Installs necessary Stata program
- Defines custom programs
- Defines common settings for figures and tables
*/
do 1_Setup.do
do 1_addtab.do
do 1_FigTabLayout.do



***** 2) PREPARE PATIENT DATA
/*
This section:
- Imports patient data from a Stata file 
- Defines cohort and generate study variables 
*/
do 2_CohortAndVars.do



***** 3) ANALYSIS
/*
This section:
- Makes calculations for text
- Exports tables
- Exports graphs
- Generates supplementary results
*/

** Check parametric assumptions
do 3_Assumptions.do


global expvars = "pet_hiber_overall pet_hiber_aoi pet_scar pet_cfr_overall pet_cfr_aoi pet_mgu_overall pet_mgu_remote pet_mgu_aoi"

** Patient characteristics
do 3_TabPatCharByDM.do
do 3_TabPatCharByEF.do
do 3_TabPatCharExcl.do

** Overall AUC and by subgroups
do 3_TabAucByCovars.do

** ROC graphs
do 3_FigROC.do

** Survival analysis
do 3_FigSurvByHiber.do

** AoI and area of hibernation
do 3_TabAoiAndHiber.do

** Miscellaneous
do 3_TextMisc.do


***** 4) REPORT
/*
This section:
- Defines layout of reports
- Combines results into Figures & Tables, Supplementary, Miscellaneous results for text, and analyses not presented in manuscript.
- Adds headers and footnotes to graphs and tables
*/
do 4_Report.do


frame reset
file close _all
window manage close graph _all
capture: log close