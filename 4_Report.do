***** 4_Report.do *****
/*
First part defines layout for headings, figures, tables and footnotes
Second part export results to report
*/
frame reset
clear
putdocx clear
file close _all



*** Define standard layout
** Heading1
capture: program drop text_heading1
program define text_heading1
syntax, text(string) [sectionbreak *]

if !mi("`sectionbreak'") {
	putdocx sectionbreak, $pagelayout `options'
}

putdocx paragraph, style(Heading1) font("Times new roman", 15, black)
putdocx text (`"`text'"')
end

** Heading2
capture: program drop text_heading2
program define text_heading2
syntax, text(string) [sectionbreak *]

if !mi("`sectionbreak'") {
	putdocx sectionbreak, $pagelayout `options'
}

putdocx paragraph, style(Heading2) font("Times new roman", 13, black)
putdocx text (`"`text'"')
end

** Figure
capture: program drop text_fig
program define text_fig
syntax, image(string) [*]

putdocx paragraph, halign(center)
putdocx image `image', `options'
end

** Table 
capture: program drop text_table
program define text_table
syntax, file(string) vars(string) header(numlist) [subheader(string) left(numlist) right(numlist)]

capture: frame drop table
frame create table
frame table {
	use "`file'", clear
	gen n=_n
	* General settings
	putdocx table tbl1 = data("`vars'"), width(100%) layout(autofitcontents) 
	putdocx table tbl1(., .), border(all, nil) halign(center) valign(center) font("Times new roman", 10, black)
	* Header
	putdocx table tbl1(`header', .), bold shading(191 191 191) // Header gray and bold
	* Alignment
	if !mi("`left'") {
		putdocx table tbl1(., `left'), halign(left)
	}
	if !mi("`right'") {
		putdocx table tbl1(., `right'), halign(right)
	}
	* Subheaders
	if !mi("`subheader'") {
		levelsof n `subheader'
		putdocx table tbl1(`r(levels)', .), shading(217 217 217) // Subheader light gray
	}
	* Lines
	qui: su n
	putdocx table tbl1(`r(max)', .), border(bottom, single, black, 1)
}
end

** Footnote
capture: program drop text_footnote
program define text_footnote
syntax, [notes(string) linebreak ABBREViations(string)]

putdocx paragraph, font("Times new roman", 10, black)

if !mi(`"`abbreviations'"') {
	putdocx text ("Abbreviations:"), bold
	putdocx text (`" `abbreviations'"'), `linebreak'
}
if !mi(`"`notes'"') {
	putdocx text ("Notes:"), bold
	putdocx text (`" `notes'"')
}
end



*** Export report
** Setup document
global pagelayout = `"pagenum(decimal)"' /// 
	+ `" footer(pfooter)"' ///
	+ `" pagesize(A4)"' ///
	+ `" margin(left, 1 in)"' ///
	+ `" margin(right, 1 in)"' //

putdocx begin, $pagelayout
	
putdocx paragraph, tofooter(pfooter)
putdocx text ("Page ")
putdocx pagenumber, bold
putdocx text (" of ")
putdocx pagenumber, totalpages bold


** Figures
text_heading1, text("Figures") 

* Fig 1
text_heading2, text("Figure 1 - ROC for predicting EF-improvement of 5% or above")
text_fig, image(Output/ROC_Prim_Combined.png) width(7.5 in)
text_footnote, ///
	abbrev("EF, ejection-fraction; HEC, hyperinsulinemic euglycemic clamp; MGU, myocardial glucose uptake; ROC, receiver operator curve. ") ///
	linebreak ///
	notes("* Hibernating tissue in area of intervention is total number of areas with at least 10% hibernating tissue. Maximum is 17 (7 for LAD, 5 for LCx and 5 for RCA). " ///
	"# Coronary flow reserve in area of intervention is average CFR across the area(s) of intervention") 

* Fig 2
text_heading2, text("Figure 2 - ROC for predicting EF-improvement of 10% or above") sectionbreak
text_fig, image(Output/ROC_Sec_Combined.png) width(7.5 in)
text_footnote, ///
	abbrev("EF, ejection-fraction; HEC, hyperinsulinemic euglycemic clamp; MGU, myocardial glucose uptake; ROC, receiver operator curve. ") ///
	linebreak ///
	notes("* Hibernating tissue in area of intervention is total number of areas with at least 10% hibernating tissue. Maximum is 17 (7 for LAD, 5 for LCx and 5 for RCA). " ///
	"# Coronary flow reserve in area of intervention is average CFR across the area(s) of intervention") 


** Tables
text_heading1, text("Tables") sectionbreak

* Tab 1
text_heading2, text("Table 1 - Patient characteristics, PET measurements, and cardiac status by diabetes status")
text_table, file("Output/TabPatCharByDM.dta") vars(rowname col_total col_0 col_1) ///
	header(1) left(1) ///
	subheader(`"if varname=="BOLD""')
text_footnote, notes("Some explanation. ") ///
	linebreak ///
	abbrev("SD, standard deviation; PCI, percutaneous coronary intervention; CABG, coronary artery bypass grafting; CTO, chronic total occlusion; HEC, hyperinsulinemic euglycemic clamp")

* Tab 3
text_heading2, text("Table 3 - AUC (95% CI) of PET Measurements by Patient Characteristics") sectionbreak landscape
text_table, file("Output/TabAucByCovars.dta") vars(rowname $expvars) ///
	header(1) left(1) ///
	subheader(`"if varname=="BOLD""')
text_footnote, notes("ROC AUC for PET measurement predicting a 5% EF improvement after intervention. ") ///
	linebreak ///
	abbrev("HEC, hyperinsulinemic euglycemic clamp; MGU, myocardial glucose uptake") 


** Supplementary
text_heading1, text("Supplementary") sectionbreak

* Sup 1
text_heading2, text("Supplementary 1 - Patient characteristics, PET measurements, and cardiac status by EF improvement after intervention")
text_table, file("Output/TabPatCharByEF.dta") vars(rowname col_total col_0 col_1) ///
	header(1) left(1) ///
	subheader(`"if varname=="BOLD""')
text_footnote, notes("Some explanation. ") ///
	linebreak ///
	abbrev("SD, standard deviation; PCI, percutaneous coronary intervention; CABG, coronary artery bypass grafting; CTO, chronic total occlusion; HEC, hyperinsulinemic euglycemic clamp")


** Save
putdocx save "Output/FigTabCombined", replace