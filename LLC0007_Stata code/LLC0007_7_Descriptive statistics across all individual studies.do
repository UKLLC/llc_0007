***SUMMARY STATS

cd "S:\LLC_0007\data\"

*log using "S:\LLC_0007\summary stats of studies", text replace

*********************************
***ANALYSIS OF ELSA
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

**drop if age

**Last min formatting
replace c19positive=0 if c19positive==.
label define c19positive 0 "No-Test" 1 "Pos Test-Result", replace 
label values c19positive c19positive

label define furlough 0 "No" 1 "Yes", replace
label values furlough furlough

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

recode c19postest_selfreported (.=0)


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
*numlabel, add
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
tab age_entry `var', missing row
tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}

tab cohort, nol
rename cohort_id cohort

keep llc_0007_stud_id study_wave pandemic_timetranche c19infection_selfreported c19postest_selfreported c19positive sex ethnicity_red deprivation_imd age_entry hm_location housing_composition keyworker soc_1d soc_2d employment employment_status home_working furlough sic_2d sic_1d sic_1dmg vacc_status cohort

gen study_id=1

save "ELSA edited\ELSA edited long version slim.dta", replace


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

*numlabel, add
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

recode employment (2=3) (3=4), copyrest test
label define employment 1 "Employed" 2 "Retired" 3 "Unemployed" 4 "Unk", replace 
label values employment employment
tab employment

recode employment_status (2=4), copyrest test
label define employment_status 0 "FT" 1 "PT" 2 "Retired" 3 "Employed but not wrk" 4 "Unemployed", replace 
label values employment_status employment_status
tab employment_status


recode age_entry (1=1) (2=1) (3=2) (4=3) (5=4), copyrest test
label define age_entry 1 "18-34" 2 "35-44" 3 "45-54" 4 "55-64", replace
label values age_entry age_entry
tab age_entry

recode ethnicity_red (3=.) (9=.)
recode sex (3=.)

recode employment (4=.)

tab cohort
rename cohort_id cohort
keep llc_0007_stud_id study_wave pandemic_timetranche c19infection_selfreported c19postest_selfreported c19positive sex ethnicity_red age_entry hm_location housing_composition  soc_1d soc_2d keyworker employment employment_status home_working furlough sic_2d sic_1d  occ_full occ_red vacc_status cohort

gen study_id=2

save "UKHLS edited\UKHLS edited long version slim.dta", replace


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
*numlabel, add
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

gen age_entry=3
label define age_entry 1 "18-34" 2 "35-44" 3 "45-54" 4 "55-64", replace
label values age_entry age_entry


recode sex (1=2) (2=1)
label define sex 1 "Female" 2 "Male", replace
label values sex sex

gen soc_1d=soc2010_1d
gen soc_2d=soc2010_2d

recode ethnicity_red (9=.)
recode home_working (4=.)

tab cohort
decode cohort, gen(cohorts)
drop cohort
rename cohorts cohort

keep llc_0007_stud_id study_wave pandemic_timetranche c19infection_selfreported c19postest_selfreported c19positive sex ethnicity_red age_entry housing_composition keyworker soc_1d soc_2d employment employment_status home_working furlough sic3 sic3cur  occ_full occ_red vacc_status cohort

gen study_id=3

save "BCS70 edited\BCS70 edited long version slim.dta", replace

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
*numlabel, add
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


gen age_entry=1 if cohort==4
label define age_entry 1 "18-34" 2 "35-44" 3 "45-54" 4 "55-64", replace
label values age_entry age_entry


recode sex (1=2) (2=1)
label define sex 1 "Female" 2 "Male", replace
label values sex sex

recode home_working (4=.)

gen soc_1d=soc2010_1d
gen soc_2d=soc2010_2d

tab cohort
decode cohort, gen(cohorts)
drop cohort
rename cohorts cohort

keep llc_0007_stud_id study_wave pandemic_timetranche c19infection_selfreported c19postest_selfreported c19positive sex ethnicity_red age_entry housing_composition keyworker soc_1d soc_2d employment employment_status home_working furlough cohort sic3 sic3cur  occ_full occ_red vacc_status cohort

gen study_id=4

save "MCS edited\MCS edited long version slim.dta", replace

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
*numlabel, add
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


gen age_entry=4 
label define age_entry 1 "18-34" 2 "35-44" 3 "45-54" 4 "55-64", replace
label values age_entry age_entry

recode ethnicity_red (9=.)

recode sex (1=2) (2=1)
label define sex 1 "Female" 2 "Male", replace
label values sex sex

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
rename soc2010_1d soc_1d
rename soc2010_2d soc_2d

recode home_working (4=.)

tab cohort
decode cohort, gen(cohorts)
drop cohort
rename cohorts cohort

keep llc_0007_stud_id study_wave pandemic_timetranche c19infection_selfreported c19postest_selfreported c19positive sex ethnicity_red age_entry housing_composition keyworker soc_1d soc_2d employment employment_status home_working furlough sic3 sic3cur  occ_full occ_red vacc_status cohort

gen study_id=5

save "NCDS58 edited\NCDS58 edited long version slim.dta", replace

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
*numlabel, add
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

recode home_working (4=.)

gen age_entry=1 
label define age_entry 1 "18-34" 2 "35-44" 3 "45-54" 4 "55-64", replace
label values age_entry age_entry


recode sex (1=2) (2=1)
label define sex 1 "Female" 2 "Male", replace
label values sex sex

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
rename soc2010_1d soc_1d
rename soc2010_2d soc_2d 

recode ethnicity_red (9=.)

tab cohort
decode cohort, gen(cohorts)
drop cohort
rename cohorts cohort


keep llc_0007_stud_id study_wave pandemic_timetranche c19infection_selfreported c19postest_selfreported c19positive sex ethnicity_red age_entry  housing_composition keyworker soc_1d soc_2d employment employment_status home_working furlough sic3 sic3cur  occ_full occ_red vacc_status cohort

gen study_id=6

save "NS edited\NS edited long version slim.dta", replace


clear


***************************************************
**Born in Bradford
***************************************************

**study_id=7

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
*numlabel, add
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


recode ethnicity_red (3=2) (9=.), copyrest test

recode employment (4=.)

tab cohort
decode cohort, gen(cohorts)
drop cohort
rename cohorts cohort
drop if cohort==""

keep llc_0007_stud_id study_wave pandemic_timetranche c19infection_selfreported c19postest_selfreported c19positive sex ethnicity_red age_entry housing_composition keyworker  employment employment_status home_working furlough vacc_status cohort

gen study_id=7

save "bib edited\bib edited long version slim.dta", replace



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
*numlabel, add
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
tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}


recode employment (4=.)

tab cohort
rename cohort_id cohort

keep llc_0007_stud_id study_wave pandemic_timetranche c19infection_selfreported c19postest_selfreported sex ethnicity_red age_entry housing_composition keyworker employment employment_status home_working furlough cohort

gen study_id=8

save "genscot edited\genscot edited long version slim.dta", replace

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


recode sex (10=2) (11=1)
label define sex 1 "Female" 2 "Male", replace
label values sex sex

tab employment 
*tab employment_status

**temporary recode/formating to fit with analysis  (saves altering all the analysis code)
*recode employment (3=4) (2=3)
*recode employment_status (2=4) 
rename soc2010_1d soc_1d
rename soc2010_2d soc_2d
replace soc_2d=. if soc_2d<0



keep llc_0007_stud_id study_wave pandemic_timetranche c19infection_selfreported c19postest_selfreported c19positive sex ethnicity_red age_entry housing_composition  soc_1d soc_2d keyworker employment furlough occ_full occ_red vacc_status

gen study_id=9

save "exceed edited\exceed edited long version slim.dta", replace


clear




******************************************************************************
**NORTHERN IRELAND COHORT FOR THE LONGITUDINAL STUDY OF AGEING (NICOLA) - study_id=10
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
*numlabel, add
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

recode employment (4=.)

gen cohort="NICOLA"

keep llc_0007_stud_id study_wave c19infection_selfreported c19postest_selfreported age_entry employment employment_status furlough keyworker cohort

gen study_id=10

save "nicola edited\nicola edited long version slim.dta", replace


clear

*******************************
**COVID19 Psychiatry and Neurological Genetics (COPING) study study_id=11
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
*numlabel, add
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

recode employment (4=.)


rename cohort subcohort
gen cohort="COPING"

keep llc_0007_stud_id study_wave pandemic_timetranche c19positive  sex ethnicity_red age_entry employment employment_status furlough cohort

gen study_id=11


save "coping edited\coping edited long version slim.dta", replace

clear

*******************************
**THE GENETIC LINKS TO ANXIETY AND DEPRESSION (GLAD) study_id=12
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
*numlabel, add
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

recode ethnicity_red (9=.)

recode sex (0=2)

drop cohort
gen cohort="GLAD"

keep llc_0007_stud_id study_wave pandemic_timetranche  c19positive sex ethnicity_red age_entry employment employment_status furlough keyworker cohort


gen study_id=12

save "glad edited\glad edited long version slim.dta", replace


clear

*******************************
**TWINS UK study_id=14 - RETURN TO COMPLETE ONCE NEW VERSION OF DATA IS AVAILABLE 
*******************************

cd "S:\LLC_0007\data\"


**Open and merge NHS data with UKHLS file
use "twinsuk edited\twinsuk edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,
*tostring avail_from_dt, replace 
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
*numlabel, add
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
tab age_entry `var', missing row
*tabstat age_entry, by(`var') stat(N mean sd min max)
*tab hm_location  `var', missing row
tab housing_composition  `var', missing row


}

recode ethnicity_red (9=.)
recode employment (4=.)

gen cohort="TWINSUK"
keep llc_0007_stud_id study_wave pandemic_timetranche c19postest_selfreported c19infection_selfreported c19positive sex ethnicity_red age_entry housing_composition keyworker employment vacc_status cohort

gen study_id=14

save "twinsuk edited\twinsuk edited long version slim.dta", replace


clear


*******************************
**THE AVON LONGITUDINAL STUDY OF PARENTS AND CHILDREN (ALSPAC) - study_id=15
*******************************

***RETURN TO CHECK THE LINKED DATA ONCE AVAILABLE

**study_id=15

**NO LINK TO NHS TESTING DATA CHECK WITH LLC (START THIS SECTION AGAIN)

**Open and merge NHS data with UKHLS file
use "alspac edited\alspac edited long version.dta", clear


*label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
*label values study_wave study_wave
tab study_wave,


sort llc_0007_stud_id study_wave
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
*numlabel, add
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

recode ethnicity_red (9=.)

recode home_working (4=.)

recode employment (4=.)

tab cohort
decode cohort, gen(cohorts)
drop cohort
rename cohorts cohort
replace cohort="ALSPAC-Mothers" if cohort=="Cohort Mothers"
replace cohort="ALSPAC-Members" if cohort=="Cohort Member"


keep llc_0007_stud_id study_wave pandemic_timetranche c19postest_selfreported c19infection_selfreported c19positive sex ethnicity_red age_entry housing_composition keyworker soc_1d soc_2d employment employment_status home_working furlough  occ_full occ_red vacc_status cohort

gen study_id=15

save "alspac edited\alspac edited long version slim.dta", replace


clear









**COMBINE THE DATASETS INTO ONE


use "ELSA edited\ELSA edited long version slim.dta", clear
append using "UKHLS edited\UKHLS edited long version slim.dta", 
append using "BCS70 edited\BCS70 edited long version slim.dta", 
append using "MCS edited\MCS edited long version slim.dta", 
append using "NCDS58 edited\NCDS58 edited long version slim.dta", 
append using "NS edited\NS edited long version slim.dta", 
append using "bib edited\bib edited long version slim.dta", 
append using "genscot edited\genscot edited long version slim.dta", 
append using "nicola edited\nicola edited long version slim.dta", 
append using "coping edited\coping edited long version slim.dta", 
append using "glad edited\glad edited long version slim.dta", 
append using "exceed edited\exceed edited long version slim.dta", 
append using "twinsuk edited\twinsuk edited long version slim.dta", 
append using "alspac edited\alspac edited long version slim.dta", 


label define study_id 0 "Total" 1 "ELSA" 2 "UKHLS" 3 "BCS70" 4 "MCS" 5 "NCDS58" 6 "NextSteps" 7 "BIB" 8 "GENSCOT" 9 "EXCEED" 10 "NICOLA"  11 "COPING" 12 "GLAD" 13 "TRACK-C19" 14 "TWINSUK" 15 "ALSPAC" 16 "MCS-Member" 17 "MCS-Parents", replace 
label values study_id study_id

tab study_id

replace cohort="exceed" if cohort==""


**gen indicator of appropriate summary stats
gen studysample=1 if study_id!=10

tab cohort

**recode odd result
replace c19infection_selfreported=0 if c19infection_selfreported==. & c19postest_selfreported==0


tab study_id c19infection_selfreported, missing
tab study_id c19postest_selfreported, missing
tab study_id c19positive, missing

tab cohort 

tab cohort c19infection_selfreported, missing row
tab cohort c19postest_selfreported, missing row
tab cohort c19positive, missing row


**Initial descriptive statistcs of the outcome(s)
tab c19infection_selfreported, missing
tab c19postest_selfreported, missing
tab c19positive, missing 

**crosstabulation of the outcomes
tab c19infection_selfreported c19postest_selfreported, missing
tab c19infection_selfreported c19positive, missing
tab c19positive c19postest_selfreported, missing


**repeated but by a more appropriate study sample (NICOLA doesnt have waves)
tab pandemic_timetranche c19infection_selfreported if studysample==1
tab pandemic_timetranche c19postest_selfreported if studysample==1
tab pandemic_timetranche c19positive if studysample==1

tab c19infection_selfreported 
tab c19postest_selfreported
tab c19positive 


**repeated including NICOLA

**collapse time-tranche two two rather than three (not enough numbers)
recode pandemic_timetranche (2=1)

**repeated but by a more appropriate study sample (NICOLA doesnt have waves)
tab pandemic_timetranche c19infection_selfreported if studysample==1, missing
tab pandemic_timetranche c19postest_selfreported if studysample==1, missing
tab pandemic_timetranche c19positive if studysample==1, missing

**repeated including NICOLA
tab c19infection_selfreported 
tab c19postest_selfreported
tab c19positive 


**DESCRIBING THE EMPLOYMENT VARIABLES **by time_tranche reduced
label var c19positive "pos test"

label define c19positive 0 "No" 1 "Yes", replace
label values c19positive c19positive 
label define c19infection_selfreported 0 "No" 1 "Yes", replace

label var c19infection_selfreported "Infection"

preserve
tab employment employment_status, missing
replace employment=2 if employment_status==2
replace employment=3 if employment_status==4 & employment==.
replace employment=3 if employment_status==3 & employment==.

replace employment_status=2 if employment_status==0 & employment==2
replace employment_status=3 if employment_status==0 & employment==3

tab employment employment_status, missing



**employment
table  employment (pandemic_timetranche c19infection_selfreported) if studysample==1, 
tab employment c19infection_selfreported
table employment (pandemic_timetranche c19positive) if studysample==1, 

**employment_status
table  employment_status (pandemic_timetranche c19infection_selfreported) if studysample==1, 
tab employment_status c19infection_selfreported
table employment_status (pandemic_timetranche c19positive) if studysample==1, 

**occupation - full version
table  occ_full (pandemic_timetranche c19infection_selfreported) if studysample==1, 
tab occ_full c19infection_selfreported
table occ_full (pandemic_timetranche c19positive) if studysample==1, 

**occupation - reduced version
table  occ_red (pandemic_timetranche c19infection_selfreported) if studysample==1, 
tab occ_red c19infection_selfreported
table occ_red (pandemic_timetranche c19positive) if studysample==1, 

*preserve 
keep if employment==1

**keyworker
table  keyworker (pandemic_timetranche c19infection_selfreported) if studysample==1, 
tab keyworker c19infection_selfreported
table keyworker (pandemic_timetranche c19positive) if studysample==1, 


**home working
table  home_working (pandemic_timetranche c19infection_selfreported) if studysample==1, 
tab home_working c19infection_selfreported
table home_working (pandemic_timetranche c19positive) if studysample==1, 

tab study_id home_working


**furlough
recode furlough (2=0) 
table  furlough (pandemic_timetranche c19infection_selfreported) if studysample==1, 
tab furlough c19infection_selfreported
table furlough (pandemic_timetranche c19positive) if studysample==1, 


restore


***covariates

**age at entry
preserve
recode age_entry (5=4)
table  age_entry (pandemic_timetranche c19infection_selfreported) if studysample==1, 
tab age_entry c19infection_selfreported
table age_entry (pandemic_timetranche c19positive) if studysample==1, 
restore

**sex
table  sex (pandemic_timetranche c19infection_selfreported) if studysample==1, 
tab sex c19infection_selfreported
table sex (pandemic_timetranche c19positive) if studysample==1, 

**ethnicity_red
table  ethnicity_red (pandemic_timetranche c19infection_selfreported) if studysample==1, 
tab ethnicity_red c19infection_selfreported
table ethnicity_red (pandemic_timetranche c19positive) if studysample==1, 

**hm_location
table  hm_location (pandemic_timetranche c19infection_selfreported) if studysample==1, 
tab hm_location c19infection_selfreported
table hm_location (pandemic_timetranche c19positive) if studysample==1, 

**housing_composition
recode housing_composition (9=.)
table  housing_composition (pandemic_timetranche c19infection_selfreported) if studysample==1, 
tab housing_composition c19infection_selfreported
table housing_composition (pandemic_timetranche c19positive) if studysample==1, 

**vaccinations
recode vacc_status (2=1) (3=1)
table  vacc_status (pandemic_timetranche c19infection_selfreported) if studysample==1, 
tab vacc_status c19infection_selfreported
table vacc_status (pandemic_timetranche c19positive) if studysample==1, 




