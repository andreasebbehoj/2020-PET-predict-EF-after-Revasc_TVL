***** 3_FigSurvByHiber.do *****
frame reset
putdocx clear
putdocx begin

local format = `"base cformat("%4.3f") pformat("%4.3f") sformat("%4.3f")"'
putdocx paragraph, style(Heading1)
putdocx text ("Survival analysis")


*** Prepare data
use Data/cohort_wexcl.dta, clear

gen date_event =date_death if death==1
replace date_event = date_cens if death==0
format %d date_event

qui: su pet_hiber_overall, detail
local label1 = "Below median (0-`r(p50)'%)"
local label2 = "Median or above (`r(p50)'-`r(max)'%)"
recode pet_hiber_overall ///
	(`r(p50)'/max=1 "`label2'") ///
	(0/`r(p50)'=0 "`label1'") ///
	, gen(hiber_simple)

tab hiber_simple itv, mi


*** Survival in ITV group
putdocx paragraph, style(Heading2)
putdocx text ("Intervention group only")

stset date_event if itv==1 ///
	, origin(time date_itv) ///
	failure(death==1) scale(365.25)

* Graph
sts graph, by(hiber_simple) ///
	legend(pos(6) ring(0)) ///
	title("Figure A" "Intervention group") ///
	xtitle("Years after intervention") ///
	tmax(5) ///
	legend(order(1 "`label1'" 2 "`label2'")) ///
	risktable  risktable(, order(1 "`label1'" 2 "`label2'") size(small) title(At risk)) ///
	plot1opts(lcolor(navy) lwidth(0.5)) ///
	plot2opts(lcolor(gs6) lwidth(0.5) lpattern(-)) ///
	name(itv, replace)

graph export "Output/SurvByHiber_ITV${exportformat}" $exportoptions

* Cox
stphplot, by(hiber_simple) name(logminuslog_itv, replace) title(Intervention patients only)
stcox ib0.hiber_simple, `format'
putdocx table tbl1=etable

* Log rank
sts test hiber_simple, logrank


*** Survival in all patients
putdocx paragraph, style(Heading2)
putdocx text ("All patients, including those without intervention")

stset date_event ///
	, origin(time date_scan) ///
	failure(death==1) scale(365.25)

* Graph
sts graph, by(hiber_simple) ///
	legend(pos(6) ring(0)) ///
	title("Figure B" "All patients") ///
	xtitle("Years after PET scan") ///
	tmax(5) ///
	legend(order(1 "`label1'" 2 "`label2'")) ///
	risktable  risktable(, order(1 "`label1'" 2 "`label2'") size(small) title(At risk)) ///
	plot1opts(lcolor(navy) lwidth(0.5)) ///
	plot2opts(lcolor(gs6) lwidth(0.5) lpattern(-)) ///
	name(all, replace)

graph export "Output/SurvByHiber_All${exportformat}" $exportoptions

* Cox
stphplot, by(hiber_simple) name(logminuslog_all, replace) title(All patients)
stcox ib0.hiber_simple, `format'
putdocx table tbl1=etable

* Log rank
sts test hiber_simple, logrank


*** Export results
* KM plots
graph combine itv all, col(1) ysize(21.0cm) xsize(14.8cm)
graph export "Output/SurvByHiber_Comb${exportformat}" $exportoptions

* Log-log plots
graph combine logminuslog_all logminuslog_itv, col(2) ysize(14.8cm) xsize(21.0cm)
graph export "Output/SurvLogMinusLog${exportformat}" $exportoptions
putdocx paragraph, style(Heading2)
putdocx text ("Checking assumptions: Log-minus-log plots")
putdocx paragraph
putdocx image "Output/SurvLogMinusLog${exportformat}"


putdocx save "Output/TextSurv", replace