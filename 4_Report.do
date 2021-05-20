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

** Define abbreviations
frame create abbrev 
frame abbrev {
    input str15 abbrev str80 meaning
	"Abbreviations" "Meaning"
	"AUC"	"area under the curve"
	"CABG"	"coronary artery bypass grafting"
	"CTO" 	"chronic total occlusion"
	"EF"	"ejection fraction"
	"FDG_PET/CT"	"18F-fluorodeoxyglucose positron emission tomography/computed tomography"
	"HEC" 	"hyperinsulinemic euglycemic clamp"
	"IQR"	"inter-quartile range (25th to 75th percentile)"
	"LAD"	"left anterior descendent artery"
	"LCx"	"left circumflex artery"
	"MGU"	"myocardial glucose uptake"
	"PCI"	"percutaneous coronary intervention"
	"RCA"	"right coronary artery"
	"ROC"	"receiver operator curve"
	"SD"	"standard deviation"
	end
	save Output/Abbreviations.dta, replace
	gen n=_n
}

** Footnote
capture: program drop text_footnote
program define text_footnote
syntax, [notes(string) linebreak ABBREViations(string)]

putdocx paragraph, font("Times new roman", 10, black)

if !mi(`"`abbreviations'"') {
	local abbrevtext = ""
	
	* Lookup abbrev
	foreach abbrev in `abbreviations' {
	    frame abbrev {
		    qui: su n if abbrev=="`abbrev'"
			if `r(N)'==0 { // Unknown abbrev
			    di as error "`abbrev' is an unknown abbreviations"
				error 1
			}
			else {
			    local meaning = meaning[`r(min)']
			}	
		}
		local abbrev2 = subinstr("`abbrev'", "_", " ", .)
		local abbrevtext = "`abbrevtext'`abbrev2', `meaning'; "
	}
	
	* Remove last ; and add .
	local abbrevtext = substr("`abbrevtext'", 1, length("`abbrevtext'")-2) + ". "
	di "`abbrevtext'"
	* Add to footnote
	putdocx text ("Abbreviations:"), bold
	putdocx text (`" `abbrevtext'"'), `linebreak'
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
	abbrev("EF HEC MGU ROC") ///
	linebreak ///
	notes("* Hibernating tissue in area of intervention is total number of subareas with at least 10% hibernating tissue divided by area(s) of intervention. LAD has 7 subareas, LCx has 5, and RCA has 5. " ///
	"# Coronary flow reserve in area of intervention is average CFR across the area(s) of intervention. " ///
	"§ Myocardial glucose uptake during hyperinsulinemic euglycemic clamp in area of intervention is average MGU across area(s) of intervention") 

* Fig 2
text_heading2, text("Figure 2 - ROC for predicting EF-improvement of 10% or above") sectionbreak
text_fig, image(Output/ROC_Sec_Combined.png) width(7.5 in)
text_footnote, ///
	abbrev("EF HEC MGU ROC") ///
	linebreak ///
	notes("* Hibernating tissue in area of intervention is total number of subareas with at least 10% hibernating tissue divided by area(s) of intervention. LAD has 7 subareas, LCx has 5, and RCA has 5. " ///
	"# Coronary flow reserve in area of intervention is average CFR across the area(s) of intervention. " ///
	"§ Myocardial glucose uptake during hyperinsulinemic euglycemic clamp in area of intervention is average MGU across area(s) of intervention") 



** Tables
text_heading1, text("Tables") sectionbreak

* Tab 1
text_heading2, text("Table 1 - Patient characteristics by EF improvement after intervention")
text_table, file("Output/TabPatCharByEF.dta") vars(rowname col_total col_0 col_1) ///
	header(1) left(1) ///
	subheader(`"if varname=="BOLD""')
text_footnote, notes("Some explanation. ") ///
	linebreak ///
	abbrev("CABG CTO HEC IQR LAD LCx PCI RCA SD")

* Tab 2
text_heading2, text("Table 2 - AUC (95%CI) of PET measures stratified by patient characteristics") sectionbreak landscape
text_table, file("Output/TabAucByCovars.dta") vars(rowname no $expvars) ///
	header(1) left(1) ///
	subheader(`"if varname=="BOLD""')
text_footnote, notes("ROC AUC for PET measurement predicting a 5% EF improvement after intervention. ") ///
	linebreak ///
	abbrev("AUC EF HEC LAD LCx MGU RCA") 


** Supplementary
text_heading1, text("Supplementary") sectionbreak

* Sup 1
text_heading2, text("Supplementary 1 - Patient flow chart") 
text_fig, image(Input/FlowFig.png) height(5)
text_footnote, abbrev("FDG_PET/CT") 

* Sup 2
text_heading2, text("Supplementary 2 - Patient characteristics for included patients who underwent cardiac intervention and excluded patients who did not") sectionbreak
text_table, file("Output/TabPatCharExcl.dta") vars(rowname col_1 col_0) ///
	header(1) left(1) ///
	subheader(`"if varname=="BOLD""')
text_footnote, abbrev("CABG CTO HEC IQR LAD LCx PCI RCA SD")

* Sup 3
text_heading2, text("Supplementary 3 - Areas of intervention compared to areas of hibernation") sectionbreak
text_table, file("Output/TabAoiAndHiber.dta") vars(rowname LAD-None) ///
	header(1 2) left(1) //
putdocx table tbl1(1, 2), colspan(9)
text_footnote, notes("Table includes both patients who underwent an intervention and those who did not (i.e. intervention 'None'). ") ///
	linebreak ///
	abbrev("LAD LCx RCA")

* Sup 4
text_heading2, text("Supplementary 4 - Patient characteristics by diabetes status") sectionbreak
text_table, file("Output/TabPatCharByDM.dta") vars(rowname col_total col_0 col_1) ///
	header(1) left(1) ///
	subheader(`"if varname=="BOLD""')
text_footnote, notes("Some explanation. ") ///
	linebreak ///
	abbrev("CABG CTO HEC IQR LAD LCx PCI RCA SD")
/* Confirm with TVL/ES/LG: order of tables and supplementary?*/


** Abbreviations
text_heading1, text("Abbreviations") sectionbreak
text_table, file("Output/Abbreviations.dta") vars(abbrev meaning) header(1) left(1 2)

** Save
putdocx save "Output/FigTabCombined", replace