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


** Abbreviations
text_heading1, text("Abbreviations") 
text_table, file("Output/Abbreviations.dta") vars(abbrev meaning) header(1) left(1 2)


** Figures
text_heading1, text("Figures") sectionbreak

* Fig 1
text_heading2, text("Figure 1 - Patient flow chart") 
text_fig, image(Input/FlowFig.png) height(5)
text_footnote, abbrev("FDG_PET/CT") 

* Fig 2
text_heading2, text("Figure 2 - Example of a dynamic cardiac PET scan") 
text_fig, image(Input/placeholder.png) height(5)
text_footnote, notes("Insert footnotes.")

* Fig 3
text_heading2, text("Figure 3 - ROC for predicting EF-improvement of 5% or above")
text_fig, image(Output/ROC_Prim_Combined.png) width(7.5 in)
text_footnote, ///
	abbrev("EF HEC MGU ROC") ///
	linebreak ///
	notes("* Hibernating tissue in area of intervention is total number of subareas with at least 10% hibernating tissue divided by area(s) of intervention. LAD has 7 subareas, LCx has 5, and RCA has 5. " ///
	"# Coronary flow reserve in area of intervention is average CFR across the area(s) of intervention. " ///
	"§ Myocardial glucose uptake during hyperinsulinemic euglycemic clamp in area of intervention is average MGU across area(s) of intervention") 

* Fig 4
text_heading2, text("Figure 4 - Hibernating tissue and survival") 
text_fig, image(Output/SurvByHiber_Comb.png)
text_footnote, notes("Kaplan-Meier curves showing survival by the presence or absence of hibernating tissue in patients who underwent intervention (left) or all patients including those who did not undergo intervention (right). Follow-up started at date of intervention in the left figure and date of PET scan in the right figure. Number of patients at risk are shown below each figure. ")


** Tables
text_heading1, text("Tables") sectionbreak

* Tab 1
text_heading2, text("Table 1 - Baseline characteristics for patients undergoing intervention")
text_table, file("Output/TabPatCharByEF.dta") vars(rowname col_total) ///
	header(1) left(1) ///
	subheader(`"if varname=="BOLD""')
text_footnote, ///
	linebreak ///
	abbrev("CABG CTO HEC IQR LAD LCx PCI RCA SD")

* Tab 2
text_heading2, text("Table 2 - Characteristics for patients with and without EF-improvement after intervention") sectionbreak
text_table, file("Output/TabPatCharByEF.dta") vars(rowname col_0 col_1 col_pval) ///
	header(1) left(1) ///
	subheader(`"if varname=="BOLD""')
text_footnote, ///
	notes("P-values for differences were calculated using Fischer's exact test (sex, diabetes, type of intervention, and area of intervention), Student's t-test (age and ejection-fraction), and Wilcoxon rank-sum test (remaining variables).")
	linebreak ///
	abbrev("CABG CTO HEC IQR LAD LCx PCI RCA SD")
	

** Save
putdocx save "Output/FigTabCombined", replace



*** Export supplementary
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

text_heading1, text("Supplementary")


* Sup 1
text_heading2, text("Supplementary 1 - Patient characteristics for included patients who underwent cardiac intervention and excluded patients who did not")
text_table, file("Output/TabPatCharExcl.dta") vars(rowname col_1 col_0 col_pval) ///
	header(1) left(1) ///
	subheader(`"if varname=="BOLD""')
text_footnote, abbrev("CABG CTO HEC IQR LAD LCx PCI RCA SD")

* Sup 2
text_heading2, text("Supplementary 2 - Areas of intervention compared to areas of hibernation") sectionbreak
text_table, file("Output/TabAoiAndHiber.dta") vars(rowname LAD-None) ///
	header(1 2) left(1) //
putdocx table tbl1(1, 2), colspan(9)
text_footnote, notes("Table includes both patients who underwent an intervention and those who did not (i.e. intervention 'None'). Dark grey indicate complete agreement between hibernating areas on PET scan and areas of intervention, light grey indicate partial agreement, and white indicate no agreement. ") ///
	linebreak ///
	abbrev("LAD LCx RCA")

** Save
putdocx save "Output/Supplementary", replace


*** Export miscellaneous calculations
local filelist : dir "Output" files "Text*"
local filesdir = ""
foreach file of local filelist {
	local filesdir = "`filesdir' Output/`file'"
}
di "`filesdir'"
putdocx append `filesdir', saving(Output/MiscellaneousCombined.docx, replace)