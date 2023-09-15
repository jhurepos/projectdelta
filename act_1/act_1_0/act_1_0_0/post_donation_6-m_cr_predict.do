//Fawaz needs a calculator
//Project Prediction of 6-m post-donation Cr and calcluate expected eGFR(2021) based on predicted creatinine

capture log close
clear all
macro drop all
set more off
set linesize 200
timer clear  

local cdat: di %tdCCYYNNDD date(c(current_date),"DMY") 
global cdat: di %tdCCYYNNDD date(c(current_date),"DMY") 
quietly di "`cdat'" 


global FILE = "C:\Users\Fawaz\OneDrive - The University of Colorado Denver\Creator 1\FawazResearch\CODE LKD\living_donor_2023\"

global DATA = "C:\Users\Fawaz\OneDrive - The University of Colorado Denver\Creator 1\FawazResearch\CODE LKD\living_donor_2023\dta"

global FIG "${FILE}\fig\"
global OUT "${FILE}\output\"
global DTA "${FILE}\dta\"

log using "${FILE}\cr_6m_predict_`cdat'.log", replace 

***Study of LKD donor 6-M eGFR prediction*********


use "${DTA}cr6m_predict", clear 

/*
1SCr per 1 mg/dL increase 
2Age per 1 year increase
³BMI per 1 kg/m2 increase
⁴Height per 1 meter increase 
*/

regress dfl_ki_creat ///
	don_ki_creat_preop cr_sp07 cr_sp09 ///
	age age_sp55_10 ///
    male ///
	c.don_ki_creat_preop#male c.cr_sp07#male ///
	nbmi bmi_sp30 ///
	ht_100 ///
	htn  

predict yhat


gen yhat_egfr_21  = 142 * ///
	min((yhat/cond(male, 0.9, 0.7)), 1)^cond(male, -0.302, -0.241)  * ///
	max((yhat/cond(male, 0.9, 0.7)), 1)^(-1.2) * ///	
	0.9938^age * cond(male, 1, 1.012)

	sum don_ki_creat_preop bfd_ckdepi2021 dfl_ki_creat ad_ckdepi2021 yhat yhat_egfr_21

	format %9.2f don_ki_creat_preop yhat dfl_ki_creat
	format %9.0f bfd_ckdepi2021 yhat_egfr_21 ad_ckdepi2021
		format %9.0f nbmi
			format %9.2f ht_100
list age male race_cat nbmi ht_100 htn sbp smoke don_ki_creat_preop bfd_ckdepi2021 yhat yhat_egfr_21 dfl_ki_creat ad_ckdepi2021 in 1/5, table	

log close
