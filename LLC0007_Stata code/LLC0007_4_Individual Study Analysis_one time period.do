
********************************************************************************
**ANALYSIS OF EACH STUDY 
********************************************************************************
cd "S:\LLC_0007\data\"


*********************************
***ANALYSIS OF ELSA study_id==1
*********************************


**Open and merge testig data`' with elsa file
use "ELSA edited\elsa_longform.dta", clear
sort llc_0007_stud_id study_wave

tab study_wave_date study_wave, nol

merge 1:1 llc_0007_stud_id study_wave using "ELSA edited\protect_nhs_c19posinfect_temp_elsaver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/08/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/01/2021", "DMY") & study_wave==2

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/08/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/01/2021", "DMY") & study_wave==2

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/08/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/01/2021", "DMY") & study_wave==2

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/08/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/01/2021", "DMY") & study_wave==2


tab vacc_status

**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

label define furlough 0 "No" 1 "Yes", replace
label values furlough furlough


**drop if age
rename age_entry age
egen age_entry=cut(age) if age>30, at(1,18,34,44,54,64,74,120) icodes
tab age_entry 
replace age_entry=age if age<10
label define age_entry 1 "18-34" 2 "35-44" 3 "45-54" 4 "55-64" 5 "65-74" 6 "75+", replace
label values age_entry age_entry
tab age_entry

drop if age_entry>=5

** ELSA - descriptive statistics
quietly tab llc_0007_stud_id
return list
local sample_n =  r(r)
local entry_n =  r(N)


**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==1 & time_tranche==1
replace entry_n=`entry_n' if study_id==1 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==1 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==1 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==1 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace

restore


**tab self-reported infect by self-reported pos test
tab c19infection_selfreported c19postest_selfreported, missing

**tab self-reported infection by test positive
tab c19positive	c19infection_selfreported, missing

**tab self-reported post test by test positive
tab c19positive	c19postest_selfreported, missing


**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	
**tab NHS digital indicated infection
tab study_wave c19positive, missing	

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing	
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing	


	
***Occupational Characteristics
numlabel, add
foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
tab soc_1d `var', missing row
tab soc_2d `var', missing row

**SCI 2003 	
tab sic_1d `var', missing row
tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
tab deprivation_imd  `var', missing row
tabstat age_entry, by(`var') stat(N mean sd min max)
tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}

**lastminute formating
replace employment=3 if employment_status==4


***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult
preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==1 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==1 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==1 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==1 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**SCI 2003 	
mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19infection_selfreported i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_eff=`beta' if study_id==1 & time_tranche==1
replace sr_re_se=`se' if study_id==1 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==1 & time_tranche==1
replace sr_un_se=`se2' if study_id==1 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_eff=`beta' if study_id==1 & time_tranche==1
replace sr_pt_se=`se' if study_id==1 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==1 & time_tranche==1
replace sr_ret_se=`se2' if study_id==1 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==1 & time_tranche==1
replace sr_nw_se=`se3' if study_id==1 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==1 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==1 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==1 & time_tranche==1
replace sr_une_se=`se4' if study_id==1 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==1 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==1 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_eff=`beta' if study_id==1 & time_tranche==1
replace sr_kw_se=`se' if study_id==1 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Home working	
mepoisson c19infection_selfreported i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_eff=`beta2' if study_id==1 & time_tranche==1
replace sr_sm_se=`se2' if study_id==1 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==1 & time_tranche==1
replace sr_no_se=`se3' if study_id==1 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==1 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==1 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_eff=`beta' if study_id==1 & time_tranche==1
replace sr_fr_se=`se' if study_id==1 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1
*replace sr_fr_eff=exp(`beta') if study_id==1 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==1 & time_tranche==1
replace lr_s101d`i'_se=_se[`i'.soc_1d] if study_id==1 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==1 & time_tranche==1
replace lr_s102d`i'_se=_se[`i'.soc_2d] if study_id==1 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19positive i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_eff=`beta' if study_id==1 & time_tranche==1
replace lr_re_se=`se' if study_id==1 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==1 & time_tranche==1
replace lr_un_se=`se2' if study_id==1 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_eff=`beta' if study_id==1 & time_tranche==1
replace lr_pt_se=`se' if study_id==1 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==1 & time_tranche==1
replace lr_ret_se=`se2' if study_id==1 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==1 & time_tranche==1
replace lr_nw_se=`se3' if study_id==1 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==1 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==1 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==1 & time_tranche==1
replace lr_une_se=`se4' if study_id==1 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==1 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==1 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 





**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_eff=`beta' if study_id==1 & time_tranche==1
replace lr_kw_se=`se' if study_id==1 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1
*replace lr_kw_eff=exp(`beta') if study_id==1 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Home working	
mepoisson c19positive i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_eff=`beta2' if study_id==1 & time_tranche==1
replace lr_sm_se=`se2' if study_id==1 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==1 & time_tranche==1
replace lr_no_se=`se3' if study_id==1 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==1 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==1 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_eff=`beta' if study_id==1 & time_tranche==1
replace lr_fr_se=`se' if study_id==1 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1
*replace lr_fr_eff=exp(`beta') if study_id==1 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



****Repeated Adjusted for key confounders
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==1 & time_tranche==1
replace sr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==1 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==1 & time_tranche==1
replace sr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==1 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
mepoisson c19infection_selfreported i.sic_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
mepoisson c19infection_selfreported i.sic_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19infection_selfreported i.employment i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_adj_eff=`beta' if study_id==1 & time_tranche==1
replace sr_re_adj_se=`se' if study_id==1 & time_tranche==1
replace sr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace sr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1

replace sr_un_adj_eff=`beta2' if study_id==1 & time_tranche==1
replace sr_un_adj_se=`se2' if study_id==1 & time_tranche==1
replace sr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_adj_eff=`beta' if study_id==1 & time_tranche==1
replace sr_pt_adj_se=`se' if study_id==1 & time_tranche==1
replace sr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace sr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1

replace sr_ret_adj_eff=`beta2' if study_id==1 & time_tranche==1
replace sr_ret_adj_se=`se2' if study_id==1 & time_tranche==1
replace sr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace sr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1

replace sr_nw_adj_eff=`beta3' if study_id==1 & time_tranche==1
replace sr_nw_adj_se=`se3' if study_id==1 & time_tranche==1
replace sr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==1 & time_tranche==1
replace sr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==1 & time_tranche==1

replace sr_une_adj_eff=`beta4' if study_id==1 & time_tranche==1
replace sr_une_adj_se=`se4' if study_id==1 & time_tranche==1
replace sr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==1 & time_tranche==1
replace sr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==1 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore




**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_adj_eff=`beta' if study_id==1 & time_tranche==1
replace sr_kw_adj_se=`se' if study_id==1 & time_tranche==1
replace sr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace sr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1
*replace sr_kw_adj_eff=exp(`beta') if study_id==1 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_adj_eff=`beta2' if study_id==1 & time_tranche==1
replace sr_sm_adj_se=`se2' if study_id==1 & time_tranche==1
replace sr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace sr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1

replace sr_no_adj_eff=`beta3' if study_id==1 & time_tranche==1
replace sr_no_adj_se=`se3' if study_id==1 & time_tranche==1
replace sr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==1 & time_tranche==1
replace sr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==1 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_adj_eff=`beta' if study_id==1 & time_tranche==1
replace sr_fr_adj_se=`se' if study_id==1 & time_tranche==1
replace sr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace sr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1
*replace sr_fr_adj_eff=exp(`beta') if study_id==1 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==1 & time_tranche==1
replace lr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==1 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==1 & time_tranche==1
replace lr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==1 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
mepoisson c19positive i.sic_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
mepoisson c19positive i.sic_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult



 


**employment
mepoisson c19positive i.employment i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_adj_eff=`beta' if study_id==1 & time_tranche==1
replace lr_re_adj_se=`se' if study_id==1 & time_tranche==1
replace lr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace lr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1

replace lr_un_adj_eff=`beta2' if study_id==1 & time_tranche==1
replace lr_un_adj_se=`se2' if study_id==1 & time_tranche==1
replace lr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_adj_eff=`beta' if study_id==1 & time_tranche==1
replace lr_pt_adj_se=`se' if study_id==1 & time_tranche==1
replace lr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace lr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1

replace lr_ret_adj_eff=`beta2' if study_id==1 & time_tranche==1
replace lr_ret_adj_se=`se2' if study_id==1 & time_tranche==1
replace lr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace lr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1

replace lr_nw_adj_eff=`beta3' if study_id==1 & time_tranche==1
replace lr_nw_adj_se=`se3' if study_id==1 & time_tranche==1
replace lr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==1 & time_tranche==1
replace lr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==1 & time_tranche==1

replace lr_une_adj_eff=`beta4' if study_id==1 & time_tranche==1
replace lr_une_adj_se=`se4' if study_id==1 & time_tranche==1
replace lr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==1 & time_tranche==1
replace lr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==1 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore



**Key worker	
mepoisson c19positive i.keyworker i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_adj_eff=`beta' if study_id==1 & time_tranche==1
replace lr_kw_adj_se=`se' if study_id==1 & time_tranche==1
replace lr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace lr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1
*replace lr_kw_adj_eff=exp(`beta') if study_id==1 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore
**Home working	
mepoisson c19positive i.home_working i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_adj_eff=`beta2' if study_id==1 & time_tranche==1
replace lr_sm_adj_se=`se2' if study_id==1 & time_tranche==1
replace lr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace lr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1

replace lr_no_adj_eff=`beta3' if study_id==1 & time_tranche==1
replace lr_no_adj_se=`se3' if study_id==1 & time_tranche==1
replace lr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==1 & time_tranche==1
replace lr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==1 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_adj_eff=`beta' if study_id==1 & time_tranche==1
replace lr_fr_adj_se=`se' if study_id==1 & time_tranche==1
replace lr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace lr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1
*replace lr_fr_adj_eff=exp(`beta') if study_id==1 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

clear




***********************************
**UNDERSTANDING SOCIETY ANALYSIS 
***********************************



**Open and merge NHS DATA with UKHLS file
use "UKHLS edited\UKHLS edited long version.dta", clear


label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
label values study_wave study_wave
tab study_wave,

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "UKHLS edited\protect_nhs_c19posinfect_temp_ukhlsver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/05/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/06/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/07/2020", "DMY") & study_wave==3
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/08/2020", "DMY") & study_wave==4
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/10/2020", "DMY") & study_wave==5
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/12/2020", "DMY") & study_wave==6
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/02/2021", "DMY") & study_wave==7
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==8

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/05/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/06/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/07/2020", "DMY") & study_wave==3
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/08/2020", "DMY") & study_wave==4
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/10/2020", "DMY") & study_wave==5
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/12/2020", "DMY") & study_wave==6
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/02/2021", "DMY") & study_wave==7
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/04/2021", "DMY") & study_wave==8

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/05/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/06/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/07/2020", "DMY") & study_wave==3
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/08/2020", "DMY") & study_wave==4
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/10/2020", "DMY") & study_wave==5
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/12/2020", "DMY") & study_wave==6
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/02/2021", "DMY") & study_wave==7
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/04/2021", "DMY") & study_wave==8

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/05/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/06/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/07/2020", "DMY") & study_wave==3
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/08/2020", "DMY") & study_wave==4
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/10/2020", "DMY") & study_wave==5
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/12/2020", "DMY") & study_wave==6
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/02/2021", "DMY") & study_wave==7
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==8


tab study_wave vacc_status




drop if age_entry>5

**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

label define furlough 0 "No" 1 "Yes", replace
label values furlough furlough

***Change labels to fit with generic analysis 
rename keyworker keyworker2
rename key_worker keyworker


** UKHLS - descriptive statistics
quietly tab llc_0007_stud_id
return list
local sample_n =  r(r)
local entry_n =  r(N)


**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==2 & time_tranche==1
replace entry_n=`entry_n' if study_id==2 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==2 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==2 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==2 & time_tranche==1

list if study_id==2 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
tab soc_1d `var', missing row
tab soc_2d `var', missing row

**SIC 2003 	
tab sic_1d `var', missing row
tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
tab age_entry `var', missing row
tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
recode employment (3=4) (2=3)
recode employment_status (2=4) 


***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==2 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==2 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==2 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==2 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19infection_selfreported i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*local beta = _b[2.employment]
*local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

*replace sr_re_eff=`beta' if study_id==2 & time_tranche==1
*replace sr_re_se=`se' if study_id==2 & time_tranche==1
*replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
*replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==2 & time_tranche==1
replace sr_un_se=`se2' if study_id==2 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**employment_status	
mepoisson c19infection_selfreported i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

*local beta2 = _b[2.employment_status]
*local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_eff=`beta' if study_id==2 & time_tranche==1
replace sr_pt_se=`se' if study_id==2 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1

*replace sr_ret_eff=`beta2' if study_id==2 & time_tranche==1
*replace sr_ret_se=`se2' if study_id==2 & time_tranche==1
*replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
*replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==2 & time_tranche==1
replace sr_nw_se=`se3' if study_id==2 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==2 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==2 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==2 & time_tranche==1
replace sr_une_se=`se4' if study_id==2 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==2 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==2 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_eff=`beta' if study_id==2 & time_tranche==1
replace sr_kw_se=`se' if study_id==2 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Home working	
mepoisson c19infection_selfreported i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_eff=`beta2' if study_id==2 & time_tranche==1
replace sr_sm_se=`se2' if study_id==2 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==2 & time_tranche==1
replace sr_no_se=`se3' if study_id==2 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==2 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==2 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_eff=`beta' if study_id==2 & time_tranche==1
replace sr_fr_se=`se' if study_id==2 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1
*replace sr_fr_eff=exp(`beta') if study_id==2 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==2 & time_tranche==1
replace lr_s101d`i'_se=_se[`i'.soc_1d] if study_id==2 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==2 & time_tranche==1
replace lr_s102d`i'_se=_se[`i'.soc_2d] if study_id==2 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 
**SCI 2003 	
mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*local beta = _b[2.employment]
*local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

*replace lr_re_eff=`beta' if study_id==2 & time_tranche==1
*replace lr_re_se=`se' if study_id==2 & time_tranche==1
*replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
*replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==2 & time_tranche==1
replace lr_un_se=`se2' if study_id==2 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

*local beta2 = _b[2.employment_status]
*local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_eff=`beta' if study_id==2 & time_tranche==1
replace lr_pt_se=`se' if study_id==2 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1

*replace lr_ret_eff=`beta2' if study_id==2 & time_tranche==1
*replace lr_ret_se=`se2' if study_id==2 & time_tranche==1
*replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
*replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==2 & time_tranche==1
replace lr_nw_se=`se3' if study_id==2 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==2 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==2 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==2 & time_tranche==1
replace lr_une_se=`se4' if study_id==2 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==2 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==2 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_eff=`beta' if study_id==2 & time_tranche==1
replace lr_kw_se=`se' if study_id==2 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1
*replace lr_kw_eff=exp(`beta') if study_id==2 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_eff=`beta2' if study_id==2 & time_tranche==1
replace lr_sm_se=`se2' if study_id==2 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==2 & time_tranche==1
replace lr_no_se=`se3' if study_id==2 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==2 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==2 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_eff=`beta' if study_id==2 & time_tranche==1
replace lr_fr_se=`se' if study_id==2 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation 
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==2 & time_tranche==1
replace sr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==2 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==2 & time_tranche==1
replace sr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==2 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
mepoisson c19infection_selfreported i.sic_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult






**employment status
mepoisson c19infection_selfreported i.employment i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*local beta = _b[2.employment]
*local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

*replace sr_re_adj_eff=`beta' if study_id==2 & time_tranche==1
*replace sr_re_adj_se=`se' if study_id==2 & time_tranche==1
*replace sr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
*replace sr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1

replace sr_un_adj_eff=`beta2' if study_id==2 & time_tranche==1
replace sr_un_adj_se=`se2' if study_id==2 & time_tranche==1
replace sr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

*local beta2 = _b[2.employment_status]
*local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_adj_eff=`beta' if study_id==2 & time_tranche==1
replace sr_pt_adj_se=`se' if study_id==2 & time_tranche==1
replace sr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace sr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1

*replace sr_ret_adj_eff=`beta2' if study_id==2 & time_tranche==1
*replace sr_ret_adj_se=`se2' if study_id==2 & time_tranche==1
*replace sr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
*replace sr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1

replace sr_nw_adj_eff=`beta3' if study_id==2 & time_tranche==1
replace sr_nw_adj_se=`se3' if study_id==2 & time_tranche==1
replace sr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==2 & time_tranche==1
replace sr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==2 & time_tranche==1

replace sr_une_adj_eff=`beta4' if study_id==2 & time_tranche==1
replace sr_une_adj_se=`se4' if study_id==2 & time_tranche==1
replace sr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==2 & time_tranche==1
replace sr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==2 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore




**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_adj_eff=`beta' if study_id==2 & time_tranche==1
replace sr_kw_adj_se=`se' if study_id==2 & time_tranche==1
replace sr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace sr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1
*replace sr_kw_adj_eff=exp(`beta') if study_id==2 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_adj_eff=`beta2' if study_id==2 & time_tranche==1
replace sr_sm_adj_se=`se2' if study_id==2 & time_tranche==1
replace sr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
replace sr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1

replace sr_no_adj_eff=`beta3' if study_id==2 & time_tranche==1
replace sr_no_adj_se=`se3' if study_id==2 & time_tranche==1
replace sr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==2 & time_tranche==1
replace sr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==2 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_adj_eff=`beta' if study_id==2 & time_tranche==1
replace sr_fr_adj_se=`se' if study_id==2 & time_tranche==1
replace sr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace sr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==2 & time_tranche==1
replace lr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==2 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==2 & time_tranche==1
replace lr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==2 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19positive i.employment i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*local beta = _b[2.employment]
*local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

*replace lr_re_adj_eff=`beta' if study_id==2 & time_tranche==1
*replace lr_re_adj_se=`se' if study_id==2 & time_tranche==1
*replace lr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
*replace lr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1

replace lr_un_adj_eff=`beta2' if study_id==2 & time_tranche==1
replace lr_un_adj_se=`se2' if study_id==2 & time_tranche==1
replace lr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

*local beta2 = _b[2.employment_status]
*local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_adj_eff=`beta' if study_id==2 & time_tranche==1
replace lr_pt_adj_se=`se' if study_id==2 & time_tranche==1
replace lr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace lr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1

*replace lr_ret_adj_eff=`beta2' if study_id==2 & time_tranche==1
*replace lr_ret_adj_se=`se2' if study_id==2 & time_tranche==1
*replace lr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
*replace lr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1

replace lr_nw_adj_eff=`beta3' if study_id==2 & time_tranche==1
replace lr_nw_adj_se=`se3' if study_id==2 & time_tranche==1
replace lr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==2 & time_tranche==1
replace lr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==2 & time_tranche==1

replace lr_une_adj_eff=`beta4' if study_id==2 & time_tranche==1
replace lr_une_adj_se=`se4' if study_id==2 & time_tranche==1
replace lr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==2 & time_tranche==1
replace lr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==2 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore

**Key worker	
mepoisson c19positive i.keyworker i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_adj_eff=`beta' if study_id==2 & time_tranche==1
replace lr_kw_adj_se=`se' if study_id==2 & time_tranche==1
replace lr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace lr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19positive i.home_working i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_adj_eff=`beta2' if study_id==2 & time_tranche==1
replace lr_sm_adj_se=`se2' if study_id==2 & time_tranche==1
replace lr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
replace lr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1

replace lr_no_adj_eff=`beta3' if study_id==2 & time_tranche==1
replace lr_no_adj_se=`se3' if study_id==2 & time_tranche==1
replace lr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==2 & time_tranche==1
replace lr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==2 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.ethnicity_red i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_adj_eff=`beta' if study_id==2 & time_tranche==1
replace lr_fr_adj_se=`se' if study_id==2 & time_tranche==1
replace lr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace lr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


clear



*******************************
**THE BRITISH COHORT 1970
*******************************




**Open and merge NHS data with UKHLS file
use "BCS70 edited\BCS70 edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,
tostring avail_from_dt, replace 

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "BCS70 edited\protect_nhs_c19posinfect_temp_bcs70ver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/04/2021", "DMY") & study_wave==3


tab study_wave vacc_status



**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2
rename key_worker keyworker


** BCS1970 - descriptive statistics
quietly tab llc_0007_stud_id
return list
local sample_n =  r(r)
local entry_n =  r(N)


**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==3 & time_tranche==1
replace entry_n=`entry_n' if study_id==3 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==3 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==3 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==3 & time_tranche==1

list if study_id==3 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
tab soc2010_1d `var', missing row
tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
*tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}

numlabel, add

tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
rename soc2010_1d soc_1d
rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2010
**1 digit
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==3 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==3 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==3 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==3 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 
	



**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19infection_selfreported i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_eff=`beta' if study_id==3 & time_tranche==1
replace sr_re_se=`se' if study_id==3 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==3 & time_tranche==1
replace sr_un_se=`se2' if study_id==3 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**employment_status	
mepoisson c19infection_selfreported i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_eff=`beta' if study_id==3 & time_tranche==1
replace sr_pt_se=`se' if study_id==3 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==3 & time_tranche==1
replace sr_ret_se=`se2' if study_id==3 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==3 & time_tranche==1
replace sr_nw_se=`se3' if study_id==3 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==3 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==3 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==3 & time_tranche==1
replace sr_une_se=`se4' if study_id==3 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==3 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==3 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_eff=`beta' if study_id==3 & time_tranche==1
replace sr_kw_se=`se' if study_id==3 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_eff=`beta2' if study_id==3 & time_tranche==1
replace sr_sm_se=`se2' if study_id==3 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==3 & time_tranche==1
replace sr_no_se=`se3' if study_id==3 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==3 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==3 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_eff=`beta' if study_id==3 & time_tranche==1
replace sr_fr_se=`se' if study_id==3 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==3 & time_tranche==1
replace lr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==3 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==3 & time_tranche==1
replace lr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==3 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_eff=`beta' if study_id==3 & time_tranche==1
replace lr_re_se=`se' if study_id==3 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==3 & time_tranche==1
replace lr_un_se=`se2' if study_id==3 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_eff=`beta' if study_id==3 & time_tranche==1
replace lr_pt_se=`se' if study_id==3 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==3 & time_tranche==1
replace lr_ret_se=`se2' if study_id==3 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==3 & time_tranche==1
replace lr_nw_se=`se3' if study_id==3 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==3 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==3 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==3 & time_tranche==1
replace lr_une_se=`se4' if study_id==3 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==3 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==3 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_eff=`beta' if study_id==3 & time_tranche==1
replace lr_kw_se=`se' if study_id==3 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19positive i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_eff=`beta2' if study_id==3 & time_tranche==1
replace lr_sm_se=`se2' if study_id==3 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==3 & time_tranche==1
replace lr_no_se=`se3' if study_id==3 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==3 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==3 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_eff=`beta' if study_id==3 & time_tranche==1
replace lr_fr_se=`se' if study_id==3 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==3 & time_tranche==1
replace sr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==3 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==3 & time_tranche==1
replace sr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==3 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_adj_eff=`beta' if study_id==3 & time_tranche==1
replace sr_re_adj_se=`se' if study_id==3 & time_tranche==1
replace sr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace sr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1

replace sr_un_adj_eff=`beta2' if study_id==3 & time_tranche==1
replace sr_un_adj_se=`se2' if study_id==3 & time_tranche==1
replace sr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_adj_eff=`beta' if study_id==3 & time_tranche==1
replace sr_pt_adj_se=`se' if study_id==3 & time_tranche==1
replace sr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace sr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1

replace sr_ret_adj_eff=`beta2' if study_id==3 & time_tranche==1
replace sr_ret_adj_se=`se2' if study_id==3 & time_tranche==1
replace sr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace sr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1

replace sr_nw_adj_eff=`beta3' if study_id==3 & time_tranche==1
replace sr_nw_adj_se=`se3' if study_id==3 & time_tranche==1
replace sr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==3 & time_tranche==1
replace sr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==3 & time_tranche==1

replace sr_une_adj_eff=`beta4' if study_id==3 & time_tranche==1
replace sr_une_adj_se=`se4' if study_id==3 & time_tranche==1
replace sr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==3 & time_tranche==1
replace sr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==3 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.ethnicity_red i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_adj_eff=`beta' if study_id==3 & time_tranche==1
replace sr_kw_adj_se=`se' if study_id==3 & time_tranche==1
replace sr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace sr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.ethnicity_red i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_adj_eff=`beta2' if study_id==3 & time_tranche==1
replace sr_sm_adj_se=`se2' if study_id==3 & time_tranche==1
replace sr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace sr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1

replace sr_no_adj_eff=`beta3' if study_id==3 & time_tranche==1
replace sr_no_adj_se=`se3' if study_id==3 & time_tranche==1
replace sr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==3 & time_tranche==1
replace sr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==3 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.ethnicity_red i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_adj_eff=`beta' if study_id==3 & time_tranche==1
replace sr_fr_adj_se=`se' if study_id==3 & time_tranche==1
replace sr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace sr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.ethnicity_red i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==3 & time_tranche==1
replace lr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==3 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==3 & time_tranche==1
replace lr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==3 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_adj_eff=`beta' if study_id==3 & time_tranche==1
replace lr_re_adj_se=`se' if study_id==3 & time_tranche==1
replace lr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace lr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1

replace lr_un_adj_eff=`beta2' if study_id==3 & time_tranche==1
replace lr_un_adj_se=`se2' if study_id==3 & time_tranche==1
replace lr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_adj_eff=`beta' if study_id==3 & time_tranche==1
replace lr_pt_adj_se=`se' if study_id==3 & time_tranche==1
replace lr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace lr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1

replace lr_ret_adj_eff=`beta2' if study_id==3 & time_tranche==1
replace lr_ret_adj_se=`se2' if study_id==3 & time_tranche==1
replace lr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace lr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1

replace lr_nw_adj_eff=`beta3' if study_id==3 & time_tranche==1
replace lr_nw_adj_se=`se3' if study_id==3 & time_tranche==1
replace lr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==3 & time_tranche==1
replace lr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==3 & time_tranche==1

replace lr_une_adj_eff=`beta4' if study_id==3 & time_tranche==1
replace lr_une_adj_se=`se4' if study_id==3 & time_tranche==1
replace lr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==3 & time_tranche==1
replace lr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==3 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.ethnicity_red i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_adj_eff=`beta' if study_id==3 & time_tranche==1
replace lr_kw_adj_se=`se' if study_id==3 & time_tranche==1
replace lr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace lr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.sex i.ethnicity_red i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_adj_eff=`beta2' if study_id==3 & time_tranche==1
replace lr_sm_adj_se=`se2' if study_id==3 & time_tranche==1
replace lr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace lr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1

replace lr_no_adj_eff=`beta3' if study_id==3 & time_tranche==1
replace lr_no_adj_se=`se3' if study_id==3 & time_tranche==1
replace lr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==3 & time_tranche==1
replace lr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==3 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.ethnicity_red i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_adj_eff=`beta' if study_id==3 & time_tranche==1
replace lr_fr_adj_se=`se' if study_id==3 & time_tranche==1
replace lr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace lr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


clear





*******************************
**THE  MILLENIUM COHORT
*******************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "MCS edited\MCS edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,
tostring avail_from_dt, replace 

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "MCS edited\protect_nhs_c19posinfect_temp_mcsver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/04/2021", "DMY") & study_wave==3


tab study_wave vacc_status



**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2
rename key_worker keyworker


** MCS - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq

**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==4 & time_tranche==1
replace entry_n=`entry_n' if study_id==4 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==4 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==4 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==4 & time_tranche==1

list if study_id==4 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
tab soc2010_1d `var', missing row
tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
*tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
rename soc2010_1d soc_1d
rename soc2010_2d soc_2d
replace soc_2d=. if soc_2d<0
***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult
preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==4 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==4 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==4 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==4 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19infection_selfreported i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_eff=`beta' if study_id==4 & time_tranche==1
replace sr_re_se=`se' if study_id==4 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==4 & time_tranche==1
replace sr_un_se=`se2' if study_id==4 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**employment_status	
mepoisson c19infection_selfreported i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_eff=`beta' if study_id==4 & time_tranche==1
replace sr_pt_se=`se' if study_id==4 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==4 & time_tranche==1
replace sr_ret_se=`se2' if study_id==4 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==4 & time_tranche==1
replace sr_nw_se=`se3' if study_id==4 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==4 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==4 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==4 & time_tranche==1
replace sr_une_se=`se4' if study_id==4 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==4 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==4 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_eff=`beta' if study_id==4 & time_tranche==1
replace sr_kw_se=`se' if study_id==4 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_eff=`beta2' if study_id==4 & time_tranche==1
replace sr_sm_se=`se2' if study_id==4 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==4 & time_tranche==1
replace sr_no_se=`se3' if study_id==4 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==4 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==4 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_eff=`beta' if study_id==4 & time_tranche==1
replace sr_fr_se=`se' if study_id==4 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==4 & time_tranche==1
replace lr_s101d`i'_se=_se[`i'.soc_1d] if study_id==4 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==4 & time_tranche==1
replace lr_s102d`i'_se=_se[`i'.soc_2d] if study_id==4 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_eff=`beta' if study_id==4 & time_tranche==1
replace lr_re_se=`se' if study_id==4 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==4 & time_tranche==1
replace lr_un_se=`se2' if study_id==4 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status i.cohort i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_eff=`beta' if study_id==4 & time_tranche==1
replace lr_pt_se=`se' if study_id==4 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==4 & time_tranche==1
replace lr_ret_se=`se2' if study_id==4 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==4 & time_tranche==1
replace lr_nw_se=`se3' if study_id==4 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==4 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==4 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==4 & time_tranche==1
replace lr_une_se=`se4' if study_id==4 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==4 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==4 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_eff=`beta' if study_id==4 & time_tranche==1
replace lr_kw_se=`se' if study_id==4 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19positive i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_eff=`beta2' if study_id==4 & time_tranche==1
replace lr_sm_se=`se2' if study_id==4 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==4 & time_tranche==1
replace lr_no_se=`se3' if study_id==4 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==4 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==4 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_eff=`beta' if study_id==4 & time_tranche==1
replace lr_fr_se=`se' if study_id==4 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.ethnicity_red i.cohort i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==4 & time_tranche==1
replace sr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==4 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==4 & time_tranche==1
replace sr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==4 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.ethnicity_red i.cohort i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_adj_eff=`beta' if study_id==4 & time_tranche==1
replace sr_re_adj_se=`se' if study_id==4 & time_tranche==1
replace sr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace sr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1

replace sr_un_adj_eff=`beta2' if study_id==4 & time_tranche==1
replace sr_un_adj_se=`se2' if study_id==4 & time_tranche==1
replace sr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.ethnicity_red i.cohort i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_adj_eff=`beta' if study_id==4 & time_tranche==1
replace sr_pt_adj_se=`se' if study_id==4 & time_tranche==1
replace sr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace sr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1

replace sr_ret_adj_eff=`beta2' if study_id==4 & time_tranche==1
replace sr_ret_adj_se=`se2' if study_id==4 & time_tranche==1
replace sr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace sr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1

replace sr_nw_adj_eff=`beta3' if study_id==4 & time_tranche==1
replace sr_nw_adj_se=`se3' if study_id==4 & time_tranche==1
replace sr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==4 & time_tranche==1
replace sr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==4 & time_tranche==1

replace sr_une_adj_eff=`beta4' if study_id==4 & time_tranche==1
replace sr_une_adj_se=`se4' if study_id==4 & time_tranche==1
replace sr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==4 & time_tranche==1
replace sr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==4 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.ethnicity_red i.cohort i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_adj_eff=`beta' if study_id==4 & time_tranche==1
replace sr_kw_adj_se=`se' if study_id==4 & time_tranche==1
replace sr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace sr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.ethnicity_red i.cohort i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_adj_eff=`beta2' if study_id==4 & time_tranche==1
replace sr_sm_adj_se=`se2' if study_id==4 & time_tranche==1
replace sr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace sr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1

replace sr_no_adj_eff=`beta3' if study_id==4 & time_tranche==1
replace sr_no_adj_se=`se3' if study_id==4 & time_tranche==1
replace sr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==4 & time_tranche==1
replace sr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==4 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.ethnicity_red i.cohort i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_adj_eff=`beta' if study_id==4 & time_tranche==1
replace sr_fr_adj_se=`se' if study_id==4 & time_tranche==1
replace sr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace sr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.ethnicity_red i.cohort i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==4 & time_tranche==1
replace lr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==4 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==4 & time_tranche==1
replace lr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==4 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_adj_eff=`beta' if study_id==4 & time_tranche==1
replace lr_re_adj_se=`se' if study_id==4 & time_tranche==1
replace lr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace lr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1

replace lr_un_adj_eff=`beta2' if study_id==4 & time_tranche==1
replace lr_un_adj_se=`se2' if study_id==4 & time_tranche==1
replace lr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.ethnicity_red i.cohort i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_adj_eff=`beta' if study_id==4 & time_tranche==1
replace lr_pt_adj_se=`se' if study_id==4 & time_tranche==1
replace lr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace lr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1

replace lr_ret_adj_eff=`beta2' if study_id==4 & time_tranche==1
replace lr_ret_adj_se=`se2' if study_id==4 & time_tranche==1
replace lr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace lr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1

replace lr_nw_adj_eff=`beta3' if study_id==4 & time_tranche==1
replace lr_nw_adj_se=`se3' if study_id==4 & time_tranche==1
replace lr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==4 & time_tranche==1
replace lr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==4 & time_tranche==1

replace lr_une_adj_eff=`beta4' if study_id==4 & time_tranche==1
replace lr_une_adj_se=`se4' if study_id==4 & time_tranche==1
replace lr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==4 & time_tranche==1
replace lr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==4 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.ethnicity_red i.cohort i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_adj_eff=`beta' if study_id==4 & time_tranche==1
replace lr_kw_adj_se=`se' if study_id==4 & time_tranche==1
replace lr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace lr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.sex i.ethnicity_red i.cohort i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_adj_eff=`beta2' if study_id==4 & time_tranche==1
replace lr_sm_adj_se=`se2' if study_id==4 & time_tranche==1
replace lr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace lr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1

replace lr_no_adj_eff=`beta3' if study_id==4 & time_tranche==1
replace lr_no_adj_se=`se3' if study_id==4 & time_tranche==1
replace lr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==4 & time_tranche==1
replace lr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==4 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.ethnicity_red i.cohort i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_adj_eff=`beta' if study_id==4 & time_tranche==1
replace lr_fr_adj_se=`se' if study_id==4 & time_tranche==1
replace lr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace lr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


clear








***************************************************
**THE 1958 NATIONAL CHILD DEVELOPMENT STUDY (NCDS)
***************************************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "NCDS58 edited\NCDS58 edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,
tostring avail_from_dt, replace 

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "NCDS58 edited\protect_nhs_c19posinfect_temp_ncds58ver"
drop if _merge==2	


**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2
rename key_worker keyworker


** NCDS58 - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq

**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==5 & time_tranche==1
replace entry_n=`entry_n' if study_id==5 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==5 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==5 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==5 & time_tranche==1

list if study_id==5 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
tab soc2010_1d `var', missing row
tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
*tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
rename soc2010_1d soc_1d
rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==5 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==5 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==5 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==5 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19infection_selfreported i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_eff=`beta' if study_id==5 & time_tranche==1
replace sr_re_se=`se' if study_id==5 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==5 & time_tranche==1
replace sr_un_se=`se2' if study_id==5 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**employment_status	
mepoisson c19infection_selfreported i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_eff=`beta' if study_id==5 & time_tranche==1
replace sr_pt_se=`se' if study_id==5 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==5 & time_tranche==1
replace sr_ret_se=`se2' if study_id==5 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==5 & time_tranche==1
replace sr_nw_se=`se3' if study_id==5 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==5 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==5 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==5 & time_tranche==1
replace sr_une_se=`se4' if study_id==5 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==5 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==5 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_eff=`beta' if study_id==5 & time_tranche==1
replace sr_kw_se=`se' if study_id==5 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_eff=`beta2' if study_id==5 & time_tranche==1
replace sr_sm_se=`se2' if study_id==5 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==5 & time_tranche==1
replace sr_no_se=`se3' if study_id==5 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==5 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==5 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_eff=`beta' if study_id==5 & time_tranche==1
replace sr_fr_se=`se' if study_id==5 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==5 & time_tranche==1
replace lr_s101d`i'_se=_se[`i'.soc_1d] if study_id==5 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==5 & time_tranche==1
replace lr_s102d`i'_se=_se[`i'.soc_2d] if study_id==5 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_eff=`beta' if study_id==5 & time_tranche==1
replace lr_re_se=`se' if study_id==5 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==5 & time_tranche==1
replace lr_un_se=`se2' if study_id==5 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_eff=`beta' if study_id==5 & time_tranche==1
replace lr_pt_se=`se' if study_id==5 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==5 & time_tranche==1
replace lr_ret_se=`se2' if study_id==5 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==5 & time_tranche==1
replace lr_nw_se=`se3' if study_id==5 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==5 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==5 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==5 & time_tranche==1
replace lr_une_se=`se4' if study_id==5 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==5 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==5 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_eff=`beta' if study_id==5 & time_tranche==1
replace lr_kw_se=`se' if study_id==5 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19positive i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_eff=`beta2' if study_id==5 & time_tranche==1
replace lr_sm_se=`se2' if study_id==5 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==5 & time_tranche==1
replace lr_no_se=`se3' if study_id==5 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==5 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==5 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_eff=`beta' if study_id==5 & time_tranche==1
replace lr_fr_se=`se' if study_id==5 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==5 & time_tranche==1
replace sr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==5 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==5 & time_tranche==1
replace sr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==5 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_adj_eff=`beta' if study_id==5 & time_tranche==1
replace sr_re_adj_se=`se' if study_id==5 & time_tranche==1
replace sr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace sr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1

replace sr_un_adj_eff=`beta2' if study_id==5 & time_tranche==1
replace sr_un_adj_se=`se2' if study_id==5 & time_tranche==1
replace sr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_adj_eff=`beta' if study_id==5 & time_tranche==1
replace sr_pt_adj_se=`se' if study_id==5 & time_tranche==1
replace sr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace sr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1

replace sr_ret_adj_eff=`beta2' if study_id==5 & time_tranche==1
replace sr_ret_adj_se=`se2' if study_id==5 & time_tranche==1
replace sr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace sr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1

replace sr_nw_adj_eff=`beta3' if study_id==5 & time_tranche==1
replace sr_nw_adj_se=`se3' if study_id==5 & time_tranche==1
replace sr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==5 & time_tranche==1
replace sr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==5 & time_tranche==1

replace sr_une_adj_eff=`beta4' if study_id==5 & time_tranche==1
replace sr_une_adj_se=`se4' if study_id==5 & time_tranche==1
replace sr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==5 & time_tranche==1
replace sr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==5 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.ethnicity_red i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_adj_eff=`beta' if study_id==5 & time_tranche==1
replace sr_kw_adj_se=`se' if study_id==5 & time_tranche==1
replace sr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace sr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.ethnicity_red i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_adj_eff=`beta2' if study_id==5 & time_tranche==1
replace sr_sm_adj_se=`se2' if study_id==5 & time_tranche==1
replace sr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace sr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1

replace sr_no_adj_eff=`beta3' if study_id==5 & time_tranche==1
replace sr_no_adj_se=`se3' if study_id==5 & time_tranche==1
replace sr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==5 & time_tranche==1
replace sr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==5 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.ethnicity_red i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_adj_eff=`beta' if study_id==5 & time_tranche==1
replace sr_fr_adj_se=`se' if study_id==5 & time_tranche==1
replace sr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace sr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.ethnicity_red i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==5 & time_tranche==1
replace lr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==5 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==5 & time_tranche==1
replace lr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==5 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_adj_eff=`beta' if study_id==5 & time_tranche==1
replace lr_re_adj_se=`se' if study_id==5 & time_tranche==1
replace lr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace lr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1

replace lr_un_adj_eff=`beta2' if study_id==5 & time_tranche==1
replace lr_un_adj_se=`se2' if study_id==5 & time_tranche==1
replace lr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_adj_eff=`beta' if study_id==5 & time_tranche==1
replace lr_pt_adj_se=`se' if study_id==5 & time_tranche==1
replace lr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace lr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1

replace lr_ret_adj_eff=`beta2' if study_id==5 & time_tranche==1
replace lr_ret_adj_se=`se2' if study_id==5 & time_tranche==1
replace lr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace lr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1

replace lr_nw_adj_eff=`beta3' if study_id==5 & time_tranche==1
replace lr_nw_adj_se=`se3' if study_id==5 & time_tranche==1
replace lr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==5 & time_tranche==1
replace lr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==5 & time_tranche==1

replace lr_une_adj_eff=`beta4' if study_id==5 & time_tranche==1
replace lr_une_adj_se=`se4' if study_id==5 & time_tranche==1
replace lr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==5 & time_tranche==1
replace lr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==5 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.ethnicity_red i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_adj_eff=`beta' if study_id==5 & time_tranche==1
replace lr_kw_adj_se=`se' if study_id==5 & time_tranche==1
replace lr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace lr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.sex i.ethnicity_red i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_adj_eff=`beta2' if study_id==5 & time_tranche==1
replace lr_sm_adj_se=`se2' if study_id==5 & time_tranche==1
replace lr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace lr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1

replace lr_no_adj_eff=`beta3' if study_id==5 & time_tranche==1
replace lr_no_adj_se=`se3' if study_id==5 & time_tranche==1
replace lr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==5 & time_tranche==1
replace lr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==5 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.ethnicity_red i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_adj_eff=`beta' if study_id==5 & time_tranche==1
replace lr_fr_adj_se=`se' if study_id==5 & time_tranche==1
replace lr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace lr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


clear



***************************************************
**NEXT STEPS 
***************************************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "NS edited\NS edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,
tostring avail_from_dt, replace 

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "NS edited\protect_nhs_c19posinfect_temp_NSver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/04/2021", "DMY") & study_wave==3


tab study_wave vacc_status


**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2
rename key_worker keyworker


** NEXT STEPS - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq

**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==6 & time_tranche==1
replace entry_n=`entry_n' if study_id==6 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==6 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==6 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==6 & time_tranche==1

list if study_id==6 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
tab soc2010_1d `var', missing row
tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
*tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
rename soc2010_1d soc_1d
rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==6 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==6 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==6 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==6 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult



*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19infection_selfreported i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_eff=`beta' if study_id==6 & time_tranche==1
replace sr_re_se=`se' if study_id==6 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==6 & time_tranche==1
replace sr_un_se=`se2' if study_id==6 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**employment_status	
mepoisson c19infection_selfreported i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_eff=`beta' if study_id==6 & time_tranche==1
replace sr_pt_se=`se' if study_id==6 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==6 & time_tranche==1
replace sr_ret_se=`se2' if study_id==6 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==6 & time_tranche==1
replace sr_nw_se=`se3' if study_id==6 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==6 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==6 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==6 & time_tranche==1
replace sr_une_se=`se4' if study_id==6 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==6 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==6 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_eff=`beta' if study_id==6 & time_tranche==1
replace sr_kw_se=`se' if study_id==6 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_eff=`beta2' if study_id==6 & time_tranche==1
replace sr_sm_se=`se2' if study_id==6 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==6 & time_tranche==1
replace sr_no_se=`se3' if study_id==6 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==6 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==6 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_eff=`beta' if study_id==6 & time_tranche==1
replace sr_fr_se=`se' if study_id==6 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==6 & time_tranche==1
replace lr_s101d`i'_se=_se[`i'.soc_1d] if study_id==6 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==6 & time_tranche==1
replace lr_s102d`i'_se=_se[`i'.soc_2d] if study_id==6 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_eff=`beta' if study_id==6 & time_tranche==1
replace lr_re_se=`se' if study_id==6 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==6 & time_tranche==1
replace lr_un_se=`se2' if study_id==6 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_eff=`beta' if study_id==6 & time_tranche==1
replace lr_pt_se=`se' if study_id==6 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==6 & time_tranche==1
replace lr_ret_se=`se2' if study_id==6 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==6 & time_tranche==1
replace lr_nw_se=`se3' if study_id==6 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==6 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==6 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==6 & time_tranche==1
replace lr_une_se=`se4' if study_id==6 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==6 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==6 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_eff=`beta' if study_id==6 & time_tranche==1
replace lr_kw_se=`se' if study_id==6 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19positive i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_eff=`beta2' if study_id==6 & time_tranche==1
replace lr_sm_se=`se2' if study_id==6 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==6 & time_tranche==1
replace lr_no_se=`se3' if study_id==6 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==6 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==6 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_eff=`beta' if study_id==6 & time_tranche==1
replace lr_fr_se=`se' if study_id==6 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==6 & time_tranche==1
replace sr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==6 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==6 & time_tranche==1
replace sr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==6 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_adj_eff=`beta' if study_id==6 & time_tranche==1
replace sr_re_adj_se=`se' if study_id==6 & time_tranche==1
replace sr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace sr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1

replace sr_un_adj_eff=`beta2' if study_id==6 & time_tranche==1
replace sr_un_adj_se=`se2' if study_id==6 & time_tranche==1
replace sr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_adj_eff=`beta' if study_id==6 & time_tranche==1
replace sr_pt_adj_se=`se' if study_id==6 & time_tranche==1
replace sr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace sr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1

replace sr_ret_adj_eff=`beta2' if study_id==6 & time_tranche==1
replace sr_ret_adj_se=`se2' if study_id==6 & time_tranche==1
replace sr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace sr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1

replace sr_nw_adj_eff=`beta3' if study_id==6 & time_tranche==1
replace sr_nw_adj_se=`se3' if study_id==6 & time_tranche==1
replace sr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==6 & time_tranche==1
replace sr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==6 & time_tranche==1

replace sr_une_adj_eff=`beta4' if study_id==6 & time_tranche==1
replace sr_une_adj_se=`se4' if study_id==6 & time_tranche==1
replace sr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==6 & time_tranche==1
replace sr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==6 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.ethnicity_red i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_adj_eff=`beta' if study_id==6 & time_tranche==1
replace sr_kw_adj_se=`se' if study_id==6 & time_tranche==1
replace sr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace sr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.ethnicity_red i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_adj_eff=`beta2' if study_id==6 & time_tranche==1
replace sr_sm_adj_se=`se2' if study_id==6 & time_tranche==1
replace sr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace sr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1

replace sr_no_adj_eff=`beta3' if study_id==6 & time_tranche==1
replace sr_no_adj_se=`se3' if study_id==6 & time_tranche==1
replace sr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==6 & time_tranche==1
replace sr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==6 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.ethnicity_red i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_adj_eff=`beta' if study_id==6 & time_tranche==1
replace sr_fr_adj_se=`se' if study_id==6 & time_tranche==1
replace sr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace sr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.ethnicity_red i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==6 & time_tranche==1
replace lr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==6 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==6 & time_tranche==1
replace lr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==6 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_adj_eff=`beta' if study_id==6 & time_tranche==1
replace lr_re_adj_se=`se' if study_id==6 & time_tranche==1
replace lr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace lr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1

replace lr_un_adj_eff=`beta2' if study_id==6 & time_tranche==1
replace lr_un_adj_se=`se2' if study_id==6 & time_tranche==1
replace lr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_adj_eff=`beta' if study_id==6 & time_tranche==1
replace lr_pt_adj_se=`se' if study_id==6 & time_tranche==1
replace lr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace lr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1

replace lr_ret_adj_eff=`beta2' if study_id==6 & time_tranche==1
replace lr_ret_adj_se=`se2' if study_id==6 & time_tranche==1
replace lr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace lr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1

replace lr_nw_adj_eff=`beta3' if study_id==6 & time_tranche==1
replace lr_nw_adj_se=`se3' if study_id==6 & time_tranche==1
replace lr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==6 & time_tranche==1
replace lr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==6 & time_tranche==1

replace lr_une_adj_eff=`beta4' if study_id==6 & time_tranche==1
replace lr_une_adj_se=`se4' if study_id==6 & time_tranche==1
replace lr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==6 & time_tranche==1
replace lr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==6 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.ethnicity_red i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_adj_eff=`beta' if study_id==6 & time_tranche==1
replace lr_kw_adj_se=`se' if study_id==6 & time_tranche==1
replace lr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace lr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.sex i.ethnicity_red i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_adj_eff=`beta2' if study_id==6 & time_tranche==1
replace lr_sm_adj_se=`se2' if study_id==6 & time_tranche==1
replace lr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace lr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1

replace lr_no_adj_eff=`beta3' if study_id==6 & time_tranche==1
replace lr_no_adj_se=`se3' if study_id==6 & time_tranche==1
replace lr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==6 & time_tranche==1
replace lr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==6 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.ethnicity_red i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult 
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_adj_eff=`beta' if study_id==6 & time_tranche==1
replace lr_fr_adj_se=`se' if study_id==6 & time_tranche==1
replace lr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace lr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


clear


***************************************************
**Born in Bradford
***************************************************

**study_id==7

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "bib edited\bib edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,
tostring avail_from_dt, replace 

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "bib edited\protect_nhs_c19posinfect_temp_bibver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/07/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/01/2021", "DMY") & study_wave==2

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/07/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/01/2021", "DMY") & study_wave==2

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/07/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/01/2021", "DMY") & study_wave==2

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/07/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/01/2021", "DMY") & study_wave==2


tab study_wave vacc_status


**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
keep if cohort==1

** BIB - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq

**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==7 & time_tranche==1
replace entry_n=`entry_n' if study_id==7 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==7 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==7 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==7 & time_tranche==1

list if study_id==7 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
*tab soc2010_1d `var', missing row
*tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
*tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
*rename soc2010_1d soc_1d
*rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2000
*mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

*preserve 
*use "S:\LLC_0007\data\results_datafile time-tranche", clear
*forvalues i = 2(1)9 {
**replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==7 & time_tranche==1
**replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==7 & time_tranche==1

*}
*save "S:\LLC_0007\data\results_datafile time-tranche", replace
*restore 

*mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*preserve 
*use "S:\LLC_0007\data\results_datafile time-tranche", clear
*foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
*replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==7 & time_tranche==1
*replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==7 & time_tranche==1
*}
*save "S:\LLC_0007\data\results_datafile time-tranche", replace
*restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult



*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19infection_selfreported i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*local beta = _b[2.employment]
*local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

*replace sr_re_eff=`beta' if study_id==7 & time_tranche==1
*replace sr_re_se=`se' if study_id==7 & time_tranche==1
*replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
*replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==7 & time_tranche==1
replace sr_un_se=`se2' if study_id==7 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**employment_status	
mepoisson c19infection_selfreported i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*local beta = _b[1.employment_status]
*local se = _se[1.employment_status]

*local beta2 = _b[2.employment_status]
*local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

*replace sr_pt_eff=`beta' if study_id==7 & time_tranche==1
*replace sr_pt_se=`se' if study_id==7 & time_tranche==1
*replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
*replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1

*replace sr_ret_eff=`beta2' if study_id==7 & time_tranche==1
*replace sr_ret_se=`se2' if study_id==7 & time_tranche==1
*replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
*replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==7 & time_tranche==1
replace sr_nw_se=`se3' if study_id==7 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==7 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==7 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==7 & time_tranche==1
replace sr_une_se=`se4' if study_id==7 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==7 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==7 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_eff=`beta' if study_id==7 & time_tranche==1
replace sr_kw_se=`se' if study_id==7 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

*local beta2 = _b[2.home_working]
*local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

*replace sr_sm_eff=`beta2' if study_id==7 & time_tranche==1
*replace sr_sm_se=`se2' if study_id==7 & time_tranche==1
*replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
*replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==7 & time_tranche==1
replace sr_no_se=`se3' if study_id==7 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==7 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==7 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_eff=`beta' if study_id==7 & time_tranche==1
replace sr_fr_se=`se' if study_id==7 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

	
**test positive C19
**SOC 2000
*mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*preserve 
*use "S:\LLC_0007\data\results_datafile time-tranche", clear
*forvalues i = 2(1)9 {
*replace lr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==7 & time_tranche==1
*replace lr_s101d`i'_se=_se[`i'.soc_1d] if study_id==7 & time_tranche==1

*}
*save "S:\LLC_0007\data\results_datafile time-tranche", replace
*restore 

*mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*preserve 
*use "S:\LLC_0007\data\results_datafile time-tranche", clear
*foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
*replace lr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==7 & time_tranche==1
*replace lr_s102d`i'_se=_se[`i'.soc_2d] if study_id==7 & time_tranche==1
*}
*save "S:\LLC_0007\data\results_datafile time-tranche", replace
*restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*local beta = _b[2.employment]
*local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

*replace lr_re_eff=`beta' if study_id==7 & time_tranche==1
**replace lr_re_se=`se' if study_id==7 & time_tranche==1
*replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
**replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==7 & time_tranche==1
replace lr_un_se=`se2' if study_id==7 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*local beta = _b[1.employment_status]
*local se = _se[1.employment_status]

**local beta2 = _b[2.employment_status]
*local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

*replace lr_pt_eff=`beta' if study_id==7 & time_tranche==1
*replace lr_pt_se=`se' if study_id==7 & time_tranche==1
*replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
*replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1

*replace lr_ret_eff=`beta2' if study_id==7 & time_tranche==1
*replace lr_ret_se=`se2' if study_id==7 & time_tranche==1
*replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
*replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==7 & time_tranche==1
replace lr_nw_se=`se3' if study_id==7 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==7 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==7 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==7 & time_tranche==1
replace lr_une_se=`se4' if study_id==7 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==7 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==7 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_eff=`beta' if study_id==7 & time_tranche==1
replace lr_kw_se=`se' if study_id==7 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19positive i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
*local beta2 = _b[2.home_working]
*local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

*replace lr_sm_eff=`beta2' if study_id==7 & time_tranche==1
*replace lr_sm_se=`se2' if study_id==7 & time_tranche==1
*replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
*replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==7 & time_tranche==1
replace lr_no_se=`se3' if study_id==7 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==7 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==7 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult startvalues(constantonly)	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_eff=`beta' if study_id==7 & time_tranche==1
replace lr_fr_se=`se' if study_id==7 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
*mepoisson c19infection_selfreported i.soc_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr *vce(robust) difficult

*preserve 
*use "S:\LLC_0007\data\results_datafile time-tranche", clear
*forvalues i = 2(1)9 {
*replace sr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==7 & time_tranche==1
*replace sr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==7 & time_tranche==1

*}
*save "S:\LLC_0007\data\results_datafile time-tranche", replace
*restore 

*mepoisson c19infection_selfreported i.soc_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr *vce(robust) difficult

*preserve 
*use "S:\LLC_0007\data\results_datafile time-tranche", clear
*foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
*replace sr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==7 & time_tranche==1
*replace sr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==7 & time_tranche==1
*}
*save "S:\LLC_0007\data\results_datafile time-tranche", replace
*restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*local beta = _b[2.employment]
*local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

*replace sr_re_adj_eff=`beta' if study_id==7 & time_tranche==1
*replace sr_re_adj_se=`se' if study_id==7 & time_tranche==1
*replace sr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
*replace sr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1

replace sr_un_adj_eff=`beta2' if study_id==7 & time_tranche==1
replace sr_un_adj_se=`se2' if study_id==7 & time_tranche==1
replace sr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*local beta = _b[1.employment_status]
*local se = _se[1.employment_status]

*local beta2 = _b[2.employment_status]
*local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

*replace sr_pt_adj_eff=`beta' if study_id==7 & time_tranche==1
*replace sr_pt_adj_se=`se' if study_id==7 & time_tranche==1
*replace sr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
*replace sr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1

*replace sr_ret_adj_eff=`beta2' if study_id==7 & time_tranche==1
*replace sr_ret_adj_se=`se2' if study_id==7 & time_tranche==1
*replace sr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
*replace sr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1

replace sr_nw_adj_eff=`beta3' if study_id==7 & time_tranche==1
replace sr_nw_adj_se=`se3' if study_id==7 & time_tranche==1
replace sr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==7 & time_tranche==1
replace sr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==7 & time_tranche==1

replace sr_une_adj_eff=`beta4' if study_id==7 & time_tranche==1
replace sr_une_adj_se=`se4' if study_id==7 & time_tranche==1
replace sr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==7 & time_tranche==1
replace sr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==7 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_adj_eff=`beta' if study_id==7 & time_tranche==1
replace sr_kw_adj_se=`se' if study_id==7 & time_tranche==1
replace sr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
replace sr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

*local beta2 = _b[2.home_working]
*local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

*replace sr_sm_adj_eff=`beta2' if study_id==7 & time_tranche==1
*replace sr_sm_adj_se=`se2' if study_id==7 & time_tranche==1
*replace sr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
*replace sr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1

replace sr_no_adj_eff=`beta3' if study_id==7 & time_tranche==1
replace sr_no_adj_se=`se3' if study_id==7 & time_tranche==1
replace sr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==7 & time_tranche==1
replace sr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==7 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult startvalues(constantonly)
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_adj_eff=`beta' if study_id==7 & time_tranche==1
replace sr_fr_adj_se=`se' if study_id==7 & time_tranche==1
replace sr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
replace sr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 




	
**test positive C19
**SOC 2000
*mepoisson c19positive i.soc_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

*preserve 
*use "S:\LLC_0007\data\results_datafile time-tranche", clear
*forvalues i = 2(1)9 {
*replace lr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==7 & time_tranche==1
*replace lr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==7 & time_tranche==1

*}
*save "S:\LLC_0007\data\results_datafile time-tranche", replace
*restore 

*mepoisson c19positive i.soc_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*preserve 
*use "S:\LLC_0007\data\results_datafile time-tranche", clear
*foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
*replace lr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==7 & time_tranche==1
*replace lr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==7 & time_tranche==1
*}
*save "S:\LLC_0007\data\results_datafile time-tranche", replace
*restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*local beta = _b[2.employment]
*local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

*replace lr_re_adj_eff=`beta' if study_id==7 & time_tranche==1
*replace lr_re_adj_se=`se' if study_id==7 & time_tranche==1
*replace lr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
*replace lr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1

replace lr_un_adj_eff=`beta2' if study_id==7 & time_tranche==1
replace lr_un_adj_se=`se2' if study_id==7 & time_tranche==1
replace lr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*local beta = _b[1.employment_status]
*local se = _se[1.employment_status]

*local beta2 = _b[2.employment_status]
*local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

*replace lr_pt_adj_eff=`beta' if study_id==7 & time_tranche==1
*replace lr_pt_adj_se=`se' if study_id==7 & time_tranche==1
*replace lr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
*replace lr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1

*replace lr_ret_adj_eff=`beta2' if study_id==7 & time_tranche==1
*replace lr_ret_adj_se=`se2' if study_id==7 & time_tranche==1
*replace lr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
*replace lr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1

replace lr_nw_adj_eff=`beta3' if study_id==7 & time_tranche==1
replace lr_nw_adj_se=`se3' if study_id==7 & time_tranche==1
replace lr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==7 & time_tranche==1
replace lr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==7 & time_tranche==1

replace lr_une_adj_eff=`beta4' if study_id==7 & time_tranche==1
replace lr_une_adj_se=`se4' if study_id==7 & time_tranche==1
replace lr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==7 & time_tranche==1
replace lr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==7 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_adj_eff=`beta' if study_id==7 & time_tranche==1
replace lr_kw_adj_se=`se' if study_id==7 & time_tranche==1
replace lr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
replace lr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

*local beta2 = _b[2.home_working]
*local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

*replace lr_sm_adj_eff=`beta2' if study_id==7 & time_tranche==1
*replace lr_sm_adj_se=`se2' if study_id==7 & time_tranche==1
*replace lr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
*replace lr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1

replace lr_no_adj_eff=`beta3' if study_id==7 & time_tranche==1
replace lr_no_adj_se=`se3' if study_id==7 & time_tranche==1
replace lr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==7 & time_tranche==1
replace lr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==7 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult startvalues(constantonly)
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_adj_eff=`beta' if study_id==7 & time_tranche==1
replace lr_fr_adj_se=`se' if study_id==7 & time_tranche==1
replace lr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
replace lr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


clear



***************************************************
**GENERATION SCOTLAND 
***************************************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file - note testing info for Scotland not available
use "Genscot edited\Genscot edited long version.dta", clear



*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
*tab study_wave,

*sort llc_0007_stud_id study_wave
*merge 1:1 llc_0007_stud_id study_wave using "Genscot edited\protect_nhs_c19posinfect_temp_Genscotver"
*drop if _merge==2	


**Last min formatting
*replace c19positive=0 if c19positive==.
*label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
*label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2
*rename key_worker keyworker


**keep if aged older the 18 and under 65
keep if age>=18 & age<=65

** GEN SCOT - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq

**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
*tab c19positive	
*count if c19positive==1
*local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==8 & time_tranche==1
replace entry_n=`entry_n' if study_id==8 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==8 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==8 & time_tranche==1
*replace linkpos_no=`linkpos_no' if study_id==8 & time_tranche==1

list if study_id==8 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
*tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
*tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported  {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
*tab soc2010_1d `var', missing row
*tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}

replace furlough=0 if furlough==97 | furlough==99
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported  {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
*tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
*rename soc2010_1d soc_1d
*rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2000
*mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

*preserve 
*use "S:\LLC_0007\data\results_datafile time-tranche", clear
*forvalues i = 2(1)9 {
*replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==8 & time_tranche==1
*replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==8 & time_tranche==1

*}
*save "S:\LLC_0007\data\results_datafile time-tranche", replace
*restore 

*mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*preserve 
*use "S:\LLC_0007\data\results_datafile time-tranche", clear
*foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
*replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==8 & time_tranche==1
*replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==8 & time_tranche==1
*}
*save "S:\LLC_0007\data\results_datafile time-tranche", replace
*restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult



*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19infection_selfreported i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]	

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_eff=`beta' if study_id==8 & time_tranche==1
replace sr_re_se=`se' if study_id==8 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==8 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==8 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==8 & time_tranche==1
replace sr_un_se=`se2' if study_id==8 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==8 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==8 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**employment_status	
mepoisson c19infection_selfreported i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*local beta = _b[1.employment_status]
*local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

*replace sr_pt_eff=`beta' if study_id==8 & time_tranche==1
*replace sr_pt_se=`se' if study_id==8 & time_tranche==1
*replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==8 & time_tranche==1
*replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==8 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==8 & time_tranche==1
replace sr_ret_se=`se2' if study_id==8 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==8 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==8 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==8 & time_tranche==1
replace sr_nw_se=`se3' if study_id==8 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==8 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==8 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==8 & time_tranche==1
replace sr_une_se=`se4' if study_id==8 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==8 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==8 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_eff=`beta' if study_id==8 & time_tranche==1
replace sr_kw_se=`se' if study_id==8 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==8 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==8 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_eff=`beta2' if study_id==8 & time_tranche==1
replace sr_sm_se=`se2' if study_id==8 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==8 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==8 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==8 & time_tranche==1
replace sr_no_se=`se3' if study_id==8 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==8 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==8 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_eff=`beta' if study_id==8 & time_tranche==1
replace sr_fr_se=`se' if study_id==8 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==8 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==8 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

	

****Repeated Adjusted for key confounders - missing i.deprivation i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19


**employment status
mepoisson c19infection_selfreported i.employment i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_adj_eff=`beta' if study_id==8 & time_tranche==1
replace sr_re_adj_se=`se' if study_id==8 & time_tranche==1
replace sr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==8 & time_tranche==1
replace sr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==8 & time_tranche==1

replace sr_un_adj_eff=`beta2' if study_id==8 & time_tranche==1
replace sr_un_adj_se=`se2' if study_id==8 & time_tranche==1
replace sr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==8 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==8 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*local beta = _b[1.employment_status]
*local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

*replace sr_pt_adj_eff=`beta' if study_id==8 & time_tranche==1
*replace sr_pt_adj_se=`se' if study_id==8 & time_tranche==1
*replace sr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==8 & time_tranche==1
*replace sr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==8 & time_tranche==1

replace sr_ret_adj_eff=`beta2' if study_id==8 & time_tranche==1
replace sr_ret_adj_se=`se2' if study_id==8 & time_tranche==1
replace sr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==8 & time_tranche==1
replace sr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==8 & time_tranche==1

replace sr_nw_adj_eff=`beta3' if study_id==8 & time_tranche==1
replace sr_nw_adj_se=`se3' if study_id==8 & time_tranche==1
replace sr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==8 & time_tranche==1
replace sr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==8 & time_tranche==1

replace sr_une_adj_eff=`beta4' if study_id==8 & time_tranche==1
replace sr_une_adj_se=`se4' if study_id==8 & time_tranche==1
replace sr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==8 & time_tranche==1
replace sr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==8 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_adj_eff=`beta' if study_id==8 & time_tranche==1
replace sr_kw_adj_se=`se' if study_id==8 & time_tranche==1
replace sr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==8 & time_tranche==1
replace sr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==8 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_adj_eff=`beta2' if study_id==8 & time_tranche==1
replace sr_sm_adj_se=`se2' if study_id==8 & time_tranche==1
replace sr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==8 & time_tranche==1
replace sr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==8 & time_tranche==1

replace sr_no_adj_eff=`beta3' if study_id==8 & time_tranche==1
replace sr_no_adj_se=`se3' if study_id==8 & time_tranche==1
replace sr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==8 & time_tranche==1
replace sr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==8 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_adj_eff=`beta' if study_id==8 & time_tranche==1
replace sr_fr_adj_se=`se' if study_id==8 & time_tranche==1
replace sr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==8 & time_tranche==1
replace sr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==8 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



clear





*******************************
**The Extended Cohort for E-health, Envirnoment, and DNA (EXCEED)" if study_id==9
*******************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "exceed edited\exceed edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,
tostring avail_from_dt, replace 

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "exceed edited\protect_nhs_c19posinfect_temp_exceedver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/07/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/11/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/07/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/11/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/07/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/11/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/07/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/11/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/04/2021", "DMY") & study_wave==3


tab study_wave vacc_status


**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2
*rename key_worker keyworker


** exceed - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq

**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==9 & time_tranche==1
replace entry_n=`entry_n' if study_id==9 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==9 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==9 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==9 & time_tranche==1

list if study_id==9 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
tab soc2010_1d `var', missing row
tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
*tab employment_status `var', missing row

**Home working	
*tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
*tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


tab employment 
*tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
rename soc2010_1d soc_1d
rename soc2010_2d soc_2d
replace soc_2d=. if soc_2d<0
***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult
preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==9 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==9 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==9 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==9 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19infection_selfreported i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_eff=`beta' if study_id==9 & time_tranche==1
replace sr_re_se=`se' if study_id==9 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==9 & time_tranche==1
replace sr_un_se=`se2' if study_id==9 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==9 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==9 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 





**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_eff=`beta' if study_id==9 & time_tranche==1
replace sr_kw_se=`se' if study_id==9 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 




**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_eff=`beta' if study_id==9 & time_tranche==1
replace sr_fr_se=`se' if study_id==9 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==9 & time_tranche==1
replace lr_s101d`i'_se=_se[`i'.soc_1d] if study_id==9 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==9 & time_tranche==1
replace lr_s102d`i'_se=_se[`i'.soc_2d] if study_id==9 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_eff=`beta' if study_id==9 & time_tranche==1
replace lr_re_se=`se' if study_id==9 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==9 & time_tranche==1
replace lr_un_se=`se2' if study_id==9 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==9 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==9 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_eff=`beta' if study_id==9 & time_tranche==1
replace lr_kw_se=`se' if study_id==9 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_eff=`beta' if study_id==9 & time_tranche==1
replace lr_fr_se=`se' if study_id==9 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19 
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==9 & time_tranche==1
replace sr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==9 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==9 & time_tranche==1
replace sr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==9 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_adj_eff=`beta' if study_id==9 & time_tranche==1
replace sr_re_adj_se=`se' if study_id==9 & time_tranche==1
replace sr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace sr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1

replace sr_un_adj_eff=`beta2' if study_id==9 & time_tranche==1
replace sr_un_adj_se=`se2' if study_id==9 & time_tranche==1
replace sr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==9 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==9 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 




**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_adj_eff=`beta' if study_id==9 & time_tranche==1
replace sr_kw_adj_se=`se' if study_id==9 & time_tranche==1
replace sr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace sr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_adj_eff=`beta' if study_id==9 & time_tranche==1
replace sr_fr_adj_se=`se' if study_id==9 & time_tranche==1
replace sr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace sr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==9 & time_tranche==1
replace lr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==9 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==9 & time_tranche==1
replace lr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==9 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_adj_eff=`beta' if study_id==9 & time_tranche==1
replace lr_re_adj_se=`se' if study_id==9 & time_tranche==1
replace lr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace lr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1

replace lr_un_adj_eff=`beta2' if study_id==9 & time_tranche==1
replace lr_un_adj_se=`se2' if study_id==9 & time_tranche==1
replace lr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==9 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==9 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_adj_eff=`beta' if study_id==9 & time_tranche==1
replace lr_kw_adj_se=`se' if study_id==9 & time_tranche==1
replace lr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace lr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**Furlough
mepoisson c19positive i.furlough i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_adj_eff=`beta' if study_id==9 & time_tranche==1
replace lr_fr_adj_se=`se' if study_id==9 & time_tranche==1
replace lr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace lr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


clear





******************************************************************************
**NORTHERN IRELAND COHORT FOR THE LONGITUDINAL STUDY OF AGEING (NICOLA) - Study_id==10
******************************************************************************

**notes - no NHS linked data for northern ireland, no sex or ethnicity data, no home_working or soc data
**no information on when covid occurred so no time_tranche data

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "nicola edited\nicola edited long version.dta", clear

drop if age_entry>=5

*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
*tab study_wave,
*tostring avail_from_dt, replace 

*sort llc_0007_stud_id study_wave
*merge 1:1 llc_0007_stud_id study_wave using "nicola edited\protect_nhs_c19posinfect_temp_nicolaver"
*drop if _merge==2	


**Last min formatting
*replace c19positive=0 if c19positive==.
*label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
*label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2
*rename key_worker keyworker


** nicola - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq

**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
*tab c19positive	
*count if c19positive==1
*local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==10 & time_tranche==1
replace entry_n=`entry_n' if study_id==10 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==10 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==10 & time_tranche==1
*replace linkpos_no=`linkpos_no' if study_id==10 & time_tranche==1

list if study_id==10 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
*tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
*tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
*tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
*tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
*tab soc2010_1d `var', missing row
*tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
*tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported {

*tab sex `var', missing row
*tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
*tab housing_composition  `var', missing row
tab household_size  `var', missing row
tab livepartner  `var', missing row
tab housing_tenure  `var', missing row
tab education  `var', missing row


}


tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
*rename soc2010_1d soc_1d
*rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19


**employment
mepoisson c19infection_selfreported i.employment   || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_eff=`beta' if study_id==10 & time_tranche==1
replace sr_re_se=`se' if study_id==10 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==10 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==10 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==10 & time_tranche==1
replace sr_un_se=`se2' if study_id==10 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==10 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==10 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**employment_status	
mepoisson c19infection_selfreported i.employment_status   || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_eff=`beta' if study_id==10 & time_tranche==1
replace sr_pt_se=`se' if study_id==10 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==10 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==10 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==10 & time_tranche==1
replace sr_ret_se=`se2' if study_id==10 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==10 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==10 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==10 & time_tranche==1
replace sr_nw_se=`se3' if study_id==10 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==10 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==10 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==10 & time_tranche==1
replace sr_une_se=`se4' if study_id==10 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==10 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==10 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Key worker	
mepoisson c19infection_selfreported i.keyworker  if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_eff=`beta' if study_id==10 & time_tranche==1
replace sr_kw_se=`se' if study_id==10 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==10 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==10 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	




**Furlough
mepoisson c19infection_selfreported i.furlough  if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_eff=`beta' if study_id==10 & time_tranche==1
replace sr_fr_se=`se' if study_id==10 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==10 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==10 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

	

****Repeated Adjusted for key confounders - missing i.deprivation i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000


**employment status
mepoisson c19infection_selfreported i.employment i.age_entry      || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_adj_eff=`beta' if study_id==10 & time_tranche==1
replace sr_re_adj_se=`se' if study_id==10 & time_tranche==1
replace sr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==10 & time_tranche==1
replace sr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==10 & time_tranche==1

replace sr_un_adj_eff=`beta2' if study_id==10 & time_tranche==1
replace sr_un_adj_se=`se2' if study_id==10 & time_tranche==1
replace sr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==10 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==10 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.age_entry      || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_adj_eff=`beta' if study_id==10 & time_tranche==1
replace sr_pt_adj_se=`se' if study_id==10 & time_tranche==1
replace sr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==10 & time_tranche==1
replace sr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==10 & time_tranche==1

replace sr_ret_adj_eff=`beta2' if study_id==10 & time_tranche==1
replace sr_ret_adj_se=`se2' if study_id==10 & time_tranche==1
replace sr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==10 & time_tranche==1
replace sr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==10 & time_tranche==1

replace sr_nw_adj_eff=`beta3' if study_id==10 & time_tranche==1
replace sr_nw_adj_se=`se3' if study_id==10 & time_tranche==1
replace sr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==10 & time_tranche==1
replace sr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==10 & time_tranche==1

replace sr_une_adj_eff=`beta4' if study_id==10 & time_tranche==1
replace sr_une_adj_se=`se4' if study_id==10 & time_tranche==1
replace sr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==10 & time_tranche==1
replace sr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==10 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.age_entry     if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_adj_eff=`beta' if study_id==10 & time_tranche==1
replace sr_kw_adj_se=`se' if study_id==10 & time_tranche==1
replace sr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==10 & time_tranche==1
replace sr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==10 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	


**Furlough
mepoisson c19infection_selfreported i.furlough i.age_entry     if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_adj_eff=`beta' if study_id==10 & time_tranche==1
replace sr_fr_adj_se=`se' if study_id==10 & time_tranche==1
replace sr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==10 & time_tranche==1
replace sr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==10 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



clear

*******************************
**COVID19 Psychiatry and Neurological Genetics (COPING) study study_id==11
*******************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "coping edited\coping edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "coping edited\protect_nhs_c19posinfect_temp_copingver"
drop if _merge==2	


**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 




** coping - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq

**tab self-reported infection 
*tab c19infection_selfreported
*count if c19infection_selfreported==1
*local selfinf_n = r(N)
**tab NHS digital indicated infection
*tab c19postest_selfreported	
*count if c19postest_selfreported==1
*local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==11 & time_tranche==1
replace entry_n=`entry_n' if study_id==11 & time_tranche==1
*replace selfinf_n=`selfinf_n' if study_id==11 & time_tranche==1
*replace selfpos_no=`selfpos_no' if study_id==11 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==11 & time_tranche==1

list if study_id==11 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace

restore

**by study wave
**tab self-reported infection 
*tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
*tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
*tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
*tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
*tab soc2010_1d `var', missing row
*tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
**tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19positive {

tab sex `var', missing row
tab ethnicity_red `var', missing row
*tab deprivation_imd  `var', missing row
tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
*tab housing_composition  `var', missing row


}


tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
*rename soc2010_1d soc_1d
*rename soc2010_2d soc_2d

***INITIAL ANALYSIS

	
**test positive C19
**employment status
mepoisson c19positive i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_eff=`beta' if study_id==11 & time_tranche==1
replace lr_re_se=`se' if study_id==11 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==11 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==11 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==11 & time_tranche==1
replace lr_un_se=`se2' if study_id==11 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==11 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==11 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_eff=`beta' if study_id==11 & time_tranche==1
replace lr_pt_se=`se' if study_id==11 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==11 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==11 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==11 & time_tranche==1
replace lr_ret_se=`se2' if study_id==11 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==11 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==11 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==11 & time_tranche==1
replace lr_nw_se=`se3' if study_id==11 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==11 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==11 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==11 & time_tranche==1
replace lr_une_se=`se4' if study_id==11 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==11 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==11 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_eff=`beta' if study_id==11 & time_tranche==1
replace lr_kw_se=`se' if study_id==11 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==11 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==11 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 




**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_eff=`beta' if study_id==11 & time_tranche==1
replace lr_fr_se=`se' if study_id==11 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==11 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==11 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation i.hm_location
***INITIAL ANALYSIS


	
**test positive C19
**employment
mepoisson c19positive i.employment i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_adj_eff=`beta' if study_id==11 & time_tranche==1
replace lr_re_adj_se=`se' if study_id==11 & time_tranche==1
replace lr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==11 & time_tranche==1
replace lr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==11 & time_tranche==1

replace lr_un_adj_eff=`beta2' if study_id==11 & time_tranche==1
replace lr_un_adj_se=`se2' if study_id==11 & time_tranche==1
replace lr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==11 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==11 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_adj_eff=`beta' if study_id==11 & time_tranche==1
replace lr_pt_adj_se=`se' if study_id==11 & time_tranche==1
replace lr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==11 & time_tranche==1
replace lr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==11 & time_tranche==1

replace lr_ret_adj_eff=`beta2' if study_id==11 & time_tranche==1
replace lr_ret_adj_se=`se2' if study_id==11 & time_tranche==1
replace lr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==11 & time_tranche==1
replace lr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==11 & time_tranche==1

replace lr_nw_adj_eff=`beta3' if study_id==11 & time_tranche==1
replace lr_nw_adj_se=`se3' if study_id==11 & time_tranche==1
replace lr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==11 & time_tranche==1
replace lr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==11 & time_tranche==1

replace lr_une_adj_eff=`beta4' if study_id==11 & time_tranche==1
replace lr_une_adj_se=`se4' if study_id==11 & time_tranche==1
replace lr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==11 & time_tranche==1
replace lr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==11 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_adj_eff=`beta' if study_id==11 & time_tranche==1
replace lr_kw_adj_se=`se' if study_id==11 & time_tranche==1
replace lr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==11 & time_tranche==1
replace lr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==11 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 





**Furlough
mepoisson c19positive i.furlough i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_adj_eff=`beta' if study_id==11 & time_tranche==1
replace lr_fr_adj_se=`se' if study_id==11 & time_tranche==1
replace lr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==11 & time_tranche==1
replace lr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==11 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


clear






*******************************
**THE GENETIC LINKS TO ANXIETY AND DEPRESSION (GLAD) study_id==12
*******************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "glad edited\glad edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "glad edited\protect_nhs_c19posinfect_temp_gladver"
drop if _merge==2	


**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 




** glad - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq

**tab self-reported infection 
*tab c19infection_selfreported
*count if c19infection_selfreported==1
*local selfinf_n = r(N)
**tab NHS digital indicated infection
*tab c19postest_selfreported	
*count if c19postest_selfreported==1
*local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==12 & time_tranche==1
replace entry_n=`entry_n' if study_id==12 & time_tranche==1
*replace selfinf_n=`selfinf_n' if study_id==12 & time_tranche==1
*replace selfpos_no=`selfpos_no' if study_id==12 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==12 & time_tranche==1

list if study_id==12 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace

restore

**by study wave
**tab self-reported infection 
*tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
*tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
*tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
*tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
*tab soc2010_1d `var', missing row
*tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
**tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19positive {

tab sex `var', missing row
tab ethnicity_red `var', missing row
*tab deprivation_imd  `var', missing row
tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
*tab housing_composition  `var', missing row


}


tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
*rename soc2010_1d soc_1d
*rename soc2010_2d soc_2d

***INITIAL ANALYSIS

	
**test positive C19
**employment status
mepoisson c19positive i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_eff=`beta' if study_id==12 & time_tranche==1
replace lr_re_se=`se' if study_id==12 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==12 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==12 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==12 & time_tranche==1
replace lr_un_se=`se2' if study_id==12 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==12 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==12 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_eff=`beta' if study_id==12 & time_tranche==1
replace lr_pt_se=`se' if study_id==12 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==12 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==12 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==12 & time_tranche==1
replace lr_ret_se=`se2' if study_id==12 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==12 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==12 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==12 & time_tranche==1
replace lr_nw_se=`se3' if study_id==12 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==12 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==12 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==12 & time_tranche==1
replace lr_une_se=`se4' if study_id==12 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==12 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==12 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_eff=`beta' if study_id==12 & time_tranche==1
replace lr_kw_se=`se' if study_id==12 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==12 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==12 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 




**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_eff=`beta' if study_id==12 & time_tranche==1
replace lr_fr_se=`se' if study_id==12 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==12 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==12 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation i.hm_location
***INITIAL ANALYSIS


	
**test positive C19
**employment
mepoisson c19positive i.employment i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_adj_eff=`beta' if study_id==12 & time_tranche==1
replace lr_re_adj_se=`se' if study_id==12 & time_tranche==1
replace lr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==12 & time_tranche==1
replace lr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==12 & time_tranche==1

replace lr_un_adj_eff=`beta2' if study_id==12 & time_tranche==1
replace lr_un_adj_se=`se2' if study_id==12 & time_tranche==1
replace lr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==12 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==12 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_adj_eff=`beta' if study_id==12 & time_tranche==1
replace lr_pt_adj_se=`se' if study_id==12 & time_tranche==1
replace lr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==12 & time_tranche==1
replace lr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==12 & time_tranche==1

replace lr_ret_adj_eff=`beta2' if study_id==12 & time_tranche==1
replace lr_ret_adj_se=`se2' if study_id==12 & time_tranche==1
replace lr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==12 & time_tranche==1
replace lr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==12 & time_tranche==1

replace lr_nw_adj_eff=`beta3' if study_id==12 & time_tranche==1
replace lr_nw_adj_se=`se3' if study_id==12 & time_tranche==1
replace lr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==12 & time_tranche==1
replace lr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==12 & time_tranche==1

replace lr_une_adj_eff=`beta4' if study_id==12 & time_tranche==1
replace lr_une_adj_se=`se4' if study_id==12 & time_tranche==1
replace lr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==12 & time_tranche==1
replace lr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==12 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_adj_eff=`beta' if study_id==12 & time_tranche==1
replace lr_kw_adj_se=`se' if study_id==12 & time_tranche==1
replace lr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==12 & time_tranche==1
replace lr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==12 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 





**Furlough
mepoisson c19positive i.furlough i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_adj_eff=`beta' if study_id==12 & time_tranche==1
replace lr_fr_adj_se=`se' if study_id==12 & time_tranche==1
replace lr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==12 & time_tranche==1
replace lr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==12 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


clear



*******************************
**TRACK COVID 19 -  NO EMPLOYMENT DATA STUDY_ID==13 
*******************************




*******************************
**TWINS UK Study_id==14 - RETURN TO COMPLETE ONCE NEW VERSION OF DATA IS AVAILABLE 
*******************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "twinsuk edited\twinsuk edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,
*tostring avail_from_dt, replace 
*drop _merge
sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "twinsuk edited\protect_nhs_c19posinfect_temp_twinsukver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/09/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/12/2020", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/09/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/12/2020", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/09/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/12/2020", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/09/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/12/2020", "DMY") & study_wave==3


tab study_wave vacc_status



**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2

drop if age>65


** twinsuk - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq

**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==14 & time_tranche==1
replace entry_n=`entry_n' if study_id==14 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==14 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==14 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==14 & time_tranche==1

list if study_id==14 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
*tab soc2010_1d `var', missing row
*tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
*tab employment `var', missing row
	
*tab employment_status `var', missing row

**Home working	
*tab home_working `var', missing row

**Furlough
*tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
*tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


*tab employment 
*tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
*rename soc2010_1d soc_1d
*rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_eff=`beta' if study_id==14 & time_tranche==1
replace sr_kw_se=`se' if study_id==14 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==14 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==14 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



	
**test positive C19


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_eff=`beta' if study_id==14 & time_tranche==1
replace lr_kw_se=`se' if study_id==14 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==14 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==14 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 





****Repeated Adjusted for key confounders - missing i.deprivation i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.age_entry i.ethnicity_red i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_adj_eff=`beta' if study_id==14 & time_tranche==1
replace sr_kw_adj_se=`se' if study_id==14 & time_tranche==1
replace sr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==14 & time_tranche==1
replace sr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==14 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



	
**test positive C19


**Key worker	
mepoisson c19positive i.keyworker i.sex i.age_entry i.ethnicity_red i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult startvalues(constantonly)
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_adj_eff=`beta' if study_id==14 & time_tranche==1
replace lr_kw_adj_se=`se' if study_id==14 & time_tranche==1
replace lr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==14 & time_tranche==1
replace lr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==14 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



clear





*******************************
**THE AVON LONGITUDINAL STUDY OF PARENTS AND CHILDREN (ALSPAC) - Study_id==15
*******************************

***RETURN TO CHECK THE LINKED DATA ONCE AVAILABLE

**study_id==15

**NO LINK TO NHS TESTING DATA CHECK WITH LLC (START THIS SECTION AGAIN)

**Open and merge NHS data with UKHLS file
use "alspac edited\alspac edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,


sort llc_0007_stud_id study_wave
*drop _merge
merge m:1 llc_0007_stud_id study_wave using "alspac edited\protect_nhs_c19posinfect_temp_alspacver"
drop if _merge==2	


**Modify the self-reported data as appears to be have you had covid at anytime not since last wave
**Readjusted so can only have covid once
tab study_wave c19infection_selfreported 
tab pandemic_timetranche c19infection_selfreported 
sort study_wave
replace c19infection_selfreported=0 if c19infection_selfreported[_n-1]==1  & study_wave>1
replace c19infection_selfreported=0 if c19infection_selfreported[_n-2]==1  & study_wave>2
replace c19infection_selfreported=0 if c19infection_selfreported[_n-3]==1  & study_wave>3
tab study_wave c19infection_selfreported 
tab pandemic_timetranche c19infection_selfreported 

tab study_wave c19postest_selfreported 
tab pandemic_timetranche c19postest_selfreported 
replace c19postest_selfreported=0 if c19postest_selfreported[_n-1]==1  & study_wave>1
replace c19postest_selfreported=0 if c19postest_selfreported[_n-2]==1  & study_wave>2
replace c19postest_selfreported=0 if c19postest_selfreported[_n-3]==1  & study_wave>3
tab study_wave c19postest_selfreported 
tab pandemic_timetranche c19postest_selfreported 


**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2

drop if age>65

** BCS1970 - descriptive statistics
quietly tab llc_0007_stud_id
return list
local sample_n =  r(r)
local entry_n =  r(N)


**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==15 & time_tranche==1
replace entry_n=`entry_n' if study_id==15 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==15 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==15 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==15 & time_tranche==1

list if study_id==15 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
*tab soc2010_1d `var', missing row
*tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}

numlabel, add

tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
*rename soc2010_1d soc_1d
*rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2010
**1 digit
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==15 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==15 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==15 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==15 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 
	



**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult



**employment
mepoisson c19infection_selfreported i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_eff=`beta' if study_id==15 & time_tranche==1
replace sr_re_se=`se' if study_id==15 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==15 & time_tranche==1
replace sr_un_se=`se2' if study_id==15 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


tab employment_status c19infection_selfreported

**employment_status	
mepoisson c19infection_selfreported i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_eff=`beta' if study_id==15 & time_tranche==1
replace sr_pt_se=`se' if study_id==15 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==15 & time_tranche==1
replace sr_ret_se=`se2' if study_id==15 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==15 & time_tranche==1
replace sr_nw_se=`se3' if study_id==15 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==15 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==15 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==15 & time_tranche==1
replace sr_une_se=`se4' if study_id==15 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==15 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==15 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

tab keyworker

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_eff=`beta' if study_id==15 & time_tranche==1
replace sr_kw_se=`se' if study_id==15 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_eff=`beta2' if study_id==15 & time_tranche==1
replace sr_sm_se=`se2' if study_id==15 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==15 & time_tranche==1
replace sr_no_se=`se3' if study_id==15 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==15 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==15 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_eff=`beta' if study_id==15 & time_tranche==1
replace sr_fr_se=`se' if study_id==15 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==15 & time_tranche==1
replace lr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==15 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==15 & time_tranche==1
replace lr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==15 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_eff=`beta' if study_id==15 & time_tranche==1
replace lr_re_se=`se' if study_id==15 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==15 & time_tranche==1
replace lr_un_se=`se2' if study_id==15 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_eff=`beta' if study_id==15 & time_tranche==1
replace lr_pt_se=`se' if study_id==15 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==15 & time_tranche==1
replace lr_ret_se=`se2' if study_id==15 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==15 & time_tranche==1
replace lr_nw_se=`se3' if study_id==15 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==15 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==15 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==15 & time_tranche==1
replace lr_une_se=`se4' if study_id==15 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==15 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==15 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_eff=`beta' if study_id==15 & time_tranche==1
replace lr_kw_se=`se' if study_id==15 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19positive i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_eff=`beta2' if study_id==15 & time_tranche==1
replace lr_sm_se=`se2' if study_id==15 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==15 & time_tranche==1
replace lr_no_se=`se3' if study_id==15 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==15 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==15 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_eff=`beta' if study_id==15 & time_tranche==1
replace lr_fr_se=`se' if study_id==15 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==15 & time_tranche==1
replace sr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==15 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==15 & time_tranche==1
replace sr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==15 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_adj_eff=`beta' if study_id==15 & time_tranche==1
replace sr_re_adj_se=`se' if study_id==15 & time_tranche==1
replace sr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace sr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1

replace sr_un_adj_eff=`beta2' if study_id==15 & time_tranche==1
replace sr_un_adj_se=`se2' if study_id==15 & time_tranche==1
replace sr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_adj_eff=`beta' if study_id==15 & time_tranche==1
replace sr_pt_adj_se=`se' if study_id==15 & time_tranche==1
replace sr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace sr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1

replace sr_ret_adj_eff=`beta2' if study_id==15 & time_tranche==1
replace sr_ret_adj_se=`se2' if study_id==15 & time_tranche==1
replace sr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace sr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1

replace sr_nw_adj_eff=`beta3' if study_id==15 & time_tranche==1
replace sr_nw_adj_se=`se3' if study_id==15 & time_tranche==1
replace sr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==15 & time_tranche==1
replace sr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==15 & time_tranche==1

replace sr_une_adj_eff=`beta4' if study_id==15 & time_tranche==1
replace sr_une_adj_se=`se4' if study_id==15 & time_tranche==1
replace sr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==15 & time_tranche==1
replace sr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==15 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_adj_eff=`beta' if study_id==15 & time_tranche==1
replace sr_kw_adj_se=`se' if study_id==15 & time_tranche==1
replace sr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace sr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_adj_eff=`beta2' if study_id==15 & time_tranche==1
replace sr_sm_adj_se=`se2' if study_id==15 & time_tranche==1
replace sr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace sr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1

replace sr_no_adj_eff=`beta3' if study_id==15 & time_tranche==1
replace sr_no_adj_se=`se3' if study_id==15 & time_tranche==1
replace sr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==15 & time_tranche==1
replace sr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==15 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_adj_eff=`beta' if study_id==15 & time_tranche==1
replace sr_fr_adj_se=`se' if study_id==15 & time_tranche==1
replace sr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace sr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==15 & time_tranche==1
replace lr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==15 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==15 & time_tranche==1
replace lr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==15 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_adj_eff=`beta' if study_id==15 & time_tranche==1
replace lr_re_adj_se=`se' if study_id==15 & time_tranche==1
replace lr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace lr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1

replace lr_un_adj_eff=`beta2' if study_id==15 & time_tranche==1
replace lr_un_adj_se=`se2' if study_id==15 & time_tranche==1
replace lr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_adj_eff=`beta' if study_id==15 & time_tranche==1
replace lr_pt_adj_se=`se' if study_id==15 & time_tranche==1
replace lr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace lr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1

replace lr_ret_adj_eff=`beta2' if study_id==15 & time_tranche==1
replace lr_ret_adj_se=`se2' if study_id==15 & time_tranche==1
replace lr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace lr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1

replace lr_nw_adj_eff=`beta3' if study_id==15 & time_tranche==1
replace lr_nw_adj_se=`se3' if study_id==15 & time_tranche==1
replace lr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==15 & time_tranche==1
replace lr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==15 & time_tranche==1

replace lr_une_adj_eff=`beta4' if study_id==15 & time_tranche==1
replace lr_une_adj_se=`se4' if study_id==15 & time_tranche==1
replace lr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==15 & time_tranche==1
replace lr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==15 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_adj_eff=`beta' if study_id==15 & time_tranche==1
replace lr_kw_adj_se=`se' if study_id==15 & time_tranche==1
replace lr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace lr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_adj_eff=`beta2' if study_id==15 & time_tranche==1
replace lr_sm_adj_se=`se2' if study_id==15 & time_tranche==1
replace lr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace lr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1

replace lr_no_adj_eff=`beta3' if study_id==15 & time_tranche==1
replace lr_no_adj_se=`se3' if study_id==15 & time_tranche==1
replace lr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==15 & time_tranche==1
replace lr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==15 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_adj_eff=`beta' if study_id==15 & time_tranche==1
replace lr_fr_adj_se=`se' if study_id==15 & time_tranche==1
replace lr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace lr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


clear










*******************************
**THE  MILLENIUM COHORT - cohort members only - study_id==16
*******************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "MCS edited\MCS edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,
tostring avail_from_dt, replace 

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "MCS edited\protect_nhs_c19posinfect_temp_mcsver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/04/2021", "DMY") & study_wave==3


tab study_wave vacc_status



**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2
rename key_worker keyworker


** MCS - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq


***KEEP IF COHORT MEMBERS AND NOT COHORT MEMBERS PARENTS

keep if cohort==4


**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==16 & time_tranche==1
replace entry_n=`entry_n' if study_id==16 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==16 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==16 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==16 & time_tranche==1

list if study_id==16 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
tab soc2010_1d `var', missing row
tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
*tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
rename soc2010_1d soc_1d
rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult
preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==16 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==16 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==16 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==16 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19infection_selfreported i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_eff=`beta' if study_id==16 & time_tranche==1
replace sr_re_se=`se' if study_id==16 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==16 & time_tranche==1
replace sr_un_se=`se2' if study_id==16 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**employment_status	
mepoisson c19infection_selfreported i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_eff=`beta' if study_id==16 & time_tranche==1
replace sr_pt_se=`se' if study_id==16 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==16 & time_tranche==1
replace sr_ret_se=`se2' if study_id==16 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==16 & time_tranche==1
replace sr_nw_se=`se3' if study_id==16 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==16 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==16 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==16 & time_tranche==1
replace sr_une_se=`se4' if study_id==16 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==16 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==16 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_eff=`beta' if study_id==16 & time_tranche==1
replace sr_kw_se=`se' if study_id==16 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_eff=`beta2' if study_id==16 & time_tranche==1
replace sr_sm_se=`se2' if study_id==16 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==16 & time_tranche==1
replace sr_no_se=`se3' if study_id==16 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==16 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==16 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_eff=`beta' if study_id==16 & time_tranche==1
replace sr_fr_se=`se' if study_id==16 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==16 & time_tranche==1
replace lr_s101d`i'_se=_se[`i'.soc_1d] if study_id==16 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==16 & time_tranche==1
replace lr_s102d`i'_se=_se[`i'.soc_2d] if study_id==16 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_eff=`beta' if study_id==16 & time_tranche==1
replace lr_re_se=`se' if study_id==16 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==16 & time_tranche==1
replace lr_un_se=`se2' if study_id==16 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status i.cohort i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_eff=`beta' if study_id==16 & time_tranche==1
replace lr_pt_se=`se' if study_id==16 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==16 & time_tranche==1
replace lr_ret_se=`se2' if study_id==16 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==16 & time_tranche==1
replace lr_nw_se=`se3' if study_id==16 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==16 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==16 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==16 & time_tranche==1
replace lr_une_se=`se4' if study_id==16 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==16 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==16 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_eff=`beta' if study_id==16 & time_tranche==1
replace lr_kw_se=`se' if study_id==16 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19positive i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_eff=`beta2' if study_id==16 & time_tranche==1
replace lr_sm_se=`se2' if study_id==16 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==16 & time_tranche==1
replace lr_no_se=`se3' if study_id==16 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==16 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==16 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_eff=`beta' if study_id==16 & time_tranche==1
replace lr_fr_se=`se' if study_id==16 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.ethnicity_red i.cohort i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==16 & time_tranche==1
replace sr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==16 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==16 & time_tranche==1
replace sr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==16 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.ethnicity_red i.cohort i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_adj_eff=`beta' if study_id==16 & time_tranche==1
replace sr_re_adj_se=`se' if study_id==16 & time_tranche==1
replace sr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace sr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1

replace sr_un_adj_eff=`beta2' if study_id==16 & time_tranche==1
replace sr_un_adj_se=`se2' if study_id==16 & time_tranche==1
replace sr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.ethnicity_red i.cohort i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_adj_eff=`beta' if study_id==16 & time_tranche==1
replace sr_pt_adj_se=`se' if study_id==16 & time_tranche==1
replace sr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace sr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1

replace sr_ret_adj_eff=`beta2' if study_id==16 & time_tranche==1
replace sr_ret_adj_se=`se2' if study_id==16 & time_tranche==1
replace sr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace sr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1

replace sr_nw_adj_eff=`beta3' if study_id==16 & time_tranche==1
replace sr_nw_adj_se=`se3' if study_id==16 & time_tranche==1
replace sr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==16 & time_tranche==1
replace sr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==16 & time_tranche==1

replace sr_une_adj_eff=`beta4' if study_id==16 & time_tranche==1
replace sr_une_adj_se=`se4' if study_id==16 & time_tranche==1
replace sr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==16 & time_tranche==1
replace sr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==16 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.ethnicity_red i.cohort i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_adj_eff=`beta' if study_id==16 & time_tranche==1
replace sr_kw_adj_se=`se' if study_id==16 & time_tranche==1
replace sr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace sr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.ethnicity_red i.cohort i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_adj_eff=`beta2' if study_id==16 & time_tranche==1
replace sr_sm_adj_se=`se2' if study_id==16 & time_tranche==1
replace sr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace sr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1

replace sr_no_adj_eff=`beta3' if study_id==16 & time_tranche==1
replace sr_no_adj_se=`se3' if study_id==16 & time_tranche==1
replace sr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==16 & time_tranche==1
replace sr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==16 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.ethnicity_red i.cohort i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_adj_eff=`beta' if study_id==16 & time_tranche==1
replace sr_fr_adj_se=`se' if study_id==16 & time_tranche==1
replace sr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace sr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.ethnicity_red i.cohort i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==16 & time_tranche==1
replace lr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==16 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==16 & time_tranche==1
replace lr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==16 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_adj_eff=`beta' if study_id==16 & time_tranche==1
replace lr_re_adj_se=`se' if study_id==16 & time_tranche==1
replace lr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace lr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1

replace lr_un_adj_eff=`beta2' if study_id==16 & time_tranche==1
replace lr_un_adj_se=`se2' if study_id==16 & time_tranche==1
replace lr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.ethnicity_red i.cohort i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_adj_eff=`beta' if study_id==16 & time_tranche==1
replace lr_pt_adj_se=`se' if study_id==16 & time_tranche==1
replace lr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace lr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1

replace lr_ret_adj_eff=`beta2' if study_id==16 & time_tranche==1
replace lr_ret_adj_se=`se2' if study_id==16 & time_tranche==1
replace lr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace lr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1

replace lr_nw_adj_eff=`beta3' if study_id==16 & time_tranche==1
replace lr_nw_adj_se=`se3' if study_id==16 & time_tranche==1
replace lr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==16 & time_tranche==1
replace lr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==16 & time_tranche==1

replace lr_une_adj_eff=`beta4' if study_id==16 & time_tranche==1
replace lr_une_adj_se=`se4' if study_id==16 & time_tranche==1
replace lr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==16 & time_tranche==1
replace lr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==16 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.ethnicity_red i.cohort i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_adj_eff=`beta' if study_id==16 & time_tranche==1
replace lr_kw_adj_se=`se' if study_id==16 & time_tranche==1
replace lr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace lr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.sex i.ethnicity_red i.cohort i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_adj_eff=`beta2' if study_id==16 & time_tranche==1
replace lr_sm_adj_se=`se2' if study_id==16 & time_tranche==1
replace lr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace lr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1

replace lr_no_adj_eff=`beta3' if study_id==16 & time_tranche==1
replace lr_no_adj_se=`se3' if study_id==16 & time_tranche==1
replace lr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==16 & time_tranche==1
replace lr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==16 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.ethnicity_red i.cohort i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_adj_eff=`beta' if study_id==16 & time_tranche==1
replace lr_fr_adj_se=`se' if study_id==16 & time_tranche==1
replace lr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace lr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


clear



*******************************
**THE  MILLENIUM COHORT - cohort members parents only - study_id==17
*******************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "MCS edited\MCS edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,
tostring avail_from_dt, replace 

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "MCS edited\protect_nhs_c19posinfect_temp_mcsver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/04/2021", "DMY") & study_wave==3


tab study_wave vacc_status



**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2
rename key_worker keyworker


** MCS - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq


***KEEP IF COHORT MEMBERS PARENT AND NOT COHORT MEMBER

keep if cohort==5


**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==17 & time_tranche==1
replace entry_n=`entry_n' if study_id==17 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==17 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==17 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==17 & time_tranche==1

list if study_id==17 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
tab soc2010_1d `var', missing row
tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
*tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
rename soc2010_1d soc_1d
rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult
preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==17 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==17 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==17 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==17 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19infection_selfreported i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_eff=`beta' if study_id==17 & time_tranche==1
replace sr_re_se=`se' if study_id==17 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==17 & time_tranche==1
replace sr_un_se=`se2' if study_id==17 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**employment_status	
mepoisson c19infection_selfreported i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_eff=`beta' if study_id==17 & time_tranche==1
replace sr_pt_se=`se' if study_id==17 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==17 & time_tranche==1
replace sr_ret_se=`se2' if study_id==17 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==17 & time_tranche==1
replace sr_nw_se=`se3' if study_id==17 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==17 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==17 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==17 & time_tranche==1
replace sr_une_se=`se4' if study_id==17 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==17 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==17 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_eff=`beta' if study_id==17 & time_tranche==1
replace sr_kw_se=`se' if study_id==17 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_eff=`beta2' if study_id==17 & time_tranche==1
replace sr_sm_se=`se2' if study_id==17 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==17 & time_tranche==1
replace sr_no_se=`se3' if study_id==17 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==17 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==17 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_eff=`beta' if study_id==17 & time_tranche==1
replace sr_fr_se=`se' if study_id==17 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==17 & time_tranche==1
replace lr_s101d`i'_se=_se[`i'.soc_1d] if study_id==17 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==17 & time_tranche==1
replace lr_s102d`i'_se=_se[`i'.soc_2d] if study_id==17 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_eff=`beta' if study_id==17 & time_tranche==1
replace lr_re_se=`se' if study_id==17 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==17 & time_tranche==1
replace lr_un_se=`se2' if study_id==17 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status i.cohort i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_eff=`beta' if study_id==17 & time_tranche==1
replace lr_pt_se=`se' if study_id==17 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==17 & time_tranche==1
replace lr_ret_se=`se2' if study_id==17 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==17 & time_tranche==1
replace lr_nw_se=`se3' if study_id==17 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==17 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==17 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==17 & time_tranche==1
replace lr_une_se=`se4' if study_id==17 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==17 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==17 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_eff=`beta' if study_id==17 & time_tranche==1
replace lr_kw_se=`se' if study_id==17 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19positive i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_eff=`beta2' if study_id==17 & time_tranche==1
replace lr_sm_se=`se2' if study_id==17 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==17 & time_tranche==1
replace lr_no_se=`se3' if study_id==17 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==17 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==17 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_eff=`beta' if study_id==17 & time_tranche==1
replace lr_fr_se=`se' if study_id==17 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.ethnicity_red i.cohort i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==17 & time_tranche==1
replace sr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==17 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==17 & time_tranche==1
replace sr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==17 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.ethnicity_red i.cohort i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_adj_eff=`beta' if study_id==17 & time_tranche==1
replace sr_re_adj_se=`se' if study_id==17 & time_tranche==1
replace sr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace sr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1

replace sr_un_adj_eff=`beta2' if study_id==17 & time_tranche==1
replace sr_un_adj_se=`se2' if study_id==17 & time_tranche==1
replace sr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.ethnicity_red i.cohort i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_adj_eff=`beta' if study_id==17 & time_tranche==1
replace sr_pt_adj_se=`se' if study_id==17 & time_tranche==1
replace sr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace sr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1

replace sr_ret_adj_eff=`beta2' if study_id==17 & time_tranche==1
replace sr_ret_adj_se=`se2' if study_id==17 & time_tranche==1
replace sr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace sr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1

replace sr_nw_adj_eff=`beta3' if study_id==17 & time_tranche==1
replace sr_nw_adj_se=`se3' if study_id==17 & time_tranche==1
replace sr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==17 & time_tranche==1
replace sr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==17 & time_tranche==1

replace sr_une_adj_eff=`beta4' if study_id==17 & time_tranche==1
replace sr_une_adj_se=`se4' if study_id==17 & time_tranche==1
replace sr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==17 & time_tranche==1
replace sr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==17 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.ethnicity_red i.cohort i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_adj_eff=`beta' if study_id==17 & time_tranche==1
replace sr_kw_adj_se=`se' if study_id==17 & time_tranche==1
replace sr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace sr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.ethnicity_red i.cohort i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_adj_eff=`beta2' if study_id==17 & time_tranche==1
replace sr_sm_adj_se=`se2' if study_id==17 & time_tranche==1
replace sr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace sr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1

replace sr_no_adj_eff=`beta3' if study_id==17 & time_tranche==1
replace sr_no_adj_se=`se3' if study_id==17 & time_tranche==1
replace sr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==17 & time_tranche==1
replace sr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==17 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.ethnicity_red i.cohort i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_adj_eff=`beta' if study_id==17 & time_tranche==1
replace sr_fr_adj_se=`se' if study_id==17 & time_tranche==1
replace sr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace sr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.ethnicity_red i.cohort i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==17 & time_tranche==1
replace lr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==17 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==17 & time_tranche==1
replace lr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==17 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.ethnicity_red i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_adj_eff=`beta' if study_id==17 & time_tranche==1
replace lr_re_adj_se=`se' if study_id==17 & time_tranche==1
replace lr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace lr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1

replace lr_un_adj_eff=`beta2' if study_id==17 & time_tranche==1
replace lr_un_adj_se=`se2' if study_id==17 & time_tranche==1
replace lr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.ethnicity_red i.cohort i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_adj_eff=`beta' if study_id==17 & time_tranche==1
replace lr_pt_adj_se=`se' if study_id==17 & time_tranche==1
replace lr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace lr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1

replace lr_ret_adj_eff=`beta2' if study_id==17 & time_tranche==1
replace lr_ret_adj_se=`se2' if study_id==17 & time_tranche==1
replace lr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace lr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1

replace lr_nw_adj_eff=`beta3' if study_id==17 & time_tranche==1
replace lr_nw_adj_se=`se3' if study_id==17 & time_tranche==1
replace lr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==17 & time_tranche==1
replace lr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==17 & time_tranche==1

replace lr_une_adj_eff=`beta4' if study_id==17 & time_tranche==1
replace lr_une_adj_se=`se4' if study_id==17 & time_tranche==1
replace lr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==17 & time_tranche==1
replace lr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==17 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.ethnicity_red i.cohort i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_adj_eff=`beta' if study_id==17 & time_tranche==1
replace lr_kw_adj_se=`se' if study_id==17 & time_tranche==1
replace lr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace lr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.sex i.ethnicity_red i.cohort i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_adj_eff=`beta2' if study_id==17 & time_tranche==1
replace lr_sm_adj_se=`se2' if study_id==17 & time_tranche==1
replace lr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace lr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1

replace lr_no_adj_eff=`beta3' if study_id==17 & time_tranche==1
replace lr_no_adj_se=`se3' if study_id==17 & time_tranche==1
replace lr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==17 & time_tranche==1
replace lr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==17 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.ethnicity_red i.cohort i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_adj_eff=`beta' if study_id==17 & time_tranche==1
replace lr_fr_adj_se=`se' if study_id==17 & time_tranche==1
replace lr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace lr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


clear




*******************************
**THE AVON LONGITUDINAL STUDY OF PARENTS AND CHILDREN (ALSPAC - Members) - study_id==18
*******************************

***RETURN TO CHECK THE LINKED DATA ONCE AVAILABLE

**study_id==18

**NO LINK TO NHS TESTING DATA CHECK WITH LLC (START THIS SECTION AGAIN)

**Open and merge NHS data with UKHLS file
use "alspac edited\alspac edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,


sort llc_0007_stud_id study_wave
*drop _merge
merge m:1 llc_0007_stud_id study_wave using "alspac edited\protect_nhs_c19posinfect_temp_alspacver"
drop if _merge==2	


**Modify the self-reported data as appears to be have you had covid at anytime not since last wave
**Readjusted so can only have covid once
tab study_wave c19infection_selfreported 
tab pandemic_timetranche c19infection_selfreported 
sort study_wave
replace c19infection_selfreported=0 if c19infection_selfreported[_n-1]==1  & study_wave>1
replace c19infection_selfreported=0 if c19infection_selfreported[_n-2]==1  & study_wave>2
replace c19infection_selfreported=0 if c19infection_selfreported[_n-3]==1  & study_wave>3
tab study_wave c19infection_selfreported 
tab pandemic_timetranche c19infection_selfreported 

tab study_wave c19postest_selfreported 
tab pandemic_timetranche c19postest_selfreported 
replace c19postest_selfreported=0 if c19postest_selfreported[_n-1]==1  & study_wave>1
replace c19postest_selfreported=0 if c19postest_selfreported[_n-2]==1  & study_wave>2
replace c19postest_selfreported=0 if c19postest_selfreported[_n-3]==1  & study_wave>3
tab study_wave c19postest_selfreported 
tab pandemic_timetranche c19postest_selfreported 


**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2

drop if age>65

keep if cohort==2

** BCS1970 - descriptive statistics
quietly tab llc_0007_stud_id
return list
local sample_n =  r(r)
local entry_n =  r(N)


**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)



preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==18 & time_tranche==1
replace entry_n=`entry_n' if study_id==18 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==18 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==18 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==18 & time_tranche==1

list if study_id==18 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
*tab soc2010_1d `var', missing row
*tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}

numlabel, add

tab employment 
tab employment_status



**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
*rename soc2010_1d soc_1d
*rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2010
**1 digit
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==18 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==18 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==18 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==18 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 
	



**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult



**employment
mepoisson c19infection_selfreported i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_eff=`beta' if study_id==18 & time_tranche==1
replace sr_re_se=`se' if study_id==18 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==18 & time_tranche==1
replace sr_un_se=`se2' if study_id==18 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


tab employment_status c19infection_selfreported

**employment_status	
mepoisson c19infection_selfreported i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_eff=`beta' if study_id==18 & time_tranche==1
replace sr_pt_se=`se' if study_id==18 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==18 & time_tranche==1
replace sr_ret_se=`se2' if study_id==18 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==18 & time_tranche==1
replace sr_nw_se=`se3' if study_id==18 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==18 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==18 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==18 & time_tranche==1
replace sr_une_se=`se4' if study_id==18 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==18 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==18 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

tab keyworker

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_eff=`beta' if study_id==18 & time_tranche==1
replace sr_kw_se=`se' if study_id==18 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_eff=`beta2' if study_id==18 & time_tranche==1
replace sr_sm_se=`se2' if study_id==18 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==18 & time_tranche==1
replace sr_no_se=`se3' if study_id==18 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==18 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==18 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_eff=`beta' if study_id==18 & time_tranche==1
replace sr_fr_se=`se' if study_id==18 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==18 & time_tranche==1
replace lr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==18 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==18 & time_tranche==1
replace lr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==18 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_eff=`beta' if study_id==18 & time_tranche==1
replace lr_re_se=`se' if study_id==18 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==18 & time_tranche==1
replace lr_un_se=`se2' if study_id==18 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_eff=`beta' if study_id==18 & time_tranche==1
replace lr_pt_se=`se' if study_id==18 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==18 & time_tranche==1
replace lr_ret_se=`se2' if study_id==18 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==18 & time_tranche==1
replace lr_nw_se=`se3' if study_id==18 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==18 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==18 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==18 & time_tranche==1
replace lr_une_se=`se4' if study_id==18 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==18 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==18 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_eff=`beta' if study_id==18 & time_tranche==1
replace lr_kw_se=`se' if study_id==18 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19positive i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_eff=`beta2' if study_id==18 & time_tranche==1
replace lr_sm_se=`se2' if study_id==18 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==18 & time_tranche==1
replace lr_no_se=`se3' if study_id==18 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==18 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==18 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_eff=`beta' if study_id==18 & time_tranche==1
replace lr_fr_se=`se' if study_id==18 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==18 & time_tranche==1
replace sr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==18 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==18 & time_tranche==1
replace sr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==18 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_adj_eff=`beta' if study_id==18 & time_tranche==1
replace sr_re_adj_se=`se' if study_id==18 & time_tranche==1
replace sr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace sr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1

replace sr_un_adj_eff=`beta2' if study_id==18 & time_tranche==1
replace sr_un_adj_se=`se2' if study_id==18 & time_tranche==1
replace sr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_adj_eff=`beta' if study_id==18 & time_tranche==1
replace sr_pt_adj_se=`se' if study_id==18 & time_tranche==1
replace sr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace sr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1

replace sr_ret_adj_eff=`beta2' if study_id==18 & time_tranche==1
replace sr_ret_adj_se=`se2' if study_id==18 & time_tranche==1
replace sr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace sr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1

replace sr_nw_adj_eff=`beta3' if study_id==18 & time_tranche==1
replace sr_nw_adj_se=`se3' if study_id==18 & time_tranche==1
replace sr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==18 & time_tranche==1
replace sr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==18 & time_tranche==1

replace sr_une_adj_eff=`beta4' if study_id==18 & time_tranche==1
replace sr_une_adj_se=`se4' if study_id==18 & time_tranche==1
replace sr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==18 & time_tranche==1
replace sr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==18 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_adj_eff=`beta' if study_id==18 & time_tranche==1
replace sr_kw_adj_se=`se' if study_id==18 & time_tranche==1
replace sr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace sr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_adj_eff=`beta2' if study_id==18 & time_tranche==1
replace sr_sm_adj_se=`se2' if study_id==18 & time_tranche==1
replace sr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace sr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1

replace sr_no_adj_eff=`beta3' if study_id==18 & time_tranche==1
replace sr_no_adj_se=`se3' if study_id==18 & time_tranche==1
replace sr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==18 & time_tranche==1
replace sr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==18 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_adj_eff=`beta' if study_id==18 & time_tranche==1
replace sr_fr_adj_se=`se' if study_id==18 & time_tranche==1
replace sr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace sr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==18 & time_tranche==1
replace lr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==18 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==18 & time_tranche==1
replace lr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==18 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_adj_eff=`beta' if study_id==18 & time_tranche==1
replace lr_re_adj_se=`se' if study_id==18 & time_tranche==1
replace lr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace lr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1

replace lr_un_adj_eff=`beta2' if study_id==18 & time_tranche==1
replace lr_un_adj_se=`se2' if study_id==18 & time_tranche==1
replace lr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_adj_eff=`beta' if study_id==18 & time_tranche==1
replace lr_pt_adj_se=`se' if study_id==18 & time_tranche==1
replace lr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace lr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1

replace lr_ret_adj_eff=`beta2' if study_id==18 & time_tranche==1
replace lr_ret_adj_se=`se2' if study_id==18 & time_tranche==1
replace lr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace lr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1

replace lr_nw_adj_eff=`beta3' if study_id==18 & time_tranche==1
replace lr_nw_adj_se=`se3' if study_id==18 & time_tranche==1
replace lr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==18 & time_tranche==1
replace lr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==18 & time_tranche==1

replace lr_une_adj_eff=`beta4' if study_id==18 & time_tranche==1
replace lr_une_adj_se=`se4' if study_id==18 & time_tranche==1
replace lr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==18 & time_tranche==1
replace lr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==18 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_adj_eff=`beta' if study_id==18 & time_tranche==1
replace lr_kw_adj_se=`se' if study_id==18 & time_tranche==1
replace lr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace lr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_adj_eff=`beta2' if study_id==18 & time_tranche==1
replace lr_sm_adj_se=`se2' if study_id==18 & time_tranche==1
replace lr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace lr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1

replace lr_no_adj_eff=`beta3' if study_id==18 & time_tranche==1
replace lr_no_adj_se=`se3' if study_id==18 & time_tranche==1
replace lr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==18 & time_tranche==1
replace lr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==18 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_adj_eff=`beta' if study_id==18 & time_tranche==1
replace lr_fr_adj_se=`se' if study_id==18 & time_tranche==1
replace lr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace lr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


clear





*******************************
**THE AVON LONGITUDINAL STUDY OF PARENTS AND CHILDREN (ALSPAC - Mothers) - study_id==19
*******************************

***RETURN TO CHECK THE LINKED DATA ONCE AVAILABLE

**study_id==19

**NO LINK TO NHS TESTING DATA CHECK WITH LLC (START THIS SECTION AGAIN)

**Open and merge NHS data with UKHLS file
use "alspac edited\alspac edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,


sort llc_0007_stud_id study_wave
*drop _merge
merge m:1 llc_0007_stud_id study_wave using "alspac edited\protect_nhs_c19posinfect_temp_alspacver"
drop if _merge==2	


**Modify the self-reported data as appears to be have you had covid at anytime not since last wave
**Readjusted so can only have covid once
tab study_wave c19infection_selfreported 
tab pandemic_timetranche c19infection_selfreported 
sort study_wave
replace c19infection_selfreported=0 if c19infection_selfreported[_n-1]==1  & study_wave>1
replace c19infection_selfreported=0 if c19infection_selfreported[_n-2]==1  & study_wave>2
replace c19infection_selfreported=0 if c19infection_selfreported[_n-3]==1  & study_wave>3
tab study_wave c19infection_selfreported 
tab pandemic_timetranche c19infection_selfreported 

tab study_wave c19postest_selfreported 
tab pandemic_timetranche c19postest_selfreported 
replace c19postest_selfreported=0 if c19postest_selfreported[_n-1]==1  & study_wave>1
replace c19postest_selfreported=0 if c19postest_selfreported[_n-2]==1  & study_wave>2
replace c19postest_selfreported=0 if c19postest_selfreported[_n-3]==1  & study_wave>3
tab study_wave c19postest_selfreported 
tab pandemic_timetranche c19postest_selfreported 


**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2

drop if age>65

keep if cohort==1

** BCS1970 - descriptive statistics
quietly tab llc_0007_stud_id
return list
local sample_n =  r(r)
local entry_n =  r(N)


**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==19 & time_tranche==1
replace entry_n=`entry_n' if study_id==19 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==19 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==19 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==19 & time_tranche==1

list if study_id==19 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
*tab soc2010_1d `var', missing row
*tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}

numlabel, add

tab employment 
tab employment_status



**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
*rename soc2010_1d soc_1d
*rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2010
**1 digit
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==19 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==19 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==19 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==19 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 
	



**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult



**employment
mepoisson c19infection_selfreported i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_eff=`beta' if study_id==19 & time_tranche==1
replace sr_re_se=`se' if study_id==19 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==19 & time_tranche==1
replace sr_un_se=`se2' if study_id==19 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


tab employment_status c19infection_selfreported

**employment_status	
mepoisson c19infection_selfreported i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_eff=`beta' if study_id==19 & time_tranche==1
replace sr_pt_se=`se' if study_id==19 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==19 & time_tranche==1
replace sr_ret_se=`se2' if study_id==19 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==19 & time_tranche==1
replace sr_nw_se=`se3' if study_id==19 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==19 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==19 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==19 & time_tranche==1
replace sr_une_se=`se4' if study_id==19 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==19 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==19 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

tab keyworker

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_eff=`beta' if study_id==19 & time_tranche==1
replace sr_kw_se=`se' if study_id==19 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_eff=`beta2' if study_id==19 & time_tranche==1
replace sr_sm_se=`se2' if study_id==19 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==19 & time_tranche==1
replace sr_no_se=`se3' if study_id==19 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==19 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==19 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_eff=`beta' if study_id==19 & time_tranche==1
replace sr_fr_se=`se' if study_id==19 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==19 & time_tranche==1
replace lr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==19 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==19 & time_tranche==1
replace lr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==19 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_eff=`beta' if study_id==19 & time_tranche==1
replace lr_re_se=`se' if study_id==19 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==19 & time_tranche==1
replace lr_un_se=`se2' if study_id==19 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_eff=`beta' if study_id==19 & time_tranche==1
replace lr_pt_se=`se' if study_id==19 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==19 & time_tranche==1
replace lr_ret_se=`se2' if study_id==19 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==19 & time_tranche==1
replace lr_nw_se=`se3' if study_id==19 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==19 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==19 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==19 & time_tranche==1
replace lr_une_se=`se4' if study_id==19 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==19 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==19 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_eff=`beta' if study_id==19 & time_tranche==1
replace lr_kw_se=`se' if study_id==19 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**Home working	
mepoisson c19positive i.home_working i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_eff=`beta2' if study_id==19 & time_tranche==1
replace lr_sm_se=`se2' if study_id==19 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==19 & time_tranche==1
replace lr_no_se=`se3' if study_id==19 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==19 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==19 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_eff=`beta' if study_id==19 & time_tranche==1
replace lr_fr_se=`se' if study_id==19 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==19 & time_tranche==1
replace sr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==19 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==19 & time_tranche==1
replace sr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==19 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_re_adj_eff=`beta' if study_id==19 & time_tranche==1
replace sr_re_adj_se=`se' if study_id==19 & time_tranche==1
replace sr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace sr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1

replace sr_un_adj_eff=`beta2' if study_id==19 & time_tranche==1
replace sr_un_adj_se=`se2' if study_id==19 & time_tranche==1
replace sr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_pt_adj_eff=`beta' if study_id==19 & time_tranche==1
replace sr_pt_adj_se=`se' if study_id==19 & time_tranche==1
replace sr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace sr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1

replace sr_ret_adj_eff=`beta2' if study_id==19 & time_tranche==1
replace sr_ret_adj_se=`se2' if study_id==19 & time_tranche==1
replace sr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace sr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1

replace sr_nw_adj_eff=`beta3' if study_id==19 & time_tranche==1
replace sr_nw_adj_se=`se3' if study_id==19 & time_tranche==1
replace sr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==19 & time_tranche==1
replace sr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==19 & time_tranche==1

replace sr_une_adj_eff=`beta4' if study_id==19 & time_tranche==1
replace sr_une_adj_se=`se4' if study_id==19 & time_tranche==1
replace sr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==19 & time_tranche==1
replace sr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==19 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_kw_adj_eff=`beta' if study_id==19 & time_tranche==1
replace sr_kw_adj_se=`se' if study_id==19 & time_tranche==1
replace sr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace sr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_sm_adj_eff=`beta2' if study_id==19 & time_tranche==1
replace sr_sm_adj_se=`se2' if study_id==19 & time_tranche==1
replace sr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace sr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1

replace sr_no_adj_eff=`beta3' if study_id==19 & time_tranche==1
replace sr_no_adj_se=`se3' if study_id==19 & time_tranche==1
replace sr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==19 & time_tranche==1
replace sr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==19 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace sr_fr_adj_eff=`beta' if study_id==19 & time_tranche==1
replace sr_fr_adj_se=`se' if study_id==19 & time_tranche==1
replace sr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace sr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adj_eff=_b[`i'.soc_1d] if study_id==19 & time_tranche==1
replace lr_s101d`i'_adj_se=_se[`i'.soc_1d] if study_id==19 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adj_eff=_b[`i'.soc_2d] if study_id==19 & time_tranche==1
replace lr_s102d`i'_adj_se=_se[`i'.soc_2d] if study_id==19 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_re_adj_eff=`beta' if study_id==19 & time_tranche==1
replace lr_re_adj_se=`se' if study_id==19 & time_tranche==1
replace lr_re_adj_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace lr_re_adj_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1

replace lr_un_adj_eff=`beta2' if study_id==19 & time_tranche==1
replace lr_un_adj_se=`se2' if study_id==19 & time_tranche==1
replace lr_un_adj_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace sr_un_adj_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_pt_adj_eff=`beta' if study_id==19 & time_tranche==1
replace lr_pt_adj_se=`se' if study_id==19 & time_tranche==1
replace lr_pt_adj_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace lr_pt_adj_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1

replace lr_ret_adj_eff=`beta2' if study_id==19 & time_tranche==1
replace lr_ret_adj_se=`se2' if study_id==19 & time_tranche==1
replace lr_ret_adj_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace lr_ret_adj_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1

replace lr_nw_adj_eff=`beta3' if study_id==19 & time_tranche==1
replace lr_nw_adj_se=`se3' if study_id==19 & time_tranche==1
replace lr_nw_adj_uc=exp(`beta3'+1.96*`se3') if study_id==19 & time_tranche==1
replace lr_nw_adj_lc=exp(`beta3'-1.96*`se3') if study_id==19 & time_tranche==1

replace lr_une_adj_eff=`beta4' if study_id==19 & time_tranche==1
replace lr_une_adj_se=`se4' if study_id==19 & time_tranche==1
replace lr_une_adj_uc=exp(`beta4'+1.96*`se4') if study_id==19 & time_tranche==1
replace lr_une_adj_lc=exp(`beta4'-1.96*`se4') if study_id==19 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_kw_adj_eff=`beta' if study_id==19 & time_tranche==1
replace lr_kw_adj_se=`se' if study_id==19 & time_tranche==1
replace lr_kw_adj_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace lr_kw_adj_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_sm_adj_eff=`beta2' if study_id==19 & time_tranche==1
replace lr_sm_adj_se=`se2' if study_id==19 & time_tranche==1
replace lr_sm_adj_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace lr_sm_adj_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1

replace lr_no_adj_eff=`beta3' if study_id==19 & time_tranche==1
replace lr_no_adj_se=`se3' if study_id==19 & time_tranche==1
replace lr_no_adj_uc=exp(`beta3'+1.96*`se3') if study_id==19 & time_tranche==1
replace lr_no_adj_lc=exp(`beta3'-1.96*`se3') if study_id==19 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.ethnicity_red i.age_entry i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche", clear

replace lr_fr_adj_eff=`beta' if study_id==19 & time_tranche==1
replace lr_fr_adj_se=`se' if study_id==19 & time_tranche==1
replace lr_fr_adj_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace lr_fr_adj_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche", replace
restore 


clear





********************************************************************************
**ANALYSIS OF EACH STUDY - VACCINATION ADJUSTMENT MODEL 
********************************************************************************
cd "S:\LLC_0007\data\"


*********************************
***ANALYSIS OF ELSA study_id==1
*********************************


**Open and merge testig data`' with elsa file
use "ELSA edited\elsa_longform.dta", clear
sort llc_0007_stud_id study_wave

tab study_wave_date study_wave, nol

merge 1:1 llc_0007_stud_id study_wave using "ELSA edited\protect_nhs_c19posinfect_temp_elsaver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/08/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/01/2021", "DMY") & study_wave==2

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/08/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/01/2021", "DMY") & study_wave==2

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/08/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/01/2021", "DMY") & study_wave==2

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/08/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/01/2021", "DMY") & study_wave==2


tab vacc_status

**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

label define furlough 0 "No" 1 "Yes", replace
label values furlough furlough


**drop if age
rename age_entry age
egen age_entry=cut(age) if age>30, at(1,18,34,44,54,64,74,120) icodes
tab age_entry 
replace age_entry=age if age<10
label define age_entry 1 "18-34" 2 "35-44" 3 "45-54" 4 "55-64" 5 "65-74" 6 "75+", replace
label values age_entry age_entry
tab age_entry

drop if age_entry>=5

** ELSA - descriptive statistics
quietly tab llc_0007_stud_id
return list
local sample_n =  r(r)
local entry_n =  r(N)


**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==1 & time_tranche==1
replace entry_n=`entry_n' if study_id==1 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==1 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==1 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==1 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace

restore


**tab self-reported infect by self-reported pos test
tab c19infection_selfreported c19postest_selfreported, missing

**tab self-reported infection by test positive
tab c19positive	c19infection_selfreported, missing

**tab self-reported post test by test positive
tab c19positive	c19postest_selfreported, missing


**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	
**tab NHS digital indicated infection
tab study_wave c19positive, missing	

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing	
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing	


	
***Occupational Characteristics
numlabel, add
foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
tab soc_1d `var', missing row
tab soc_2d `var', missing row

**SCI 2003 	
tab sic_1d `var', missing row
tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
tab deprivation_imd  `var', missing row
tabstat age_entry, by(`var') stat(N mean sd min max)
tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}

**lastminute formating
replace employment=3 if employment_status==4


***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult
preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==1 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==1 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==1 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==1 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**SCI 2003 	
mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19infection_selfreported i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_eff=`beta' if study_id==1 & time_tranche==1
replace sr_re_se=`se' if study_id==1 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==1 & time_tranche==1
replace sr_un_se=`se2' if study_id==1 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_eff=`beta' if study_id==1 & time_tranche==1
replace sr_pt_se=`se' if study_id==1 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==1 & time_tranche==1
replace sr_ret_se=`se2' if study_id==1 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==1 & time_tranche==1
replace sr_nw_se=`se3' if study_id==1 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==1 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==1 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==1 & time_tranche==1
replace sr_une_se=`se4' if study_id==1 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==1 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==1 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_eff=`beta' if study_id==1 & time_tranche==1
replace sr_kw_se=`se' if study_id==1 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Home working	
mepoisson c19infection_selfreported i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_eff=`beta2' if study_id==1 & time_tranche==1
replace sr_sm_se=`se2' if study_id==1 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==1 & time_tranche==1
replace sr_no_se=`se3' if study_id==1 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==1 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==1 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_eff=`beta' if study_id==1 & time_tranche==1
replace sr_fr_se=`se' if study_id==1 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1
*replace sr_fr_eff=exp(`beta') if study_id==1 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==1 & time_tranche==1
replace lr_s101d`i'_se=_se[`i'.soc_1d] if study_id==1 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==1 & time_tranche==1
replace lr_s102d`i'_se=_se[`i'.soc_2d] if study_id==1 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19positive i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_eff=`beta' if study_id==1 & time_tranche==1
replace lr_re_se=`se' if study_id==1 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==1 & time_tranche==1
replace lr_un_se=`se2' if study_id==1 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_eff=`beta' if study_id==1 & time_tranche==1
replace lr_pt_se=`se' if study_id==1 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==1 & time_tranche==1
replace lr_ret_se=`se2' if study_id==1 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==1 & time_tranche==1
replace lr_nw_se=`se3' if study_id==1 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==1 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==1 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==1 & time_tranche==1
replace lr_une_se=`se4' if study_id==1 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==1 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==1 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 





**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_eff=`beta' if study_id==1 & time_tranche==1
replace lr_kw_se=`se' if study_id==1 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1
*replace lr_kw_eff=exp(`beta') if study_id==1 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Home working	
mepoisson c19positive i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_eff=`beta2' if study_id==1 & time_tranche==1
replace lr_sm_se=`se2' if study_id==1 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==1 & time_tranche==1
replace lr_no_se=`se3' if study_id==1 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==1 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==1 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_eff=`beta' if study_id==1 & time_tranche==1
replace lr_fr_se=`se' if study_id==1 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1
*replace lr_fr_eff=exp(`beta') if study_id==1 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



****Repeated Adjusted for key confounders
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.vacc_status  i.ethnicity_red i.deprivation age_entry i.hm_location i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==1 & time_tranche==1
replace sr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==1 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.vacc_status  i.ethnicity_red i.deprivation age_entry i.hm_location i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==1 & time_tranche==1
replace sr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==1 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
mepoisson c19infection_selfreported i.sic_1d i.sex i.vacc_status  i.ethnicity_red i.deprivation age_entry i.hm_location i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
mepoisson c19infection_selfreported i.sic_2d i.sex i.vacc_status  i.ethnicity_red i.deprivation age_entry i.hm_location i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19infection_selfreported i.employment i.sex i.vacc_status  i.ethnicity_red i.deprivation age_entry i.hm_location i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_adjv_eff=`beta' if study_id==1 & time_tranche==1
replace sr_re_adjv_se=`se' if study_id==1 & time_tranche==1
replace sr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace sr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1

replace sr_un_adjv_eff=`beta2' if study_id==1 & time_tranche==1
replace sr_un_adjv_se=`se2' if study_id==1 & time_tranche==1
replace sr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.vacc_status  i.ethnicity_red i.deprivation age_entry i.hm_location i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_adjv_eff=`beta' if study_id==1 & time_tranche==1
replace sr_pt_adjv_se=`se' if study_id==1 & time_tranche==1
replace sr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace sr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1

replace sr_ret_adjv_eff=`beta2' if study_id==1 & time_tranche==1
replace sr_ret_adjv_se=`se2' if study_id==1 & time_tranche==1
replace sr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace sr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1

replace sr_nw_adjv_eff=`beta3' if study_id==1 & time_tranche==1
replace sr_nw_adjv_se=`se3' if study_id==1 & time_tranche==1
replace sr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==1 & time_tranche==1
replace sr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==1 & time_tranche==1

replace sr_une_adjv_eff=`beta4' if study_id==1 & time_tranche==1
replace sr_une_adjv_se=`se4' if study_id==1 & time_tranche==1
replace sr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==1 & time_tranche==1
replace sr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==1 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore




**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.vacc_status  i.ethnicity_red i.deprivation age_entry i.hm_location i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_adjv_eff=`beta' if study_id==1 & time_tranche==1
replace sr_kw_adjv_se=`se' if study_id==1 & time_tranche==1
replace sr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace sr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1
*replace sr_kw_adjv_eff=exp(`beta') if study_id==1 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.vacc_status  i.ethnicity_red i.deprivation age_entry i.hm_location i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_adjv_eff=`beta2' if study_id==1 & time_tranche==1
replace sr_sm_adjv_se=`se2' if study_id==1 & time_tranche==1
replace sr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace sr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1

replace sr_no_adjv_eff=`beta3' if study_id==1 & time_tranche==1
replace sr_no_adjv_se=`se3' if study_id==1 & time_tranche==1
replace sr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==1 & time_tranche==1
replace sr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==1 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.vacc_status  i.ethnicity_red i.deprivation age_entry i.hm_location i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_adjv_eff=`beta' if study_id==1 & time_tranche==1
replace sr_fr_adjv_se=`se' if study_id==1 & time_tranche==1
replace sr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace sr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1
*replace sr_fr_adjv_eff=exp(`beta') if study_id==1 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.vacc_status  i.ethnicity_red i.deprivation age_entry i.hm_location i.housing_composition i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==1 & time_tranche==1
replace lr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==1 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.vacc_status  i.ethnicity_red i.deprivation age_entry i.hm_location i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==1 & time_tranche==1
replace lr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==1 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
mepoisson c19positive i.sic_1d i.sex i.vacc_status  i.ethnicity_red i.deprivation age_entry i.hm_location i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
mepoisson c19positive i.sic_2d i.sex i.vacc_status  i.ethnicity_red i.deprivation age_entry i.hm_location i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult



 


**employment
mepoisson c19positive i.employment i.sex i.vacc_status  i.ethnicity_red i.deprivation age_entry i.hm_location i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_adjv_eff=`beta' if study_id==1 & time_tranche==1
replace lr_re_adjv_se=`se' if study_id==1 & time_tranche==1
replace lr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace lr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1

replace lr_un_adjv_eff=`beta2' if study_id==1 & time_tranche==1
replace lr_un_adjv_se=`se2' if study_id==1 & time_tranche==1
replace lr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.vacc_status  i.ethnicity_red i.deprivation age_entry i.hm_location i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_adjv_eff=`beta' if study_id==1 & time_tranche==1
replace lr_pt_adjv_se=`se' if study_id==1 & time_tranche==1
replace lr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace lr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1

replace lr_ret_adjv_eff=`beta2' if study_id==1 & time_tranche==1
replace lr_ret_adjv_se=`se2' if study_id==1 & time_tranche==1
replace lr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace lr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1

replace lr_nw_adjv_eff=`beta3' if study_id==1 & time_tranche==1
replace lr_nw_adjv_se=`se3' if study_id==1 & time_tranche==1
replace lr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==1 & time_tranche==1
replace lr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==1 & time_tranche==1

replace lr_une_adjv_eff=`beta4' if study_id==1 & time_tranche==1
replace lr_une_adjv_se=`se4' if study_id==1 & time_tranche==1
replace lr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==1 & time_tranche==1
replace lr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==1 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore



**Key worker	
mepoisson c19positive i.keyworker i.sex i.vacc_status  i.ethnicity_red i.deprivation age_entry i.hm_location i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_adjv_eff=`beta' if study_id==1 & time_tranche==1
replace lr_kw_adjv_se=`se' if study_id==1 & time_tranche==1
replace lr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace lr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1
*replace lr_kw_adjv_eff=exp(`beta') if study_id==1 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore
**Home working	
mepoisson c19positive i.home_working i.sex i.vacc_status  i.ethnicity_red i.deprivation age_entry i.hm_location i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_adjv_eff=`beta2' if study_id==1 & time_tranche==1
replace lr_sm_adjv_se=`se2' if study_id==1 & time_tranche==1
replace lr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==1 & time_tranche==1
replace lr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==1 & time_tranche==1

replace lr_no_adjv_eff=`beta3' if study_id==1 & time_tranche==1
replace lr_no_adjv_se=`se3' if study_id==1 & time_tranche==1
replace lr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==1 & time_tranche==1
replace lr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==1 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.vacc_status  i.ethnicity_red i.deprivation age_entry i.hm_location i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_adjv_eff=`beta' if study_id==1 & time_tranche==1
replace lr_fr_adjv_se=`se' if study_id==1 & time_tranche==1
replace lr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==1 & time_tranche==1
replace lr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==1 & time_tranche==1
*replace lr_fr_adjv_eff=exp(`beta') if study_id==1 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

clear




***********************************
**UNDERSTANDING SOCIETY ANALYSIS 
***********************************



**Open and merge NHS DATA with UKHLS file
use "UKHLS edited\UKHLS edited long version.dta", clear


label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
label values study_wave study_wave
tab study_wave,

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "UKHLS edited\protect_nhs_c19posinfect_temp_ukhlsver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/05/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/06/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/07/2020", "DMY") & study_wave==3
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/08/2020", "DMY") & study_wave==4
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/10/2020", "DMY") & study_wave==5
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/12/2020", "DMY") & study_wave==6
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/02/2021", "DMY") & study_wave==7
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==8

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/05/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/06/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/07/2020", "DMY") & study_wave==3
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/08/2020", "DMY") & study_wave==4
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/10/2020", "DMY") & study_wave==5
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/12/2020", "DMY") & study_wave==6
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/02/2021", "DMY") & study_wave==7
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/04/2021", "DMY") & study_wave==8

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/05/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/06/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/07/2020", "DMY") & study_wave==3
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/08/2020", "DMY") & study_wave==4
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/10/2020", "DMY") & study_wave==5
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/12/2020", "DMY") & study_wave==6
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/02/2021", "DMY") & study_wave==7
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/04/2021", "DMY") & study_wave==8

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/05/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/06/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/07/2020", "DMY") & study_wave==3
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/08/2020", "DMY") & study_wave==4
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/10/2020", "DMY") & study_wave==5
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/12/2020", "DMY") & study_wave==6
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/02/2021", "DMY") & study_wave==7
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==8


tab study_wave vacc_status
replace vacc_status=1 if vacc_status>1 & vacc_status!=.
label define vacc_status 0 "No Vacc" 1 "1+ Dose Vacc", replace
label values vacc_status vacc_status
tab study_wave vacc_status




drop if age_entry>5

**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

label define furlough 0 "No" 1 "Yes", replace
label values furlough furlough

***Change labels to fit with generic analysis 
rename keyworker keyworker2
rename key_worker keyworker


** UKHLS - descriptive statistics
quietly tab llc_0007_stud_id
return list
local sample_n =  r(r)
local entry_n =  r(N)


**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==2 & time_tranche==1
replace entry_n=`entry_n' if study_id==2 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==2 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==2 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==2 & time_tranche==1

list if study_id==2 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
tab soc_1d `var', missing row
tab soc_2d `var', missing row

**SIC 2003 	
tab sic_1d `var', missing row
tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
tab age_entry `var', missing row
tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
recode employment (3=4) (2=3)
recode employment_status (2=4) 


***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==2 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==2 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==2 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==2 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19infection_selfreported i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*local beta = _b[2.employment]
*local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

*replace sr_re_eff=`beta' if study_id==2 & time_tranche==1
*replace sr_re_se=`se' if study_id==2 & time_tranche==1
*replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
*replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==2 & time_tranche==1
replace sr_un_se=`se2' if study_id==2 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**employment_status	
mepoisson c19infection_selfreported i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

*local beta2 = _b[2.employment_status]
*local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_eff=`beta' if study_id==2 & time_tranche==1
replace sr_pt_se=`se' if study_id==2 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1

*replace sr_ret_eff=`beta2' if study_id==2 & time_tranche==1
*replace sr_ret_se=`se2' if study_id==2 & time_tranche==1
*replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
*replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==2 & time_tranche==1
replace sr_nw_se=`se3' if study_id==2 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==2 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==2 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==2 & time_tranche==1
replace sr_une_se=`se4' if study_id==2 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==2 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==2 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_eff=`beta' if study_id==2 & time_tranche==1
replace sr_kw_se=`se' if study_id==2 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Home working	
mepoisson c19infection_selfreported i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_eff=`beta2' if study_id==2 & time_tranche==1
replace sr_sm_se=`se2' if study_id==2 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==2 & time_tranche==1
replace sr_no_se=`se3' if study_id==2 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==2 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==2 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_eff=`beta' if study_id==2 & time_tranche==1
replace sr_fr_se=`se' if study_id==2 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1
*replace sr_fr_eff=exp(`beta') if study_id==2 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==2 & time_tranche==1
replace lr_s101d`i'_se=_se[`i'.soc_1d] if study_id==2 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==2 & time_tranche==1
replace lr_s102d`i'_se=_se[`i'.soc_2d] if study_id==2 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 
**SCI 2003 	
mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*local beta = _b[2.employment]
*local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

*replace lr_re_eff=`beta' if study_id==2 & time_tranche==1
*replace lr_re_se=`se' if study_id==2 & time_tranche==1
*replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
*replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==2 & time_tranche==1
replace lr_un_se=`se2' if study_id==2 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

*local beta2 = _b[2.employment_status]
*local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_eff=`beta' if study_id==2 & time_tranche==1
replace lr_pt_se=`se' if study_id==2 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1

*replace lr_ret_eff=`beta2' if study_id==2 & time_tranche==1
*replace lr_ret_se=`se2' if study_id==2 & time_tranche==1
*replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
*replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==2 & time_tranche==1
replace lr_nw_se=`se3' if study_id==2 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==2 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==2 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==2 & time_tranche==1
replace lr_une_se=`se4' if study_id==2 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==2 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==2 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_eff=`beta' if study_id==2 & time_tranche==1
replace lr_kw_se=`se' if study_id==2 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1
*replace lr_kw_eff=exp(`beta') if study_id==2 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**Home working	
mepoisson c19positive i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_eff=`beta2' if study_id==2 & time_tranche==1
replace lr_sm_se=`se2' if study_id==2 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==2 & time_tranche==1
replace lr_no_se=`se3' if study_id==2 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==2 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==2 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_eff=`beta' if study_id==2 & time_tranche==1
replace lr_fr_se=`se' if study_id==2 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation 
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.vacc_status  i.ethnicity_red age_entry i.hm_location i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==2 & time_tranche==1
replace sr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==2 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.vacc_status  i.ethnicity_red age_entry i.hm_location i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==2 & time_tranche==1
replace sr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==2 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
mepoisson c19infection_selfreported i.sic_1d i.sex i.vacc_status  i.ethnicity_red age_entry i.hm_location i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.vacc_status  i.ethnicity_red age_entry i.hm_location i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult






**employment status
mepoisson c19infection_selfreported i.employment i.sex i.vacc_status  i.ethnicity_red age_entry i.hm_location i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*local beta = _b[2.employment]
*local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

*replace sr_re_adjv_eff=`beta' if study_id==2 & time_tranche==1
*replace sr_re_adjv_se=`se' if study_id==2 & time_tranche==1
*replace sr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
*replace sr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1

replace sr_un_adjv_eff=`beta2' if study_id==2 & time_tranche==1
replace sr_un_adjv_se=`se2' if study_id==2 & time_tranche==1
replace sr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.vacc_status  i.ethnicity_red age_entry i.hm_location i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

*local beta2 = _b[2.employment_status]
*local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_adjv_eff=`beta' if study_id==2 & time_tranche==1
replace sr_pt_adjv_se=`se' if study_id==2 & time_tranche==1
replace sr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace sr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1

*replace sr_ret_adjv_eff=`beta2' if study_id==2 & time_tranche==1
*replace sr_ret_adjv_se=`se2' if study_id==2 & time_tranche==1
*replace sr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
*replace sr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1

replace sr_nw_adjv_eff=`beta3' if study_id==2 & time_tranche==1
replace sr_nw_adjv_se=`se3' if study_id==2 & time_tranche==1
replace sr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==2 & time_tranche==1
replace sr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==2 & time_tranche==1

replace sr_une_adjv_eff=`beta4' if study_id==2 & time_tranche==1
replace sr_une_adjv_se=`se4' if study_id==2 & time_tranche==1
replace sr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==2 & time_tranche==1
replace sr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==2 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore




**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.vacc_status  i.ethnicity_red age_entry i.hm_location i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_adjv_eff=`beta' if study_id==2 & time_tranche==1
replace sr_kw_adjv_se=`se' if study_id==2 & time_tranche==1
replace sr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace sr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1
*replace sr_kw_adjv_eff=exp(`beta') if study_id==2 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.vacc_status  i.ethnicity_red age_entry i.hm_location i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_adjv_eff=`beta2' if study_id==2 & time_tranche==1
replace sr_sm_adjv_se=`se2' if study_id==2 & time_tranche==1
replace sr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
replace sr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1

replace sr_no_adjv_eff=`beta3' if study_id==2 & time_tranche==1
replace sr_no_adjv_se=`se3' if study_id==2 & time_tranche==1
replace sr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==2 & time_tranche==1
replace sr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==2 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.vacc_status  i.ethnicity_red age_entry i.hm_location i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_adjv_eff=`beta' if study_id==2 & time_tranche==1
replace sr_fr_adjv_se=`se' if study_id==2 & time_tranche==1
replace sr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace sr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.vacc_status  i.ethnicity_red age_entry i.hm_location i.housing_composition i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==2 & time_tranche==1
replace lr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==2 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.vacc_status  i.ethnicity_red age_entry i.hm_location i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==2 & time_tranche==1
replace lr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==2 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.vacc_status  i.ethnicity_red age_entry i.hm_location i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.vacc_status  i.ethnicity_red age_entry i.hm_location i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19positive i.employment i.sex i.vacc_status  i.ethnicity_red age_entry i.hm_location i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*local beta = _b[2.employment]
*local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

*replace lr_re_adjv_eff=`beta' if study_id==2 & time_tranche==1
*replace lr_re_adjv_se=`se' if study_id==2 & time_tranche==1
*replace lr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
*replace lr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1

replace lr_un_adjv_eff=`beta2' if study_id==2 & time_tranche==1
replace lr_un_adjv_se=`se2' if study_id==2 & time_tranche==1
replace lr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.vacc_status  i.ethnicity_red age_entry i.hm_location i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

*local beta2 = _b[2.employment_status]
*local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_adjv_eff=`beta' if study_id==2 & time_tranche==1
replace lr_pt_adjv_se=`se' if study_id==2 & time_tranche==1
replace lr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace lr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1

*replace lr_ret_adjv_eff=`beta2' if study_id==2 & time_tranche==1
*replace lr_ret_adjv_se=`se2' if study_id==2 & time_tranche==1
*replace lr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
*replace lr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1

replace lr_nw_adjv_eff=`beta3' if study_id==2 & time_tranche==1
replace lr_nw_adjv_se=`se3' if study_id==2 & time_tranche==1
replace lr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==2 & time_tranche==1
replace lr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==2 & time_tranche==1

replace lr_une_adjv_eff=`beta4' if study_id==2 & time_tranche==1
replace lr_une_adjv_se=`se4' if study_id==2 & time_tranche==1
replace lr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==2 & time_tranche==1
replace lr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==2 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore

**Key worker	
mepoisson c19positive i.keyworker i.sex i.vacc_status  i.ethnicity_red age_entry i.hm_location i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_adjv_eff=`beta' if study_id==2 & time_tranche==1
replace lr_kw_adjv_se=`se' if study_id==2 & time_tranche==1
replace lr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace lr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19positive i.home_working i.sex i.vacc_status  i.ethnicity_red age_entry i.hm_location i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_adjv_eff=`beta2' if study_id==2 & time_tranche==1
replace lr_sm_adjv_se=`se2' if study_id==2 & time_tranche==1
replace lr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==2 & time_tranche==1
replace lr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==2 & time_tranche==1

replace lr_no_adjv_eff=`beta3' if study_id==2 & time_tranche==1
replace lr_no_adjv_se=`se3' if study_id==2 & time_tranche==1
replace lr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==2 & time_tranche==1
replace lr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==2 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.vacc_status  i.ethnicity_red  i.hm_location i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_adjv_eff=`beta' if study_id==2 & time_tranche==1
replace lr_fr_adjv_se=`se' if study_id==2 & time_tranche==1
replace lr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==2 & time_tranche==1
replace lr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==2 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


clear



*******************************
**THE BRITISH COHORT 1970
*******************************




**Open and merge NHS data with UKHLS file
use "BCS70 edited\BCS70 edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,
tostring avail_from_dt, replace 

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "BCS70 edited\protect_nhs_c19posinfect_temp_bcs70ver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/04/2021", "DMY") & study_wave==3


tab study_wave vacc_status
replace vacc_status=1 if vacc_status>1 & vacc_status!=.
label define vacc_status 0 "No Vacc" 1 "1+ Dose Vacc", replace
label values vacc_status vacc_status
tab study_wave vacc_status



**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2
rename key_worker keyworker


** BCS1970 - descriptive statistics
quietly tab llc_0007_stud_id
return list
local sample_n =  r(r)
local entry_n =  r(N)


**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==3 & time_tranche==1
replace entry_n=`entry_n' if study_id==3 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==3 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==3 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==3 & time_tranche==1

list if study_id==3 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
tab soc2010_1d `var', missing row
tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
*tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}

numlabel, add

tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
rename soc2010_1d soc_1d
rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2010
**1 digit
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==3 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==3 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==3 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==3 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 
	



**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19infection_selfreported i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_eff=`beta' if study_id==3 & time_tranche==1
replace sr_re_se=`se' if study_id==3 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==3 & time_tranche==1
replace sr_un_se=`se2' if study_id==3 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**employment_status	
mepoisson c19infection_selfreported i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_eff=`beta' if study_id==3 & time_tranche==1
replace sr_pt_se=`se' if study_id==3 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==3 & time_tranche==1
replace sr_ret_se=`se2' if study_id==3 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==3 & time_tranche==1
replace sr_nw_se=`se3' if study_id==3 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==3 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==3 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==3 & time_tranche==1
replace sr_une_se=`se4' if study_id==3 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==3 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==3 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_eff=`beta' if study_id==3 & time_tranche==1
replace sr_kw_se=`se' if study_id==3 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_eff=`beta2' if study_id==3 & time_tranche==1
replace sr_sm_se=`se2' if study_id==3 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==3 & time_tranche==1
replace sr_no_se=`se3' if study_id==3 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==3 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==3 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_eff=`beta' if study_id==3 & time_tranche==1
replace sr_fr_se=`se' if study_id==3 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==3 & time_tranche==1
replace lr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==3 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==3 & time_tranche==1
replace lr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==3 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_eff=`beta' if study_id==3 & time_tranche==1
replace lr_re_se=`se' if study_id==3 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==3 & time_tranche==1
replace lr_un_se=`se2' if study_id==3 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_eff=`beta' if study_id==3 & time_tranche==1
replace lr_pt_se=`se' if study_id==3 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==3 & time_tranche==1
replace lr_ret_se=`se2' if study_id==3 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==3 & time_tranche==1
replace lr_nw_se=`se3' if study_id==3 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==3 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==3 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==3 & time_tranche==1
replace lr_une_se=`se4' if study_id==3 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==3 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==3 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_eff=`beta' if study_id==3 & time_tranche==1
replace lr_kw_se=`se' if study_id==3 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19positive i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_eff=`beta2' if study_id==3 & time_tranche==1
replace lr_sm_se=`se2' if study_id==3 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==3 & time_tranche==1
replace lr_no_se=`se3' if study_id==3 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==3 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==3 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_eff=`beta' if study_id==3 & time_tranche==1
replace lr_fr_se=`se' if study_id==3 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation  i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==3 & time_tranche==1
replace sr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==3 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==3 & time_tranche==1
replace sr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==3 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_adjv_eff=`beta' if study_id==3 & time_tranche==1
replace sr_re_adjv_se=`se' if study_id==3 & time_tranche==1
replace sr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace sr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1

replace sr_un_adjv_eff=`beta2' if study_id==3 & time_tranche==1
replace sr_un_adjv_se=`se2' if study_id==3 & time_tranche==1
replace sr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_adjv_eff=`beta' if study_id==3 & time_tranche==1
replace sr_pt_adjv_se=`se' if study_id==3 & time_tranche==1
replace sr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace sr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1

replace sr_ret_adjv_eff=`beta2' if study_id==3 & time_tranche==1
replace sr_ret_adjv_se=`se2' if study_id==3 & time_tranche==1
replace sr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace sr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1

replace sr_nw_adjv_eff=`beta3' if study_id==3 & time_tranche==1
replace sr_nw_adjv_se=`se3' if study_id==3 & time_tranche==1
replace sr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==3 & time_tranche==1
replace sr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==3 & time_tranche==1

replace sr_une_adjv_eff=`beta4' if study_id==3 & time_tranche==1
replace sr_une_adjv_se=`se4' if study_id==3 & time_tranche==1
replace sr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==3 & time_tranche==1
replace sr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==3 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_adjv_eff=`beta' if study_id==3 & time_tranche==1
replace sr_kw_adjv_se=`se' if study_id==3 & time_tranche==1
replace sr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace sr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_adjv_eff=`beta2' if study_id==3 & time_tranche==1
replace sr_sm_adjv_se=`se2' if study_id==3 & time_tranche==1
replace sr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace sr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1

replace sr_no_adjv_eff=`beta3' if study_id==3 & time_tranche==1
replace sr_no_adjv_se=`se3' if study_id==3 & time_tranche==1
replace sr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==3 & time_tranche==1
replace sr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==3 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_adjv_eff=`beta' if study_id==3 & time_tranche==1
replace sr_fr_adjv_se=`se' if study_id==3 & time_tranche==1
replace sr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace sr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==3 & time_tranche==1
replace lr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==3 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==3 & time_tranche==1
replace lr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==3 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_adjv_eff=`beta' if study_id==3 & time_tranche==1
replace lr_re_adjv_se=`se' if study_id==3 & time_tranche==1
replace lr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace lr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1

replace lr_un_adjv_eff=`beta2' if study_id==3 & time_tranche==1
replace lr_un_adjv_se=`se2' if study_id==3 & time_tranche==1
replace lr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_adjv_eff=`beta' if study_id==3 & time_tranche==1
replace lr_pt_adjv_se=`se' if study_id==3 & time_tranche==1
replace lr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace lr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1

replace lr_ret_adjv_eff=`beta2' if study_id==3 & time_tranche==1
replace lr_ret_adjv_se=`se2' if study_id==3 & time_tranche==1
replace lr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace lr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1

replace lr_nw_adjv_eff=`beta3' if study_id==3 & time_tranche==1
replace lr_nw_adjv_se=`se3' if study_id==3 & time_tranche==1
replace lr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==3 & time_tranche==1
replace lr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==3 & time_tranche==1

replace lr_une_adjv_eff=`beta4' if study_id==3 & time_tranche==1
replace lr_une_adjv_se=`se4' if study_id==3 & time_tranche==1
replace lr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==3 & time_tranche==1
replace lr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==3 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_adjv_eff=`beta' if study_id==3 & time_tranche==1
replace lr_kw_adjv_se=`se' if study_id==3 & time_tranche==1
replace lr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace lr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_adjv_eff=`beta2' if study_id==3 & time_tranche==1
replace lr_sm_adjv_se=`se2' if study_id==3 & time_tranche==1
replace lr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==3 & time_tranche==1
replace lr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==3 & time_tranche==1

replace lr_no_adjv_eff=`beta3' if study_id==3 & time_tranche==1
replace lr_no_adjv_se=`se3' if study_id==3 & time_tranche==1
replace lr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==3 & time_tranche==1
replace lr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==3 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_adjv_eff=`beta' if study_id==3 & time_tranche==1
replace lr_fr_adjv_se=`se' if study_id==3 & time_tranche==1
replace lr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==3 & time_tranche==1
replace lr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==3 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


clear





*******************************
**THE  MILLENIUM COHORT
*******************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "MCS edited\MCS edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,
tostring avail_from_dt, replace 

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "MCS edited\protect_nhs_c19posinfect_temp_mcsver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/04/2021", "DMY") & study_wave==3


tab study_wave vacc_status
replace vacc_status=1 if vacc_status>1 & vacc_status!=.
label define vacc_status 0 "No Vacc" 1 "1+ Dose Vacc", replace
label values vacc_status vacc_status
tab study_wave vacc_status



**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2
rename key_worker keyworker


** MCS - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq

**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==4 & time_tranche==1
replace entry_n=`entry_n' if study_id==4 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==4 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==4 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==4 & time_tranche==1

list if study_id==4 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
tab soc2010_1d `var', missing row
tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
*tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
rename soc2010_1d soc_1d
rename soc2010_2d soc_2d
replace soc_2d=. if soc_2d<0
***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult
preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==4 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==4 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==4 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==4 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19infection_selfreported i.employment   i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_eff=`beta' if study_id==4 & time_tranche==1
replace sr_re_se=`se' if study_id==4 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==4 & time_tranche==1
replace sr_un_se=`se2' if study_id==4 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**employment_status	
mepoisson c19infection_selfreported i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_eff=`beta' if study_id==4 & time_tranche==1
replace sr_pt_se=`se' if study_id==4 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==4 & time_tranche==1
replace sr_ret_se=`se2' if study_id==4 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==4 & time_tranche==1
replace sr_nw_se=`se3' if study_id==4 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==4 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==4 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==4 & time_tranche==1
replace sr_une_se=`se4' if study_id==4 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==4 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==4 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_eff=`beta' if study_id==4 & time_tranche==1
replace sr_kw_se=`se' if study_id==4 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_eff=`beta2' if study_id==4 & time_tranche==1
replace sr_sm_se=`se2' if study_id==4 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==4 & time_tranche==1
replace sr_no_se=`se3' if study_id==4 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==4 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==4 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_eff=`beta' if study_id==4 & time_tranche==1
replace sr_fr_se=`se' if study_id==4 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==4 & time_tranche==1
replace lr_s101d`i'_se=_se[`i'.soc_1d] if study_id==4 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==4 & time_tranche==1
replace lr_s102d`i'_se=_se[`i'.soc_2d] if study_id==4 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_eff=`beta' if study_id==4 & time_tranche==1
replace lr_re_se=`se' if study_id==4 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==4 & time_tranche==1
replace lr_un_se=`se2' if study_id==4 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status i.cohort i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_eff=`beta' if study_id==4 & time_tranche==1
replace lr_pt_se=`se' if study_id==4 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==4 & time_tranche==1
replace lr_ret_se=`se2' if study_id==4 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==4 & time_tranche==1
replace lr_nw_se=`se3' if study_id==4 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==4 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==4 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==4 & time_tranche==1
replace lr_une_se=`se4' if study_id==4 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==4 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==4 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_eff=`beta' if study_id==4 & time_tranche==1
replace lr_kw_se=`se' if study_id==4 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19positive i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_eff=`beta2' if study_id==4 & time_tranche==1
replace lr_sm_se=`se2' if study_id==4 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==4 & time_tranche==1
replace lr_no_se=`se3' if study_id==4 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==4 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==4 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_eff=`beta' if study_id==4 & time_tranche==1
replace lr_fr_se=`se' if study_id==4 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation  i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.vacc_status  i.ethnicity_red  i.cohort i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==4 & time_tranche==1
replace sr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==4 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==4 & time_tranche==1
replace sr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==4 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_adjv_eff=`beta' if study_id==4 & time_tranche==1
replace sr_re_adjv_se=`se' if study_id==4 & time_tranche==1
replace sr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace sr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1

replace sr_un_adjv_eff=`beta2' if study_id==4 & time_tranche==1
replace sr_un_adjv_se=`se2' if study_id==4 & time_tranche==1
replace sr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_adjv_eff=`beta' if study_id==4 & time_tranche==1
replace sr_pt_adjv_se=`se' if study_id==4 & time_tranche==1
replace sr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace sr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1

replace sr_ret_adjv_eff=`beta2' if study_id==4 & time_tranche==1
replace sr_ret_adjv_se=`se2' if study_id==4 & time_tranche==1
replace sr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace sr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1

replace sr_nw_adjv_eff=`beta3' if study_id==4 & time_tranche==1
replace sr_nw_adjv_se=`se3' if study_id==4 & time_tranche==1
replace sr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==4 & time_tranche==1
replace sr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==4 & time_tranche==1

replace sr_une_adjv_eff=`beta4' if study_id==4 & time_tranche==1
replace sr_une_adjv_se=`se4' if study_id==4 & time_tranche==1
replace sr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==4 & time_tranche==1
replace sr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==4 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_adjv_eff=`beta' if study_id==4 & time_tranche==1
replace sr_kw_adjv_se=`se' if study_id==4 & time_tranche==1
replace sr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace sr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_adjv_eff=`beta2' if study_id==4 & time_tranche==1
replace sr_sm_adjv_se=`se2' if study_id==4 & time_tranche==1
replace sr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace sr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1

replace sr_no_adjv_eff=`beta3' if study_id==4 & time_tranche==1
replace sr_no_adjv_se=`se3' if study_id==4 & time_tranche==1
replace sr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==4 & time_tranche==1
replace sr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==4 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_adjv_eff=`beta' if study_id==4 & time_tranche==1
replace sr_fr_adjv_se=`se' if study_id==4 & time_tranche==1
replace sr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace sr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==4 & time_tranche==1
replace lr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==4 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==4 & time_tranche==1
replace lr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==4 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_adjv_eff=`beta' if study_id==4 & time_tranche==1
replace lr_re_adjv_se=`se' if study_id==4 & time_tranche==1
replace lr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace lr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1

replace lr_un_adjv_eff=`beta2' if study_id==4 & time_tranche==1
replace lr_un_adjv_se=`se2' if study_id==4 & time_tranche==1
replace lr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_adjv_eff=`beta' if study_id==4 & time_tranche==1
replace lr_pt_adjv_se=`se' if study_id==4 & time_tranche==1
replace lr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace lr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1

replace lr_ret_adjv_eff=`beta2' if study_id==4 & time_tranche==1
replace lr_ret_adjv_se=`se2' if study_id==4 & time_tranche==1
replace lr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace lr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1

replace lr_nw_adjv_eff=`beta3' if study_id==4 & time_tranche==1
replace lr_nw_adjv_se=`se3' if study_id==4 & time_tranche==1
replace lr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==4 & time_tranche==1
replace lr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==4 & time_tranche==1

replace lr_une_adjv_eff=`beta4' if study_id==4 & time_tranche==1
replace lr_une_adjv_se=`se4' if study_id==4 & time_tranche==1
replace lr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==4 & time_tranche==1
replace lr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==4 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_adjv_eff=`beta' if study_id==4 & time_tranche==1
replace lr_kw_adjv_se=`se' if study_id==4 & time_tranche==1
replace lr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace lr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_adjv_eff=`beta2' if study_id==4 & time_tranche==1
replace lr_sm_adjv_se=`se2' if study_id==4 & time_tranche==1
replace lr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==4 & time_tranche==1
replace lr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==4 & time_tranche==1

replace lr_no_adjv_eff=`beta3' if study_id==4 & time_tranche==1
replace lr_no_adjv_se=`se3' if study_id==4 & time_tranche==1
replace lr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==4 & time_tranche==1
replace lr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==4 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_adjv_eff=`beta' if study_id==4 & time_tranche==1
replace lr_fr_adjv_se=`se' if study_id==4 & time_tranche==1
replace lr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==4 & time_tranche==1
replace lr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==4 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


clear








***************************************************
**THE 1958 NATIONAL CHILD DEVELOPMENT STUDY (NCDS)
***************************************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "NCDS58 edited\NCDS58 edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,
tostring avail_from_dt, replace 

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "NCDS58 edited\protect_nhs_c19posinfect_temp_ncds58ver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/11/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/11/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/11/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/11/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/04/2021", "DMY") & study_wave==3


tab study_wave vacc_status
replace vacc_status=1 if vacc_status>1 & vacc_status!=.
label define vacc_status 0 "No Vacc" 1 "1+ Dose Vacc", replace
label values vacc_status vacc_status
tab study_wave vacc_status



**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2
rename key_worker keyworker


** NCDS58 - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq

**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==5 & time_tranche==1
replace entry_n=`entry_n' if study_id==5 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==5 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==5 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==5 & time_tranche==1

list if study_id==5 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
tab soc2010_1d `var', missing row
tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
*tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
rename soc2010_1d soc_1d
rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==5 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==5 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==5 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==5 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19infection_selfreported i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_eff=`beta' if study_id==5 & time_tranche==1
replace sr_re_se=`se' if study_id==5 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==5 & time_tranche==1
replace sr_un_se=`se2' if study_id==5 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**employment_status	
mepoisson c19infection_selfreported i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_eff=`beta' if study_id==5 & time_tranche==1
replace sr_pt_se=`se' if study_id==5 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==5 & time_tranche==1
replace sr_ret_se=`se2' if study_id==5 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==5 & time_tranche==1
replace sr_nw_se=`se3' if study_id==5 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==5 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==5 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==5 & time_tranche==1
replace sr_une_se=`se4' if study_id==5 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==5 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==5 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_eff=`beta' if study_id==5 & time_tranche==1
replace sr_kw_se=`se' if study_id==5 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_eff=`beta2' if study_id==5 & time_tranche==1
replace sr_sm_se=`se2' if study_id==5 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==5 & time_tranche==1
replace sr_no_se=`se3' if study_id==5 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==5 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==5 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_eff=`beta' if study_id==5 & time_tranche==1
replace sr_fr_se=`se' if study_id==5 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==5 & time_tranche==1
replace lr_s101d`i'_se=_se[`i'.soc_1d] if study_id==5 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==5 & time_tranche==1
replace lr_s102d`i'_se=_se[`i'.soc_2d] if study_id==5 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_eff=`beta' if study_id==5 & time_tranche==1
replace lr_re_se=`se' if study_id==5 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==5 & time_tranche==1
replace lr_un_se=`se2' if study_id==5 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_eff=`beta' if study_id==5 & time_tranche==1
replace lr_pt_se=`se' if study_id==5 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==5 & time_tranche==1
replace lr_ret_se=`se2' if study_id==5 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==5 & time_tranche==1
replace lr_nw_se=`se3' if study_id==5 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==5 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==5 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==5 & time_tranche==1
replace lr_une_se=`se4' if study_id==5 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==5 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==5 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_eff=`beta' if study_id==5 & time_tranche==1
replace lr_kw_se=`se' if study_id==5 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19positive i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_eff=`beta2' if study_id==5 & time_tranche==1
replace lr_sm_se=`se2' if study_id==5 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==5 & time_tranche==1
replace lr_no_se=`se3' if study_id==5 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==5 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==5 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_eff=`beta' if study_id==5 & time_tranche==1
replace lr_fr_se=`se' if study_id==5 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation  i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==5 & time_tranche==1
replace sr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==5 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==5 & time_tranche==1
replace sr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==5 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_adjv_eff=`beta' if study_id==5 & time_tranche==1
replace sr_re_adjv_se=`se' if study_id==5 & time_tranche==1
replace sr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace sr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1

replace sr_un_adjv_eff=`beta2' if study_id==5 & time_tranche==1
replace sr_un_adjv_se=`se2' if study_id==5 & time_tranche==1
replace sr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_adjv_eff=`beta' if study_id==5 & time_tranche==1
replace sr_pt_adjv_se=`se' if study_id==5 & time_tranche==1
replace sr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace sr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1

replace sr_ret_adjv_eff=`beta2' if study_id==5 & time_tranche==1
replace sr_ret_adjv_se=`se2' if study_id==5 & time_tranche==1
replace sr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace sr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1

replace sr_nw_adjv_eff=`beta3' if study_id==5 & time_tranche==1
replace sr_nw_adjv_se=`se3' if study_id==5 & time_tranche==1
replace sr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==5 & time_tranche==1
replace sr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==5 & time_tranche==1

replace sr_une_adjv_eff=`beta4' if study_id==5 & time_tranche==1
replace sr_une_adjv_se=`se4' if study_id==5 & time_tranche==1
replace sr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==5 & time_tranche==1
replace sr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==5 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_adjv_eff=`beta' if study_id==5 & time_tranche==1
replace sr_kw_adjv_se=`se' if study_id==5 & time_tranche==1
replace sr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace sr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_adjv_eff=`beta2' if study_id==5 & time_tranche==1
replace sr_sm_adjv_se=`se2' if study_id==5 & time_tranche==1
replace sr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace sr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1

replace sr_no_adjv_eff=`beta3' if study_id==5 & time_tranche==1
replace sr_no_adjv_se=`se3' if study_id==5 & time_tranche==1
replace sr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==5 & time_tranche==1
replace sr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==5 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_adjv_eff=`beta' if study_id==5 & time_tranche==1
replace sr_fr_adjv_se=`se' if study_id==5 & time_tranche==1
replace sr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace sr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==5 & time_tranche==1
replace lr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==5 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==5 & time_tranche==1
replace lr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==5 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_adjv_eff=`beta' if study_id==5 & time_tranche==1
replace lr_re_adjv_se=`se' if study_id==5 & time_tranche==1
replace lr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace lr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1

replace lr_un_adjv_eff=`beta2' if study_id==5 & time_tranche==1
replace lr_un_adjv_se=`se2' if study_id==5 & time_tranche==1
replace lr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_adjv_eff=`beta' if study_id==5 & time_tranche==1
replace lr_pt_adjv_se=`se' if study_id==5 & time_tranche==1
replace lr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace lr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1

replace lr_ret_adjv_eff=`beta2' if study_id==5 & time_tranche==1
replace lr_ret_adjv_se=`se2' if study_id==5 & time_tranche==1
replace lr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace lr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1

replace lr_nw_adjv_eff=`beta3' if study_id==5 & time_tranche==1
replace lr_nw_adjv_se=`se3' if study_id==5 & time_tranche==1
replace lr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==5 & time_tranche==1
replace lr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==5 & time_tranche==1

replace lr_une_adjv_eff=`beta4' if study_id==5 & time_tranche==1
replace lr_une_adjv_se=`se4' if study_id==5 & time_tranche==1
replace lr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==5 & time_tranche==1
replace lr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==5 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_adjv_eff=`beta' if study_id==5 & time_tranche==1
replace lr_kw_adjv_se=`se' if study_id==5 & time_tranche==1
replace lr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace lr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_adjv_eff=`beta2' if study_id==5 & time_tranche==1
replace lr_sm_adjv_se=`se2' if study_id==5 & time_tranche==1
replace lr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==5 & time_tranche==1
replace lr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==5 & time_tranche==1

replace lr_no_adjv_eff=`beta3' if study_id==5 & time_tranche==1
replace lr_no_adjv_se=`se3' if study_id==5 & time_tranche==1
replace lr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==5 & time_tranche==1
replace lr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==5 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_adjv_eff=`beta' if study_id==5 & time_tranche==1
replace lr_fr_adjv_se=`se' if study_id==5 & time_tranche==1
replace lr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==5 & time_tranche==1
replace lr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==5 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


clear



***************************************************
**NEXT STEPS 
***************************************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "NS edited\NS edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,
tostring avail_from_dt, replace 

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "NS edited\protect_nhs_c19posinfect_temp_NSver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/04/2021", "DMY") & study_wave==3


tab study_wave vacc_status
replace vacc_status=1 if vacc_status>1 & vacc_status!=.
label define vacc_status 0 "No Vacc" 1 "1+ Dose Vacc", replace
label values vacc_status vacc_status
tab study_wave vacc_status


**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2
rename key_worker keyworker


** NEXT STEPS - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq

**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==6 & time_tranche==1
replace entry_n=`entry_n' if study_id==6 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==6 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==6 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==6 & time_tranche==1

list if study_id==6 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
tab soc2010_1d `var', missing row
tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
*tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
rename soc2010_1d soc_1d
rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==6 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==6 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==6 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==6 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult



*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19infection_selfreported i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_eff=`beta' if study_id==6 & time_tranche==1
replace sr_re_se=`se' if study_id==6 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==6 & time_tranche==1
replace sr_un_se=`se2' if study_id==6 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**employment_status	
mepoisson c19infection_selfreported i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_eff=`beta' if study_id==6 & time_tranche==1
replace sr_pt_se=`se' if study_id==6 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==6 & time_tranche==1
replace sr_ret_se=`se2' if study_id==6 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==6 & time_tranche==1
replace sr_nw_se=`se3' if study_id==6 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==6 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==6 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==6 & time_tranche==1
replace sr_une_se=`se4' if study_id==6 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==6 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==6 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_eff=`beta' if study_id==6 & time_tranche==1
replace sr_kw_se=`se' if study_id==6 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_eff=`beta2' if study_id==6 & time_tranche==1
replace sr_sm_se=`se2' if study_id==6 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==6 & time_tranche==1
replace sr_no_se=`se3' if study_id==6 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==6 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==6 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_eff=`beta' if study_id==6 & time_tranche==1
replace sr_fr_se=`se' if study_id==6 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==6 & time_tranche==1
replace lr_s101d`i'_se=_se[`i'.soc_1d] if study_id==6 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==6 & time_tranche==1
replace lr_s102d`i'_se=_se[`i'.soc_2d] if study_id==6 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_eff=`beta' if study_id==6 & time_tranche==1
replace lr_re_se=`se' if study_id==6 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==6 & time_tranche==1
replace lr_un_se=`se2' if study_id==6 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_eff=`beta' if study_id==6 & time_tranche==1
replace lr_pt_se=`se' if study_id==6 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==6 & time_tranche==1
replace lr_ret_se=`se2' if study_id==6 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==6 & time_tranche==1
replace lr_nw_se=`se3' if study_id==6 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==6 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==6 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==6 & time_tranche==1
replace lr_une_se=`se4' if study_id==6 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==6 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==6 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_eff=`beta' if study_id==6 & time_tranche==1
replace lr_kw_se=`se' if study_id==6 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19positive i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_eff=`beta2' if study_id==6 & time_tranche==1
replace lr_sm_se=`se2' if study_id==6 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==6 & time_tranche==1
replace lr_no_se=`se3' if study_id==6 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==6 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==6 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_eff=`beta' if study_id==6 & time_tranche==1
replace lr_fr_se=`se' if study_id==6 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation  i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==6 & time_tranche==1
replace sr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==6 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==6 & time_tranche==1
replace sr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==6 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_adjv_eff=`beta' if study_id==6 & time_tranche==1
replace sr_re_adjv_se=`se' if study_id==6 & time_tranche==1
replace sr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace sr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1

replace sr_un_adjv_eff=`beta2' if study_id==6 & time_tranche==1
replace sr_un_adjv_se=`se2' if study_id==6 & time_tranche==1
replace sr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_adjv_eff=`beta' if study_id==6 & time_tranche==1
replace sr_pt_adjv_se=`se' if study_id==6 & time_tranche==1
replace sr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace sr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1

replace sr_ret_adjv_eff=`beta2' if study_id==6 & time_tranche==1
replace sr_ret_adjv_se=`se2' if study_id==6 & time_tranche==1
replace sr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace sr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1

replace sr_nw_adjv_eff=`beta3' if study_id==6 & time_tranche==1
replace sr_nw_adjv_se=`se3' if study_id==6 & time_tranche==1
replace sr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==6 & time_tranche==1
replace sr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==6 & time_tranche==1

replace sr_une_adjv_eff=`beta4' if study_id==6 & time_tranche==1
replace sr_une_adjv_se=`se4' if study_id==6 & time_tranche==1
replace sr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==6 & time_tranche==1
replace sr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==6 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_adjv_eff=`beta' if study_id==6 & time_tranche==1
replace sr_kw_adjv_se=`se' if study_id==6 & time_tranche==1
replace sr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace sr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_adjv_eff=`beta2' if study_id==6 & time_tranche==1
replace sr_sm_adjv_se=`se2' if study_id==6 & time_tranche==1
replace sr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace sr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1

replace sr_no_adjv_eff=`beta3' if study_id==6 & time_tranche==1
replace sr_no_adjv_se=`se3' if study_id==6 & time_tranche==1
replace sr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==6 & time_tranche==1
replace sr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==6 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_adjv_eff=`beta' if study_id==6 & time_tranche==1
replace sr_fr_adjv_se=`se' if study_id==6 & time_tranche==1
replace sr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace sr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==6 & time_tranche==1
replace lr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==6 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==6 & time_tranche==1
replace lr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==6 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_adjv_eff=`beta' if study_id==6 & time_tranche==1
replace lr_re_adjv_se=`se' if study_id==6 & time_tranche==1
replace lr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace lr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1

replace lr_un_adjv_eff=`beta2' if study_id==6 & time_tranche==1
replace lr_un_adjv_se=`se2' if study_id==6 & time_tranche==1
replace lr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_adjv_eff=`beta' if study_id==6 & time_tranche==1
replace lr_pt_adjv_se=`se' if study_id==6 & time_tranche==1
replace lr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace lr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1

replace lr_ret_adjv_eff=`beta2' if study_id==6 & time_tranche==1
replace lr_ret_adjv_se=`se2' if study_id==6 & time_tranche==1
replace lr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace lr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1

replace lr_nw_adjv_eff=`beta3' if study_id==6 & time_tranche==1
replace lr_nw_adjv_se=`se3' if study_id==6 & time_tranche==1
replace lr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==6 & time_tranche==1
replace lr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==6 & time_tranche==1

replace lr_une_adjv_eff=`beta4' if study_id==6 & time_tranche==1
replace lr_une_adjv_se=`se4' if study_id==6 & time_tranche==1
replace lr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==6 & time_tranche==1
replace lr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==6 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_adjv_eff=`beta' if study_id==6 & time_tranche==1
replace lr_kw_adjv_se=`se' if study_id==6 & time_tranche==1
replace lr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace lr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_adjv_eff=`beta2' if study_id==6 & time_tranche==1
replace lr_sm_adjv_se=`se2' if study_id==6 & time_tranche==1
replace lr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==6 & time_tranche==1
replace lr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==6 & time_tranche==1

replace lr_no_adjv_eff=`beta3' if study_id==6 & time_tranche==1
replace lr_no_adjv_se=`se3' if study_id==6 & time_tranche==1
replace lr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==6 & time_tranche==1
replace lr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==6 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult 
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_adjv_eff=`beta' if study_id==6 & time_tranche==1
replace lr_fr_adjv_se=`se' if study_id==6 & time_tranche==1
replace lr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==6 & time_tranche==1
replace lr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==6 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


clear


***************************************************
**Born in Bradford
***************************************************

**study_id==7

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "bib edited\bib edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,
tostring avail_from_dt, replace 

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "bib edited\protect_nhs_c19posinfect_temp_bibver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/07/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/01/2021", "DMY") & study_wave==2

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/07/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/01/2021", "DMY") & study_wave==2

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/07/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/01/2021", "DMY") & study_wave==2

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/07/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/01/2021", "DMY") & study_wave==2


tab study_wave vacc_status
replace vacc_status=1 if vacc_status>1 & vacc_status!=.
label define vacc_status 0 "No Vacc" 1 "1+ Dose Vacc", replace
label values vacc_status vacc_status
tab study_wave vacc_status


**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
keep if cohort==1

** BIB - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq

**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==7 & time_tranche==1
replace entry_n=`entry_n' if study_id==7 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==7 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==7 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==7 & time_tranche==1

list if study_id==7 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
*tab soc2010_1d `var', missing row
*tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
*tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
*rename soc2010_1d soc_1d
*rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2000
*mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

*preserve 
*use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
*forvalues i = 2(1)9 {
**replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==7 & time_tranche==1
**replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==7 & time_tranche==1

*}
*save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
*restore 

*mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*preserve 
*use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
*foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
*replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==7 & time_tranche==1
*replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==7 & time_tranche==1
*}
*save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
*restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult



*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19infection_selfreported i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*local beta = _b[2.employment]
*local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

*replace sr_re_eff=`beta' if study_id==7 & time_tranche==1
*replace sr_re_se=`se' if study_id==7 & time_tranche==1
*replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
*replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==7 & time_tranche==1
replace sr_un_se=`se2' if study_id==7 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**employment_status	
mepoisson c19infection_selfreported i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*local beta = _b[1.employment_status]
*local se = _se[1.employment_status]

*local beta2 = _b[2.employment_status]
*local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

*replace sr_pt_eff=`beta' if study_id==7 & time_tranche==1
*replace sr_pt_se=`se' if study_id==7 & time_tranche==1
*replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
*replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1

*replace sr_ret_eff=`beta2' if study_id==7 & time_tranche==1
*replace sr_ret_se=`se2' if study_id==7 & time_tranche==1
*replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
*replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==7 & time_tranche==1
replace sr_nw_se=`se3' if study_id==7 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==7 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==7 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==7 & time_tranche==1
replace sr_une_se=`se4' if study_id==7 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==7 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==7 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_eff=`beta' if study_id==7 & time_tranche==1
replace sr_kw_se=`se' if study_id==7 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

*local beta2 = _b[2.home_working]
*local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

*replace sr_sm_eff=`beta2' if study_id==7 & time_tranche==1
*replace sr_sm_se=`se2' if study_id==7 & time_tranche==1
*replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
*replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==7 & time_tranche==1
replace sr_no_se=`se3' if study_id==7 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==7 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==7 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_eff=`beta' if study_id==7 & time_tranche==1
replace sr_fr_se=`se' if study_id==7 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

	
**test positive C19
**SOC 2000
*mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*preserve 
*use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
*forvalues i = 2(1)9 {
*replace lr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==7 & time_tranche==1
*replace lr_s101d`i'_se=_se[`i'.soc_1d] if study_id==7 & time_tranche==1

*}
*save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
*restore 

*mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*preserve 
*use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
*foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
*replace lr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==7 & time_tranche==1
*replace lr_s102d`i'_se=_se[`i'.soc_2d] if study_id==7 & time_tranche==1
*}
*save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
*restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*local beta = _b[2.employment]
*local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

*replace lr_re_eff=`beta' if study_id==7 & time_tranche==1
**replace lr_re_se=`se' if study_id==7 & time_tranche==1
*replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
**replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==7 & time_tranche==1
replace lr_un_se=`se2' if study_id==7 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*local beta = _b[1.employment_status]
*local se = _se[1.employment_status]

**local beta2 = _b[2.employment_status]
*local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

*replace lr_pt_eff=`beta' if study_id==7 & time_tranche==1
*replace lr_pt_se=`se' if study_id==7 & time_tranche==1
*replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
*replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1

*replace lr_ret_eff=`beta2' if study_id==7 & time_tranche==1
*replace lr_ret_se=`se2' if study_id==7 & time_tranche==1
*replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
*replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==7 & time_tranche==1
replace lr_nw_se=`se3' if study_id==7 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==7 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==7 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==7 & time_tranche==1
replace lr_une_se=`se4' if study_id==7 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==7 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==7 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_eff=`beta' if study_id==7 & time_tranche==1
replace lr_kw_se=`se' if study_id==7 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19positive i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
*local beta2 = _b[2.home_working]
*local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

*replace lr_sm_eff=`beta2' if study_id==7 & time_tranche==1
*replace lr_sm_se=`se2' if study_id==7 & time_tranche==1
*replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
*replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==7 & time_tranche==1
replace lr_no_se=`se3' if study_id==7 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==7 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==7 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult startvalues(constantonly)	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_eff=`beta' if study_id==7 & time_tranche==1
replace lr_fr_se=`se' if study_id==7 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation  i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
*mepoisson c19infection_selfreported i.soc_1d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr *vce(robust) difficult

*preserve 
*use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
*forvalues i = 2(1)9 {
*replace sr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==7 & time_tranche==1
*replace sr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==7 & time_tranche==1

*}
*save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
*restore 

*mepoisson c19infection_selfreported i.soc_2d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr *vce(robust) difficult

*preserve 
*use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
*foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
*replace sr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==7 & time_tranche==1
*replace sr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==7 & time_tranche==1
*}
*save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
*restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*local beta = _b[2.employment]
*local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

*replace sr_re_adjv_eff=`beta' if study_id==7 & time_tranche==1
*replace sr_re_adjv_se=`se' if study_id==7 & time_tranche==1
*replace sr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
*replace sr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1

replace sr_un_adjv_eff=`beta2' if study_id==7 & time_tranche==1
replace sr_un_adjv_se=`se2' if study_id==7 & time_tranche==1
replace sr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*local beta = _b[1.employment_status]
*local se = _se[1.employment_status]

*local beta2 = _b[2.employment_status]
*local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

*replace sr_pt_adjv_eff=`beta' if study_id==7 & time_tranche==1
*replace sr_pt_adjv_se=`se' if study_id==7 & time_tranche==1
*replace sr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
*replace sr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1

*replace sr_ret_adjv_eff=`beta2' if study_id==7 & time_tranche==1
*replace sr_ret_adjv_se=`se2' if study_id==7 & time_tranche==1
*replace sr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
*replace sr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1

replace sr_nw_adjv_eff=`beta3' if study_id==7 & time_tranche==1
replace sr_nw_adjv_se=`se3' if study_id==7 & time_tranche==1
replace sr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==7 & time_tranche==1
replace sr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==7 & time_tranche==1

replace sr_une_adjv_eff=`beta4' if study_id==7 & time_tranche==1
replace sr_une_adjv_se=`se4' if study_id==7 & time_tranche==1
replace sr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==7 & time_tranche==1
replace sr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==7 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_adjv_eff=`beta' if study_id==7 & time_tranche==1
replace sr_kw_adjv_se=`se' if study_id==7 & time_tranche==1
replace sr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
replace sr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

*local beta2 = _b[2.home_working]
*local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

*replace sr_sm_adjv_eff=`beta2' if study_id==7 & time_tranche==1
*replace sr_sm_adjv_se=`se2' if study_id==7 & time_tranche==1
*replace sr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
*replace sr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1

replace sr_no_adjv_eff=`beta3' if study_id==7 & time_tranche==1
replace sr_no_adjv_se=`se3' if study_id==7 & time_tranche==1
replace sr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==7 & time_tranche==1
replace sr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==7 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult startvalues(constantonly)
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_adjv_eff=`beta' if study_id==7 & time_tranche==1
replace sr_fr_adjv_se=`se' if study_id==7 & time_tranche==1
replace sr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
replace sr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 




	
**test positive C19
**SOC 2000
*mepoisson c19positive i.soc_1d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

*preserve 
*use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
*forvalues i = 2(1)9 {
*replace lr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==7 & time_tranche==1
*replace lr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==7 & time_tranche==1

*}
*save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
*restore 

*mepoisson c19positive i.soc_2d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*preserve 
*use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
*foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
*replace lr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==7 & time_tranche==1
*replace lr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==7 & time_tranche==1
*}
*save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
*restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*local beta = _b[2.employment]
*local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

*replace lr_re_adjv_eff=`beta' if study_id==7 & time_tranche==1
*replace lr_re_adjv_se=`se' if study_id==7 & time_tranche==1
*replace lr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
*replace lr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1

replace lr_un_adjv_eff=`beta2' if study_id==7 & time_tranche==1
replace lr_un_adjv_se=`se2' if study_id==7 & time_tranche==1
replace lr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*local beta = _b[1.employment_status]
*local se = _se[1.employment_status]

*local beta2 = _b[2.employment_status]
*local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

*replace lr_pt_adjv_eff=`beta' if study_id==7 & time_tranche==1
*replace lr_pt_adjv_se=`se' if study_id==7 & time_tranche==1
*replace lr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
*replace lr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1

*replace lr_ret_adjv_eff=`beta2' if study_id==7 & time_tranche==1
*replace lr_ret_adjv_se=`se2' if study_id==7 & time_tranche==1
*replace lr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
*replace lr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1

replace lr_nw_adjv_eff=`beta3' if study_id==7 & time_tranche==1
replace lr_nw_adjv_se=`se3' if study_id==7 & time_tranche==1
replace lr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==7 & time_tranche==1
replace lr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==7 & time_tranche==1

replace lr_une_adjv_eff=`beta4' if study_id==7 & time_tranche==1
replace lr_une_adjv_se=`se4' if study_id==7 & time_tranche==1
replace lr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==7 & time_tranche==1
replace lr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==7 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_adjv_eff=`beta' if study_id==7 & time_tranche==1
replace lr_kw_adjv_se=`se' if study_id==7 & time_tranche==1
replace lr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
replace lr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

*local beta2 = _b[2.home_working]
*local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

*replace lr_sm_adjv_eff=`beta2' if study_id==7 & time_tranche==1
*replace lr_sm_adjv_se=`se2' if study_id==7 & time_tranche==1
*replace lr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==7 & time_tranche==1
*replace lr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==7 & time_tranche==1

replace lr_no_adjv_eff=`beta3' if study_id==7 & time_tranche==1
replace lr_no_adjv_se=`se3' if study_id==7 & time_tranche==1
replace lr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==7 & time_tranche==1
replace lr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==7 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult startvalues(constantonly)
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_adjv_eff=`beta' if study_id==7 & time_tranche==1
replace lr_fr_adjv_se=`se' if study_id==7 & time_tranche==1
replace lr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==7 & time_tranche==1
replace lr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==7 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


clear



***************************************************
**GENERATION SCOTLAND 
***************************************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file - note testing info for Scotland not available
use "Genscot edited\Genscot edited long version.dta", clear



*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
*tab study_wave,

*sort llc_0007_stud_id study_wave
*merge 1:1 llc_0007_stud_id study_wave using "Genscot edited\protect_nhs_c19posinfect_temp_Genscotver"
*drop if _merge==2	


**Last min formatting
*replace c19positive=0 if c19positive==.
*label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
*label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2
*rename key_worker keyworker


**keep if aged older the 18 and under 65
keep if age>=18 & age<=65

** GEN SCOT - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq

**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
*tab c19positive	
*count if c19positive==1
*local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==8 & time_tranche==1
replace entry_n=`entry_n' if study_id==8 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==8 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==8 & time_tranche==1
*replace linkpos_no=`linkpos_no' if study_id==8 & time_tranche==1

list if study_id==8 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
*tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
*tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported  {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
*tab soc2010_1d `var', missing row
*tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}

replace furlough=0 if furlough==97 | furlough==99
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported  {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
*tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
*rename soc2010_1d soc_1d
*rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2000
*mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

*preserve 
*use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
*forvalues i = 2(1)9 {
*replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==8 & time_tranche==1
*replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==8 & time_tranche==1

*}
*save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
*restore 

*mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*preserve 
*use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
*foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
*replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==8 & time_tranche==1
*replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==8 & time_tranche==1
*}
*save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
*restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult



*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19infection_selfreported i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]	

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_eff=`beta' if study_id==8 & time_tranche==1
replace sr_re_se=`se' if study_id==8 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==8 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==8 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==8 & time_tranche==1
replace sr_un_se=`se2' if study_id==8 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==8 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==8 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**employment_status	
mepoisson c19infection_selfreported i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*local beta = _b[1.employment_status]
*local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

*replace sr_pt_eff=`beta' if study_id==8 & time_tranche==1
*replace sr_pt_se=`se' if study_id==8 & time_tranche==1
*replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==8 & time_tranche==1
*replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==8 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==8 & time_tranche==1
replace sr_ret_se=`se2' if study_id==8 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==8 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==8 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==8 & time_tranche==1
replace sr_nw_se=`se3' if study_id==8 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==8 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==8 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==8 & time_tranche==1
replace sr_une_se=`se4' if study_id==8 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==8 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==8 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_eff=`beta' if study_id==8 & time_tranche==1
replace sr_kw_se=`se' if study_id==8 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==8 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==8 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_eff=`beta2' if study_id==8 & time_tranche==1
replace sr_sm_se=`se2' if study_id==8 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==8 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==8 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==8 & time_tranche==1
replace sr_no_se=`se3' if study_id==8 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==8 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==8 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_eff=`beta' if study_id==8 & time_tranche==1
replace sr_fr_se=`se' if study_id==8 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==8 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==8 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

	

****Repeated Adjusted for key confounders - missing i.deprivation  i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19


**employment status
mepoisson c19infection_selfreported i.employment i.sex i.vacc_status  i.age_entry i.ethnicity_red  i.housing_composition i.education household_size  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_adjv_eff=`beta' if study_id==8 & time_tranche==1
replace sr_re_adjv_se=`se' if study_id==8 & time_tranche==1
replace sr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==8 & time_tranche==1
replace sr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==8 & time_tranche==1

replace sr_un_adjv_eff=`beta2' if study_id==8 & time_tranche==1
replace sr_un_adjv_se=`se2' if study_id==8 & time_tranche==1
replace sr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==8 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==8 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.vacc_status  i.age_entry i.ethnicity_red  i.housing_composition i.education household_size  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

*local beta = _b[1.employment_status]
*local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

*replace sr_pt_adjv_eff=`beta' if study_id==8 & time_tranche==1
*replace sr_pt_adjv_se=`se' if study_id==8 & time_tranche==1
*replace sr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==8 & time_tranche==1
*replace sr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==8 & time_tranche==1

replace sr_ret_adjv_eff=`beta2' if study_id==8 & time_tranche==1
replace sr_ret_adjv_se=`se2' if study_id==8 & time_tranche==1
replace sr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==8 & time_tranche==1
replace sr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==8 & time_tranche==1

replace sr_nw_adjv_eff=`beta3' if study_id==8 & time_tranche==1
replace sr_nw_adjv_se=`se3' if study_id==8 & time_tranche==1
replace sr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==8 & time_tranche==1
replace sr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==8 & time_tranche==1

replace sr_une_adjv_eff=`beta4' if study_id==8 & time_tranche==1
replace sr_une_adjv_se=`se4' if study_id==8 & time_tranche==1
replace sr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==8 & time_tranche==1
replace sr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==8 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.vacc_status  i.age_entry i.ethnicity_red  i.housing_composition i.education household_size i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_adjv_eff=`beta' if study_id==8 & time_tranche==1
replace sr_kw_adjv_se=`se' if study_id==8 & time_tranche==1
replace sr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==8 & time_tranche==1
replace sr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==8 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.vacc_status  i.age_entry i.ethnicity_red  i.housing_composition i.education household_size  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_adjv_eff=`beta2' if study_id==8 & time_tranche==1
replace sr_sm_adjv_se=`se2' if study_id==8 & time_tranche==1
replace sr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==8 & time_tranche==1
replace sr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==8 & time_tranche==1

replace sr_no_adjv_eff=`beta3' if study_id==8 & time_tranche==1
replace sr_no_adjv_se=`se3' if study_id==8 & time_tranche==1
replace sr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==8 & time_tranche==1
replace sr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==8 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.vacc_status  i.age_entry i.ethnicity_red  i.housing_composition i.education household_size i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_adjv_eff=`beta' if study_id==8 & time_tranche==1
replace sr_fr_adjv_se=`se' if study_id==8 & time_tranche==1
replace sr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==8 & time_tranche==1
replace sr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==8 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



clear





*******************************
**The Extended Cohort for E-health, Envirnoment, and DNA (EXCEED)" if study_id==9
*******************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "exceed edited\exceed edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,
tostring avail_from_dt, replace 

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "exceed edited\protect_nhs_c19posinfect_temp_exceedver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/07/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/11/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/07/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/11/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/07/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/11/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/07/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/11/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/04/2021", "DMY") & study_wave==3


tab study_wave vacc_status
replace vacc_status=1 if vacc_status>1 & vacc_status!=.
label define vacc_status 0 "No Vacc" 1 "1+ Dose Vacc", replace
label values vacc_status vacc_status
tab study_wave vacc_status


**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2
*rename key_worker keyworker


** exceed - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq

**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==9 & time_tranche==1
replace entry_n=`entry_n' if study_id==9 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==9 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==9 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==9 & time_tranche==1

list if study_id==9 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
tab soc2010_1d `var', missing row
tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
*tab employment_status `var', missing row

**Home working	
*tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
*tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


tab employment 
*tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
rename soc2010_1d soc_1d
rename soc2010_2d soc_2d
replace soc_2d=. if soc_2d<0
***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult
preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==9 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==9 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==9 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==9 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19infection_selfreported i.employment   i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_eff=`beta' if study_id==9 & time_tranche==1
replace sr_re_se=`se' if study_id==9 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==9 & time_tranche==1
replace sr_un_se=`se2' if study_id==9 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==9 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==9 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 





**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_eff=`beta' if study_id==9 & time_tranche==1
replace sr_kw_se=`se' if study_id==9 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 




**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_eff=`beta' if study_id==9 & time_tranche==1
replace sr_fr_se=`se' if study_id==9 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==9 & time_tranche==1
replace lr_s101d`i'_se=_se[`i'.soc_1d] if study_id==9 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==9 & time_tranche==1
replace lr_s102d`i'_se=_se[`i'.soc_2d] if study_id==9 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_eff=`beta' if study_id==9 & time_tranche==1
replace lr_re_se=`se' if study_id==9 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==9 & time_tranche==1
replace lr_un_se=`se2' if study_id==9 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==9 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==9 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_eff=`beta' if study_id==9 & time_tranche==1
replace lr_kw_se=`se' if study_id==9 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_eff=`beta' if study_id==9 & time_tranche==1
replace lr_fr_se=`se' if study_id==9 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation  i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19 
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.vacc_status  i.ethnicity_red i.age_entry i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==9 & time_tranche==1
replace sr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==9 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==9 & time_tranche==1
replace sr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==9 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.vacc_status  i.ethnicity_red i.age_entry i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_adjv_eff=`beta' if study_id==9 & time_tranche==1
replace sr_re_adjv_se=`se' if study_id==9 & time_tranche==1
replace sr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace sr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1

replace sr_un_adjv_eff=`beta2' if study_id==9 & time_tranche==1
replace sr_un_adjv_se=`se2' if study_id==9 & time_tranche==1
replace sr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==9 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==9 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 




**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.vacc_status  i.ethnicity_red i.age_entry i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_adjv_eff=`beta' if study_id==9 & time_tranche==1
replace sr_kw_adjv_se=`se' if study_id==9 & time_tranche==1
replace sr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace sr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.vacc_status  i.ethnicity_red i.age_entry i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_adjv_eff=`beta' if study_id==9 & time_tranche==1
replace sr_fr_adjv_se=`se' if study_id==9 & time_tranche==1
replace sr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace sr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.vacc_status  i.ethnicity_red i.age_entry i.housing_composition i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==9 & time_tranche==1
replace lr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==9 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==9 & time_tranche==1
replace lr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==9 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_adjv_eff=`beta' if study_id==9 & time_tranche==1
replace lr_re_adjv_se=`se' if study_id==9 & time_tranche==1
replace lr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace lr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1

replace lr_un_adjv_eff=`beta2' if study_id==9 & time_tranche==1
replace lr_un_adjv_se=`se2' if study_id==9 & time_tranche==1
replace lr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==9 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==9 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.sex i.vacc_status  i.ethnicity_red i.age_entry i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_adjv_eff=`beta' if study_id==9 & time_tranche==1
replace lr_kw_adjv_se=`se' if study_id==9 & time_tranche==1
replace lr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace lr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**Furlough
mepoisson c19positive i.furlough i.sex i.vacc_status  i.ethnicity_red i.age_entry i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_adjv_eff=`beta' if study_id==9 & time_tranche==1
replace lr_fr_adjv_se=`se' if study_id==9 & time_tranche==1
replace lr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==9 & time_tranche==1
replace lr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==9 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


clear





******************************************************************************
**NORTHERN IRELAND COHORT FOR THE LONGITUDINAL STUDY OF AGEING (NICOLA) - Study_id==10
******************************************************************************

**notes - no NHS linked data for northern ireland, no sex or ethnicity data, no home_working or soc data
**no information on when covid occurred so no time_tranche data

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "nicola edited\nicola edited long version.dta", clear

drop if age_entry>=5

*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
*tab study_wave,
*tostring avail_from_dt, replace 

*sort llc_0007_stud_id study_wave
*merge 1:1 llc_0007_stud_id study_wave using "nicola edited\protect_nhs_c19posinfect_temp_nicolaver"
*drop if _merge==2	


**Last min formatting
*replace c19positive=0 if c19positive==.
*label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
*label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2
*rename key_worker keyworker


** nicola - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq

**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
*tab c19positive	
*count if c19positive==1
*local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==10 & time_tranche==1
replace entry_n=`entry_n' if study_id==10 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==10 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==10 & time_tranche==1
*replace linkpos_no=`linkpos_no' if study_id==10 & time_tranche==1

list if study_id==10 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
*tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
*tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
*tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
*tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
*tab soc2010_1d `var', missing row
*tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
*tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported {

*tab sex `var', missing row
*tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
*tab housing_composition  `var', missing row
tab household_size  `var', missing row
tab livepartner  `var', missing row
tab housing_tenure  `var', missing row
tab education  `var', missing row


}


tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
*rename soc2010_1d soc_1d
*rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19


**employment
mepoisson c19infection_selfreported i.employment   || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_eff=`beta' if study_id==10 & time_tranche==1
replace sr_re_se=`se' if study_id==10 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==10 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==10 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==10 & time_tranche==1
replace sr_un_se=`se2' if study_id==10 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==10 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==10 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**employment_status	
mepoisson c19infection_selfreported i.employment_status   || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_eff=`beta' if study_id==10 & time_tranche==1
replace sr_pt_se=`se' if study_id==10 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==10 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==10 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==10 & time_tranche==1
replace sr_ret_se=`se2' if study_id==10 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==10 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==10 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==10 & time_tranche==1
replace sr_nw_se=`se3' if study_id==10 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==10 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==10 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==10 & time_tranche==1
replace sr_une_se=`se4' if study_id==10 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==10 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==10 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Key worker	
mepoisson c19infection_selfreported i.keyworker  if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_eff=`beta' if study_id==10 & time_tranche==1
replace sr_kw_se=`se' if study_id==10 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==10 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==10 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	




**Furlough
mepoisson c19infection_selfreported i.furlough  if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_eff=`beta' if study_id==10 & time_tranche==1
replace sr_fr_se=`se' if study_id==10 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==10 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==10 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

	

****Repeated Adjusted for key confounders - missing i.deprivation  i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000


**employment status
mepoisson c19infection_selfreported i.employment i.age_entry household_size i.livepartner i.housing_tenure i.education   || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_adjv_eff=`beta' if study_id==10 & time_tranche==1
replace sr_re_adjv_se=`se' if study_id==10 & time_tranche==1
replace sr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==10 & time_tranche==1
replace sr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==10 & time_tranche==1

replace sr_un_adjv_eff=`beta2' if study_id==10 & time_tranche==1
replace sr_un_adjv_se=`se2' if study_id==10 & time_tranche==1
replace sr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==10 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==10 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.age_entry household_size i.livepartner i.housing_tenure i.education   || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_adjv_eff=`beta' if study_id==10 & time_tranche==1
replace sr_pt_adjv_se=`se' if study_id==10 & time_tranche==1
replace sr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==10 & time_tranche==1
replace sr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==10 & time_tranche==1

replace sr_ret_adjv_eff=`beta2' if study_id==10 & time_tranche==1
replace sr_ret_adjv_se=`se2' if study_id==10 & time_tranche==1
replace sr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==10 & time_tranche==1
replace sr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==10 & time_tranche==1

replace sr_nw_adjv_eff=`beta3' if study_id==10 & time_tranche==1
replace sr_nw_adjv_se=`se3' if study_id==10 & time_tranche==1
replace sr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==10 & time_tranche==1
replace sr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==10 & time_tranche==1

replace sr_une_adjv_eff=`beta4' if study_id==10 & time_tranche==1
replace sr_une_adjv_se=`se4' if study_id==10 & time_tranche==1
replace sr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==10 & time_tranche==1
replace sr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==10 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.age_entry household_size i.livepartner i.housing_tenure i.education  if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_adjv_eff=`beta' if study_id==10 & time_tranche==1
replace sr_kw_adjv_se=`se' if study_id==10 & time_tranche==1
replace sr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==10 & time_tranche==1
replace sr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==10 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	


**Furlough
mepoisson c19infection_selfreported i.furlough i.age_entry household_size i.livepartner i.housing_tenure i.education  if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_adjv_eff=`beta' if study_id==10 & time_tranche==1
replace sr_fr_adjv_se=`se' if study_id==10 & time_tranche==1
replace sr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==10 & time_tranche==1
replace sr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==10 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



clear

*******************************
**COVID19 Psychiatry and Neurological Genetics (COPING) study study_id==11
*******************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "coping edited\coping edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "coping edited\protect_nhs_c19posinfect_temp_copingver"
drop if _merge==2	


**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 




** coping - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq

**tab self-reported infection 
*tab c19infection_selfreported
*count if c19infection_selfreported==1
*local selfinf_n = r(N)
**tab NHS digital indicated infection
*tab c19postest_selfreported	
*count if c19postest_selfreported==1
*local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==11 & time_tranche==1
replace entry_n=`entry_n' if study_id==11 & time_tranche==1
*replace selfinf_n=`selfinf_n' if study_id==11 & time_tranche==1
*replace selfpos_no=`selfpos_no' if study_id==11 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==11 & time_tranche==1

list if study_id==11 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace

restore

**by study wave
**tab self-reported infection 
*tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
*tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
*tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
*tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
*tab soc2010_1d `var', missing row
*tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
**tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19positive {

tab sex `var', missing row
tab ethnicity_red `var', missing row
*tab deprivation_imd  `var', missing row
tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
*tab housing_composition  `var', missing row


}


tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
*rename soc2010_1d soc_1d
*rename soc2010_2d soc_2d

***INITIAL ANALYSIS

	
**test positive C19
**employment status
mepoisson c19positive i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_eff=`beta' if study_id==11 & time_tranche==1
replace lr_re_se=`se' if study_id==11 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==11 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==11 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==11 & time_tranche==1
replace lr_un_se=`se2' if study_id==11 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==11 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==11 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_eff=`beta' if study_id==11 & time_tranche==1
replace lr_pt_se=`se' if study_id==11 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==11 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==11 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==11 & time_tranche==1
replace lr_ret_se=`se2' if study_id==11 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==11 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==11 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==11 & time_tranche==1
replace lr_nw_se=`se3' if study_id==11 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==11 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==11 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==11 & time_tranche==1
replace lr_une_se=`se4' if study_id==11 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==11 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==11 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_eff=`beta' if study_id==11 & time_tranche==1
replace lr_kw_se=`se' if study_id==11 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==11 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==11 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 




**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_eff=`beta' if study_id==11 & time_tranche==1
replace lr_fr_se=`se' if study_id==11 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==11 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==11 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation  i.hm_location
***INITIAL ANALYSIS


	
**test positive C19
**employment
mepoisson c19positive i.employment i.sex i.vacc_status  i.ethnicity_red i.age_entry i.education i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_adjv_eff=`beta' if study_id==11 & time_tranche==1
replace lr_re_adjv_se=`se' if study_id==11 & time_tranche==1
replace lr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==11 & time_tranche==1
replace lr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==11 & time_tranche==1

replace lr_un_adjv_eff=`beta2' if study_id==11 & time_tranche==1
replace lr_un_adjv_se=`se2' if study_id==11 & time_tranche==1
replace lr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==11 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==11 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.vacc_status  i.ethnicity_red i.age_entry i.education i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_adjv_eff=`beta' if study_id==11 & time_tranche==1
replace lr_pt_adjv_se=`se' if study_id==11 & time_tranche==1
replace lr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==11 & time_tranche==1
replace lr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==11 & time_tranche==1

replace lr_ret_adjv_eff=`beta2' if study_id==11 & time_tranche==1
replace lr_ret_adjv_se=`se2' if study_id==11 & time_tranche==1
replace lr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==11 & time_tranche==1
replace lr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==11 & time_tranche==1

replace lr_nw_adjv_eff=`beta3' if study_id==11 & time_tranche==1
replace lr_nw_adjv_se=`se3' if study_id==11 & time_tranche==1
replace lr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==11 & time_tranche==1
replace lr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==11 & time_tranche==1

replace lr_une_adjv_eff=`beta4' if study_id==11 & time_tranche==1
replace lr_une_adjv_se=`se4' if study_id==11 & time_tranche==1
replace lr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==11 & time_tranche==1
replace lr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==11 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.vacc_status  i.ethnicity_red i.age_entry i.education i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_adjv_eff=`beta' if study_id==11 & time_tranche==1
replace lr_kw_adjv_se=`se' if study_id==11 & time_tranche==1
replace lr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==11 & time_tranche==1
replace lr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==11 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 





**Furlough
mepoisson c19positive i.furlough i.sex i.vacc_status  i.ethnicity_red i.age_entry i.education i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_adjv_eff=`beta' if study_id==11 & time_tranche==1
replace lr_fr_adjv_se=`se' if study_id==11 & time_tranche==1
replace lr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==11 & time_tranche==1
replace lr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==11 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


clear






*******************************
**THE GENETIC LINKS TO ANXIETY AND DEPRESSION (GLAD) study_id==12
*******************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "glad edited\glad edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "glad edited\protect_nhs_c19posinfect_temp_gladver"
drop if _merge==2	


**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 




** glad - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq

**tab self-reported infection 
*tab c19infection_selfreported
*count if c19infection_selfreported==1
*local selfinf_n = r(N)
**tab NHS digital indicated infection
*tab c19postest_selfreported	
*count if c19postest_selfreported==1
*local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==12 & time_tranche==1
replace entry_n=`entry_n' if study_id==12 & time_tranche==1
*replace selfinf_n=`selfinf_n' if study_id==12 & time_tranche==1
*replace selfpos_no=`selfpos_no' if study_id==12 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==12 & time_tranche==1

list if study_id==12 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace

restore

**by study wave
**tab self-reported infection 
*tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
*tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
*tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
*tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
*tab soc2010_1d `var', missing row
*tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
**tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19positive {

tab sex `var', missing row
tab ethnicity_red `var', missing row
*tab deprivation_imd  `var', missing row
tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
*tab housing_composition  `var', missing row


}


tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
*rename soc2010_1d soc_1d
*rename soc2010_2d soc_2d

***INITIAL ANALYSIS

	
**test positive C19
**employment status
mepoisson c19positive i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_eff=`beta' if study_id==12 & time_tranche==1
replace lr_re_se=`se' if study_id==12 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==12 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==12 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==12 & time_tranche==1
replace lr_un_se=`se2' if study_id==12 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==12 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==12 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_eff=`beta' if study_id==12 & time_tranche==1
replace lr_pt_se=`se' if study_id==12 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==12 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==12 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==12 & time_tranche==1
replace lr_ret_se=`se2' if study_id==12 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==12 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==12 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==12 & time_tranche==1
replace lr_nw_se=`se3' if study_id==12 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==12 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==12 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==12 & time_tranche==1
replace lr_une_se=`se4' if study_id==12 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==12 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==12 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_eff=`beta' if study_id==12 & time_tranche==1
replace lr_kw_se=`se' if study_id==12 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==12 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==12 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 




**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_eff=`beta' if study_id==12 & time_tranche==1
replace lr_fr_se=`se' if study_id==12 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==12 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==12 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation  i.hm_location
***INITIAL ANALYSIS


	
**test positive C19
**employment
mepoisson c19positive i.employment i.sex i.vacc_status  i.ethnicity_red i.age_entry i.education i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_adjv_eff=`beta' if study_id==12 & time_tranche==1
replace lr_re_adjv_se=`se' if study_id==12 & time_tranche==1
replace lr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==12 & time_tranche==1
replace lr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==12 & time_tranche==1

replace lr_un_adjv_eff=`beta2' if study_id==12 & time_tranche==1
replace lr_un_adjv_se=`se2' if study_id==12 & time_tranche==1
replace lr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==12 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==12 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.vacc_status  i.ethnicity_red i.age_entry i.education i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_adjv_eff=`beta' if study_id==12 & time_tranche==1
replace lr_pt_adjv_se=`se' if study_id==12 & time_tranche==1
replace lr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==12 & time_tranche==1
replace lr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==12 & time_tranche==1

replace lr_ret_adjv_eff=`beta2' if study_id==12 & time_tranche==1
replace lr_ret_adjv_se=`se2' if study_id==12 & time_tranche==1
replace lr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==12 & time_tranche==1
replace lr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==12 & time_tranche==1

replace lr_nw_adjv_eff=`beta3' if study_id==12 & time_tranche==1
replace lr_nw_adjv_se=`se3' if study_id==12 & time_tranche==1
replace lr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==12 & time_tranche==1
replace lr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==12 & time_tranche==1

replace lr_une_adjv_eff=`beta4' if study_id==12 & time_tranche==1
replace lr_une_adjv_se=`se4' if study_id==12 & time_tranche==1
replace lr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==12 & time_tranche==1
replace lr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==12 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.vacc_status  i.ethnicity_red i.age_entry i.education i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_adjv_eff=`beta' if study_id==12 & time_tranche==1
replace lr_kw_adjv_se=`se' if study_id==12 & time_tranche==1
replace lr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==12 & time_tranche==1
replace lr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==12 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 





**Furlough
mepoisson c19positive i.furlough i.sex i.vacc_status  i.ethnicity_red i.age_entry i.education i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_adjv_eff=`beta' if study_id==12 & time_tranche==1
replace lr_fr_adjv_se=`se' if study_id==12 & time_tranche==1
replace lr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==12 & time_tranche==1
replace lr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==12 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


clear



*******************************
**TRACK COVID 19 -  NO EMPLOYMENT DATA STUDY_ID==13 
*******************************




*******************************
**TWINS UK Study_id==14 - RETURN TO COMPLETE ONCE NEW VERSION OF DATA IS AVAILABLE 
*******************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "twinsuk edited\twinsuk edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,
*tostring avail_from_dt, replace 
*drop _merge
sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "twinsuk edited\protect_nhs_c19posinfect_temp_twinsukver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/09/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/12/2020", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/09/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/12/2020", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/09/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/12/2020", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/09/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/12/2020", "DMY") & study_wave==3


tab study_wave vacc_status
replace vacc_status=1 if vacc_status>1 & vacc_status!=.
label define vacc_status 0 "No Vacc" 1 "1+ Dose Vacc", replace
label values vacc_status vacc_status
tab study_wave vacc_status



**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2

drop if age>65


** twinsuk - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq

**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==14 & time_tranche==1
replace entry_n=`entry_n' if study_id==14 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==14 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==14 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==14 & time_tranche==1

list if study_id==14 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
*tab soc2010_1d `var', missing row
*tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
*tab employment `var', missing row
	
*tab employment_status `var', missing row

**Home working	
*tab home_working `var', missing row

**Furlough
*tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
*tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


*tab employment 
*tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
*rename soc2010_1d soc_1d
*rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_eff=`beta' if study_id==14 & time_tranche==1
replace sr_kw_se=`se' if study_id==14 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==14 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==14 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



	
**test positive C19


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_eff=`beta' if study_id==14 & time_tranche==1
replace lr_kw_se=`se' if study_id==14 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==14 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==14 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 





****Repeated Adjusted for key confounders - missing i.deprivation  i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.vacc_status  i.age_entry i.ethnicity_red  i.housing_composition i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_adjv_eff=`beta' if study_id==14 & time_tranche==1
replace sr_kw_adjv_se=`se' if study_id==14 & time_tranche==1
replace sr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==14 & time_tranche==1
replace sr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==14 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



	
**test positive C19


**Key worker	
mepoisson c19positive i.keyworker i.sex i.vacc_status  i.age_entry i.ethnicity_red  i.housing_composition i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult startvalues(constantonly)
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_adjv_eff=`beta' if study_id==14 & time_tranche==1
replace lr_kw_adjv_se=`se' if study_id==14 & time_tranche==1
replace lr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==14 & time_tranche==1
replace lr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==14 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



clear





*******************************
**THE AVON LONGITUDINAL STUDY OF PARENTS AND CHILDREN (ALSPAC) - Study_id==15
*******************************

***RETURN TO CHECK THE LINKED DATA ONCE AVAILABLE

**study_id==15

**NO LINK TO NHS TESTING DATA CHECK WITH LLC (START THIS SECTION AGAIN)

**Open and merge NHS data with UKHLS file
use "alspac edited\alspac edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,


sort llc_0007_stud_id study_wave
*drop _merge
merge m:1 llc_0007_stud_id study_wave using "alspac edited\protect_nhs_c19posinfect_temp_alspacver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/07/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/11/2020", "DMY") & study_wave==3
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==4

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/07/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/11/2020", "DMY") & study_wave==3
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/04/2021", "DMY") & study_wave==4

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/07/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/11/2020", "DMY") & study_wave==3
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/04/2021", "DMY") & study_wave==4

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/07/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/11/2020", "DMY") & study_wave==3
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==4


tab study_wave vacc_status
replace vacc_status=1 if vacc_status>1 & vacc_status!=.
label define vacc_status 0 "No Vacc" 1 "1+ Dose Vacc", replace
label values vacc_status vacc_status
tab study_wave vacc_status


**Modify the self-reported data as appears to be have you had covid at anytime not since last wave
**Readjusted so can only have covid once
tab study_wave c19infection_selfreported 
tab pandemic_timetranche c19infection_selfreported 
sort study_wave
replace c19infection_selfreported=0 if c19infection_selfreported[_n-1]==1  & study_wave>1
replace c19infection_selfreported=0 if c19infection_selfreported[_n-2]==1  & study_wave>2
replace c19infection_selfreported=0 if c19infection_selfreported[_n-3]==1  & study_wave>3
tab study_wave c19infection_selfreported 
tab pandemic_timetranche c19infection_selfreported 

tab study_wave c19postest_selfreported 
tab pandemic_timetranche c19postest_selfreported 
replace c19postest_selfreported=0 if c19postest_selfreported[_n-1]==1  & study_wave>1
replace c19postest_selfreported=0 if c19postest_selfreported[_n-2]==1  & study_wave>2
replace c19postest_selfreported=0 if c19postest_selfreported[_n-3]==1  & study_wave>3
tab study_wave c19postest_selfreported 
tab pandemic_timetranche c19postest_selfreported 


**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2

drop if age>65

** BCS1970 - descriptive statistics
quietly tab llc_0007_stud_id
return list
local sample_n =  r(r)
local entry_n =  r(N)


**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==15 & time_tranche==1
replace entry_n=`entry_n' if study_id==15 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==15 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==15 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==15 & time_tranche==1

list if study_id==15 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
*tab soc2010_1d `var', missing row
*tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}

numlabel, add

tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
*rename soc2010_1d soc_1d
*rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2010
**1 digit
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==15 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==15 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==15 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==15 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 
	



**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult



**employment
mepoisson c19infection_selfreported i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_eff=`beta' if study_id==15 & time_tranche==1
replace sr_re_se=`se' if study_id==15 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==15 & time_tranche==1
replace sr_un_se=`se2' if study_id==15 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


tab employment_status c19infection_selfreported

**employment_status	
mepoisson c19infection_selfreported i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_eff=`beta' if study_id==15 & time_tranche==1
replace sr_pt_se=`se' if study_id==15 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==15 & time_tranche==1
replace sr_ret_se=`se2' if study_id==15 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==15 & time_tranche==1
replace sr_nw_se=`se3' if study_id==15 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==15 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==15 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==15 & time_tranche==1
replace sr_une_se=`se4' if study_id==15 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==15 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==15 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

tab keyworker

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_eff=`beta' if study_id==15 & time_tranche==1
replace sr_kw_se=`se' if study_id==15 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_eff=`beta2' if study_id==15 & time_tranche==1
replace sr_sm_se=`se2' if study_id==15 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==15 & time_tranche==1
replace sr_no_se=`se3' if study_id==15 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==15 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==15 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_eff=`beta' if study_id==15 & time_tranche==1
replace sr_fr_se=`se' if study_id==15 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==15 & time_tranche==1
replace lr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==15 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==15 & time_tranche==1
replace lr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==15 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_eff=`beta' if study_id==15 & time_tranche==1
replace lr_re_se=`se' if study_id==15 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==15 & time_tranche==1
replace lr_un_se=`se2' if study_id==15 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_eff=`beta' if study_id==15 & time_tranche==1
replace lr_pt_se=`se' if study_id==15 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==15 & time_tranche==1
replace lr_ret_se=`se2' if study_id==15 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==15 & time_tranche==1
replace lr_nw_se=`se3' if study_id==15 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==15 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==15 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==15 & time_tranche==1
replace lr_une_se=`se4' if study_id==15 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==15 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==15 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_eff=`beta' if study_id==15 & time_tranche==1
replace lr_kw_se=`se' if study_id==15 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19positive i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_eff=`beta2' if study_id==15 & time_tranche==1
replace lr_sm_se=`se2' if study_id==15 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==15 & time_tranche==1
replace lr_no_se=`se3' if study_id==15 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==15 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==15 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_eff=`beta' if study_id==15 & time_tranche==1
replace lr_fr_se=`se' if study_id==15 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation  i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==15 & time_tranche==1
replace sr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==15 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==15 & time_tranche==1
replace sr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==15 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_adjv_eff=`beta' if study_id==15 & time_tranche==1
replace sr_re_adjv_se=`se' if study_id==15 & time_tranche==1
replace sr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace sr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1

replace sr_un_adjv_eff=`beta2' if study_id==15 & time_tranche==1
replace sr_un_adjv_se=`se2' if study_id==15 & time_tranche==1
replace sr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_adjv_eff=`beta' if study_id==15 & time_tranche==1
replace sr_pt_adjv_se=`se' if study_id==15 & time_tranche==1
replace sr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace sr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1

replace sr_ret_adjv_eff=`beta2' if study_id==15 & time_tranche==1
replace sr_ret_adjv_se=`se2' if study_id==15 & time_tranche==1
replace sr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace sr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1

replace sr_nw_adjv_eff=`beta3' if study_id==15 & time_tranche==1
replace sr_nw_adjv_se=`se3' if study_id==15 & time_tranche==1
replace sr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==15 & time_tranche==1
replace sr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==15 & time_tranche==1

replace sr_une_adjv_eff=`beta4' if study_id==15 & time_tranche==1
replace sr_une_adjv_se=`se4' if study_id==15 & time_tranche==1
replace sr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==15 & time_tranche==1
replace sr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==15 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_adjv_eff=`beta' if study_id==15 & time_tranche==1
replace sr_kw_adjv_se=`se' if study_id==15 & time_tranche==1
replace sr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace sr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_adjv_eff=`beta2' if study_id==15 & time_tranche==1
replace sr_sm_adjv_se=`se2' if study_id==15 & time_tranche==1
replace sr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace sr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1

replace sr_no_adjv_eff=`beta3' if study_id==15 & time_tranche==1
replace sr_no_adjv_se=`se3' if study_id==15 & time_tranche==1
replace sr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==15 & time_tranche==1
replace sr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==15 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_adjv_eff=`beta' if study_id==15 & time_tranche==1
replace sr_fr_adjv_se=`se' if study_id==15 & time_tranche==1
replace sr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace sr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==15 & time_tranche==1
replace lr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==15 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==15 & time_tranche==1
replace lr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==15 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_adjv_eff=`beta' if study_id==15 & time_tranche==1
replace lr_re_adjv_se=`se' if study_id==15 & time_tranche==1
replace lr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace lr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1

replace lr_un_adjv_eff=`beta2' if study_id==15 & time_tranche==1
replace lr_un_adjv_se=`se2' if study_id==15 & time_tranche==1
replace lr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_adjv_eff=`beta' if study_id==15 & time_tranche==1
replace lr_pt_adjv_se=`se' if study_id==15 & time_tranche==1
replace lr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace lr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1

replace lr_ret_adjv_eff=`beta2' if study_id==15 & time_tranche==1
replace lr_ret_adjv_se=`se2' if study_id==15 & time_tranche==1
replace lr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace lr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1

replace lr_nw_adjv_eff=`beta3' if study_id==15 & time_tranche==1
replace lr_nw_adjv_se=`se3' if study_id==15 & time_tranche==1
replace lr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==15 & time_tranche==1
replace lr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==15 & time_tranche==1

replace lr_une_adjv_eff=`beta4' if study_id==15 & time_tranche==1
replace lr_une_adjv_se=`se4' if study_id==15 & time_tranche==1
replace lr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==15 & time_tranche==1
replace lr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==15 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_adjv_eff=`beta' if study_id==15 & time_tranche==1
replace lr_kw_adjv_se=`se' if study_id==15 & time_tranche==1
replace lr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace lr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_adjv_eff=`beta2' if study_id==15 & time_tranche==1
replace lr_sm_adjv_se=`se2' if study_id==15 & time_tranche==1
replace lr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==15 & time_tranche==1
replace lr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==15 & time_tranche==1

replace lr_no_adjv_eff=`beta3' if study_id==15 & time_tranche==1
replace lr_no_adjv_se=`se3' if study_id==15 & time_tranche==1
replace lr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==15 & time_tranche==1
replace lr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==15 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_adjv_eff=`beta' if study_id==15 & time_tranche==1
replace lr_fr_adjv_se=`se' if study_id==15 & time_tranche==1
replace lr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==15 & time_tranche==1
replace lr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==15 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


clear










*******************************
**THE  MILLENIUM COHORT - cohort members only - study_id==16
*******************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "MCS edited\MCS edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,
tostring avail_from_dt, replace 

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "MCS edited\protect_nhs_c19posinfect_temp_mcsver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/04/2021", "DMY") & study_wave==3


tab study_wave vacc_status
replace vacc_status=1 if vacc_status>1 & vacc_status!=.
label define vacc_status 0 "No Vacc" 1 "1+ Dose Vacc", replace
label values vacc_status vacc_status
tab study_wave vacc_status



**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2
rename key_worker keyworker


** MCS - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq


***KEEP IF COHORT MEMBERS AND NOT COHORT MEMBERS PARENTS

keep if cohort==4


**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==16 & time_tranche==1
replace entry_n=`entry_n' if study_id==16 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==16 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==16 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==16 & time_tranche==1

list if study_id==16 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
tab soc2010_1d `var', missing row
tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
*tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
rename soc2010_1d soc_1d
rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult
preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==16 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==16 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==16 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==16 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19infection_selfreported i.employment   i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_eff=`beta' if study_id==16 & time_tranche==1
replace sr_re_se=`se' if study_id==16 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==16 & time_tranche==1
replace sr_un_se=`se2' if study_id==16 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**employment_status	
mepoisson c19infection_selfreported i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_eff=`beta' if study_id==16 & time_tranche==1
replace sr_pt_se=`se' if study_id==16 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==16 & time_tranche==1
replace sr_ret_se=`se2' if study_id==16 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==16 & time_tranche==1
replace sr_nw_se=`se3' if study_id==16 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==16 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==16 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==16 & time_tranche==1
replace sr_une_se=`se4' if study_id==16 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==16 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==16 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_eff=`beta' if study_id==16 & time_tranche==1
replace sr_kw_se=`se' if study_id==16 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_eff=`beta2' if study_id==16 & time_tranche==1
replace sr_sm_se=`se2' if study_id==16 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==16 & time_tranche==1
replace sr_no_se=`se3' if study_id==16 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==16 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==16 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_eff=`beta' if study_id==16 & time_tranche==1
replace sr_fr_se=`se' if study_id==16 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==16 & time_tranche==1
replace lr_s101d`i'_se=_se[`i'.soc_1d] if study_id==16 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==16 & time_tranche==1
replace lr_s102d`i'_se=_se[`i'.soc_2d] if study_id==16 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_eff=`beta' if study_id==16 & time_tranche==1
replace lr_re_se=`se' if study_id==16 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==16 & time_tranche==1
replace lr_un_se=`se2' if study_id==16 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status i.cohort i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_eff=`beta' if study_id==16 & time_tranche==1
replace lr_pt_se=`se' if study_id==16 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==16 & time_tranche==1
replace lr_ret_se=`se2' if study_id==16 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==16 & time_tranche==1
replace lr_nw_se=`se3' if study_id==16 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==16 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==16 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==16 & time_tranche==1
replace lr_une_se=`se4' if study_id==16 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==16 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==16 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_eff=`beta' if study_id==16 & time_tranche==1
replace lr_kw_se=`se' if study_id==16 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19positive i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_eff=`beta2' if study_id==16 & time_tranche==1
replace lr_sm_se=`se2' if study_id==16 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==16 & time_tranche==1
replace lr_no_se=`se3' if study_id==16 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==16 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==16 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_eff=`beta' if study_id==16 & time_tranche==1
replace lr_fr_se=`se' if study_id==16 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation  i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.vacc_status  i.ethnicity_red  i.cohort i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==16 & time_tranche==1
replace sr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==16 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==16 & time_tranche==1
replace sr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==16 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_adjv_eff=`beta' if study_id==16 & time_tranche==1
replace sr_re_adjv_se=`se' if study_id==16 & time_tranche==1
replace sr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace sr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1

replace sr_un_adjv_eff=`beta2' if study_id==16 & time_tranche==1
replace sr_un_adjv_se=`se2' if study_id==16 & time_tranche==1
replace sr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_adjv_eff=`beta' if study_id==16 & time_tranche==1
replace sr_pt_adjv_se=`se' if study_id==16 & time_tranche==1
replace sr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace sr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1

replace sr_ret_adjv_eff=`beta2' if study_id==16 & time_tranche==1
replace sr_ret_adjv_se=`se2' if study_id==16 & time_tranche==1
replace sr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace sr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1

replace sr_nw_adjv_eff=`beta3' if study_id==16 & time_tranche==1
replace sr_nw_adjv_se=`se3' if study_id==16 & time_tranche==1
replace sr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==16 & time_tranche==1
replace sr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==16 & time_tranche==1

replace sr_une_adjv_eff=`beta4' if study_id==16 & time_tranche==1
replace sr_une_adjv_se=`se4' if study_id==16 & time_tranche==1
replace sr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==16 & time_tranche==1
replace sr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==16 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_adjv_eff=`beta' if study_id==16 & time_tranche==1
replace sr_kw_adjv_se=`se' if study_id==16 & time_tranche==1
replace sr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace sr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_adjv_eff=`beta2' if study_id==16 & time_tranche==1
replace sr_sm_adjv_se=`se2' if study_id==16 & time_tranche==1
replace sr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace sr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1

replace sr_no_adjv_eff=`beta3' if study_id==16 & time_tranche==1
replace sr_no_adjv_se=`se3' if study_id==16 & time_tranche==1
replace sr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==16 & time_tranche==1
replace sr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==16 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_adjv_eff=`beta' if study_id==16 & time_tranche==1
replace sr_fr_adjv_se=`se' if study_id==16 & time_tranche==1
replace sr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace sr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==16 & time_tranche==1
replace lr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==16 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==16 & time_tranche==1
replace lr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==16 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_adjv_eff=`beta' if study_id==16 & time_tranche==1
replace lr_re_adjv_se=`se' if study_id==16 & time_tranche==1
replace lr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace lr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1

replace lr_un_adjv_eff=`beta2' if study_id==16 & time_tranche==1
replace lr_un_adjv_se=`se2' if study_id==16 & time_tranche==1
replace lr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_adjv_eff=`beta' if study_id==16 & time_tranche==1
replace lr_pt_adjv_se=`se' if study_id==16 & time_tranche==1
replace lr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace lr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1

replace lr_ret_adjv_eff=`beta2' if study_id==16 & time_tranche==1
replace lr_ret_adjv_se=`se2' if study_id==16 & time_tranche==1
replace lr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace lr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1

replace lr_nw_adjv_eff=`beta3' if study_id==16 & time_tranche==1
replace lr_nw_adjv_se=`se3' if study_id==16 & time_tranche==1
replace lr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==16 & time_tranche==1
replace lr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==16 & time_tranche==1

replace lr_une_adjv_eff=`beta4' if study_id==16 & time_tranche==1
replace lr_une_adjv_se=`se4' if study_id==16 & time_tranche==1
replace lr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==16 & time_tranche==1
replace lr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==16 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_adjv_eff=`beta' if study_id==16 & time_tranche==1
replace lr_kw_adjv_se=`se' if study_id==16 & time_tranche==1
replace lr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace lr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_adjv_eff=`beta2' if study_id==16 & time_tranche==1
replace lr_sm_adjv_se=`se2' if study_id==16 & time_tranche==1
replace lr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==16 & time_tranche==1
replace lr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==16 & time_tranche==1

replace lr_no_adjv_eff=`beta3' if study_id==16 & time_tranche==1
replace lr_no_adjv_se=`se3' if study_id==16 & time_tranche==1
replace lr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==16 & time_tranche==1
replace lr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==16 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_adjv_eff=`beta' if study_id==16 & time_tranche==1
replace lr_fr_adjv_se=`se' if study_id==16 & time_tranche==1
replace lr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==16 & time_tranche==1
replace lr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==16 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


clear



*******************************
**THE  MILLENIUM COHORT - cohort members parents only - study_id==17
*******************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "MCS edited\MCS edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,
tostring avail_from_dt, replace 

sort llc_0007_stud_id study_wave
merge 1:1 llc_0007_stud_id study_wave using "MCS edited\protect_nhs_c19posinfect_temp_mcsver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/04/2021", "DMY") & study_wave==3

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/12/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/04/2021", "DMY") & study_wave==3


tab study_wave vacc_status
replace vacc_status=1 if vacc_status>1 & vacc_status!=.
label define vacc_status 0 "No Vacc" 1 "1+ Dose Vacc", replace
label values vacc_status vacc_status
tab study_wave vacc_status



**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2
rename key_worker keyworker


** MCS - descriptive statistics
bysort llc_0007_stud_id: egen seq=seq()
count if seq==1
return list
local sample_n =  r(N)
count
return list
local entry_n =  r(N)
*quietly tab llc_0007_stud_id
*return list
drop seq


***KEEP IF COHORT MEMBERS PARENT AND NOT COHORT MEMBER

keep if cohort==5


**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==17 & time_tranche==1
replace entry_n=`entry_n' if study_id==17 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==17 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==17 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==17 & time_tranche==1

list if study_id==17 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
tab soc2010_1d `var', missing row
tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
*tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


tab employment 
tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
rename soc2010_1d soc_1d
rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult
preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==17 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==17 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==17 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==17 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment
mepoisson c19infection_selfreported i.employment   i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_eff=`beta' if study_id==17 & time_tranche==1
replace sr_re_se=`se' if study_id==17 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==17 & time_tranche==1
replace sr_un_se=`se2' if study_id==17 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**employment_status	
mepoisson c19infection_selfreported i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_eff=`beta' if study_id==17 & time_tranche==1
replace sr_pt_se=`se' if study_id==17 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==17 & time_tranche==1
replace sr_ret_se=`se2' if study_id==17 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==17 & time_tranche==1
replace sr_nw_se=`se3' if study_id==17 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==17 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==17 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==17 & time_tranche==1
replace sr_une_se=`se4' if study_id==17 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==17 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==17 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_eff=`beta' if study_id==17 & time_tranche==1
replace sr_kw_se=`se' if study_id==17 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_eff=`beta2' if study_id==17 & time_tranche==1
replace sr_sm_se=`se2' if study_id==17 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==17 & time_tranche==1
replace sr_no_se=`se3' if study_id==17 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==17 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==17 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_eff=`beta' if study_id==17 & time_tranche==1
replace sr_fr_se=`se' if study_id==17 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==17 & time_tranche==1
replace lr_s101d`i'_se=_se[`i'.soc_1d] if study_id==17 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==17 & time_tranche==1
replace lr_s102d`i'_se=_se[`i'.soc_2d] if study_id==17 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_eff=`beta' if study_id==17 & time_tranche==1
replace lr_re_se=`se' if study_id==17 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==17 & time_tranche==1
replace lr_un_se=`se2' if study_id==17 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status i.cohort i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_eff=`beta' if study_id==17 & time_tranche==1
replace lr_pt_se=`se' if study_id==17 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==17 & time_tranche==1
replace lr_ret_se=`se2' if study_id==17 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==17 & time_tranche==1
replace lr_nw_se=`se3' if study_id==17 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==17 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==17 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==17 & time_tranche==1
replace lr_une_se=`se4' if study_id==17 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==17 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==17 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_eff=`beta' if study_id==17 & time_tranche==1
replace lr_kw_se=`se' if study_id==17 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19positive i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_eff=`beta2' if study_id==17 & time_tranche==1
replace lr_sm_se=`se2' if study_id==17 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==17 & time_tranche==1
replace lr_no_se=`se3' if study_id==17 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==17 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==17 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_eff=`beta' if study_id==17 & time_tranche==1
replace lr_fr_se=`se' if study_id==17 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation  i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.vacc_status  i.ethnicity_red  i.cohort i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==17 & time_tranche==1
replace sr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==17 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==17 & time_tranche==1
replace sr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==17 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_adjv_eff=`beta' if study_id==17 & time_tranche==1
replace sr_re_adjv_se=`se' if study_id==17 & time_tranche==1
replace sr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace sr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1

replace sr_un_adjv_eff=`beta2' if study_id==17 & time_tranche==1
replace sr_un_adjv_se=`se2' if study_id==17 & time_tranche==1
replace sr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_adjv_eff=`beta' if study_id==17 & time_tranche==1
replace sr_pt_adjv_se=`se' if study_id==17 & time_tranche==1
replace sr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace sr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1

replace sr_ret_adjv_eff=`beta2' if study_id==17 & time_tranche==1
replace sr_ret_adjv_se=`se2' if study_id==17 & time_tranche==1
replace sr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace sr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1

replace sr_nw_adjv_eff=`beta3' if study_id==17 & time_tranche==1
replace sr_nw_adjv_se=`se3' if study_id==17 & time_tranche==1
replace sr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==17 & time_tranche==1
replace sr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==17 & time_tranche==1

replace sr_une_adjv_eff=`beta4' if study_id==17 & time_tranche==1
replace sr_une_adjv_se=`se4' if study_id==17 & time_tranche==1
replace sr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==17 & time_tranche==1
replace sr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==17 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_adjv_eff=`beta' if study_id==17 & time_tranche==1
replace sr_kw_adjv_se=`se' if study_id==17 & time_tranche==1
replace sr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace sr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_adjv_eff=`beta2' if study_id==17 & time_tranche==1
replace sr_sm_adjv_se=`se2' if study_id==17 & time_tranche==1
replace sr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace sr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1

replace sr_no_adjv_eff=`beta3' if study_id==17 & time_tranche==1
replace sr_no_adjv_se=`se3' if study_id==17 & time_tranche==1
replace sr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==17 & time_tranche==1
replace sr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==17 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_adjv_eff=`beta' if study_id==17 & time_tranche==1
replace sr_fr_adjv_se=`se' if study_id==17 & time_tranche==1
replace sr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace sr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==17 & time_tranche==1
replace lr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==17 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==17 & time_tranche==1
replace lr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==17 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.vacc_status  i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.vacc_status  i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_adjv_eff=`beta' if study_id==17 & time_tranche==1
replace lr_re_adjv_se=`se' if study_id==17 & time_tranche==1
replace lr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace lr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1

replace lr_un_adjv_eff=`beta2' if study_id==17 & time_tranche==1
replace lr_un_adjv_se=`se2' if study_id==17 & time_tranche==1
replace lr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_adjv_eff=`beta' if study_id==17 & time_tranche==1
replace lr_pt_adjv_se=`se' if study_id==17 & time_tranche==1
replace lr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace lr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1

replace lr_ret_adjv_eff=`beta2' if study_id==17 & time_tranche==1
replace lr_ret_adjv_se=`se2' if study_id==17 & time_tranche==1
replace lr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace lr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1

replace lr_nw_adjv_eff=`beta3' if study_id==17 & time_tranche==1
replace lr_nw_adjv_se=`se3' if study_id==17 & time_tranche==1
replace lr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==17 & time_tranche==1
replace lr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==17 & time_tranche==1

replace lr_une_adjv_eff=`beta4' if study_id==17 & time_tranche==1
replace lr_une_adjv_se=`se4' if study_id==17 & time_tranche==1
replace lr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==17 & time_tranche==1
replace lr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==17 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_adjv_eff=`beta' if study_id==17 & time_tranche==1
replace lr_kw_adjv_se=`se' if study_id==17 & time_tranche==1
replace lr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace lr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_adjv_eff=`beta2' if study_id==17 & time_tranche==1
replace lr_sm_adjv_se=`se2' if study_id==17 & time_tranche==1
replace lr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==17 & time_tranche==1
replace lr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==17 & time_tranche==1

replace lr_no_adjv_eff=`beta3' if study_id==17 & time_tranche==1
replace lr_no_adjv_se=`se3' if study_id==17 & time_tranche==1
replace lr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==17 & time_tranche==1
replace lr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==17 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.vacc_status  i.ethnicity_red i.cohort i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_adjv_eff=`beta' if study_id==17 & time_tranche==1
replace lr_fr_adjv_se=`se' if study_id==17 & time_tranche==1
replace lr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==17 & time_tranche==1
replace lr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==17 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


clear




*******************************
**THE AVON LONGITUDINAL STUDY OF PARENTS AND CHILDREN (ALSPAC - Members) - study_id==18
*******************************

***RETURN TO CHECK THE LINKED DATA ONCE AVAILABLE

**study_id==18

**NO LINK TO NHS TESTING DATA CHECK WITH LLC (START THIS SECTION AGAIN)

**Open and merge NHS data with UKHLS file
use "alspac edited\alspac edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,


sort llc_0007_stud_id study_wave
*drop _merge
merge m:1 llc_0007_stud_id study_wave using "alspac edited\protect_nhs_c19posinfect_temp_alspacver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/07/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/11/2020", "DMY") & study_wave==3
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==4

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/07/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/11/2020", "DMY") & study_wave==3
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/04/2021", "DMY") & study_wave==4

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/07/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/11/2020", "DMY") & study_wave==3
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/04/2021", "DMY") & study_wave==4

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/07/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/11/2020", "DMY") & study_wave==3
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==4


tab study_wave vacc_status
replace vacc_status=1 if vacc_status>1 & vacc_status!=.
label define vacc_status 0 "No Vacc" 1 "1+ Dose Vacc", replace
label values vacc_status vacc_status
tab study_wave vacc_status


**Modify the self-reported data as appears to be have you had covid at anytime not since last wave
**Readjusted so can only have covid once
tab study_wave c19infection_selfreported 
tab pandemic_timetranche c19infection_selfreported 
sort study_wave
replace c19infection_selfreported=0 if c19infection_selfreported[_n-1]==1  & study_wave>1
replace c19infection_selfreported=0 if c19infection_selfreported[_n-2]==1  & study_wave>2
replace c19infection_selfreported=0 if c19infection_selfreported[_n-3]==1  & study_wave>3
tab study_wave c19infection_selfreported 
tab pandemic_timetranche c19infection_selfreported 

tab study_wave c19postest_selfreported 
tab pandemic_timetranche c19postest_selfreported 
replace c19postest_selfreported=0 if c19postest_selfreported[_n-1]==1  & study_wave>1
replace c19postest_selfreported=0 if c19postest_selfreported[_n-2]==1  & study_wave>2
replace c19postest_selfreported=0 if c19postest_selfreported[_n-3]==1  & study_wave>3
tab study_wave c19postest_selfreported 
tab pandemic_timetranche c19postest_selfreported 


**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2

drop if age>65

keep if cohort==2

** BCS1970 - descriptive statistics
quietly tab llc_0007_stud_id
return list
local sample_n =  r(r)
local entry_n =  r(N)


**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)



preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==18 & time_tranche==1
replace entry_n=`entry_n' if study_id==18 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==18 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==18 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==18 & time_tranche==1

list if study_id==18 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
*tab soc2010_1d `var', missing row
*tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}

numlabel, add

tab employment 
tab employment_status



**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
*rename soc2010_1d soc_1d
*rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2010
**1 digit
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==18 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==18 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==18 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==18 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 
	



**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult



**employment
mepoisson c19infection_selfreported i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_eff=`beta' if study_id==18 & time_tranche==1
replace sr_re_se=`se' if study_id==18 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==18 & time_tranche==1
replace sr_un_se=`se2' if study_id==18 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


tab employment_status c19infection_selfreported

**employment_status	
mepoisson c19infection_selfreported i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_eff=`beta' if study_id==18 & time_tranche==1
replace sr_pt_se=`se' if study_id==18 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==18 & time_tranche==1
replace sr_ret_se=`se2' if study_id==18 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==18 & time_tranche==1
replace sr_nw_se=`se3' if study_id==18 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==18 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==18 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==18 & time_tranche==1
replace sr_une_se=`se4' if study_id==18 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==18 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==18 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

tab keyworker

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_eff=`beta' if study_id==18 & time_tranche==1
replace sr_kw_se=`se' if study_id==18 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_eff=`beta2' if study_id==18 & time_tranche==1
replace sr_sm_se=`se2' if study_id==18 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==18 & time_tranche==1
replace sr_no_se=`se3' if study_id==18 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==18 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==18 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_eff=`beta' if study_id==18 & time_tranche==1
replace sr_fr_se=`se' if study_id==18 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==18 & time_tranche==1
replace lr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==18 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==18 & time_tranche==1
replace lr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==18 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_eff=`beta' if study_id==18 & time_tranche==1
replace lr_re_se=`se' if study_id==18 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==18 & time_tranche==1
replace lr_un_se=`se2' if study_id==18 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_eff=`beta' if study_id==18 & time_tranche==1
replace lr_pt_se=`se' if study_id==18 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==18 & time_tranche==1
replace lr_ret_se=`se2' if study_id==18 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==18 & time_tranche==1
replace lr_nw_se=`se3' if study_id==18 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==18 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==18 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==18 & time_tranche==1
replace lr_une_se=`se4' if study_id==18 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==18 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==18 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_eff=`beta' if study_id==18 & time_tranche==1
replace lr_kw_se=`se' if study_id==18 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19positive i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_eff=`beta2' if study_id==18 & time_tranche==1
replace lr_sm_se=`se2' if study_id==18 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==18 & time_tranche==1
replace lr_no_se=`se3' if study_id==18 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==18 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==18 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_eff=`beta' if study_id==18 & time_tranche==1
replace lr_fr_se=`se' if study_id==18 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation  i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==18 & time_tranche==1
replace sr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==18 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==18 & time_tranche==1
replace sr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==18 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_adjv_eff=`beta' if study_id==18 & time_tranche==1
replace sr_re_adjv_se=`se' if study_id==18 & time_tranche==1
replace sr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace sr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1

replace sr_un_adjv_eff=`beta2' if study_id==18 & time_tranche==1
replace sr_un_adjv_se=`se2' if study_id==18 & time_tranche==1
replace sr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_adjv_eff=`beta' if study_id==18 & time_tranche==1
replace sr_pt_adjv_se=`se' if study_id==18 & time_tranche==1
replace sr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace sr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1

replace sr_ret_adjv_eff=`beta2' if study_id==18 & time_tranche==1
replace sr_ret_adjv_se=`se2' if study_id==18 & time_tranche==1
replace sr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace sr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1

replace sr_nw_adjv_eff=`beta3' if study_id==18 & time_tranche==1
replace sr_nw_adjv_se=`se3' if study_id==18 & time_tranche==1
replace sr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==18 & time_tranche==1
replace sr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==18 & time_tranche==1

replace sr_une_adjv_eff=`beta4' if study_id==18 & time_tranche==1
replace sr_une_adjv_se=`se4' if study_id==18 & time_tranche==1
replace sr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==18 & time_tranche==1
replace sr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==18 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_adjv_eff=`beta' if study_id==18 & time_tranche==1
replace sr_kw_adjv_se=`se' if study_id==18 & time_tranche==1
replace sr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace sr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_adjv_eff=`beta2' if study_id==18 & time_tranche==1
replace sr_sm_adjv_se=`se2' if study_id==18 & time_tranche==1
replace sr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace sr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1

replace sr_no_adjv_eff=`beta3' if study_id==18 & time_tranche==1
replace sr_no_adjv_se=`se3' if study_id==18 & time_tranche==1
replace sr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==18 & time_tranche==1
replace sr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==18 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_adjv_eff=`beta' if study_id==18 & time_tranche==1
replace sr_fr_adjv_se=`se' if study_id==18 & time_tranche==1
replace sr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace sr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==18 & time_tranche==1
replace lr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==18 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==18 & time_tranche==1
replace lr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==18 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_adjv_eff=`beta' if study_id==18 & time_tranche==1
replace lr_re_adjv_se=`se' if study_id==18 & time_tranche==1
replace lr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace lr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1

replace lr_un_adjv_eff=`beta2' if study_id==18 & time_tranche==1
replace lr_un_adjv_se=`se2' if study_id==18 & time_tranche==1
replace lr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_adjv_eff=`beta' if study_id==18 & time_tranche==1
replace lr_pt_adjv_se=`se' if study_id==18 & time_tranche==1
replace lr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace lr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1

replace lr_ret_adjv_eff=`beta2' if study_id==18 & time_tranche==1
replace lr_ret_adjv_se=`se2' if study_id==18 & time_tranche==1
replace lr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace lr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1

replace lr_nw_adjv_eff=`beta3' if study_id==18 & time_tranche==1
replace lr_nw_adjv_se=`se3' if study_id==18 & time_tranche==1
replace lr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==18 & time_tranche==1
replace lr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==18 & time_tranche==1

replace lr_une_adjv_eff=`beta4' if study_id==18 & time_tranche==1
replace lr_une_adjv_se=`se4' if study_id==18 & time_tranche==1
replace lr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==18 & time_tranche==1
replace lr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==18 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_adjv_eff=`beta' if study_id==18 & time_tranche==1
replace lr_kw_adjv_se=`se' if study_id==18 & time_tranche==1
replace lr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace lr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_adjv_eff=`beta2' if study_id==18 & time_tranche==1
replace lr_sm_adjv_se=`se2' if study_id==18 & time_tranche==1
replace lr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==18 & time_tranche==1
replace lr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==18 & time_tranche==1

replace lr_no_adjv_eff=`beta3' if study_id==18 & time_tranche==1
replace lr_no_adjv_se=`se3' if study_id==18 & time_tranche==1
replace lr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==18 & time_tranche==1
replace lr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==18 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_adjv_eff=`beta' if study_id==18 & time_tranche==1
replace lr_fr_adjv_se=`se' if study_id==18 & time_tranche==1
replace lr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==18 & time_tranche==1
replace lr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==18 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


clear





*******************************
**THE AVON LONGITUDINAL STUDY OF PARENTS AND CHILDREN (ALSPAC - Mothers) - study_id==19
*******************************

***RETURN TO CHECK THE LINKED DATA ONCE AVAILABLE

**study_id==19

**NO LINK TO NHS TESTING DATA CHECK WITH LLC (START THIS SECTION AGAIN)

**Open and merge NHS data with UKHLS file
use "alspac edited\alspac edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,


sort llc_0007_stud_id study_wave
*drop _merge
merge m:1 llc_0007_stud_id study_wave using "alspac edited\protect_nhs_c19posinfect_temp_alspacver"
drop if _merge==2	
drop _merge

**add in vaccination status
merge m:1 llc_0007_stud_id using "NHS edited\CVS_protect_temp wide",
drop if _merge==2	
drop _merge

**edit vaccination status at each study wave - can only do it based on the wave not exact dates
gen vacc_status=0
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/07/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/11/2020", "DMY") & study_wave==3
replace vacc_status=vacc_status+1 if vaccination_procedure_term1!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==4

replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/07/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/11/2020", "DMY") & study_wave==3
replace vacc_status=vacc_status+1 if vaccination_procedure_term2!=. & event_received_ts2<date("01/04/2021", "DMY") & study_wave==4

replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/07/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/11/2020", "DMY") & study_wave==3
replace vacc_status=vacc_status+1 if vaccination_procedure_term3!=. & event_received_ts3<date("01/04/2021", "DMY") & study_wave==4

replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/06/2020", "DMY") & study_wave==1
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/07/2020", "DMY") & study_wave==2
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts4<date("01/11/2020", "DMY") & study_wave==3
replace vacc_status=vacc_status+1 if vaccination_procedure_term4!=. & event_received_ts1<date("01/04/2021", "DMY") & study_wave==4


tab study_wave vacc_status
replace vacc_status=1 if vacc_status>1 & vacc_status!=.
label define vacc_status 0 "No Vacc" 1 "1+ Dose Vacc", replace
label values vacc_status vacc_status
tab study_wave vacc_status


**Modify the self-reported data as appears to be have you had covid at anytime not since last wave
**Readjusted so can only have covid once
tab study_wave c19infection_selfreported 
tab pandemic_timetranche c19infection_selfreported 
sort study_wave
replace c19infection_selfreported=0 if c19infection_selfreported[_n-1]==1  & study_wave>1
replace c19infection_selfreported=0 if c19infection_selfreported[_n-2]==1  & study_wave>2
replace c19infection_selfreported=0 if c19infection_selfreported[_n-3]==1  & study_wave>3
tab study_wave c19infection_selfreported 
tab pandemic_timetranche c19infection_selfreported 

tab study_wave c19postest_selfreported 
tab pandemic_timetranche c19postest_selfreported 
replace c19postest_selfreported=0 if c19postest_selfreported[_n-1]==1  & study_wave>1
replace c19postest_selfreported=0 if c19postest_selfreported[_n-2]==1  & study_wave>2
replace c19postest_selfreported=0 if c19postest_selfreported[_n-3]==1  & study_wave>3
tab study_wave c19postest_selfreported 
tab pandemic_timetranche c19postest_selfreported 


**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough

***Change labels to fit with generic analysis 
*rename keyworker keyworker2

drop if age>65

keep if cohort==1

** BCS1970 - descriptive statistics
quietly tab llc_0007_stud_id
return list
local sample_n =  r(r)
local entry_n =  r(N)


**tab self-reported infection 
tab c19infection_selfreported
count if c19infection_selfreported==1
local selfinf_n = r(N)
**tab NHS digital indicated infection
tab c19postest_selfreported	
count if c19postest_selfreported==1
local selfpos_no = r(N)
**tab NHS digital indicated infection
tab c19positive	
count if c19positive==1
local linkpos_no = r(N)


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

display `sample_n'
display `entry_n'

replace sample_n=`sample_n' if study_id==19 & time_tranche==1
replace entry_n=`entry_n' if study_id==19 & time_tranche==1
replace selfinf_n=`selfinf_n' if study_id==19 & time_tranche==1
replace selfpos_no=`selfpos_no' if study_id==19 & time_tranche==1
replace linkpos_no=`linkpos_no' if study_id==19 & time_tranche==1

list if study_id==19 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace

restore

**by study wave
**tab self-reported infection 
tab study_wave c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab study_wave c19postest_selfreported, missing	row
**tab NHS digital indicated infection
tab study_wave c19positive, missing	row

**by time-tranche
**tab self-reported infection 
tab pandemic_timetranche c19infection_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19postest_selfreported, missing row
**tab NHS digital indicated infection
tab pandemic_timetranche c19positive, missing row
	
***Occupational Characteristics

foreach var of varlist c19infection_selfreported c19positive {
**SOC 2000
*tab soc_1d `var', missing row
*tab soc_2d `var', missing row

**SOC 2010
*tab soc2010_1d `var', missing row
*tab soc2010_2d `var', missing row


**SIC 2003 	
*tab sic_1d `var', missing row
*tab sic_2d `var', missing row



**Key worker	
tab keyworker `var', missing row

**employment status
tab employment `var', missing row
	
tab employment_status `var', missing row

**Home working	
tab home_working `var', missing row

**Furlough
tab furlough `var', missing row	
	
	}
	
	
**confounders - need to check age

foreach var of varlist c19infection_selfreported c19positive {

tab sex `var', missing row
tab ethnicity_red  `var', missing row
*tab deprivation_imd  `var', missing row
tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}

numlabel, add

tab employment 
tab employment_status



**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
*rename soc2010_1d soc_1d
*rename soc2010_2d soc_2d

***INITIAL ANALYSIS


**SELF-REPORTED C19
**SOC 2010
**1 digit
mepoisson c19infection_selfreported i.soc_1d i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_eff=_b[`i'.soc_1d] if study_id==19 & time_tranche==1
replace sr_s101d`i'_se=_se[`i'.soc_1d] if study_id==19 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


mepoisson c19infection_selfreported i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_eff=_b[`i'.soc_2d] if study_id==19 & time_tranche==1
replace sr_s102d`i'_se=_se[`i'.soc_2d] if study_id==19 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 
	



**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult



**employment
mepoisson c19infection_selfreported i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_eff=`beta' if study_id==19 & time_tranche==1
replace sr_re_se=`se' if study_id==19 & time_tranche==1
replace sr_re_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace sr_re_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1

replace sr_un_eff=`beta2' if study_id==19 & time_tranche==1
replace sr_un_se=`se2' if study_id==19 & time_tranche==1
replace sr_un_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace sr_un_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


tab employment_status c19infection_selfreported

**employment_status	
mepoisson c19infection_selfreported i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_eff=`beta' if study_id==19 & time_tranche==1
replace sr_pt_se=`se' if study_id==19 & time_tranche==1
replace sr_pt_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace sr_pt_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1

replace sr_ret_eff=`beta2' if study_id==19 & time_tranche==1
replace sr_ret_se=`se2' if study_id==19 & time_tranche==1
replace sr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace sr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1

replace sr_nw_eff=`beta3' if study_id==19 & time_tranche==1
replace sr_nw_se=`se3' if study_id==19 & time_tranche==1
replace sr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==19 & time_tranche==1
replace sr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==19 & time_tranche==1

replace sr_une_eff=`beta4' if study_id==19 & time_tranche==1
replace sr_une_se=`se4' if study_id==19 & time_tranche==1
replace sr_une_uc=exp(`beta4'+1.96*`se4') if study_id==19 & time_tranche==1
replace sr_une_lc=exp(`beta4'-1.96*`se4') if study_id==19 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

tab keyworker

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_eff=`beta' if study_id==19 & time_tranche==1
replace sr_kw_se=`se' if study_id==19 & time_tranche==1
replace sr_kw_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace sr_kw_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19infection_selfreported i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_eff=`beta2' if study_id==19 & time_tranche==1
replace sr_sm_se=`se2' if study_id==19 & time_tranche==1
replace sr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace sr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1

replace sr_no_eff=`beta3' if study_id==19 & time_tranche==1
replace sr_no_se=`se3' if study_id==19 & time_tranche==1
replace sr_no_uc=exp(`beta3'+1.96*`se3') if study_id==19 & time_tranche==1
replace sr_no_lc=exp(`beta3'-1.96*`se3') if study_id==19 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 





**Furlough
mepoisson c19infection_selfreported i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_eff=`beta' if study_id==19 & time_tranche==1
replace sr_fr_se=`se' if study_id==19 & time_tranche==1
replace sr_fr_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace sr_fr_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==19 & time_tranche==1
replace lr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==19 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==19 & time_tranche==1
replace lr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==19 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment status
mepoisson c19positive i.employment  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_eff=`beta' if study_id==19 & time_tranche==1
replace lr_re_se=`se' if study_id==19 & time_tranche==1
replace lr_re_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace lr_re_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1

replace lr_un_eff=`beta2' if study_id==19 & time_tranche==1
replace lr_un_se=`se2' if study_id==19 & time_tranche==1
replace lr_un_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace lr_un_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status		
mepoisson c19positive i.employment_status  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_eff=`beta' if study_id==19 & time_tranche==1
replace lr_pt_se=`se' if study_id==19 & time_tranche==1
replace lr_pt_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace lr_pt_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1

replace lr_ret_eff=`beta2' if study_id==19 & time_tranche==1
replace lr_ret_se=`se2' if study_id==19 & time_tranche==1
replace lr_ret_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace lr_ret_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1

replace lr_nw_eff=`beta3' if study_id==19 & time_tranche==1
replace lr_nw_se=`se3' if study_id==19 & time_tranche==1
replace lr_nw_uc=exp(`beta3'+1.96*`se3') if study_id==19 & time_tranche==1
replace lr_nw_lc=exp(`beta3'-1.96*`se3') if study_id==19 & time_tranche==1

replace lr_une_eff=`beta4' if study_id==19 & time_tranche==1
replace lr_une_se=`se4' if study_id==19 & time_tranche==1
replace lr_une_uc=exp(`beta4'+1.96*`se4') if study_id==19 & time_tranche==1
replace lr_une_lc=exp(`beta4'-1.96*`se4') if study_id==19 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Key worker	
mepoisson c19positive i.keyworker i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_eff=`beta' if study_id==19 & time_tranche==1
replace lr_kw_se=`se' if study_id==19 & time_tranche==1
replace lr_kw_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace lr_kw_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**Home working	
mepoisson c19positive i.home_working  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_eff=`beta2' if study_id==19 & time_tranche==1
replace lr_sm_se=`se2' if study_id==19 & time_tranche==1
replace lr_sm_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace lr_sm_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1

replace lr_no_eff=`beta3' if study_id==19 & time_tranche==1
replace lr_no_se=`se3' if study_id==19 & time_tranche==1
replace lr_no_uc=exp(`beta3'+1.96*`se3') if study_id==19 & time_tranche==1
replace lr_no_lc=exp(`beta3'-1.96*`se3') if study_id==19 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**Furlough
mepoisson c19positive i.furlough i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_eff=`beta' if study_id==19 & time_tranche==1
replace lr_fr_se=`se' if study_id==19 & time_tranche==1
replace lr_fr_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace lr_fr_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



****Repeated Adjusted for key confounders - missing i.deprivation  i.hm_location
***INITIAL ANALYSIS

**SELF-REPORTED C19
**SOC 2000
mepoisson c19infection_selfreported i.soc_1d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace sr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==19 & time_tranche==1
replace sr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==19 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19infection_selfreported i.soc_2d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace sr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==19 & time_tranche==1
replace sr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==19 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19infection_selfreported i.sic_1d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19infection_selfreported i.sic_2d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult





**employment status
mepoisson c19infection_selfreported i.employment i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_re_adjv_eff=`beta' if study_id==19 & time_tranche==1
replace sr_re_adjv_se=`se' if study_id==19 & time_tranche==1
replace sr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace sr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1

replace sr_un_adjv_eff=`beta2' if study_id==19 & time_tranche==1
replace sr_un_adjv_se=`se2' if study_id==19 & time_tranche==1
replace sr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


**employment_status	
mepoisson c19infection_selfreported i.employment_status i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_pt_adjv_eff=`beta' if study_id==19 & time_tranche==1
replace sr_pt_adjv_se=`se' if study_id==19 & time_tranche==1
replace sr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace sr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1

replace sr_ret_adjv_eff=`beta2' if study_id==19 & time_tranche==1
replace sr_ret_adjv_se=`se2' if study_id==19 & time_tranche==1
replace sr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace sr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1

replace sr_nw_adjv_eff=`beta3' if study_id==19 & time_tranche==1
replace sr_nw_adjv_se=`se3' if study_id==19 & time_tranche==1
replace sr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==19 & time_tranche==1
replace sr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==19 & time_tranche==1

replace sr_une_adjv_eff=`beta4' if study_id==19 & time_tranche==1
replace sr_une_adjv_se=`se4' if study_id==19 & time_tranche==1
replace sr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==19 & time_tranche==1
replace sr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==19 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore

**Key worker	
mepoisson c19infection_selfreported i.keyworker i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_kw_adjv_eff=`beta' if study_id==19 & time_tranche==1
replace sr_kw_adjv_se=`se' if study_id==19 & time_tranche==1
replace sr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace sr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 
**Home working	
mepoisson c19infection_selfreported i.home_working i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_sm_adjv_eff=`beta2' if study_id==19 & time_tranche==1
replace sr_sm_adjv_se=`se2' if study_id==19 & time_tranche==1
replace sr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace sr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1

replace sr_no_adjv_eff=`beta3' if study_id==19 & time_tranche==1
replace sr_no_adjv_se=`se3' if study_id==19 & time_tranche==1
replace sr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==19 & time_tranche==1
replace sr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==19 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore



**Furlough
mepoisson c19infection_selfreported i.furlough i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace sr_fr_adjv_eff=`beta' if study_id==19 & time_tranche==1
replace sr_fr_adjv_se=`se' if study_id==19 & time_tranche==1
replace sr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace sr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 




	
**test positive C19
**SOC 2000
mepoisson c19positive i.soc_1d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche  || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
forvalues i = 2(1)9 {
replace lr_s101d`i'_adjv_eff=_b[`i'.soc_1d] if study_id==19 & time_tranche==1
replace lr_s101d`i'_adjv_se=_se[`i'.soc_1d] if study_id==19 & time_tranche==1

}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

mepoisson c19positive i.soc_2d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
foreach i in 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92 {
replace lr_s102d`i'_adjv_eff=_b[`i'.soc_2d] if study_id==19 & time_tranche==1
replace lr_s102d`i'_adjv_se=_se[`i'.soc_2d] if study_id==19 & time_tranche==1
}
save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**SCI 2003 	
*mepoisson c19positive i.sic_1d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
*mepoisson c19positive i.sic_2d i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult




**employment
mepoisson c19positive i.employment i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[2.employment]
local se = _se[2.employment]

local beta2 = _b[3.employment]
local se2 = _se[3.employment]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_re_adjv_eff=`beta' if study_id==19 & time_tranche==1
replace lr_re_adjv_se=`se' if study_id==19 & time_tranche==1
replace lr_re_adjv_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace lr_re_adjv_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1

replace lr_un_adjv_eff=`beta2' if study_id==19 & time_tranche==1
replace lr_un_adjv_se=`se2' if study_id==19 & time_tranche==1
replace lr_un_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace sr_un_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 

**employment status	
mepoisson c19positive i.employment_status i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.employment_status]
local se = _se[1.employment_status]

local beta2 = _b[2.employment_status]
local se2 = _se[2.employment_status]

local beta3 = _b[3.employment_status]
local se3 = _se[3.employment_status]

local beta4 = _b[4.employment_status]
local se4 = _se[4.employment_status]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_pt_adjv_eff=`beta' if study_id==19 & time_tranche==1
replace lr_pt_adjv_se=`se' if study_id==19 & time_tranche==1
replace lr_pt_adjv_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace lr_pt_adjv_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1

replace lr_ret_adjv_eff=`beta2' if study_id==19 & time_tranche==1
replace lr_ret_adjv_se=`se2' if study_id==19 & time_tranche==1
replace lr_ret_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace lr_ret_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1

replace lr_nw_adjv_eff=`beta3' if study_id==19 & time_tranche==1
replace lr_nw_adjv_se=`se3' if study_id==19 & time_tranche==1
replace lr_nw_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==19 & time_tranche==1
replace lr_nw_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==19 & time_tranche==1

replace lr_une_adjv_eff=`beta4' if study_id==19 & time_tranche==1
replace lr_une_adjv_se=`se4' if study_id==19 & time_tranche==1
replace lr_une_adjv_uc=exp(`beta4'+1.96*`se4') if study_id==19 & time_tranche==1
replace lr_une_adjv_lc=exp(`beta4'-1.96*`se4') if study_id==19 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Key worker	
mepoisson c19positive i.keyworker i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult
local beta = _b[1.keyworker]
local se = _se[1.keyworker]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_kw_adjv_eff=`beta' if study_id==19 & time_tranche==1
replace lr_kw_adjv_se=`se' if study_id==19 & time_tranche==1
replace lr_kw_adjv_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace lr_kw_adjv_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 



**Home working	
mepoisson c19positive i.home_working i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition  i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult

local beta2 = _b[2.home_working]
local se2 = _se[2.home_working]

local beta3 = _b[3.home_working]
local se3 = _se[3.home_working]

preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_sm_adjv_eff=`beta2' if study_id==19 & time_tranche==1
replace lr_sm_adjv_se=`se2' if study_id==19 & time_tranche==1
replace lr_sm_adjv_uc=exp(`beta2'+1.96*`se2') if study_id==19 & time_tranche==1
replace lr_sm_adjv_lc=exp(`beta2'-1.96*`se2') if study_id==19 & time_tranche==1

replace lr_no_adjv_eff=`beta3' if study_id==19 & time_tranche==1
replace lr_no_adjv_se=`se3' if study_id==19 & time_tranche==1
replace lr_no_adjv_uc=exp(`beta3'+1.96*`se3') if study_id==19 & time_tranche==1
replace lr_no_adjv_lc=exp(`beta3'-1.96*`se3') if study_id==19 & time_tranche==1

save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore


**Furlough
mepoisson c19positive i.furlough i.sex i.vacc_status  i.age_entry i.education i.ethnicity_red  i.housing_composition i.pandemic_timetranche if employment==1 || llc_0007_stud_id:, irr vce(robust) difficult	
local beta = _b[1.furlough]
local se = _se[1.furlough]


preserve 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear

replace lr_fr_adjv_eff=`beta' if study_id==19 & time_tranche==1
replace lr_fr_adjv_se=`se' if study_id==19 & time_tranche==1
replace lr_fr_adjv_uc=exp(`beta'+1.96*`se') if study_id==19 & time_tranche==1
replace lr_fr_adjv_lc=exp(`beta'-1.96*`se') if study_id==19 & time_tranche==1



save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace
restore 


clear


