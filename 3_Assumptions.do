***** 3_Assumptions.do *****
use Data/Cohort, clear
*** Check parametric non-parametric
capture: mkdir Output/Qnorm

* By DM status for TabPatByCharDM
foreach var in pat_age pat_bmi pat_meanbs pat_meangir ef_pre ef_post pet_cfr_aoi pet_cfr_overall pet_hiber_aoi pet_hiber_overall pet_mgu_aoi pet_mgu_overall pet_mgu_remote pet_scar {
	qnorm `var' if pat_dm==0, title("Non-DM") name(q1, replace)
	qnorm `var' if pat_dm==1, title("DM") name(q2, replace)
	graph combine q1 q2, title("`var' by DM") name("`var'", replace)
	graph export Output/Qnorm/ByDM_`var'.png, replace width(1080) height(540)
}

* By EF improvement for TabPatByCharDM
foreach var in pat_age pat_bmi pat_meanbs pat_meangir ef_pre ef_post pet_cfr_aoi pet_cfr_overall pet_hiber_aoi pet_hiber_overall pet_mgu_aoi pet_mgu_overall pet_mgu_remote pet_scar {
	qnorm `var' if ef_prim==0, title("Not improved") name(q1, replace)
	qnorm `var' if ef_prim==1, title("Improved") name(q2, replace)
	graph combine q1 q2, title("`var' by EF") name("`var'", replace)
	graph export Output/Qnorm/ByEF_`var'.png, replace width(1080) height(540)
}

* By ITV vs non-ITV
use Data/Cohort_wexcl, clear
foreach var in pat_age pat_bmi pat_meanbs pat_meangir ef_pre pet_cfr_overall pet_hiber_overall pet_mgu_overall pet_mgu_remote pet_scar {
	qnorm `var' if itv==0, title("No intervention") name(q1, replace)
	qnorm `var' if itv==1, title("Intervention") name(q2, replace)
	graph combine q1 q2, title("`var' by ITV") name("`var'", replace)
	graph export Output/Qnorm/ByITV_`var'.png, replace width(1080) height(540)
}