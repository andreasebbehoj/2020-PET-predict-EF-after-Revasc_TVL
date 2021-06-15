***** 3_TextMisc.do *****
frame reset
putdocx clear
putdocx begin


*** Chi2 for hibernation vs intervention
putdocx paragraph, style(Heading2)
putdocx text ("Test for difference hibernation (some/none) vs intervention (yes/no)")

use Data/cohort_wexcl.dta, clear
recode pet_hiber_overall (0=0 "No hibernation (0%)") (1/max=1 "Some hibernation (1-22%)"), gen(hiber_simple)

* Table
addtab_setup, frame(table) columnvar(itv)
qui: addtab_no if hiber_simple==1, colpercent var(hiber_simple) rowname("Some hibernation (1-22%)")
qui: addtab_no if hiber_simple==0, colpercent var(hiber_simple) rowname("No hibernation (0%)")
frame table: putdocx table tbl=data(rowname col_0 col_1)

* Fishers exact
tab hiber_simple itv, exact
putdocx paragraph
local pval = string(round(`r(p_exact)', 0.01), "%4.2f")
putdocx text (`"Using Fishers exact text to test for a difference in the 2x2 table results in a p-value of `pval'"'), linebreak

* Ranksum
ranksum pet_hiber_overall, by(itv)
local pval = string(round(`r(p_exact)', 0.01), "%4.2f")
putdocx text (`"Using Wilcoxon rank-sum test to test for a difference in hibernation (as a continuous variable) between the two groups results in a p-value of `pval' (same p-value as in the supplementary table)"'), linebreak


*** Export
putdocx save Output/TextMisc, replace