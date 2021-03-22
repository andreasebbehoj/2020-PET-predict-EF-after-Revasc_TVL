***** 2_CohortAndVars.do *****
use Input/.dta, clear


*** Define outcomes


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
