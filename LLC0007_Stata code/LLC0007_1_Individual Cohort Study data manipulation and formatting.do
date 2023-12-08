


********************************************************************************
**DATA FORMATING AND MANIPULATION - USING COMBINATION OF HEALTH AND WELL BEING CODE
********************************************************************************
cd "S:\LLC_0007\data\"
ssc install datesum

**********************************************************************************
**NHS DATA - Format and Set up

*Notes
**Pillar 1 - Health Care worker swab testing 
**Pillar 2 - Gen Pop swab testing 
**Pillar 3 - serology C19 antibody testing 


**NHS Digital SARI Watch formerly CHESS (COVID Hospitalisations in England Surveillance System)
**contains demographic risk factor treatment and outcome info for patients admitted to hosp with confirmed C19
use "stata_w_labs\nhsd_CHESS_v0001", clear
**contain information on hosp addmissions for those admitted (seems to be 104 only)
count
codebook, compact



*format dates 
foreach var of varlist dateadmittedicu dateleavingicu dateupdated estimateddateonset finaloutcomedate hospitaladmissiondate infectionswabdate labtestdate sbpdate {
	gen `var'_chess=clock(`var', "YMDhms")
	format %tc `var'_chess
	replace `var'_chess=dofc(`var'_chess) 
	format %td `var'_chess
}

gen testdate_chess=labtestdate_chess
format %td testdate_chess

hist testdate_chess if testdate_chess>=date("01/01/2020", "DMY"), freq


**testing 

**Gen Any positive test
gen c19positive_chess=1 if covid19=="Yes"
label var c19positive_chess "Hospital admission test result for those tested postive for COVID"
label define c19pos 0 "Neg" 1 "Pos" 2 "Unk-result", replace
label values c19positive_chess c19pos 
numlabel, add
tab c19positive_chess


**Number of within person tests 
bysort llc_0007_stud_id: egen testno_chess=seq()
label var testno_chess "Num of tests per person"
tab testno_chess

**appear to be be multiple responses per person - all data the same in each
keep if testno_chess==1


**Number of within peron positive test - same as person tests and should be one now 
bysort c19positive_chess llc_0007_stud_id: egen testposno_chess=seq() 
label var testposno_chess "Num of positive tests per person"
tab testposno_chess

**Create NPEX id
gen source=4
label define source 1 "NPEX (P2)" 2 "IELISA (P3)" 3 "SSGS (P1/2)" 4 "CHESS (hosp)", replace
label values source source

bysort llc_0007_stud_id testdate: egen repeated=seq()
tab repeated
list llc_0007_stud_id if repeated>10

keep llc_0007_stud_id *_chess source 
rename *_chess *
sort llc_0007_stud_id


save "NHS edited\CHESS_protect_temp", replace







**Vaccination status - NHS Digital Covid 19 vaccination Status
use "stata_w_labs\nhsd_CVS_v0001", clear
count
codebook, compact

**vaccination 
foreach var of varlist site_of_vaccination_term vaccination_procedure_term vaccine_product_term {
	encode `var', gen(`var'_cvs)
	drop `var'
	tab `var'
}

tab vaccination_procedure_term_cvs
label define vaccination_procedure_term_cvs 1 "First Vac Dose" 2 "Second Vac Dose" 3 "3rd/1st booster" 4 "4th/2nd Booster", replace
tab vaccination_procedure_term_cvs

tab dose_sequence 



**date of vaccination
*format dates 
foreach var of varlist event_received_ts  {
	gen `var'_cvs=clock(`var', "YMDhms")
	format %tc `var'_cvs
	replace `var'_cvs=dofc(`var'_cvs) 
	format %td `var'_cvs
}

tab event_received_ts_cvs
hist event_received_ts_cvs if event_received_ts_cvs>=date("01/01/2020", "DMY"), freq by(vaccination_procedure_term_cvs)


keep llc_0007_stud_id vaccination_procedure_term_cvs site_of_vaccination_term_cvs vaccination_procedure_term_cvs vaccine_product_term_cvs event_received_ts_cvs dose_sequence
rename *_cvs *
sort llc_0007_stud_id

**remove duplicates - start with identical repeats
duplicates tag llc_0007_stud_id event_received_ts vaccination_procedure_term site_of_vaccination_term, gen(dup_tag)
tab dup_tag
duplicates drop llc_0007_stud_id event_received_ts vaccination_procedure_term site_of_vaccination_term, force
tab dup_tag
drop dup_tag
**remove duplicates - drop repeats that must have wrong dates for secondary vacc - no choice but to choose first - small numbers dropped and late in year
duplicates tag llc_0007_stud_id event_received_ts , gen(dup_tag)
tab dup_tag
list llc_0007_stud_id event_received_ts vaccination_procedure_term site_of_vaccination_term dup_tag if dup_tag>1, sepby(llc_0007_stud_id)
drop if dup_tag>0 & vaccination_procedure_term!=1
drop dup_tag
duplicates tag llc_0007_stud_id event_received_ts , gen(dup_tag)
tab dup_tag
list llc_0007_stud_id event_received_ts vaccination_procedure_term site_of_vaccination_term dup_tag if dup_tag>0, sepby(llc_0007_stud_id)
duplicates drop llc_0007_stud_id event_received_ts , force
tab dup_tag
drop dup_tag

save "NHS edited\CVS_protect_temp", replace

**reshape wide to include one obs per person with multiple records of vaccinations
**some very odd vacc sequences
bysort llc_0007_stud_id (event_received_ts): egen vacc_seq=seq()
tab vacc_seq
reshape wide dose_sequence site_of_vaccination_term vaccination_procedure_term vaccine_product_term event_received_ts, i(llc_0007_stud_id) j(vacc_seq)

save "NHS edited\CVS_protect_temp wide", replace


********************************************************************************
**Demographics 
use "stata_w_labs\nhsd_DEMOGRAPHICS_20220716", clear
**Demomgraphic info inc dob, gender and some derived variables including dod (year and mth)
count
codebook, compact

use "stata_w_labs\nhsd_DEMOGRAPHICS_SUB_20220716", clear
**Simply DOB Y/M, and gender 
count
codebook, compact

********************************************************************************
**NHS Digital GDPPR Data for Pandemic Planning and Reserach (C-19)
**Not sure this is useful, contains mostly repeated demographic info
use "stata_w_labs\nhsd_GDPPR_v0001", clear
count
codebook, compact



********************************************************************************
**Mortality - NHS Digital Civil Registration - Death
use "stata_w_labs\nhsd_MORTALITY_20220716", clear
count
codebook, compact

**date of death
tostring reg_date_of_death, replace 
gen reg_date_of_death_mor=date(reg_date_of_death, "YMD")
format %td reg_date_of_death_mor

hist reg_date_of_death_mor if reg_date_of_death_mor>=date("01/01/2020", "DMY")

keep llc_0007_stud_id reg_date_of_death_mor
sort llc_0007_stud_id
save "NHS edited\nhsd_mortality_protect_temp", replace


********************************************************************************
**NHS Digital National Pathology Exchange NPex (pillar 2)
use "stata_w_labs\nhsd_NPEX_v0001", clear
count
*codebook, compact

**symptoms
tab covidsymptomatic
encode covidsymptomatic, gen(covidsymptomatic_npex)
tab covidsymptomatic_npex covidsymptomatic
label var covidsymptomatic_npex "Was individual symptomatic?" 
drop covidsymptomatic

**possible worker info - cannot find any coding for this
tab industrysector 
tab keyworkertype 
tab occupation 
tab occupationtitle 
tab workorstudystatus 
tab workstatus 

foreach var of varlist industrysector keyworkertype workorstudystatus workstatus {
	encode `var', gen(`var'_npex)
	drop `var'
}

*format dates 
foreach var of varlist appointmentdate dateofonset recordcreateddate samplecreationdate specimenprocesseddate testenddate teststartdate {
	gen `var'_npex=clock(`var', "YMDhms")
	format %tc `var'_npex
	replace `var'_npex=dofc(`var'_npex) 
	format %td `var'_npex
}
drop testenddate_npex
rename teststartdate_npex testdate_npex

hist testdate_npex if testdate_npex>=date("01/01/2020", "DMY"), freq


**testing 
foreach var of varlist resultinfo testresult testtype testlocation testcentrecountry testcentrecountryname {
	encode `var', gen(`var'_npex)
	drop `var'
}
label var testresult_npex "Gen Pop COVID Pillar 2 test result"
numlabel, add
tab testresult_npex 
**recoded based on SNOMED_CT search
*1. SCT:1240581000000104 = 1 "Positive-RNA Detection" 
*2. SCT:1240591000000102 = 2 "Neg-RNA Detection" 
*3. SCT:1321691000000102 = 3 "Unk-RNA Detection" 
*4. SCT:1322781000000102 = 4 "Pos-Antigen Detection"
*5. SCT:1322791000000100 = 5 "Neg-Antigen Detection" 
*6. SCT:1322821000000105 = 6 "Unk-Antigen Detection Result"

label define testresult_npex 1 "Positive-RNA Detection" 2 "Neg-RNA Detection" 3 "Unk-RNA Detection" 4 "Pos-Antigen Detection" 5 "Neg-Antigen Detection" 6 "Unk-Antigen Detection Result", replace
label var testresult_npex "SARS-CoV2 Test results"
tab testresult_npex

**Gen Any positive test
recode testresult_npex (1=1) (2=0) (3=2) (4=1) (5=0) (6=2), gen(c19positive_npex)
label define c19pos 0 "Neg" 1 "Pos" 2 "Unk-result", replace
label values c19positive_npex c19pos 

**Number of within person tests 
bysort llc_0007_stud_id: egen testno_npex=seq()
label var testno_npex "Num of tests per person"
tab testno_npex

**Number of within peron positive test 
bysort c19positive_npex llc_0007_stud_id: egen testposno_npex=seq() if testresult==1
label var testposno_npex "Num of positive tests per person"
tab testposno_npex

**Create NPEX id
gen source=1
label define source 1 "NPEX (P2)" 2 "IELISA (P3)" 3 "SSGS (P1/2)"  4 "CHESS (hosp)", replace
label values source source

bysort llc_0007_stud_id testdate: egen repeated=seq()
tab repeated
list llc_0007_stud_id if repeated>10

keep llc_0007_stud_id *_npex source industrysector keyworkertype occupation occupationtitle workorstudystatus workstatus 
rename *_npex *
sort llc_0007_stud_id
**Save file for merging
save "NHS edited\npex_protect_temp", replace


********************************************************************************
**NHS Digital Covid 19 UK Non-hosptial Antibody testing result (Pillar 3)
use "stata_w_labs\nhsd_IELISA_v0001", clear
count
codebook, compact

**symptoms
tab covidsymptomatic
encode covidsymptomatic, gen(covidsymptomatic_ielisa)
tab covidsymptomatic_ielisa covidsymptomatic
label var covidsymptomatic_ielisa "Was individual symptomatic?" 
drop covidsymptomatic

**possible worker info - cannot find any coding for this
tab industrysector 
tab keyworkertype 
tab occupation 
tab workstatus 

foreach var of varlist industrysector keyworkertype workstatus {
	encode `var', gen(`var'_ielisa)
	drop `var'
}

*format dates 
foreach var of varlist appointmentdate dateofonset recordcreateddate specimenprocesseddate testenddate teststartdate {
	gen `var'_ielisa=clock(`var', "YMDhms")
	format %tc `var'_ielisa
	replace `var'_ielisa=dofc(`var'_ielisa) 
	format %td `var'_ielisa
}
drop testenddate_ielisa
rename teststartdate_ielisa testdate_ielisa

tab testdate_ielisa
hist testdate_ielisa if testdate_ielisa>=date("01/01/2020", "DMY"), freq


**testing 
foreach var of varlist testresult testtype testlocation  {
	encode `var', gen(`var'_ielisa)
	drop `var'
}
label var testresult_ielisa "Gen Pop COVID Pillar 3 test result"
numlabel, add
tab testresult_ielisa 
**recoded based on SNOMED_CT search
*1. SCT:1321541000000108 = 1 "SARS-CoV2 -ImmunoglobulinG Detected" 
*2. SCT:1321571000000102 = 2 "SARS-CoV2 -ImmunoglobulinG Not-Detect" 
*2. SCT:1321641000000107 = 3 "SARS-CoV2 -ImmunoglobulinG Unknown" 
label define testresult_ielisa 1 "SCoV2-ImmunoglobulinG Detected" 2 "SCoV2-ImmunoglobulinG Not-Detect" 3 "SARS-CoV2 -ImmunoglobulinG Unknown", replace
label values testresult_ielisa testresult_ielisa
label var testresult_ielisa "SARS-CoV2 Antibody ImmunoglobulinG Test results"
tab testresult_ielisa

**Gen Any positive test
recode testresult_ielisa (1=1) (2=0) (3=2), gen(c19positive_ielisa)
label define c19pos 0 "Neg" 1 "Pos" 2 "Unk-result", replace
label values c19positive_ielisa c19pos 
tab c19positive_ielisa

**Number of within person tests 
bysort llc_0007_stud_id: egen testno_ielisa=seq()
label var testno_ielisa "Num of tests per person"
tab testno_ielisa

**Number of within person positive test 
bysort c19positive_ielisa llc_0007_stud_id: egen testposno_ielisa=seq() if testresult_ielisa==1
label var testposno_ielisa "Num of positive tests per person"
tab testposno_ielisa

**Create NPEX id
gen source=2
label define source 1 "NPEX (P2)" 2 "IELISA (P3)" 3 "SSGS (P1/2)"  4 "CHESS (hosp)", replace
label values source source
tab source

bysort llc_0007_stud_id testdate: egen repeated=seq()
tab repeated
list llc_0007_stud_id if repeated>10

keep llc_0007_stud_id *_ielisa source industrysector keyworkertype occupation workstatus 
rename *_ielisa *
sort llc_0007_stud_id

save "NHS edited\ielisa_protect_temp", replace

********************************************************************************
**NHS Digital COVID SSGS - UKHSA Second Generation Surveillance System
**contains demographic and diagnostic info for patients tested for the suspected and confirmed causitive agent for C19 
**Should contain Pillar 1 and Pillar 2 data - but mostly Pillar 1
use "stata_w_labs\nhsd_COVIDSGSS_v0001", clear
count 
codebook, compact


foreach var of varlist care_home ethnicity_description reporting_lab organism_species_name {
	encode `var', gen(`var'_ssgs)
	tab `var'_ssgs
	drop `var'
}


**Seems to have been used to identify those with SARS-CoV2 (as Identified by SSGS Pillar 1 and Pillar 2) 
**note no negative testing
tab organism_species_name_ssgs

**generate a test result variable to match NPEX and IELISA
gen testresult_ssgs:organism_species_name_ssgs=organism_species_name_ssgs
label var testresult_ssgs "COVID Pillar 1/2 test result"
numlabel, add
tab testresult_ssgs 
**recoded 

**Gen Any positive test
gen c19positive_ssgs=testresult_ssgs
label define c19pos 0 "Neg" 1 "Pos" 2 "Unk-result", replace
label values c19positive_ssgs c19pos 
tab c19positive_ssgs


*format dates 
foreach var of varlist avail_from_dt lab_report_date specimen_date {
	gen `var'_ssgs=clock(`var', "YMDhms")
	format %tc `var'_ssgs
	replace `var'_ssgs=dofc(`var'_ssgs) 
	format %td `var'_ssgs
}

gen testdate_ssgs=specimen_date_ssgs
format %td testdate_ssgs

tab testdate_ssgs
hist testdate_ssgs if testdate_ssgs>=date("01/01/2020", "DMY"), freq


**Number of within person tests 
bysort llc_0007_stud_id: egen testno_ssgs=seq()
label var testno_ssgs "Num of tests per person"
tab testno_ssgs

**Number of within peron positive test 
bysort c19positive_ssgs llc_0007_stud_id: egen testposno_ssgs=seq() if testresult_ssgs==1
label var testposno_ssgs "Num of positive tests per person"
tab testposno_ssgs


gen source=3
label define source 1 "NPEX (P2)" 2 "IELISA (P3)" 3 "SSGS (P1/2)" 4 "CHESS (hosp)", replace
label values source source
tab source


keep llc_0007_stud_id *_ssgs source
rename *_ssgs *
sort llc_0007_stud_id
save "NHS edited\ssgs_protect_temp", replace



********************************************************************************
***APPEND/MERGE FORMATTED NHS DATA TOGETHER

**Append the four sources of test result data together
use "NHS edited\npex_protect_temp", clear
count
tab source
append using "NHS edited\ielisa_protect_temp",
count
tab source
append using "NHS edited\ssgs_protect_temp", 
count
tab source
append using "NHS edited\CHESS_protect_temp", 
count
tab source



**Assess if Multiple entries on the same date with the same test result
**Count number with repeated entries on same testdate with same result
bysort llc_0007_stud_id c19positive testdate: egen repeated=seq()
tab repeated c19positive

list llc_0007_stud_id if repeated==72
list llc_0007_stud_id c19positive testdate source if llc_0007_stud_id==165414690598074080


**reduce to just one entry per day per result - drops 41,787 entries
keep if repeated==1
tab source
drop repeated

**Assess if Multiple entries on the same date with different test result
**Count number with repeated entries on same testdate with same result
bysort llc_0007_stud_id testdate: egen repeated=seq()
tab repeated source
*list llc_0007_stud_id source repeated if repeated>2

**Gen count of number of events
gsort llc_0007_stud_id testdate -repeated
bysort llc_0007_stud_id testdate: gen testcount=repeated if _n==1
bysort llc_0007_stud_id testdate: replace testcount=testcount[_n-1] if _n>1

**if repeated on same day keep positive result if one present
**drop those with an `unknown' result when also having multiple tests with different results (on same day) = 2,240 dropped
drop if c19positive==2 & testcount>1
**drop those with an `Neg' result when also having multiple tests with different results (on same day) = 5,273 dropped
drop if c19positive==0 & testcount>1

**leaves
tab source c19positive

***For PROTECT only need info on positive tests (for within waves per study - do this during merge process)
keep if c19positive==1
**Leaves 100,393 positive tests
tab source c19positive

***repeated infections within the same person - within a period of X months must be the same infection? 
drop testno
bysort llc_0007_stud_id (testdate): gen time_sinceprevpos=testdate-testdate[_n-1]
bysort llc_0007_stud_id (testdate): replace time_sinceprevpos=0 if time_sinceprevpos==.
bysort llc_0007_stud_id (testdate): egen testno=seq()
sum time_sinceprevpos
sum time_sinceprevpos if testno>1

egen time_sinceprevposg=cut(time_sinceprevpos), at(0,1,7,14,30,90,180,365) label
tabstat time_sinceprevpos, by(time_sinceprevposg) stat(N min max)


**temporarily save for merging with cohorts 
save "NHS edited\protect_nhs_c19posinfect_temp", replace 



********************************************************************************
**ENGLISH LONGITUDINAL STUDY OF AGEING - ORIGINALLY PROVIDED BY JINGMIN ZHU FURTHER EDITED BY MGITTINS
**Study_id==1
********************************************************************************

*Note - everything lower case so MG first replaced syntax with one with all lowercase 

*use "data\stata_w_labs\ELSA_elsa_covid_w1_eul_v0001_20211101", clear
*use "data\stata_w_labs\ELSA_elsa_covid_w2_eul_v0001_20211101", clear
*use "stata_w_labs\ELSA_wave_9_elsa_data_eul_fq_v0001_20211101", clear
*use "stata_w_labs\ELSA_wave_9_elsa_data_eul_heps_v0001_20211101", clear
*use "stata_w_labs\ELSA_wave_9_elsa_data_eul_wp_v0001_20211101", clear

************** ELSA **************
cd "S:\LLC_0007\data\"

	
********************************************************************************
/* Merge dataset */
	use "stata_w_labs\ELSA_elsa_covid_w1_eul_v0001_20211101.dta",replace
	rename * *_w1
*	rename idauniq_w1 idauniq
	rename llc_0007_stud_id_w1 llc_0007_stud_id
	save "ELSA edited\temp_w1.dta",replace
	
	use "stata_w_labs\ELSA_elsa_covid_w2_eul_v0001_20211101.dta",replace
	rename * *_w2
*	rename idauniq_w2 idauniq
	rename llc_0007_stud_id_w2 llc_0007_stud_id
	save "ELSA edited\temp_w2.dta",replace

	use "ELSA edited\temp_w1.dta",replace
	merge 1:1 llc_0007_stud_id using "ELSA edited\temp_w2.dta"
	keep if _merge==3
	drop if age_arch_w1>66
	drop if age_arch_w2>66
	drop _merge
**no hotenu variable removed from keepusing hotenu
	merge 1:1 llc_0007_stud_id using stata_w_labs\ELSA_wave_9_elsa_data_eul_wp_v0001_20211101.dta, keepusing( w9soc2000r w9sic2003r)
	keep if _merge==3
	drop _merge
**dervived variables data 
	merge 1:1 llc_0007_stud_id using stata_w_labs\ELSA_wave_9_ifs_derived_variables_v0001_20211101.dta, keepusing(edqual)
	keep if _merge==3
	drop _merge
	
	save "ELSA edited\elsa_wideform.dta", replace

********************************************************************************
/* Generating variables*/	
*** Measured at the start of pandemic ***
****** Age, sex, ethnicity, household size, location at the start of pandemic	
	gen age_entry=age_arch_w1
	recode age_entry (50/54=4) (55/64=5) (65/74=6)

	
	
	gen sex:sex=sex_w1
	recode sex (1=2)(2=1)
	label define sex 1 "f" 2 "m" , replace
	
	gen ethnicity_red=ethnicity_arch_w1
	label define ethnicity 1 "White" 2 "Other", replace
	label values ethnicity_red ethnicity
	tab ethnicity_red
	
	gen household_size:cvnump_w1=cvnump_w1
	recode household_size (-8/-1=.)
	replace household_size=cvnump_w2 if household_size==. & cvnump_w2>0

	
	gen hm_location=ru11ind_arch_w1
	recode hm_location (-1=.)
	label define hm_location 1 "Urban" 2 "Rural", replace
	label values hm_location hm_location

	tab hm_location
	

	*** measured at each time point ***
****** household composition at each time point
	egen offspring_w1=anymatch(demographics_*_cvrelp_w1), values(2 3)
	egen offspring_w2=anymatch(demographics_*_cvrelp_w2), values(2 3)
	egen partinhh_w1=anymatch(demographics_*_cvrelp_w1), values(1)
	egen partinhh_w2=anymatch(demographics_*_cvrelp_w2), values(1)
	recode partinhh_w1 -1=0
	forvalues k=1/2 {
		generate housing_composition_w`k'=.
		replace housing_composition_w`k'=1 if cvnump_w`k'>=2 & partinhh_w`k'==1 & offspring_w`k'==1
		replace housing_composition_w`k'=2 if cvnump_w`k'==2 & partinhh_w`k'==1
		replace housing_composition_w`k'=3 if cvnump_w`k'>=2 & partinhh_w`k'==0 & offspring_w`k'==1
		replace housing_composition_w`k'=4 if cvnump_w`k'==-1 | (cvnump_w`k'>=2 & partinhh_w`k'==0 & offspring_w`k'==0) | (cvnump_w`k'>=3 & partinhh_w`k'==1 & offspring_w`k'==0)
		replace housing_composition_w`k'=5 if cvnump_w`k'==1
		label define cvhhcomp 1"partner+kids" 2"only partner" 3"single parent" 4"other" 5"alone", replace
		label values housing_composition_w* cvhhcomp
		}

****** deprevation at each time point
	gen deprivation_imd_w1=eimd_2015_quintile_w1
	gen deprivation_imd_w2=eimd_2015_quintile_w2
	recode deprivation_imd_w1 -1=.
	recode deprivation_imd_w2 -1=.

	
****** key worker at each time point
	recode cvkey_w* (-9/-1=.)
	generate keyworker_w1:cvkey_w1=(cvkey_w1==1) if cvkey_w1!=.
	generate keyworker_w2:cvkey_w2=(cvkey_w2==1) if cvkey_w2!=.			
	label define noyes 0 "No" 1 "Yes"
	label values keyworker_w* noyes
	tab keyworker_w1
	tab keyworker_w2

	
****** furlough, employment at each time point
	recode cvpstd_w* (-9/-8=.)
	forvalues k=1/2 {
		gen furlough_w`k'=(cvpstd_w`k'==3) if cvpstd_w`k'!=.
		label values furlough_w`k' yesno
		
		gen employment_w`k'=cvpstd_w`k'
		recode employment_w`k' (2/5=1)(1=2)(6/8=2)(.=3)
		label define employment 1 "Employed/looking for work" 2 "Retired" 3 "Unemployed" , replace
		label values employment_w`k' employment
		tab employment_w`k'
	
		gen employment_status_w`k'=0 if (cvpstd_w`k'==2 | cvpstd_w`k'==4) & cvpsth_w`k'>=30
		replace employment_status_w`k'=1 if (cvpstd_w`k'==2 | cvpstd_w`k'==4) & cvpsth_w`k'<30
		replace employment_status_w`k'=2 if employment_w`k'==2
		replace employment_status_w`k'=3 if cvpstd_w`k'==3 | cvpstd_w`k'==5
		replace employment_status_w`k'=4 if cvpstd_w`k'==6 | cvpstd_w`k'==7 | cvpstd_w`k'==8
		label define employment_status 0 "Full-time employment" 1 "Part-time employment" 2 "Retired" 3 "Employed but not working" 4 "Unemployed", replace
		label values employment_status_w`k' employment_status
		tab employment_status_w`k'
	}
	
	
	
******home working at each time point
	recode cvjbhw_w* (-8/-1=.)
	generate home_working_w1:cvjbhw=cvjbhw_w1
	generate home_working_w2:cvjbhw=cvjbhw_w2
	tab home_working_w1
	
****** self-reported covid infection at each time point
    ** covid w1: one of three core symptoms/positive covid test/hospitalisation
	egen srcovid_w1=rowtotal (cvsymp01_w1 cvsymp02_w1 cvsymp05_w1)
    gen srcovid1_w1=(srcovid_w1>=1) if srcovid_w1!=.
    tab cvtestb_w1,mis
    tab cvhosp_w1,mis
	gen c19infection_selfreported_w1=(cvtestb_w1==1 | cvhosp_w1==1 | srcovid1_w1==1) if cvtestb_w1!=. | cvhosp_w1!=. | srcovid1_w1!=.
	label values c19infection_selfreported_w1 yesno
	** covid w2
	recode cvhosp_w2 (-8=.)
    recode cvtestb_w2 (-9=.)
	recode cvtestwhy_final001_w2 -1=.
    gen c19infection_selfreported_w2=(cvtestb_w2 == 1 | cvhosp_w2 == 1 | cvtestwhy_final001_w2==1) if cvhosp_w2!=. | cvtestb_w2!=. | cvtestwhy_final001_w2!=.
	label values c19infection_selfreported_w2 yesno

****** self-reported positive test at each time point
	gen c19postest_selfreported_w1=(cvtestb_w1==1) if cvtestb_w1!=.
	gen c19postest_selfreported_w2=(cvtestb_w2==1) if cvtestb_w2!=.
	label values c19postest_selfreported_w1 yesno
	label values c19postest_selfreported_w2 yesno
	
	
*** measured pre-pandemic wave 9 ***
	
****** education from pre-pandemic wave - missing edqual
	recode edqual w9edqual_w1 (-9/-1=.)
	generate education=edqual
	replace education=w9edqual_w1 if education==.
	recode education 2/7=0 .=3
	
****** soc2000 from pre-pandemic wave
	gen soc_desingation=0
	recode w9soc2000r (-3=.)
	gen soc_1d=floor(w9soc2000r/10)
	gen soc_2d=w9soc2000r

****** sic2003 from pre-pandemic wave
    recode w9sic2003r (-3=.)
	gen sic_2d=w9sic2003r
	gen sic_1d=sic_2d
	recode sic_1d (1/3=1)(5/9=2)(10/33=3)(35=4)(36/39=5)(41/43=6)(45/47=7)(49/53=8)(55/56=9)(58/63=10)(64/66=11)(68=12)(69/75=13)(77/82=14)(84=15)(85=16)(86/88=17)(90/93=18)(94/96=19)(97/98=20)(99=21)(.=22)
	recode sic_1d (34=22)(40=22)(67=22)(89=22)

	save "ELSA edited\elsa_wideform.dta", replace

	
********************************************************************************	
/* reshape to long form*/

**Missing = housing_tenure education

	keep llc_0007_stud_id age_entry sex ethnicity_red household_size hm_location housing_composition_w1 housing_composition_w2 deprivation_imd_w1 deprivation_imd_w2 keyworker_w1 keyworker_w2 furlough_w1 employment_w1 employment_status_w1 furlough_w2 employment_w2 employment_status_w2 home_working_w1 home_working_w2 c19infection_selfreported_w1 c19infection_selfreported_w2 c19postest_selfreported_w1 c19postest_selfreported_w2  soc_desingation soc_1d soc_2d sic_2d sic_1d
	reshape long housing_composition_w deprivation_imd_w keyworker_w furlough_w employment_w employment_status_w home_working_w c19infection_selfreported_w c19postest_selfreported_w, i(llc_0007_stud_id) j(study_wave)
	rename *_w *
	
	gen study_id=1
	gen cohort_id="elsa"
	gen study_wave_date="june/july 2020" if study_wave==1
	replace study_wave_date="nov/dec 2020" if study_wave==2
	gen pandemic_timetranche=1 if study_wave==1
	replace pandemic_timetranche=3 if study_wave==2

	save "ELSA edited\elsa_longform.dta", replace

codebook, compact


**add labels
label var sex "Sex"
label var ethnicity_red "Ethinicty"
label var age_entry "age at entry"			
label var household_size "Household size"			
label var hm_location "Home Location"			
label var deprivation_imd "IMD deprivation"			
label var keyworker "Key worker status"			
label var furlough "Furlough?"			
label var home_working "Home working?"			
label var c19infection_selfreported "Self-reported C19infection"			
label var c19postest_selfreported "Self-reported C19 pos test"			
label var housing_composition "Housing composition"
label var employment "Employment category"
label var employment_status "Employment Status" 
label var soc_1d "1 digit SOC 2000"
label var soc_2d "1 digit SOC 2000"
label var sic_2d "2 digit SIC 2003"
label var sic_1d "1 digit SIC 2003"


***label values - not copied through
**time-tranche
label var pandemic_timetranche "Time-Tranche H&W version"
label define pandemic_timetranche 1 "Apr20-Jun20" 2 "Jul20-Oct20" 3 "Nov20-Mar21", replace
label values pandemic_timetranche pandemic_timetranche
 
 
 
***label self-reported infection 
label define c19infection_selfreported 0 "No" 1 "Self-Rep Infection", replace 
label define c19postest_selfreported 0 "No" 1 "Self-Rep Postest", replace
label values c19infection_selfreported c19infection_selfreported
label values c19postest_selfreported c19postest_selfreported


 
**SOC2000 1 digit
label define soc_1d 1 "Managers and Senior Officals" 2 "Professional Occupations" 3 "Associate Professional and Technical" 4 "Administrative and Secretarial" 5 "Skilled Trades" 6 "Personal Service" 7 "Sales and Customer Services" 8 "Process, Plant and Machine Operative" 9 "Elementary Occ", replace  
label values soc_1d soc_1d
tab soc_1d study_wave_date, missing

**SOC2000 2 digit
label define soc_2d 11 "Corporate Managers" 12 "Managers and Proprietors in Agriculture and Services" 21 "Science and Tech Prof" 22 "Health Prof" 23 "Teaching and Research Prof" 24 "Buisness and Public Services Prof" 31 "Science and Tech A-Prof" 32 "Health and Social Welfare A-Prof" 33 "Protective Services" 34 "Culture, Media, Sports Occ" 35 "Buisness and Public Serivces A-Prof" 41 "Administrative Occ" 42 "Secretarial and Related" 51 "Skilled Agricultural Trades" 52 "Skilled Metal and Electrical Trades" 53 "Skilled Construction and Building Trades" 54 "Textiles, Printing, Other skilled Trades" 61 "Caring Personal Services" 62 "Leisure & Other Personal Service Occ" 71 "Sales Occ" 72 "Customer Service" 81  "Process, Plant, and Machine Operative" 82 "Transport, Mobile Macnine Drivers and Operatives" 91 "Elementary Trades, Plant and Storage related Occ" 92 "Elementary Admin and Service Occ", replace 
label values soc_2d soc_2d
tab soc_2d study_wave_date, missing

*SIC2003 1 digit 
**sic_1d provided - version based on ONS webpage?
label var sic_1d "1 digit SIC based on ONS version of workbook - MG version"
label define sic_1d 1 "A:Agriculture, Hunting, and Forestry "  2  "B:Mining and Quarrying"  3 "C:Manufacturing"  4 "D:Electricity, Gas, steam and air con" 5 "E:Water Supply, Sewerage, Waste Man"  6 "F:Construction"  7 "G:Wholesale and Retail Trade; Repair of Motor Vehicles Motorcycles, Household Goods"  8 "H:Transport, Storage" 9 "I: Accomodation and Food Service"  10 "J:Information and Communication" 11 "K:Financial Intermediation"  12 "L:Real Estate Activities" 13 "M:Professional, Scientific, and Technical Act" 14 "N:Administrative and Support Sercices Act" 15 "O:Public Admin and Defence; Compulsory Social Security" 16 "P:Education"  17 "Q:Human Health and Social Work" 18 "R:Arts, Entertainment, and Recreation" 19 "S:Other Service Activities" 20 "T:Activities of Households as Employers" 21 "U:Activities of Extraterritorial Organisations and Bodies" 22 "Miss", replace
label values sic_1d sic_1d
tab sic_1d



**generate mg version of 1 digital SIC codebook 89==.?
gen sic_1dmg=sic_2d
recode sic_1dmg (1/2=1) (5=2) (10/14=3) (15/37=4) (40/41=5) (45=6) (50/52=7) (55=8) (60/64=9) (65/67=10) (70/74=11) (75=12) (80=13) (85=14) (90/93=15) (95/97=16) (99=17) (89=.)
label var sic_1dmg "1 digit SIC based on SOC2003 workbook - MG version"
label define sic_1dmg 1 "A:Agriculture, Hunting, and Forestry "  2 "B:Fishing"  3 "C:Mining and Quarrying"  4 "D:Manufacturing"  5 "E:Electricity, Gas, and Water Supply"  6 "F:Construction"  7 "G:Wholesale and Retail Trade; Repair of Motor Vehicles Motorcycles, Household Goods"  8 "H:Hotels and Restaurants"  9 "I:Transport, Storage, and Communication"  10 "J:Financial Intermediation"  11 "K:Real Estate, Renting and Business Activities"  12 "L:Public Admin and Defence; Compulsory Social Security"  13 "M:Education"  14 "N:Health and Social Work"  15 "O:Other Community, Social and Personal Service Activities"  16 "P:Private Households Employing Staff and Undifferentiated Production Activities of Households for Own Use "  17 "Q:Extra-territorial Organisation and Bodies", replace
label values sic_1dmg sic_1dmg
tab sic_1dmg

tab sic_1d sic_1dmg


*SIC2003 2 digit
label define sic20032dig 1 "Agriculture Production - Crops"  2 "Forestry Logging And Related Services"  15 "Manufacture Of Food Products And Beverages"  17 "Manufacture Of Textile Products"  18 "Manufacture Of Wearing Apparel"  21 "Manufacture Of Pulp, Paper, And Paper Products"  22 "Publishing, Printing, And Reproduction Of Recorded Media"  23 "Manufacture Of Coke, Refined Petroleum Products And Nuclear Fuel"  24 "Manufacture Of Chemicals And Chemical Products"  25 "Manufacture Of Rubber And Plastic Products"  26 "Manufacture Of Other Non-Metalic Mineral Products"  28 "Manufacture Of Fabricated Metal Products Except Machinery And Equipment"  29 "Manufacture Of Machinery And Equipment Not Elsewhere Classified"  31 "Manufacture Of Electrical Machinery And Apparatus Not Elsewhere Defined"  32 "Manufacture Of Radio, Television And Communication Equipment And Apparatus"  33 "Manufacture Of Medical, Precision And Optical Instruments, Watches And Clocks"  34 "Manufacture Of Motor Vehicles And Semi-Trailers"  35 "Manufacture Of Other Transport Equipment"  36 "Manufacture Of Furniture; Manufacturing Not Elsewhere Classified"  37 "Recycling"  40 "Electricity, Gas, Steam And Hot Water Supply"  41 "Collection, Purification And Distribution Of Water"  45 "Construction"  50 "Sale, Maintenance And Repair Of Motor Vehicles And Motorcycles "  51 "Wholesale Trade And Commission Trade, Except Of Motor Vehicles And Motorcycles "  52 "Retail Trade, Except Of Motor Vehicles And Motorcycles; Repair Of Personal And Household Goods"  55 "Hotels And Restaurants"  60 "Land Transport; Transport Via Pipelines"  61 "Water Transport"  62 "Air Transport"  63 "Supporting And Auxiliary Transport Activities; Activities Of Travel Agencies"  64 "Post And Telecommunications"  65 "Financial Intermediation, Except Insurance And Pension Funding"  66 "Insurance And Pension Funding; Except Compulsory Social Security "  67 "Activities Auxiliary To Financial Intermediation"  70 "Real Estate Activities"  71 "Renting Of Machinery And Equipment Without Operator And Of Personal And Household Goods"  72 "Computer And Related Activities"  73 "Research And Development "  74 "Other Business Activities"  75 "Public Administration And Defence; Compulsory Social Security"  80 "Education"  85 "Health And Social Work"  89 "???"  90 "Sewage And Refuse Disposal Sanitation And Similar Activities"  91 "Activities Of Membership Organisations Not Elsewhere Classified"  92 "Recreational Cultural And Sporting Activities"  93 "Other Services Activities"  95 "Activities Of Households As Employers Of Domestic Staff"  99 "Extra-Territorial Organisations And Bodies", replace 
label values sic_2d sic20032dig
tab sic_2d

codebook, compact





save "ELSA edited\elsa_longform.dta", replace


***************************************	
****MERGING WITH THE NHS TESTING DATA
use "NHS edited\protect_nhs_c19posinfect_temp", clear
count


**drop if within 2 weeks - drops 14,309, leaves 25,125 positive tests
drop if time_sinceprevpos<14 & time_sinceprevpos!=0


***create identification of (ELSA) wave in nhs infection data
gen study_wave=1 if testdate<=date("31/07/2020", "DMY")
replace study_wave=2 if testdate>date("31/07/2020", "DMY") & testdate<date("31/12/2020", "DMY")
label define study_wave 1 "june/july 2020" 2 "nov/dec 2020" , replace
label values study_wave study_wave
drop if study_wave==.
tab source
sort llc_0007_stud_id study_wave

**Look for within wave repeats
bysort llc_0007_stud_id study_wave: egen seq=seq()
tab seq
gen rep_n=seq
gsort llc_0007_stud_id study_wave -seq
by llc_0007_stud_id study_wave: replace rep_n=rep_n[_n-1] if _n>1
tab rep_n
list llc_0007_stud_id study_wave testdate seq if rep_n!=1
*take first pos test
keep if seq==1
drop seq rep_n

**save temporay elsa version of nhs infection data
save "ELSA edited\protect_nhs_c19posinfect_temp_elsaver", replace


clear



********************************************************************************
***********SETTING UP UNDERSTANDING SOCIETY***********
**study_id==2
********************************************************************************



*PROBLEM in caps indicates place where there there might be a problem withthe data. 
*Varable search funding on the website. 
*https://www.understandingsociety.ac.uk/documentation/covid-19/dataset-documentation

**Project: Study title: Multi-Longitudinal Cohort Study into occupational factors and Covid-19 Risk
**Analysts: OH (olivia.hamilton@glasgow.ac.uk) and Richard Shaw (Richard.Shaw@glasgow.ac.uk)
** NOte that this a collaborative work with Liv Identifying key variables in R and Richard converting into. Stata. 
**Also note that this Mike Green ( Michael.Green@glasgow.ac.uk) developed much of the Early code. 
**This file contains R code used to derive variables required for analysis

********************************************************************************
*** Assembling files 
*Note this currently assumes that the USoc Files are in stata format as held on the data archive. 
*This will require a preliminay step downloading them 

****some waves of data have multiple files _1_ _2_ _3_ etc , seems to be vars seperated out
**Have merged, but ask Richard.


*Setting File locations 
**
clear all
set maxvar 30000
set more off


**File Path
cd "S:\LLC_0007\data\"

***Preparing data files
*Recoding Prepandmic variables with same name across files. 
foreach x in a b c d  g h {
clear 
use "stata_w_labs\UKHLS_c`x'_indresp_w_v0003_20220531.dta" 
rename (racel_dv psu strata) (c`x'_racel_dv c`x'_psu c`x'_strata)

save "UKHLS edited\c`x'_indresp_w_c`x'racel.dta", replace
}

*Recoding Prepandmic variables with same name across files.
*e and f require have a split file 1 and 2, 1 seems to contain vars to be altered 
foreach x in e f {
clear 
use "stata_w_labs\UKHLS_c`x'_indresp_w_v0003_1_20220531.dta" 
rename (racel_dv psu strata) (c`x'_racel_dv c`x'_psu c`x'_strata)

merge 1:1 llc_0007_stud_id using "stata_w_labs\UKHLS_c`x'_indresp_w_v0003_2_20220531.dta" 
tab _merge
drop _merge

save "UKHLS edited\c`x'_indresp_w_c`x'racel.dta", replace
}




*** Merging data files 
clear 

**Pre-pandemic waves - LLC version has waves in multiple seperate files 
*Wave 10
use "stata_w_labs\UKHLS_j_indresp_v0003_1_20220531.dta", clear
merge 1:1 llc_0007_stud_id using "stata_w_labs\UKHLS_j_indresp_v0003_2_20220531.dta",
drop _merge
merge 1:1 llc_0007_stud_id using "stata_w_labs\UKHLS_j_indresp_v0003_3_20220531.dta", 
drop _merge




*Add wave 9 
merge 1:1 llc_0007_stud_id using "stata_w_labs\UKHLS_i_indresp_v0003_1_20220531.dta", gen(w9mrg)
merge 1:1 llc_0007_stud_id using "stata_w_labs\UKHLS_i_indresp_v0003_2_20220531.dta",
drop _merge
merge 1:1 llc_0007_stud_id using "stata_w_labs\UKHLS_i_indresp_v0003_3_20220531.dta", 
drop _merge
merge 1:1 llc_0007_stud_id using "stata_w_labs\UKHLS_i_indresp_v0003_4_20220531.dta", 
drop _merge


*Add wave 8 
*merge 1:1 llc_0007_stud_id using "stata_w_labs\UKHLS_h_indresp_v0003_1_20220531.dta", gen(w8mrg)
*Add wave 7
*merge 1:1 llc_0007_stud_id using "stata_w_labs\UKHLS_g_indresp_v0003_1_20220531.dta", gen(w7mrg)



**Covid data 
*add covid data
*global Working_Data "D:\Data\UnderstandingSociety\WorkingFiles\ARQ7_P4"
foreach x in a b c d e f g h {
merge 1:1 llc_0007_stud_id using "UKHLS edited\c`x'_indresp_w_c`x'racel.dta", gen(c`x'_mrg)
tab c`x'_mrg
}


*********************************************************************************
*****Variables 
********************************************************************************
*NB initially ordered as in Example Data structure but some will need to be returned
* after reshaping the file. 


***study_id
*Note this will need to be taken from the LLC info 

***cohort_id
gen cohort_id = "USoc" 

***study_wave
*Calculate when reshaping will require changing variable names. 


***pandemic_timetranche
label define  pandemic_timetranche 1 "T1: April-June 2020" 2 "T2: July-October 2020" 3 "T3: November 2020-March 2021"
*Note will need to be calculated based on a reshaped dataset. 


***age_entry 
*Note I will use age when first particpated in USoc as proxy for age at start pandemic but replacing ca_AGE with ca_pipcorrected as miising for ca_age
* with later waves   or derived from dob for pre pandemics. 


label define age_entry 1 "16-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55-64" 6 "65-74"  7 "75+" 
gen lob_birthy = j_birthy
recode lob_birthy (-9/-1 = .)
replace lob_birthy = i_birthy if lob_birthy == . 
recode lob_birthy (-9/-1 = .)
*replace lob_birthy = h_birthy if lob_birthy == . 
*recode lob_birthy (-9/-1 = .)
*replace lob_birthy = g_birthy if lob_birthy == . 
*recode lob_birthy (-9/-1 = .)
gen dob_age = 2020 - lob_birthy

gen ca_age_temp = ca_age
*replace ca_age_temp = . if ca_llc_0007_stud_idcorrected > 0 

gen  age = ca_age_temp
foreach wave in  b c d e f g h {
replace age = c`wave'_age if age == . 
}
replace age = dob_age if age ==. 

recode age 16/24 = 1  25/34 = 2 35/44 = 3 45/54 = 4 55/64 = 5 65/74 = 6 75/110 = 7, gen(age_entry) 
label values age_entry age_entry 



***sex 
clonevar sex=j_sex
replace sex=. if sex<0
replace sex=i_sex if sex==.
*replace sex=h_sex if sex==.
*replace sex=g_sex if sex==.
foreach x in ca cb cc cd ce cf cg{
replace sex=`x'_sex if sex==.
}
replace sex=. if sex<0|sex==3
recode sex (2 = 1) (1 = 2) (. = 3) 
label var sex "Sex"
label define  sex 1 "female" 2 "male" 3 "unknown" 
label values sex sex
tab sex,m

***ethnicity & ethnicity_red

*Create ethnic group
label define ethnicity 1 "White" 2 "Mixed" 3 "South Asian" 4 "Black"  5 "Other Asian" 6 "Other" 7 "Missing" 
label define ethnmin 1 "White" 2 "Non-White" 3 "Missing" 

*-g h
foreach x in  i j ca cb cc cd ce cf cg ch{
recode `x'_racel_dv (-9/0=.) (1/4=1) (5/8=2) (9/11=3) (12/13=5) (14/16=4) (17 97=6), gen(`x'_eth)
label var `x'_eth "Ethnic group"
label values `x'_eth ethnicity
tab `x'_eth, m
recode `x'_eth (1=1) (2/6=2), gen(`x'_ethmin)
tab `x'_ethmin, m
label values `x'_ethmin ethnmin
}


*create overall ethnicity var using data from all waves
*prefer pre-pandemic data
*-h g
clonevar ethnicity=j_eth
foreach x in i  ca cb cc cd ce cf cg ch{
replace ethnicity=`x'_eth if ethnicity==.
}
label var ethnicity "Ethnic group"
label values ethnicity ethnicity
recode ethnicity (1=1) (2/6=2) (. = 3), gen(ethnicity_red)
label values ethnicity_red ethnmin
recode ethnicity . = 7
tab ethnicity_red, m
tab ethnicity, m


 *** household_size 
 *1,...,4,5+ 
*Note that this is not based on an idea measure many of hte individual groups are 2+ 
* As this is one measure at the start of pandemic, and people had different start dates. 
* willl take the first value. 

*-
gen household_size = .
foreach wave in a b c d e f g h {
egen c`wave'_numbhh  = rowtotal(c`wave'_hhcompa c`wave'_hhcompa c`wave'_hhcompb c`wave'_hhcompc c`wave'_hhcompd c`wave'_hhcompe) 
replace c`wave'_numbhh =. if c`wave'_hhcompa == . 
replace household_size = c`wave'_numbhh  + 1 if household_size  ==. 
}

recode household_size 6/16 = 5
label define household_size 5 "5+" 
label values household_size household_size

***housing_composition 
label define housing_composition 1 "partner & children" 2 "partner no children" 3 "lone parent" 4 "other" 5 "alone" 


*number of children
*going to use children under16 as derived variable available
*and some 16 year olds included in sample
*-g h
foreach x in  i j{
recode `x'_nchild_dv (0=0) (1/20=1) (-20/-1=.), gen(`x'_anychd)
tab `x'_anychd, m
}
gen cb_anychd=.
replace cb_anychd=0 if cb_couple>=0 & cb_couple!=. 
foreach var in a b c d e f g h i j k l m n {
replace cb_personage`var'=. if cb_personage`var'<0
replace cb_anychd=1 if cb_personage`var'<=15 & cb_relation`var'==3
}
tab cb_anychd
*for CA use CB unless missing, in which case use w9
clonevar ca_anychd=cb_anychd
replace ca_anychd=i_anychd if cb_anychd==.
tab ca_anychd 
tab ca_anychd i_anychd, m
foreach x in cc cd ce cf cg ch{
recode `x'_parent015 (-9/0=.) (1=1) (2=0), gen(`x'_anychd)
label values `x'_anychd yesno
tab `x'_anychd
}
*-g h
foreach x in  i j{
recode `x'_single_dv (0=1) (1=2), gen(`x'_couple)
}
label define hhtyp 0 "Single no Kids" 1 "Single with Kids" 2 "Couple no Kids" 3 "Couple with Kids"
*-g h
foreach x in  i j ca cb cc cd ce cf cg ch{
gen `x'_hhtyp=.
replace `x'_hhtyp=0 if `x'_couple==2 & `x'_anychd==0
replace `x'_hhtyp=1 if `x'_couple==2 & `x'_anychd==1
replace `x'_hhtyp=2 if `x'_couple==1 & `x'_anychd==0
replace `x'_hhtyp=3 if `x'_couple==1 & `x'_anychd==1
label values `x'_hhtyp hhtyp
label variable `x'_hhtyp "Partner/Child Status"
tab `x'_hhtyp
}
*Note to create the other category based on household size. 
foreach wave in a b c d e f g h {
gen c`wave'_hhtyp_plus = c`wave'_hhtyp
recode c`wave'_hhtyp_plus 0 = 4 if c`wave'_numbhh > 0 & c`wave'_numbhh <= 16
}

gen housing_composition = . 
foreach wave in a b c d e f g h {
replace housing_composition = c`wave'_hhtyp_plus  if housing_composition ==. 
}
recode housing_composition 3 = 1  2 = 2 1 = 3 0 = 5 4 =4 
label values housing_composition housing_composition 

foreach wave in a b c d e f g h {
recode c`wave'_hhtyp_plus 3 = 1  2 = 2 1 = 3 0 = 5 4 =4 , gen(c`wave'_housing_composition)
label values c`wave'_housing_composition  housing_composition
}



*** housing_tenure
* Note only avaiable from the 4th wave with movers updating in subsequent waves. 
* Note those refusing in the 4th wave are not asked agiagn in the firth wave. 
* Would require pre-pandemic data for other outcomes. 
*Recode the valid measures for all waves
label define housing_tenure 1 "Own/mortage" 2 "Other/rent" 
foreach wave in d e f g h {
recode c`wave'_hsownd_cv  (1 2 3 = 1) ( 4 5 6 97 = 2), gen(c`wave'_tenure)
label values c`wave'_tenure tenure
}

*Other waves recode the non applicable to carry forward past values and code other values as missing Note this is valid foe each wave
replace ce_tenure = cd_tenure if ce_tenure == -8  & (cd_tenure == 1 | cd_tenure == 2)


replace cf_tenure = ce_tenure if cf_tenure == -8 & (ce_tenure == 1 | ce_tenure == 2)
replace cf_tenure = cd_tenure if cf_tenure == -8 & (cd_tenure == 1 | cd_tenure == 2)


replace cg_tenure = cf_tenure if cg_tenure == -8 & (cf_tenure == 1 | cf_tenure == 2)
replace cg_tenure = ce_tenure if cg_tenure == -8 & (ce_tenure == 1 | ce_tenure == 2)
replace cg_tenure = cd_tenure if cg_tenure == -8 & (cd_tenure == 1 | cd_tenure == 2)

replace ch_tenure = cg_tenure if ch_tenure == -8 & (cg_tenure == 1 | cg_tenure == 2)
replace ch_tenure = cf_tenure if ch_tenure == -8 & (cf_tenure == 1 | cf_tenure == 2)
replace ch_tenure = ce_tenure if ch_tenure == -8 & (ce_tenure == 1 | ce_tenure == 2)
replace ch_tenure = cd_tenure if ch_tenure == -8 & (cd_tenure == 1 | cd_tenure == 2)

foreach wave in d e f g h {
recode c`wave'_tenure (-9/-1 =.) 
}

*This is first tenure value for anybody who has tenure data.  

gen tenure = cd_tenure
foreach wave in e f g h {
replace tenure = c`wave'_tenure if tenure == . 
}

gen housing_tenure = tenure 
label values  housing_tenure housing_tenure

foreach wave in  d e f g h {
gen c`wave'_housing_tenure =  c`wave'_tenure
label values c`wave'_housing_tenure housing_tenure
}
 

*** deprivation IMD 
*Requires additional file, and will need to recode for each country.  May be available in the NHS data.  


*** education 
*Highest education: 4 groups
label define educn 1 "Degree" 2 "ALevel" 3 "GCSE" 4 "None"
*binary degree level
label define edubin 0 "Less than degree" 1 "Degree or equivalent"
*Final degree variable with missing category 
label define education 0 "No Degree" 1 "Degree" 3 "Not-reported" 

*-g h
foreach x in  i j {
gen `x'_educ=. 
replace `x'_educ=4 if `x'_qfhigh_dv==96
replace `x'_educ=1 if `x'_qfhigh_dv==1 | `x'_qfhigh_dv==2 | `x'_qfhigh_dv==3 | `x'_qfhigh_dv==4 | `x'_qfhigh_dv==5 | `x'_qfhigh_dv==6
replace `x'_educ=2 if `x'_qfhigh_dv>=7 & `x'_qfhigh_dv<13
replace `x'_educ=3 if `x'_qfhigh_dv>12 & `x'_qfhigh_dv<17 
label values `x'_educ educn
label var `x'_educ "Education level"
recode `x'_educ (1=1) (2 3 4=0), gen(`x'_degree)
label values `x'_degree edubin
*tabs
tab1 `x'_educ `x'_degree
}


gen high_qual = j_educ
replace high_qual = i_educ if high_qual ==. 
*replace high_qual = h_educ if high_qual ==. 
*replace high_qual = g_educ if high_qual ==. 

recode high_qual 1 = 1 2 = 0  3  = 0 4 = 0, gen(degree)

recode degree 0 = 0 1 = 1 . =3 , gen(education) 
label values education education 


*** hm_location
*Note based on pre-pandemic 
label define hm_location 1 "Urban" 2 "Rural" 
*urban/rural indicator
*-g h
foreach x in  i j{
	tab `x'_urban_dv
	recode `x'_urban_dv (-9/-1=.) (1=1) (2=0), gen(`x'_urban)
	tab `x'_urban
}
*get last observed urban rural across wave g-j
clonevar lob_urban=j_urban
tab lob_urban
*-h g
foreach x in i  {
	replace lob_urban=`x'_urban if lob_urban==.
}
tab lob_urban 
recode lob_urban 0 = 2 , gen(hm_location) 
label values hm_location hm_location

*** contacts_outside_work
label define  contacts_outside_work 1 "Daily" 2 "Several times per week" 3 "At least once per week" 4 "Several times per month"   5 "At least once per month" 6 "Less often" 7 "Never" 

*Available in june and novermber wave only  
*Text: In the last 4 weeks, how often have you met in person with friends and family who do not live with you?
* Note I am not coding for pre-pandemic cc_blf2fcontact 
* 
* 

recode cc_f2fcontact (-9/-1 = .), gen(cc_contacts_outside_work)
label values cc_contacts_outside_work contacts_outside_work

recode cf_f2fcontact (-9/-1 = .), gen(cf_contacts_outside_work)
label values cf_contacts_outside_work contacts_outside_work





*** public transport 
*Note is available for three of the months but would probably only be used in a sepereate questoin 
* trbusfq_cv trtrnfq_cv trtubefq These would be bus, train and tube respectively. 
* Conc only measured in 3 of the 8 waves and 5% use any transport so would drop. 
*Logic will 
label define public_transport 0 "Less than that or never" 1 "Once or twice a week" 2 "At lesst three times a week, but not every day" 3 "At least once a day" 

foreach wave in c f h {
gen c`wave'_public_transport = . 
recode c`wave'_public_transport . = 3 if c`wave'_trbusfq_cv == 1 | c`wave'_trtrnfq_cv  == 1 | c`wave'_trtubefq == 1 
recode c`wave'_public_transport . = 2 if c`wave'_trbusfq_cv == 2 | c`wave'_trtrnfq_cv  == 2 | c`wave'_trtubefq == 2 
recode c`wave'_public_transport . = 1 if c`wave'_trbusfq_cv == 3 | c`wave'_trtrnfq_cv  == 3 | c`wave'_trtubefq == 3 
recode c`wave'_public_transport . = 0 if c`wave'_trbusfq_cv == 4 | c`wave'_trtrnfq_cv  == 4 | c`wave'_trtubefq == 4 
replace c`wave'_public_transport = . if c`wave'_trbusfq_cv < 0 | c`wave'_trtrnfq_cv  < 0  | c`wave'_trtubefq < 0 
label values c`wave'_public_transport public_transport
}

*** Hospitality 
*I am not aware of this variable existing. 


**** vaccination_status
* Based on the surveys a small proportion might be indentifable as having had the vaccine in the January and March waves. 
* It is possible to code this but may be a lot of work. 
label define vaccination_status 0 "None" 1 "1st dose" 2 "2nd does" 3 "3rd dose" 4 "4th Booster" 

*Note I am assuming that nobody has had the vaccine before Jan 2021 survey. 

foreach wave in a b c d e f  {
gen c`wave'_vaccination_status = 0 
label values c`wave'_vaccination_status vaccination_status
}


gen cg_vaccination_status = cg_hadcvvac
recode cg_vaccination_status (-9/-1 = .) (1 = 1 ) (2 = 2 )(3 = 0) (4 = 0 )
label values cg_vaccination_status vaccination_status

gen ch_vaccination_status = ch_ff_hadcvvac
recode ch_vaccination_status 3 = 0 
replace ch_vaccination_status = 1 if ch_hadcvvac == 1
replace ch_vaccination_status = 2 if ch_hadcvvac == 2
recode ch_vaccination_status -9/-1 = . 


*** key_worker

label define key_worker 0 "No" 1 "Yes" 

* PROBLEM  asking key worker status in Understanding society is very inconsistent. The options are either to limit to wave where the same question and methodolgy is asked 
* b c g h  or to have a single fixed value across time, using the first best availabel value. 


*NOte this is coding variables for each wave. (DO NOT USE d  e  g 
recode ca_keyworker -9/-1 = . 2 = 0, gen(ca_key_worker)
label values ca_key_worker key_worker

foreach wave in  b c d e  g h {
recode c`wave'_keyworksector -9/-1 = . 1/8 = 1 9 = 0, gen(c`wave'_key_worker)
label values c`wave'_key_worker key_worker
}

gen key_worker  = . 
foreach  wave in  b c d e g h {
recode key_worker . = 1 if  c`wave'_keyworksector  >= 1 & c`wave'_keyworksector  <= 8
recode key_worker . = 0 if  c`wave'_keyworksector  == 9
}
recode key_worker . = 1 if ca_keyworker == 1
recode key_worker . = 0 if ca_keyworker == 2

label values key_worker  key_worker




*** furlough 
label define furlough 0 "Employed" 1 "Furloughed" 

**NB this will require quite a lot of complicated recoding because
* pre_existing variables with the name. 
* Liv's R code which I am adapting is quite complicated 
* Will first use Liv's code to create a variable that identifies the numerator data 
* Then combine that with the employment data to derive the 
* Note that CG and CH ask furlough slighly different so the way of deriviving the measures will be slightly different. 


*Note only creating valed values for those who are employed or furloughed. 




** FURLOUGH STATUS NOT ASCERTAINED IN THE SAME WAY AT EACH WAVE, SO REQUIRES SOME WRANGLING
** for waves cb, cc and cd, they only ask if participants are on furlough if they've not reported being on 
** furlough previously (cx_furlough)
** we also have cx_ff_furlough, which is furlough at any previous timepoint
** so we can combine, cx_furlough and cx_ff_furlough at each timepoint, but this will treat people who have 
** been taken off furlough as still being furloughed
** to remedy this, I've created a flag for those who reported being on furlough at a previous wave, but who 
** have reported an increase in working hours since then, as this indicates that they have likely come off furlough


** first changing missing codes to NA
** NB originally followed Liv's code for this but may still need the actual missing values to determin dominator. 
** So generating new variable instead of just recoding missing values. 
foreach wave in a b c d {
recode c`wave'_furlough -9/-1 = . ,gen(c`wave'_furlough_miss)
}

foreach wave in a b c d e f g h {
recode c`wave'_hours -9/-1 = . , gen(c`wave'_hours_miss)
}

foreach wave in b c d e f g h {
recode c`wave'_ff_hours -9/-1 = . , gen(c`wave'_ff_hours_miss)
}

recode cg_newfurlough -9/-1 = . ,gen(cg_newfurlough_miss) 
recode ch_newfurlough -9/-1 = . , gen(ch_newfurlough_miss) 

** there is a variable called stillfurl for waves 5 and 6, but this is only asked to ppts who had previously reported
** being furloughed, so just going to use same method for classifying furlough in 5 & 6 as I do for 2, 3 and 4 
** creating flag for ppts working more hours than last reported wave
** hours have increased=1
** ours have not increased=0
 
foreach wave in b c d e f g h  {
gen c`wave'_hrs_increase = 1 if (c`wave'_hours_miss > c`wave'_ff_hours_miss) & c`wave'_hours_miss != . 
}


** If on furlough at previous wave and if hours have not increased since then, indicates they are likely still on furlough
** Still on furlough=1
** Otherwise=0
recode ca_furlough_miss 2 = 0, gen(ca_furl)


*** rjs logic added will be done slightly different due to how stata handles missing data. 
*** Furloughed = new furlough 

* Note the code below should be accurate for the numerator of the furloughed but will need to be create
* The correct denominator population. 

gen cb_furl = .  
replace cb_furl = 1 if ca_furl == 1 
replace cb_furl = 1 if cb_furlough == 1 
replace cb_furl = 0 if cb_furlough == 2 & cb_furl == 1
replace cb_furl = 0 if cb_hrs_increase == 1 & cb_furl == 1

gen cc_furl = .  
replace cc_furl = 1 if cb_furl == 1 
replace cc_furl = 1 if cc_furlough == 1 
replace cc_furl = 0 if cc_furlough == 2 & cc_furl == 1
replace cc_furl = 0 if cc_hrs_increase == 1 & cc_furl == 1

gen cd_furl = .  
replace cd_furl = 1 if cc_furl == 1 
replace cd_furl = 1 if cd_furlough == 1 
replace cd_furl = 0 if cd_furlough == 2 & cd_furl == 1
replace cd_furl = 0 if cd_hrs_increase == 1 & cd_furl ==  1


*** PROBLEM Note liv's approach tends to clasify people who are part working and part furloughed as 
*** Employed this probably makes sense but. As consistent bujt needs checking 

gen ce_furl = .  
replace ce_furl = 1 if cd_furl == 1 
replace ce_furl = 0 if ce_hrs_increase == 1 & ce_furl ==  1

gen cf_furl = .  
replace cf_furl = 1 if ce_furl == 1 
replace cf_furl = 0 if cf_hrs_increase == 1 & cf_furl ==  1


recode cg_newfurlough_miss 2 = 0, gen (cg_furl) 
recode ch_newfurlough_miss 2 = 0, gen (ch_furl) 


** Now creating a new cx_series
* Denominator will be those employed cx_sempderiv minus those who have chosen not to respon to the furlough question 
* PROBLEM Note for CA there are some people who state they are employed in ca_sempderived, but inapplicable for furlough. I am 
* assuming that they are a valid part of the population. 

* Ca - Cf 
* Will use denominator population those with valid empoyment or both data data, and not  missing, refusal, or don't know for furlough. 
* Note self-empoyed can't be furloughed. 

foreach wave in a b c d  {
gen c`wave'_furloughx = 0 if c`wave'_sempderived == 1 | c`wave'_sempderived == 3 
recode c`wave'_furloughx 0 = 1 if c`wave'_furl == 1
replace  c`wave'_furloughx =. if c`wave'_furlough < 0 &  c`wave'_furlough  != -8 
}

foreach wave in e f  {
gen c`wave'_furloughx = 0 if c`wave'_sempderived == 1 | c`wave'_sempderived == 3 
recode c`wave'_furloughx 0 = 1 if c`wave'_furl == 1
}

foreach wave in g h {
gen c`wave'_furloughx  = 0 if c`wave'_sempderived == 1 | c`wave'_sempderived == 3 
recode c`wave'_furloughx 0 = 1 if c`wave'_newfurlough == 1 
replace c`wave'_furloughx = . if  c`wave'_newfurlough < 0
}


foreach wave in a b c d e f g h {
label values c`wave'_furloughx furlough 
}


*** Employment 
label define employed 1 "Employed" 2 "Unemployed" 3 "Not Reported" 
foreach wave in a b c d e f g h {
recode c`wave'_sempderived  -9/-1 = 3 1/3 = 1 4 = 2 , gen(c`wave'_employment) 
label values c`wave'_employment employed 
}


*** employment_status 

label define employment_status 0 "Full time employed / self-employed" 1 "Part-time employed/self-employed <30 h per week)" 2 "Unemployed" 3 "Furloughed or in paid / unpaid leave in materinity leave, etc"
* PROBLEM There are lots of potential problems with this e.g. some furloughed people are working very long hours. 
* I am ignoring the furlough variable and just classifying the employed on the basis of the sempderived variable and the hours variable. 
* People with then be classifed into the other groups based on the hours variable. DK for the hours will be coded as missing. 

bysort ca_sempderived: tab ca_hours 

foreach wave in a b c d e f g h  {
gen c`wave'_employment_status = . 
recode c`wave'_employment_status . = 0 if c`wave'_sempderived >=1 &  c`wave'_sempderived <=3 & c`wave'_hours >= 30 & c`wave'_hours <= 168
recode c`wave'_employment_status . = 1 if c`wave'_sempderived >=1 &  c`wave'_sempderived <=3 & c`wave'_hours > 0 & c`wave'_hours < 30
recode c`wave'_employment_status . = 2 if c`wave'_sempderived == 4 
recode c`wave'_employment_status . = 3 if c`wave'_sempderived >=1 &  c`wave'_sempderived <=3 & c`wave'_hours ==0 
label values c`wave'_employment_status employment_status
}





*** home_work
*PROBLEM not compatable with the CLS cohorts will need ot confirm how this is done in analyses. 
label define home_working 1 "fully" 2 "partial" 3 "none" 

foreach wave in a b c d e f g h {
recode c`wave'_wah (-9/-1 = .) (1 = 1) (2 3 = 2) (4 = 3), gen(c`wave'_home_working) 
lab values c`wave'_home_working home_working
}

label define homework_binary 1 "Always or partial" 2 "Never" 

foreach wave in a b c d e f g h {
recode c`wave'_wah (-9/-1 = .) (1 2 3 = 1) (4 = 2) , gen(c`wave'_home_work_binary) 
lab values c`wave'_home_work_binary homework_binary
}










*** SOC - pre-pandemic
*NB not sure this is necessarily the most efficient, and have corrected some of Mikes code. 
*Namely d2 needs both `y' and `z' and d3 needs both `y' `z' `k' 
*Can probably just divide the three digit version by ten for the 2 digit version then 

*SOC codes
foreach job in soc00 soc10 {
gen lob_`job'_d3=.
}

*-h g
foreach x in j i  {
	foreach job in jbsoc00 jlsoc00 jbsoc10 jlsoc10{
	recode `x'_`job'_cc (-9/-1=.), gen(`x'_`job')
	}
	foreach code in soc00 soc10{
	replace lob_`code'_d3=`x'_jb`code' if lob_`code'==.
	replace lob_`code'_d3=`x'_jl`code' if lob_`code'==.
	}
}
gen lob_soc00_d2 = floor(lob_soc00_d3/10) 
gen lob_soc00_d1 = floor(lob_soc00_d2/10) 


gen lob_soc10_d2 = floor(lob_soc10/10) 
gen lob_soc10_d1 = floor(lob_soc10_d2/10) 

*** soc_designation
label define soc_designation 0 "SOC2000" 1 "SOC2010" 2 "Missing" 

gen soc_designation = 1 if lob_soc10_d1 ! =. 
recode soc_designation . = 0 if lob_soc00_d1  !=. 
recode soc_designation . = 2 
label values soc_designation soc_designation


*** soc_1d 
gen soc_1d = lob_soc10_d1
replace soc_1d = lob_soc00_d1 if soc_1d == . 


*** soc_2d
gen soc_2d = lob_soc10_d2
replace soc_2d = lob_soc00_d2 if soc_2d == .


*** soc_3d
gen soc_3d = lob_soc10_d3
replace soc_3d = lob_soc00_d3 if soc_3d == .









*** SIC - Prepandemic 
label define sic2007_sec ///
1 "A AGRICULTURE, FORESTRY AND FISHING 1-3" /// 
2 "B MINING AND QUARRYING 5-9" /// 
3 "C MANUFACTURING 10 - 33" ///
4 "D ELECTRICITY, GAS, STEAM AND AIR CONDITIONING SUPPLY 35" /// 35
5 "E WATER SUPPLY; SEWERAGE, WASTE MANAGEMENT AND REMEDIATION ACTIVITIES 36 - 39" ///
6 "F CONSTRUCTION 41 - 43" ///
7 "G WHOLESALE AND RETAIL TRADE; REPAIR OF MOTOR VEHICLES AND MOTORCYCLES 45 - 47" ///
8 "H TRANSPORTATION AND STORAGE 49 - 53" ///
9 "I ACCOMMODATION AND FOOD SERVICE ACTIVITIES 55 - 56" ///
10 "J INFORMATION AND COMMUNICATION 58 - 63" ///
11 "K FINANCIAL AND INSURANCE ACTIVITIES 64 - 66" ///
12 "L REAL ESTATE ACTIVITIES 68" ///
13 "M PROFESSIONAL, SCIENTIFIC AND TECHNICAL ACTIVITIES 69 - 75" ///
14 "N ADMINISTRATIVE AND SUPPORT SERVICE ACTIVITIES 77 - 82" ///
15 "O PUBLIC ADMINISTRATION AND DEFENCE; COMPULSORY SOCIAL SECURITY 84" ///
16 "P EDUCATION 85" ///
17 "Q HUMAN HEALTH AND SOCIAL WORK ACTIVITIES 86 - 88" ///
18 "R ARTS, ENTERTAINMENT AND RECREATION 90 - 93" ///
19 "S OTHER SERVICE ACTIVITIES 94 - 96" ///
20 "T ACTIVITIES OF HOUSEHOLDS AS EMPLOYERS; UNDIFFERENTIATED GOODS-AND SERVICES-PRODUCING ACTIVITIES OF HOUSEHOLDS FOR OWN USE 97 - 98" ///
21 "U ACTIVITIES OF EXTRATERRITORIAL ORGANISATIONS AND BODIES 99" ///
22 "Missing" 																

gen lob_sic07 = . 
*-h g
foreach wave in j i  {
replace lob_sic07 = `wave'_jbsic07_cc if lob_sic07 == . 
recode lob_sic07 -9/-1 = . 
replace lob_sic07 = `wave'_jlsic07_cc if lob_sic07 == . 
recode lob_sic07 -9/-1 = . 
}
label values lob_sic07 j_jbsic07_cc

recode lob_sic07 (1/3 = 1) (5/9 = 2) (10/33 = 3) (35 = 4) (36/39 = 5) (41/43 = 6) (45/47 = 7) (49/53 = 8) (55/56 = 9) (58/63 = 10) (64/66 = 11) ///
(68 = 12) (69/75 = 13) (77/82 = 14) (84 = 15) (85 = 16) (86/88 = 17) (90/93 = 18) (94/96 = 19) (97/98 = 20) (99 = 21) (. = 22) , gen(lob_sic07_sec)
label values lob_sic07_sec sic2007_sec


rename lob_sic07 sic_2d
rename lob_sic07_sec sic_1d
tab sic_1d



*** occupation 
*Note this the pattern for which this is asked for everybody is a bit strange. 
* The first month is missing then it is inconistent so the main is a single measure. 
* Soc might be more useful. 
 label define occupation  1 "Health and social care" 2 "Education and childcare"  3 "Key public services" 4 "Local and national government"  5 "Food and other necessary goods"    6 "Public safety and national security"  7 "Transport"   8 "Utilities, communications and financial services"   9 "No, I am not working as a key worker"
 
foreach wave in b c d e  g h {
recode c`wave'_keyworksector (-9/-1 = . ) , gen(c`wave'_worktemp)
}

gen occupation = cb_worktemp
foreach wave in c d e  g h {
replace occupation = c`wave'_worktemp if occupation == . 
}

label values occupation occupation 





*** occupation_red
*Full occupation measure needs confirming first. 


*** Note initial code from ARQ1 Paper 5


*****Coding Covid Variables 

***Coding symptoms in each wave
label define No_Yes 0 "No"  1 "Yes" 
foreach wave in a b c d e f g h {
recode c`wave'_hadsymp -9/-1 = . 1 = 1 2 = 0 , gen(c`wave'_wave_symp)
label variable c`wave'_wave_symp "c`wave' symptoms in wave" 
label values c`wave'_wave_symp No_Yes
}


***Coding  ever symptoms until wave particpation
*NOT THE CUMULATIVE MEASURE TO BE USED FOR ARQ1 PAPER 5, but an intermediate variable to create it. 

gen  ca_ever_symp = ca_wave_symp 
label variable  ca_ever_symp "Symptoms in anywave ca" 
label value ca_ever_symp No_Yes

gen cb_ever_symp = ca_ever_symp
recode cb_ever_symp . = 0 if cb_wave_symp == 0
replace cb_ever_symp  = 1 if cb_wave_symp == 1
label variable  cb_ever_symp "Symptoms in anywave cb" 
label value cb_ever_symp No_Yes

gen cc_ever_symp = cb_ever_symp
recode cc_ever_symp . = 0 if cc_wave_symp == 0
replace cc_ever_symp  = 1 if cc_wave_symp == 1
label variable  cc_ever_symp "Symptoms in anywave cc" 
label value cc_ever_symp No_Yes

gen cd_ever_symp = cc_ever_symp
recode cd_ever_symp . = 0 if cd_wave_symp == 0
replace cd_ever_symp  = 1 if cd_wave_symp == 1
label variable  cd_ever_symp "Symptoms in anywave cd" 
label value cd_ever_symp No_Yes

gen ce_ever_symp = cd_ever_symp
recode ce_ever_symp . = 0 if ce_wave_symp == 0
replace ce_ever_symp  = 1 if ce_wave_symp == 1
label variable  ce_ever_symp "Symptoms in anywave ce" 
label value ce_ever_symp No_Yes

gen cf_ever_symp = ce_ever_symp
recode cf_ever_symp . = 0 if cf_wave_symp == 0
replace cf_ever_symp  = 1 if cf_wave_symp == 1
label variable  cf_ever_symp "Symptoms in anywave cf" 
label value cf_ever_symp No_Yes

gen cg_ever_symp = cf_ever_symp
recode cg_ever_symp . = 0 if cg_wave_symp == 0
replace cg_ever_symp  = 1 if cg_wave_symp == 1
label variable  cg_ever_symp "Symptoms in anywave cg" 
label value cg_ever_symp No_Yes

gen ch_ever_symp = cg_ever_symp
recode ch_ever_symp . = 0 if ch_wave_symp == 0
replace ch_ever_symp  = 1 if ch_wave_symp == 1
label variable  ch_ever_symp "Symptoms in anywave ch" 
label value ch_ever_symp No_Yes



***Cumulative Covid measures. 
*Logic 
*1. I aim to recode only those people who particpate in a wave. 
*2. I am only going to recode those with valid responses to had_symp for each wave, as otherwise carrying forward would be related to covid status. 
*3. Note this is not entirely consistent with the duration below. For this measure I have ignored don't knows etc. The duration measure I exclude them. 

gen ca_cuml_symp = ca_wave_symp
label variable ca_cuml_symp "Ever Covid Symtomps inc ca" 
label values ca_cuml_symp  No_Yes

foreach wave in b c d e f g h {
gen  c`wave'_cuml_symp  =  c`wave'_wave_symp
recode  c`wave'_cuml_symp 0 = 1 if c`wave'_ever_symp == 1
label variable c`wave'_cuml_symp "Ever Covid Symtomps inc `wave'" 
label values c`wave'_cuml_symp No_Yes
}


*Order of priority 
*Note tests may be done for reasons where there is low reason to suspect positve status eg travel 
*Test postive - confirmed
*Test negative  - No  
*Ignore inclusive waiting for test results 
*Ignore tested variable 
*Had symptoms Yes  - suspected 
*Had symptoms No - NO 
label define c19_confirmed 0 "No" 1 "Suspected" 2 "Confirmed" 


foreach wave in a b c d e f {
gen c`wave'_c19_confirmed = . 
recode c`wave'_c19_confirmed . = 2 if c`wave'_testresult == 1
recode c`wave'_c19_confirmed . = 0 if c`wave'_testresult == 2
recode c`wave'_c19_confirmed . = 1 if c`wave'_hadsymp == 1
recode c`wave'_c19_confirmed . = 0 if c`wave'_hadsymp == 2
label variable c`wave'_c19_confirmed "c`wave' C19 SR confirmed" 
label values c`wave'_c19_confirmed c19_confirmed
}
*Order of priority in January 2021
*Test postive any of the three tests confirmed 
*Test negative any of theree tests (and not positive) - No 

gen cg_c19_confirmed = . 
recode cg_c19_confirmed . = 2 if cg_testresult_test1 == 1 | cg_testresult_test2 == 1 | cg_testresult_test2 == 1 
recode cg_c19_confirmed . = 0 if  cg_testresult_test1 == 2 | cg_testresult_test2 == 2 | cg_testresult_test2 == 2
recode cg_c19_confirmed . = 1 if cg_hadsymp == 1
recode cg_c19_confirmed . = 0 if cg_hadsymp == 2
label variable cg_c19_confirmed "cg C19 SR confirmed" 
label values cg_c19_confirmed c19_confirmed


*Now coding March 2021
*Any positive tests  - confirmed
*Asserts that did not test positive  - No 
*Does not know test results - is not being accounted for as none of the people who did not know their test results had Covid19 symptoms.  
*Had symptoms - suspected 
*Did not have sympotms - no 

gen ch_c19_confirmed = . 
recode ch_c19_confirmed . = 2 if ch_testpos == 1 
recode ch_c19_confirmed . = 0 if ch_testpos == 2
recode ch_c19_confirmed . = 1 if ch_hadsymp == 1
recode ch_c19_confirmed . = 0 if ch_hadsymp == 2
label variable ch_c19_confirmed "ch C19 SR confirmed" 
label values ch_c19_confirmed c19_confirmed





*** c19infection_selfreported	& c19postest_selfreported
label define c19infection_selfreported 0 "None" 1 "Yes" 
label define c19postest_selfreported 0 "No"  1 "Positive" 

foreach wave in a b c d e f g h {
recode c`wave'_c19_confirmed (0 = 0) ( 1 2 = 1) , gen(c`wave'_c19infection_selfreported)
label values c`wave'_c19infection_selfreported c19infection_selfreported
recode c`wave'_c19_confirmed (0 1 = 0) ( 2 = 1) , gen(c`wave'_c19postest_selfreported)
label values c`wave'_c19postest_selfreported c19postest_selfreported
}

*** Country

*****Control Variables 
*** UK Country of residence 
gen pan_region = ca_gor_dv 
recode pan_region -9 = .
foreach wave in  b c d e f g h {
replace pan_region = c`wave'_gor_dv if pan_region == . 
recode pan_region -9 = .
}
recode pan_region  1/9 = 0  10 = 2  11 = 3 12 = 4 , gen(pan_country)
label define pan_country 0 "England" 2 "Wales" 3 "Scotland" 4 "Northern Ireland" 
label values pan_country pan_country 





keep llc_0007_stud_id cohort_id  /* id variable - to be determined looking at lllc study_id: study_id study_wave study_wave_date pandemic_timetranche
weight variables */ /*  these are weight variables cacluated for previous studies but not necessariliy used in this one j_psu j_strata j_indinui_xw  j_iwgt_xw   *_addwgt1 cb_addwgt1
Demographic measures  */  age_entry sex ethnicity ethnicity_red   /* 
Misc SEP measures  */ household_size hm_location *housing_composition *housing_tenure  education /*
misc  */ pan_country *public_transport *vaccination_status /*
employment  */ *key_worker  *furloughx  *employment  *employment_status  *home_working   /*
occupation */ soc* sic* occupation /*
covid measures */ *c19infection_selfreported *c19postest_selfreported


rename *_furloughx *_furlough


*Below is likely to vary depending on time varying or constant measuers. 

rename ca_*  *1 
rename cb_*  *2 
rename cc_*  *3 
rename cd_*  *4 
rename ce_*  *5 
rename cf_*  *6 
rename cg_*  *7 
rename ch_*  *8 

rename housing_composition housing_composition_b
rename housing_tenure housingtenure_b
rename key_worker key_worker_b 

**save long version of final UKHLS file
save "UKHLS edited\UKHLS edited wide version.dta", replace

reshape long /* id variable - to be determined looking at lllc study_id: study_id study_wave study_wave_date pandemic_timetranche
weight variables */ /*  these are weight variables cacluated for previous studies but not necessariliy used in this one j_psu j_strata j_indinui_xw  j_iwgt_xw   *_addwgt1 cb_addwgt1
Misc SEP measures  */  housing_composition   housing_tenure/*
misc  */ public_transport vaccination_status contacts_outside_work/*
employment  */ key_worker  furlough  employment  employment_status  home_working   /*
covid measures */ c19infection_selfreported c19postest_selfreported ,  i(llc_0007_stud_id) j(study_wave)


recode study_wave	(1 2 3 = 1) (4 5 = 2) (6 7 8 = 3) , gen(pandemic_timetranche)
label values pandemic_timetranche pandemic_timetranche 

**define and label study_wave
label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
label values study_wave study_wave

**tidying up employment variables 
tab  employment employment_status, missing nol

*replace employment_status=2 if employment==2
*replace employment=2 if employment_status==2


*gen occupation vars (defined in protocol)
recode soc_3d (110=9) (111=9) (112=11)	(113=9)	(114=12) (115=9)	(116=8)	(117=6)	(118=1)	(119=12)	(121=13)	(122=1) (123=9)	(124=12)	(125=9)	(211=9)	(212=9)	(213=9)	(214=9)	(215=9)	(221=1)	(222=1)	(223=1)	(231=5) (232=9)	(241=9)	(242=9)	(243=9)	(244=9)	(245=9)	(246=9)	(247=9)	(311=9)	(312=9)	(313=9)	(321=1) (322=1)	(323=4)	(331=6)	(341=9)	(342=9) (343=9)	(344=9)	(350=8)	(351=8)	(352=9)	(353=9)	(354=9)	(355=9)	(356=9)	(411=9)	(412=9)	(413=9) (414=9)	(415=12)	(416=9)	(421=9)	(511=7)	(521=9)	(522=11)	(523=9)	(524=9)	(525=11) (531=9)	(532=9)	(533=9)	(540=9) (541=9)	(542=9)	(543=7)	(544=9) (549=9) (611=1)	(612=4)	(613=9)	(614=1)	(621=8)	(622=9)	(623=13)	(624=13) (629=9)	(711=12)	(712=9)	(713=12) (721=12)	(722=12)	(811=11)	(812=11)	(813=11)	(814=9)	(821=8)	(822=9)	(823=8)	(911=9)	(912=9)	(913=11) (914=11) (921=8) (922=9)	(923=9)	(924=9)	(925=12)	(926=11)	(927=13) if soc_designation==0, gen(occ_full)


recode soc_3d (110=9) (111=9) (112=11)	(113=9)	(115=9)	(116=8)	(117=6)	(118=1)	(119=12)	(121=13)	(122=1)	(124=12)	(125=9)	(211=9)	(212=9)	(213=9)	(214=9)	(215=9)	(221=1)	(222=1)	(223=1)	(231=5)	(241=9)	(242=9)	(243=9)	(244=9)	(245=9)	(246=9)	(247=9)	(311=9)	(312=9)	(313=9)	(321=1)	(323=4)	(331=6)	(341=9)	(342=9)	(344=9)	(350=8)	(351=8)	(352=9)	(353=9)	(354=9)	(355=9)	(356=9)	(411=9)	(412=9)	(413=9)	(415=12)	(416=9)	(421=9)	(511=7)	(521=9)	(522=11)	(523=9)	(524=9)	(525=11) (531=9)	(532=9)	(533=9)	(540=9) (541=9)	(542=9)	(543=7)	(544=9)	(612=4)	(613=9)	(614=1)	(621=8)	(622=9)	(623=13)	(624=13)	(711=12)	(712=9)	(713=12) (721=12)	(722=12)	(811=11)	(812=11)	(813=11)	(814=9)	(821=8)	(822=9)	(823=8)	(911=9)	(912=9)	(913=11)	(921=8)	(923=9)	(924=9)	(925=12)	(926=11)	(927=13) if soc_designation==1, gen(occ_full2)

replace occ_full=occ_full2 if soc_designation==1

label var occ_full "occupation full"
label define occ_full 1 "Health Care Prof" 2 "Other Health care prof" 3 "Medical Support" 4 "Social Care" 5 "Education" 6 "Police & Protection serv" 7 "Food Workers" 8 "Transport workers" 9 "Other workers" 11 "Factory" 12 "Customer serv" 13 "Hospitality" 20 "Missing/Not in work"
label values occ_full occ_full
tab occ_full



bysort llc_0007_stud_id (occ_full): replace occ_full=occ_full[_n-1] if _n>1 & occ_full==.
sort llc_0007_stud_id study_wave
replace occ_full=20 if occ_full==.
tab occ_full


**gen occupation vars (defined in protocol - reduced)
recode occ_full (1=2) (2=2) (3=2) (4=3) (5=3) (6=4) (7=5) (8=5) (9=1) (11=5) (12=5) (13=5) (20=6), gen(occ_red)
label var occ_red "occupation reduced"
label define occ_red 1 "Non-essential workers" 2 "Health Care workers" 3 "Social and Education" 4 "Police and Protective" 5 "Other essential workers" 6 "Missing/not in wrk"
label values occ_red occ_red
tab occ_red









**save long version of final UKHLS file
save "UKHLS edited\UKHLS edited long version.dta", replace


preserve
drop if age_entry>5
tab employment
tab employment_status
tab employment employment_status, missing
restore




tab study_wave c19infection_selfreported , row

tab pandemic_timetranche c19infection_selfreported 
tab pandemic_timetranche c19postest_selfreported



***********PREPARE/FORMAT and MERGE NHS TESTING DATA*********************

***************************************	
****MERGING WITH THE NHS TESTING DATA
use "NHS edited\protect_nhs_c19posinfect_temp", clear
count

**drop if within 2 weeks - drops 14,309, leaves 25,125 positive tests
drop if time_sinceprevpos<14 & time_sinceprevpos!=0


***create identification of (UKHLS) wave in nhs infection data
**Eight waves April, May, June, July, Sep, Nov, 2020 Jan Mar and Sept 2021
gen study_wave=1 if testdate<=date("30/04/2020", "DMY")
replace study_wave=2 if testdate>date("30/04/2020", "DMY") & testdate<=date("30/05/2020", "DMY")
replace study_wave=3 if testdate>date("30/05/2020", "DMY") & testdate<=date("30/06/2020", "DMY")
replace study_wave=4 if testdate>date("30/06/2020", "DMY") & testdate<=date("31/07/2020", "DMY")
replace study_wave=5 if testdate>date("31/07/2020", "DMY") & testdate<=date("30/09/2020", "DMY")
replace study_wave=6 if testdate>date("30/09/2020", "DMY") & testdate<=date("30/11/2020", "DMY")
replace study_wave=7 if testdate>date("30/11/2020", "DMY") & testdate<=date("30/01/2021", "DMY")
replace study_wave=8 if study_wave==. & testdate>date("30/01/2021", "DMY") & testdate<=date("30/03/2021", "DMY")
replace study_wave=. if testdate>date("30/03/2021", "DMY")

label define study_wave 1 "April 2020" 2 "May 2020" 3 "June 2020" 4 "July 2020" 5 "Sept 2020" 6 "Nov 2020" 7 "Jan 2021" 8 "Mar 2021", replace
label values study_wave study_wave
tab study_wave
bysort study_wave: datesum testdate


drop if study_wave==.
tab source
sort llc_0007_stud_id study_wave

**Look for within wave repeats
bysort llc_0007_stud_id study_wave: egen seq=seq()
tab seq
gen rep_n=seq
gsort llc_0007_stud_id study_wave -seq
by llc_0007_stud_id study_wave: replace rep_n=rep_n[_n-1] if _n>1
tab rep_n
sort llc_0007_stud_id study_wave seq
list llc_0007_stud_id study_wave testdate seq rep_n if rep_n!=1, sepby(llc_0007_stud_id)
*take first pos test
keep if seq==1
drop seq rep_n

**rename occupation var
rename occupation occupation_nhs

**save temporay elsa version of nhs infection data
save "UKHLS edited\protect_nhs_c19posinfect_temp_ukhlsver", replace






********************************************************************************
***British cohort study 1970
**study_id==3
********************************************************************************

**Set up - modified from CLS provided codebook
cd "S:\LLC_0007\data\"

use "stata_w_labs\BCS70_basic_demographic_v0001_20211101", clear
count 
codebook, compact

use "stata_w_labs\BCS70_bcs10_employment_v0001_20211101", clear
count 
codebook, compact

**housing data here appears to be related to moving house pre pandemic - not useful
use "stata_w_labs\BCS70_bcs10_housing_v0001_20211101", clear
count 
codebook, compact

use "stata_w_labs\BCS70_bcs10_qualifications_v0001_20211101", clear
count 
codebook, compact

use "stata_w_labs\BCS70_COVID_w1_v0001_20211101", clear
count 
codebook, compact

use "stata_w_labs\BCS70_COVID_w2_v0001_20211101", clear
count 
codebook, compact

use "stata_w_labs\BCS70_COVID_w3_v0001_20211101", clear
count 
codebook, compact

* Set up Merge files together

*********************************************
***setting up qualifications bc10 data

use "stata_w_labs\BCS70_bcs10_qualifications_v0001_20211101", clear


**drop non-reported qualification & repeated qualifications
drop if b10qualtp==32
bysort llc_0007_stud_id b10ewhen b10qualtp: egen seq=seq()
tab seq
drop if seq>1 & seq!=.
drop seq

**identify repeates 
bysort llc_0007_stud_id: egen seq=seq()
gsort llc_0007_stud_id -seq
by llc_0007_stud_id: gen count=seq if _n==1
by llc_0007_stud_id: replace count=count[_n-1] if _n>1
tab seq

sort llc_0007_stud_id seq
list llc_0007_stud_id  b10ewhen b10qualtp seq if count>4, sepby(llc_0007_stud_id)

**recode multiple qualifications into highest qualification 
numlabel, add
tab b10qualtp
recode b10qualtp (1=1) (2=1) (3=2) (4=2) (5=2) (6=2) (11=2) (13=2) (15=4) (16=4) (17=5) (18=5) (20=3) (21=3) (22=3) (23=3) (24=3)  (25=3) (26=3) (27=3) (28=3) (29=3), gen(highqual)
label define highqual 1 "GCSE" 2 "Alevel eq" 3 "BTEC/HND/GNVQ eq" 4 "Degree eq" 5 "Higher Degree" 
label values highqual highqual
label var highqual "Highest Qualification in BCS70 BC10"
tab highqual 

gsort llc_0007_stud_id -highqual
by llc_0007_stud_id: egen qualseq=seq()
tab qualseq 

list llc_0007_stud_id highqual qualseq if count>4 , sepby(llc_0007_stud_id)

**keep highest qualifications
keep if qualseq==1

**check no repeates
drop seq
bysort llc_0007_stud_id: egen seq=seq()
tab seq

**keep var indicating highest qualification
keep llc_0007_stud_id highqual

save "BCS70 edited\BCS70_bcs10_qualifications temp", replace


*********************************************************
***setting up employment bc10 data
use "stata_w_labs\BCS70_bcs10_employment_v0001_20211101", clear
count 
codebook, compact

**drop if not currently active job role
keep if b10acurac==1

**identify repeates 
bysort llc_0007_stud_id ( b10aendy b10aendm): egen seq=seq()
gsort llc_0007_stud_id -seq
by llc_0007_stud_id: gen count=seq if _n==1
by llc_0007_stud_id: replace count=count[_n-1] if _n>1
tab seq

**keep final currentl active job 
keep if seq==count
drop seq count

**keep useful variables
drop avail_from_dt econo

count

save "BCS70 edited\BCS70_bcs10_employ temp", replace



***************************************************************************
***START BY APPENDING/MERGING THE COVID WAVES
**covid waves

**Wave 1
use "stata_w_labs\BCS70_COVID_w1_v0001_20211101", clear
rename cw1_* *
gen wave=1
save "BCS70 edited\BCS70_COVID_w1_v0001_20211101 temp", replace
**Wave 2
use "stata_w_labs\BCS70_COVID_w2_v0001_20211101", clear
rename cw2_* *
gen wave=2
save "BCS70 edited\BCS70_COVID_w2_v0001_20211101 temp", replace
**Wave 3
use "stata_w_labs\BCS70_COVID_w3_v0001_20211101", clear
rename cw3_* *
gen wave=3
save "BCS70 edited\BCS70_COVID_w3_v0001_20211101 temp", replace

**APPEND WAVE FILES INTO ONE LONG FILE
use "BCS70 edited\BCS70_COVID_w1_v0001_20211101 temp", clear
append using "BCS70 edited\BCS70_COVID_w2_v0001_20211101 temp"
append using "BCS70 edited\BCS70_COVID_w3_v0001_20211101 temp"


***ADD IN THE ADDITIONAL BCS10 DATA
**Add in demographics
merge m:1 llc_0007_stud_id using "stata_w_labs\BCS70_basic_demographic_v0001_20211101"
tab _merge
drop if _merge==2
drop _merge
**Add in qualifications higest 
merge m:1 llc_0007_stud_id using "BCS70 edited\BCS70_bcs10_qualifications temp"
tab _merge
drop if _merge==2
drop _merge
**Add in qualifications higest 
merge m:1 llc_0007_stud_id using "BCS70 edited\BCS70_bcs10_employ temp"
tab _merge
drop if _merge==2
drop _merge


*****FORMATTING VARIABLES******
***i.sex i.ethnicity_red  i.hm_location i.housing_composition  i.pandemic_timetranche i.deprivation

numlabel, add

***SEX
rename psex sex
tab sex

***ETHNICITY
**single var = ethnic
tab ethnic
recode ethnic (1=1) (2=1) (3=1) (4=2) (5=2) (6=2) (7=2) (8=2) (9=2) (10=2) (11=2) (12=2) (13=2) (14=2) (15=2) (16=2) (99=9) (.=9), generate(ethnicity_red)
label define ethnicity_red 1 "White/British" 2 "Other" 9 "Missing", replace
label values ethnicity_red ethnicity_red
tab ethnicity_red, missing

**Age at entry 
**all participants born in a single week during 1970 so all are aged 52

***HOUSEHOLD NUMBERS/COMPOSITION
**hhnum_cw1 hhnum_cw2 hhnum_cw3
**should generate a single var when reshaped
**1"partner+kids" 2"only partner" 3"single parent" 4"other" 5"alone"

label define housing_composition 1 "partner and children" 2 "partner no children" 3 "lone parents" 4 "no partner no children" 5 "alone" 9 "missing", replace

***Generate housing_composition
**partner
tab hhnumwh_1 
tab hhnumwh_2 
tab hhnumwh_3 
tab hhnumwh_4 
tab hhnumwh_5 
tab hhnumwh_6 
tab hhnumwh_7 
tab hhnumwh_8 
tab hhnumwh_9
tab hhnum


gen housing_composition=.
**partner and children
replace housing_composition=1 if hhnumwh_1==1 & hhnumwh_2==2
**partner no children
replace housing_composition=2 if hhnumwh_1==1 & hhnumwh_2==1
**lone parents
replace housing_composition=3 if hhnumwh_1==2 & hhnumwh_2==1
**no partner no children/other 
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_3==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_4==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_5==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_6==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_7==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_8==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_9==1
**Alone
replace housing_composition=5 if hhnum==0
bysort llc_0007_stud_id (wave): replace housing_composition=housing_composition[_n-1] if wave==2 & housing_composition==. & housing_composition[_n-1]!=.
bysort llc_0007_stud_id (wave): replace housing_composition=housing_composition[_n-1] if wave==3 & housing_composition==. & housing_composition[_n-1]!=.

bysort llc_0007_stud_id (wave): replace housing_composition=housing_composition[_n+1] if wave==2 & housing_composition==. & housing_composition[_n+1]!=.
bysort llc_0007_stud_id (wave): replace housing_composition=housing_composition[_n+1] if wave==1 & housing_composition==. & housing_composition[_n+1]!=.
replace housing_composition=9 if housing_composition==.

label values housing_composition housing_composition
tab housing_composition, missing



**REGION
**No indicator of living in urban or rural area


***WAVE DATES
label define wave 1 "May 2020" 2 "Sep/Oct 2020" 3 "Feb/Mar 2021", replace
label values wave wave
rename wave study_wave
tab study_wave


***TRANCHE
gen pandemic_timetranche=study_wave
label var pandemic_timetranche "Time-Tranche H&W version"
label define pandemic_timetranche 1 "Apr20-Jun20" 2 "Jul20-Oct20" 3 "Nov20-Mar21", replace
label values pandemic_timetranche pandemic_timetranche
tab pandemic_timetranche



codebook covid_hospad covid19 covidresult covidtest covid19pos covidincresult covidincwhen covidcurresult covidcurwhen covidpasresult covidpaswhen covidtest_1 covidtest_2 covidtest_3 covidtest_4 outcome, compact

foreach var of varlist covid19 covidresult covidtest covid19pos covidincresult covidincwhen covidcurresult covidcurwhen covidpasresult covidpaswhen covidtest_1 covidtest_2 covidtest_3 covidtest_4 {
	tab `var'
}

***SELF-REPORTED INFECTION 
tab covid19 , missing
recode covid19 (1=1) (2=1) (3=0) (4=0), gen(c19infection_selfreported)
label define c19infection_selfreported 0 "No" 1 "Yes", replace
label values c19infection_selfreported c19infection_selfreported
tab c19infection_selfreported

***SELF-REPORTED POSITIVE TEST 
recode covid19 (1=1) (2=0) (3=0) (4=0), gen(c19postest_selfreported)
label define c19postest_selfreported 0 "No" 1 "Yes", replace
label values c19postest_selfreported c19postest_selfreported
tab c19postest_selfreported


***ADD IN OCCUPATIONAL VARS

**SOC 1dig
tab soc2010, nol
gen soc2010_1d=floor(soc2010/100)
label define soc2010_1d 1 "Managers, Directors, & Senior Off" 2 "Prof Occupations" 3 "Associate Prof & Technical Occup" 4 "Administrative and Secretarial" 5 "Skilled Trades" 6 "Caring, Leisure, and Other Service" 7 "Sales and Customer Serv" 8 "Process, Plant, and Machine Operatives" 9 "Elementary Occupations", replace
label values soc2010_1d soc2010_1d
tab soc2010_1d
bysort llc_0007_stud_id (study_wave): egen seq=seq()
bysort llc_0007_stud_id (study_wave): replace soc2010_1d=soc2010_1d[_n-1] if soc2010_1d==. & seq>1



**SOC 2dig
tab soc2010, nol
gen soc2010_2d=floor(soc2010/10)
tab soc2010_2d
label define soc2010_2d 11 "Corporate Managers" 12 "Other Managers and Proprietors in Agriculture and Services" 21 "Science, res, and Tech Prof" 22 "Health Prof" 23 "Teaching and Educa Prof" 24 "Buisness and Public Services Prof" 31 "Science and Tech A-Prof" 32 "Health and Social Welfare A-Prof" 33 "Protective Services" 34 "Culture, Media, Sports Occ" 35 "Buisness and Public Serivces A-Prof" 41 "Administrative Occ" 42 "Secretarial and Related" 51 "Skilled Agricultural Trades" 52 "Skilled Metal and Electrical Trades" 53 "Skilled Construction and Building Trades" 54 "Textiles, Printing, Other skilled Trades" 61 "Caring Personal Services" 62 "Leisure & Other Personal Service Occ" 71 "Sales Occ" 72 "Customer Service" 81  "Process, Plant, and Machine Operative" 82 "Transport, Mobile Macnine Drivers and Operatives" 91 "Elementary Trades, Plant and Storage related Occ" 92 "Elementary Admin and Service Occ", replace 
label values soc2010_2d soc2010_2d
bysort llc_0007_stud_id (study_wave): replace soc2010_2d=soc2010_2d[_n-1] if soc2010_2d==. & seq>1
tab soc2010_2d, missing
drop seq

**SIC??
tab sic3 

tab soc2010

*gen occupation vars (defined in protocol)
tab soc2010
recode soc2010 (110=9) (111=9) (112=11)	(113=9)	(115=9)	(116=8)	(117=6)	(118=1)	(119=12)	(121=13)	(122=1)	(124=12)	(125=9)	(211=9)	(212=9)	(213=9)	(214=9)	(215=9)	(221=1)	(222=1)	(223=1)	(231=5)	(241=9)	(242=9)	(243=9)	(244=9)	(245=9)	(246=9)	(247=9)	(311=9)	(312=9)	(313=9)	(321=1)	(323=4)	(331=6)	(341=9)	(342=9)	(344=9)	(350=8)	(351=8)	(352=9)	(353=9)	(354=9)	(355=9)	(356=9)	(411=9)	(412=9)	(413=9)	(415=12)	(416=9)	(421=9)	(511=7)	(521=9)	(522=11)	(523=9)	(524=9)	(525=11) (531=9)	(532=9)	(533=9)	(540=9)	(542=9)	(543=7)	(544=9)	(612=4)	(613=9)	(614=1)	(621=8)	(622=9)	(623=13)	(624=13)	(711=12)	(712=9)	(713=12) (721=12)	(722=12)	(811=11)	(812=11)	(813=11)	(814=9)	(821=8)	(822=9)	(823=8)	(911=9)	(912=9)	(913=11)	(921=8)	(923=9)	(924=9)	(925=12)	(926=11)	(927=13), gen(occ_full)
label var occ_full "occupation full"
label define occ_full 1 "Health Care Prof" 2 "Other Health care prof" 3 "Medical Support" 4 "Social Care" 5 "Education" 6 "Police & Protection serv" 7 "Food Workers" 8 "Transport workers" 9 "Other workers" 11 "Factory" 12 "Customer serv" 13 "Hospitality" 20 "Missing/Not in work"
label values occ_full occ_full
tab occ_full

bysort llc_0007_stud_id (occ_full): replace occ_full=occ_full[_n-1] if _n>1 & occ_full==.
sort llc_0007_stud_id study_wave
replace occ_full=20 if occ_full==.
tab occ_full


**gen occupation vars (defined in protocol - reduced)
recode occ_full (1=2) (2=2) (3=2) (4=3) (5=3) (6=4) (7=5) (8=5) (9=1) (11=5) (12=5) (13=5) (20=6), gen(occ_red)
label var occ_red "occupation reduced"
label define occ_red 1 "Non-essential workers" 2 "Health Care workers" 3 "Social and Education" 4 "Police and Protective" 5 "Other essential workers" 6 "Missing/not in wrk"
label values occ_red occ_red
tab occ_red




**generate weekly working hours
gen  wk_worhrs=wrkhoursd
replace wk_worhrs=timeuse1_1_1 if wk_worhrs==.
replace wk_worhrs=timeuse_1*5 if wk_worhrs==.
replace wk_worhrs=wrkhoursb if wk_worhrs==.

tab wk_worhrs study_wave


**employment
recode econactivityd (1=1) (2=1)  (3=1) (4=1) (5=1) (6=1) (7=0) (8=0) (9=0) (10=0) (11=0) (12=0) (13=0), gen(employed)
label var employed "Participant employed during COVID"
label define employed 0 "No" 1 "Yes", replace
label values employed employed
tab employed


**employment
tab wk_worhrs
tab econactivityd
tab wk_worhrs if econactivityd==.

recode econactivityd (1=1) (2=1)  (3=1) (4=1) (5=1) (6=1) (7=3) (8=3) (9=3) (10=3) (11=3) (12=2) (13=3), gen(employment) 
replace employment=3 if wk_worhrs<8 & employment==.
replace employment=1 if wk_worhrs>=8 & wk_worhrs!=. & employment==.

label var employment "Participant employment_status during COVID"
label define employment 1 "Employed/looking for work" 2 "Retired" 3 "Unemployed", replace
label values employment employment
tab employment

tab econactivityd employment, missing


**employment_status
tab wk_worhrs
tab econactivityd

recode econactivityd (1=1) (2=3)  (3=3) (5=3) (6=1) (7=3) (8=4) (9=4) (10=4) (11=4) (12=2) (13=4), gen(employment_status) 
replace employment_status=1 if wk_worhrs<8 & employment_status==.
replace employment_status=1 if wk_worhrs>=8 & wk_worhrs!=. & employment_status==.
replace employment_status=0 if wk_worhrs>=20 & wk_worhrs!=. & employment_status==1


label var employment_status "Participant employment_status during COVID"
label define employment_status 0 "Full-Time employment" 1 "Part-time employment" 2 "Retired" 3 "Employed but not working" 4 "Unemployed", replace
label values employment_status employment_status
tab econactivityd employment_status


**Key worker 
tab keyworkerd study_wave

recode keyworkerd (1=1) (2=0), gen(key_worker)
label define key_worker 0 "No" 1 "Yes"
label values key_worker key_worker
tab key_worker


**Home working	 
tab wrklocationd study_wave
gen home_working=wrklocationd
replace home_working=4 if study_wave==1 & wrklocationd==3
recode home_working (2=3) (3=2)
label define home_working 1 "Wrk from hm" 2 "Some" 3 "None" 4 "Other", replace
label values home_working home_working
tab home_working

**Furlough - 
tab econactivityd
gen furlough=1 if inlist(econactivityd, 2, 3)
replace furlough=0 if inlist(econactivityd, 1, 5, 6)
replace furlough=2 if furlough==. 
label define furlough 0 "In wrk" 1 "furlough" 2 "other", replace
label values furlough furlough
tab furlough


tab employment employment_status, missing

**Employed if stating in full time work
replace employment=1 if employment_status==0
**Unemployed if stated unemployed
replace employment=3 if employment_status==4 & employment==.
replace employment_status=4 if employment==3 & employment_status==.
**Retired if stated retired
replace employment_status=2 if employment==2 & employment_status==.
replace employment_status=2 if employment==2 & employment_status==4 
replace employment_status=2 if employment==2 & employment_status==3
replace employment=2 if employment_status==2 & employment==1
**economically active (employed in some form or looking for work) if stated so
replace employment=1 if employment_status==3 & employment==.
replace employment=1 if employment_status==3 & employment==3

**economically active if doing part-time/full time work 
replace employment=1 if employment_status==0 | employment_status==1 

tab employment employment_status, missing


**save long version of final BCS70 file
save "BCS70 edited\BCS70 edited long version.dta", replace


tab study_wave c19infection_selfreported , row

tab pandemic_timetranche c19infection_selfreported 
tab pandemic_timetranche c19postest_selfreported



***********PREPARE/FORMAT and MERGE NHS TESTING DATA*********************

***************************************	
****MERGING WITH THE NHS TESTING DATA
use "NHS edited\protect_nhs_c19posinfect_temp", clear
count


**drop if within 2 weeks - drops 14,309, leaves 25,125 positive tests
drop if time_sinceprevpos<14 & time_sinceprevpos!=0


***create identification of (BCS1970) wave in nhs infection data
**Three waves pre-"May 2020", May-"Sep/Oct 2020", Nov20-"Feb/Mar 2021"

gen study_wave=1 if testdate<=date("01/05/2020", "DMY")
replace study_wave=2 if testdate>date("01/05/2020", "DMY") & testdate<=date("31/10/2020", "DMY")
replace study_wave=3 if testdate>date("31/10/2020", "DMY") & testdate<=date("30/03/2021", "DMY")
replace study_wave=. if testdate>date("30/03/2021", "DMY")

label define study_wave 1 "pre-April 2020" 2 "May-Sep/Oct 2020" 3 "Nov20-Feb/Mar 2021", replace
label values study_wave study_wave
tab study_wave
bysort study_wave: datesum testdate


drop if study_wave==.
tab source
sort llc_0007_stud_id study_wave

**Look for within wave repeats
bysort llc_0007_stud_id study_wave: egen seq=seq()
tab seq
gen rep_n=seq
gsort llc_0007_stud_id study_wave -seq
by llc_0007_stud_id study_wave: replace rep_n=rep_n[_n-1] if _n>1
tab rep_n
sort llc_0007_stud_id study_wave seq
list llc_0007_stud_id study_wave testdate seq rep_n if rep_n!=1, sepby(llc_0007_stud_id)
*take first pos test
keep if seq==1
drop seq rep_n

**rename occupation var
rename occupation occupation_nhs

tostring avail_from_dt, replace

**save temporay elsa version of nhs infection data
save "BCS70 edited\protect_nhs_c19posinfect_temp_bcs70ver", replace



clear 



*******************************************
***THE MILLENIUM COHORT
**study_id==4
*******************************************

cd "S:\LLC_0007\data\"

**********************************
**THE MILLENIUM COHORT
**Set up - modified from CLS provided codebook

use "stata_w_labs\MCS_basic_demographic_cm_v0001_20211101", clear
count 
codebook, compact

use "stata_w_labs\MCS_basic_demographic_parent_v0001_20211101", clear
count 
codebook, compact

use "stata_w_labs\MCS_mcs7_cm_interview_v0001_20211101", clear
count 
codebook, compact


use "stata_w_labs\MCS_COVID_w1_v0001_20211101", clear
count 
codebook, compact

use "stata_w_labs\MCS_COVID_w2_v0001_20211101", clear
count 
codebook, compact

use "stata_w_labs\MCS_COVID_w3_v0001_20211101", clear
count 
codebook, compact

* Set up Merge files together

*********************************************
***setting up demographics mcs data

use "stata_w_labs\MCS_basic_demographic_cm_v0001_20211101", clear
count 
codebook, compact 

**gen ethnic groups
gen ethnic=adc11e00
replace ethnic=bdc11e00 if ethnic==.
tab ethnic
gen ethnicity_red=ethnic
replace ethnicity_red=1 if ethnic<=3 & ethnic!=.
replace ethnicity_red=2 if ethnic>3 & ethnic!=.
label define ethnicity_red 1 "White/British" 2 "Other", replace
label values ethnicity_red ethnicity_red
tab ethnicity_red


**soc2010 if working
gen soc2010=gcsoc00_tr3 if gcsoc00_tr3!="---" & gcsoc00_tr3!="-1"
destring soc2010, replace

*soc2010_1d
gen soc2010_1d=floor(soc2010/100) 
tab soc2010_1d
label define soc2010_1d 1 "Managers, Directors, & Senior Off" 2 "Prof Occupations" 3 "Associate Prof & Technical Occup" 4 "Administrative and Secretarial" 5 "Skilled Trades" 6 "Caring, Leisure, and Other Service" 7 "Sales and Customer Serv" 8 "Process, Plant, and Machine Operatives" 9 "Elementary Occupations", replace
label values soc2010_1d soc2010_1d
tab soc2010_1d


*soc2010_2d
gen soc2010_2d=floor(soc2010/10) 
tab soc2010_2d
label define soc2010_2d 11 "Corporate Managers" 12 "Other Managers and Proprietors in Agriculture and Services" 21 "Science, res, and Tech Prof" 22 "Health Prof" 23 "Teaching and Educa Prof" 24 "Buisness and Public Services Prof" 31 "Science and Tech A-Prof" 32 "Health and Social Welfare A-Prof" 33 "Protective Services" 34 "Culture, Media, Sports Occ" 35 "Buisness and Public Serivces A-Prof" 41 "Administrative Occ" 42 "Secretarial and Related" 51 "Skilled Agricultural Trades" 52 "Skilled Metal and Electrical Trades" 53 "Skilled Construction and Building Trades" 54 "Textiles, Printing, Other skilled Trades" 61 "Caring Personal Services" 62 "Leisure & Other Personal Service Occ" 71 "Sales Occ" 72 "Customer Service" 81  "Process, Plant, and Machine Operative" 82 "Transport, Mobile Macnine Drivers and Operatives" 91 "Elementary Trades, Plant and Storage related Occ" 92 "Elementary Admin and Service Occ", replace 
label values soc2010_2d soc2010_2d
tab soc2010_2d, missing


**
save "MCS edited\MCS_basic_demographics_cm_temp", replace


use "stata_w_labs\MCS_basic_demographic_parent_v0001_20211101", clear
count 
codebook, compact

**gen ethnic groups
gen ethnic=bdd11e00
replace ethnic=bdd11e00 if ethnic==.
tab ethnic
gen ethnicity_red=ethnic
replace ethnicity_red=1 if ethnic<=3 & ethnic!=.
replace ethnicity_red=2 if ethnic>3 & ethnic!=.
label define ethnicity_red 1 "White/British" 2 "Other", replace
label values ethnicity_red ethnicity_red
tab ethnicity_red

*soc2000
gen soc2000=bpjbso00a1 
replace soc2000=soc2000*10 if soc2000<100 & soc2000>=10
replace soc2000=soc2000*100 if soc2000<10 

**soc2000_1d
gen soc2000_1d=floor(soc2000/100)
tab soc2000_1d
label define soc2000_1d 1 "Managers and Senior Officals" 2 "Professional Occupations" 3 "Associate Professional and Technical" 4 "Administrative and Secretarial" 5 "Skilled Trades" 6 "Personal Service" 7 "Sales and Customer Services" 8 "Process, Plant and Machine Operative" 9 "Elementary Occ", replace  
label values soc2000_1d soc2000_1d
tab soc2000_1d , missing

**soc2000_2d
gen soc2000_2d=floor(soc2000/10)
tab soc2000_2d
label define soc2000_2d 11 "Corporate Managers" 12 "Managers and Proprietors in Agriculture and Services" 21 "Science and Tech Prof" 22 "Health Prof" 23 "Teaching and Research Prof" 24 "Buisness and Public Services Prof" 31 "Science and Tech A-Prof" 32 "Health and Social Welfare A-Prof" 33 "Protective Services" 34 "Culture, Media, Sports Occ" 35 "Buisness and Public Serivces A-Prof" 41 "Administrative Occ" 42 "Secretarial and Related" 51 "Skilled Agricultural Trades" 52 "Skilled Metal and Electrical Trades" 53 "Skilled Construction and Building Trades" 54 "Textiles, Printing, Other skilled Trades" 61 "Caring Personal Services" 62 "Leisure & Other Personal Service Occ" 71 "Sales Occ" 72 "Customer Service" 81  "Process, Plant, and Machine Operative" 82 "Transport, Mobile Macnine Drivers and Operatives" 91 "Elementary Trades, Plant and Storage related Occ" 92 "Elementary Admin and Service Occ", replace 
label values soc2000_2d soc2000_2d
tab soc2000_2d , missing


*soc2010_1d
gen soc2010_1d=floor(fpsocc00/100) if fpsocc00>=0
tab soc2010_1d
label define soc2010_1d 1 "Managers, Directors, & Senior Off" 2 "Prof Occupations" 3 "Associate Prof & Technical Occup" 4 "Administrative and Secretarial" 5 "Skilled Trades" 6 "Caring, Leisure, and Other Service" 7 "Sales and Customer Serv" 8 "Process, Plant, and Machine Operatives" 9 "Elementary Occupations", replace
label values soc2010_1d soc2010_1d
tab soc2010_1d


*soc2010_2d
gen soc2010_2d=floor(fpsocc00/10) 
tab soc2010_2d
label define soc2010_2d 11 "Corporate Managers" 12 "Other Managers and Proprietors in Agriculture and Services" 21 "Science, res, and Tech Prof" 22 "Health Prof" 23 "Teaching and Educa Prof" 24 "Buisness and Public Services Prof" 31 "Science and Tech A-Prof" 32 "Health and Social Welfare A-Prof" 33 "Protective Services" 34 "Culture, Media, Sports Occ" 35 "Buisness and Public Serivces A-Prof" 41 "Administrative Occ" 42 "Secretarial and Related" 51 "Skilled Agricultural Trades" 52 "Skilled Metal and Electrical Trades" 53 "Skilled Construction and Building Trades" 54 "Textiles, Printing, Other skilled Trades" 61 "Caring Personal Services" 62 "Leisure & Other Personal Service Occ" 71 "Sales Occ" 72 "Customer Service" 81  "Process, Plant, and Machine Operative" 82 "Transport, Mobile Macnine Drivers and Operatives" 91 "Elementary Trades, Plant and Storage related Occ" 92 "Elementary Admin and Service Occ", replace 
label values soc2010_2d soc2010_2d
tab soc2010_2d, missing



label define nssecmj 1 "Large emp" 2 "Hi Manag" 3 "High Prof" 4 "Lo Prof/Hi Tech" 5 "Lower managers" 6 "Hi Supervisory" 7 "Intermediate" 8 "Small empl" 9 "Self-emp non prof" 10 "Lower Supervisor" 10 "Lower tech" 12 "Semi-routine" 13 "routine", replace
label define nssec7 1 "Higher Man/prof" 2 "Low Man/prof" 3 "Intermediate occ" 4 "Small empself-emp" 5 "Lower sup and tech" 6 "Semi routine" 7 "Rountine occ", replace
label define nssec5 1 "Man/prof occ" 2 "Intermediate occ" 3 "Small employers self employed" 4 "Lower  technical occ" 5 "Semi/Rountine occ" , replace 

label values add05s00 nssec5
label values add07s00 nssec7
label values add13s00 nssecmj
label values bdd07s00 nssec7
label values bdd05s00 nssecmj
label values bdd13s00 nssec5
label values fd05s00 nssec5
label values fd07s00 nssec7
label values fd13s00 nssecmj	

label define fdacaq00  1 "NVQ l1-lowGCSE" 2 "NVQ l2-higGCSE" 3 "NVQ l3-Alevel" 4 "NVQ l4-Degree" 5 "NVQ l5-postgrad" 95 "Overseas qual only" 96 "None of these", replace
label values fdacaq00 fdacaq00 

label define fdact00 1 "Employed" 2 "Self-Emp" 3 "Looking for work" 4 "Poor health" 5 "New deal, appren" 6 "Student" 7 "Looking after family" 8 "Waiting for job to start" 9 "Non-working other reason" 10 "retired" -8 "Unknown" -1 "Not applicable", replace
label values fdact00 fdact00


label values fdnvq00 fdacaq00
label define fdwrk00 -1 "NA" 1 "In work/onleave" 2 "Not in work"
label values fdwrk00 fdwrk00


save "MCS edited\MCS_basic_demographics_parent_temp", replace

use "stata_w_labs\MCS_mcs7_cm_interview_v0001_20211101", clear
count 
codebook, compact
**dont think this is useful
clear


***************************************************************************
***START BY APPENDING/MERGING THE COVID WAVES
**covid waves

**Wave 1
use "stata_w_labs\MCS_COVID_w1_v0001_20211101", clear
rename cw1_* *
gen wave=1
save "MCS edited\MCS_COVID_w1_v0001_20211101 temp", replace
**Wave 2
use "stata_w_labs\MCS_COVID_w2_v0001_20211101", clear
rename cw2_* *
gen wave=2
save "MCS edited\MCS_COVID_w2_v0001_20211101 temp", replace
**Wave 3
use "stata_w_labs\MCS_COVID_w3_v0001_20211101", clear
rename cw3_* *
gen wave=3
save "MCS edited\MCS_COVID_w3_v0001_20211101 temp", replace

**APPEND WAVE FILES INTO ONE LONG FILE
use "MCS edited\MCS_COVID_w1_v0001_20211101 temp", clear
append using "MCS edited\MCS_COVID_w2_v0001_20211101 temp"
append using "MCS edited\MCS_COVID_w3_v0001_20211101 temp"

count
bysort llc_0007_stud_id: egen seq=seq()
tab seq
tab wave

***ADD IN THE ADDITIONAL BCS10 DATA
**Add in demographics
merge m:1 llc_0007_stud_id using "MCS edited\MCS_basic_demographics_parent_temp"
tab _merge
drop if _merge==2
drop _merge

**Add in demographics
merge m:1 llc_0007_stud_id using "MCS edited\MCS_basic_demographics_cm_temp"
tab _merge
tab _merge wave, missing
drop if _merge==2
drop _merge

 

*****FORMATTING VARIABLES******
***i.sex i.ethnicity_red  i.hm_location i.housing_composition  i.pandemic_timetranche i.deprivation

numlabel, add

***SEX
rename psex sex
tab sex

***ETHNICITY
**single var = ethnic
replace ethnic = adc11e00 if ethnic==.
replace ethnic = bdc11e00 if ethnic==.
tab ethnic
replace ethnicity_red=2 if inrange(ethnic, 4, 20)
replace ethnicity_red=1 if inrange(ethnic, 1, 3)
label define ethnicity_red 1 "White/British" 2 "Other" 9 "Missing", replace
label values ethnicity_red ethnicity_red
tab ethnicity_red, missing
*list llc_0007_stud_id ethnic ethnicity_red adc11e00 bdc11e00 if ethnicity_red==.
list llc_0007_stud_id ethnic ethnicity_red adc11e00 bdc11e00 wave if llc_0007_stud_id==199206005927992224


**Age at entry 
**all participants born in a single week during 1970 so all are aged 52

***HOUSEHOLD NUMBERS/COMPOSITION
**hhnum_cw1 hhnum_cw2 hhnum_cw3
**should generate a single var when reshaped
**1"partner+kids" 2"only partner" 3"single parent" 4"other" 5"alone"

label define housing_composition 1 "partner and children" 2 "partner no children" 3 "lone parents" 4 "no partner no children" 5 "alone" 9 "missing", replace

***Generate housing_composition
**partner
tab hhnumwh_1 
tab hhnumwh_2 
tab hhnumwh_3 
tab hhnumwh_4 
tab hhnumwh_5 
tab hhnumwh_6 
tab hhnumwh_7 
tab hhnumwh_8 
tab hhnumwh_9
tab hhnum


gen housing_composition=.
**partner and children
replace housing_composition=1 if hhnumwh_1==1 & hhnumwh_2==2
**partner no children
replace housing_composition=2 if hhnumwh_1==1 & hhnumwh_2==1
**lone parents
replace housing_composition=3 if hhnumwh_1==2 & hhnumwh_2==1
**no partner no children/other 
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_3==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_4==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_5==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_6==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_7==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_8==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_9==1
**Alone
replace housing_composition=5 if hhnum==0
bysort llc_0007_stud_id (wave): replace housing_composition=housing_composition[_n-1] if wave==2 & housing_composition==. & housing_composition[_n-1]!=.
bysort llc_0007_stud_id (wave): replace housing_composition=housing_composition[_n-1] if wave==3 & housing_composition==. & housing_composition[_n-1]!=.

bysort llc_0007_stud_id (wave): replace housing_composition=housing_composition[_n+1] if wave==2 & housing_composition==. & housing_composition[_n+1]!=.
bysort llc_0007_stud_id (wave): replace housing_composition=housing_composition[_n+1] if wave==1 & housing_composition==. & housing_composition[_n+1]!=.
replace housing_composition=9 if housing_composition==.

label values housing_composition housing_composition
tab housing_composition, missing



**REGION
**No indicator of living in urban or rural area


***WAVE DATES
label define wave 1 "May 2020" 2 "Sep/Oct 2020" 3 "Feb/Mar 2021", replace
label values wave wave
rename wave study_wave
tab study_wave


***TRANCHE
gen pandemic_timetranche=study_wave
label var pandemic_timetranche "Time-Tranche H&W version"
label define pandemic_timetranche 1 "Apr20-Jun20" 2 "Jul20-Oct20" 3 "Nov20-Mar21", replace
label values pandemic_timetranche pandemic_timetranche
tab pandemic_timetranche



codebook covid_hospad covid19 covidresult covidtest covid19pos covidincresult covidincwhen covidcurresult covidcurwhen covidpasresult covidpaswhen covidtest_1 covidtest_2 covidtest_3 covidtest_4 outcome, compact

foreach var of varlist covid19 covidresult covidtest covid19pos covidincresult covidincwhen covidcurresult covidcurwhen covidpasresult covidpaswhen covidtest_1 covidtest_2 covidtest_3 covidtest_4 {
	tab `var'
}

***SELF-REPORTED INFECTION 
tab covid19 , missing
recode covid19 (1=1) (2=1) (3=0) (4=0), gen(c19infection_selfreported)
label define c19infection_selfreported 0 "No" 1 "Yes", replace
label values c19infection_selfreported c19infection_selfreported
tab c19infection_selfreported

***SELF-REPORTED POSITIVE TEST 
recode covid19 (1=1) (2=0) (3=0) (4=0), gen(c19postest_selfreported)
label define c19postest_selfreported 0 "No" 1 "Yes", replace
label values c19postest_selfreported c19postest_selfreported
tab c19postest_selfreported


***ADD IN OCCUPATIONAL VARS
codebook soc2010 soc2020 bpjbso00a1 fpsocc00 soc2000 soc2000_1d soc2000_2d soc2010_1d soc2010_2d gcsoc00_tr3, compact
drop seq

**SOC 1dig
tab soc2010, nol
replace soc2010_1d=floor(soc2010/100) if soc2010_1d==.
label define soc2010_1d 1 "Managers, Directors, & Senior Off" 2 "Prof Occupations" 3 "Associate Prof & Technical Occup" 4 "Administrative and Secretarial" 5 "Skilled Trades" 6 "Caring, Leisure, and Other Service" 7 "Sales and Customer Serv" 8 "Process, Plant, and Machine Operatives" 9 "Elementary Occupations", replace
label values soc2010_1d soc2010_1d
tab soc2010_1d
bysort llc_0007_stud_id (study_wave): egen seq=seq()
bysort llc_0007_stud_id (study_wave): replace soc2010_1d=soc2010_1d[_n-1] if soc2010_1d==. & seq>1



**SOC 2dig
tab soc2010, nol
replace soc2010_2d=floor(soc2010/10) if soc2010_2d==.
tab soc2010_2d
label define soc2010_2d 11 "Corporate Managers" 12 "Other Managers and Proprietors in Agriculture and Services" 21 "Science, res, and Tech Prof" 22 "Health Prof" 23 "Teaching and Educa Prof" 24 "Buisness and Public Services Prof" 31 "Science and Tech A-Prof" 32 "Health and Social Welfare A-Prof" 33 "Protective Services" 34 "Culture, Media, Sports Occ" 35 "Buisness and Public Serivces A-Prof" 41 "Administrative Occ" 42 "Secretarial and Related" 51 "Skilled Agricultural Trades" 52 "Skilled Metal and Electrical Trades" 53 "Skilled Construction and Building Trades" 54 "Textiles, Printing, Other skilled Trades" 61 "Caring Personal Services" 62 "Leisure & Other Personal Service Occ" 71 "Sales Occ" 72 "Customer Service" 81  "Process, Plant, and Machine Operative" 82 "Transport, Mobile Macnine Drivers and Operatives" 91 "Elementary Trades, Plant and Storage related Occ" 92 "Elementary Admin and Service Occ", replace 
label values soc2010_2d soc2010_2d
bysort llc_0007_stud_id (study_wave): replace soc2010_2d=soc2010_2d[_n-1] if soc2010_2d==. & seq>1
tab soc2010_2d, missing
drop seq

**SIC??
tab sic3
tab sic3cur

*gen occupation vars (defined in protocol)
replace soc2010=soc2010cur if soc2010==.
tab soc2010
recode soc2010 (110=9) (111=9) (112=11)	(113=9)	(115=9)	(116=8)	(117=6)	(118=1)	(119=12)	(121=13)	(122=1)	(124=12)	(125=9)	(211=9)	(212=9)	(213=9)	(214=9)	(215=9)	(221=1)	(222=1)	(223=1)	(231=5)	(241=9)	(242=9)	(243=9)	(244=9)	(245=9)	(246=9)	(247=9)	(311=9)	(312=9)	(313=9)	(321=1)	(323=4)	(331=6)	(341=9)	(342=9)	(344=9)	(350=8)	(351=8)	(352=9)	(353=9)	(354=9)	(355=9)	(356=9)	(411=9)	(412=9)	(413=9)	(415=12)	(416=9)	(421=9)	(511=7)	(521=9)	(522=11)	(523=9)	(524=9)	(525=11) (531=9)	(532=9)	(533=9)	(540=9) (541=9)	(542=9)	(543=7)	(544=9)	(612=4)	(613=9)	(614=1)	(621=8)	(622=9)	(623=13)	(624=13)	(711=12)	(712=9)	(713=12) (721=12)	(722=12)	(811=11)	(812=11)	(813=11)	(814=9)	(821=8)	(822=9)	(823=8)	(911=9)	(912=9)	(913=11)	(921=8)	(923=9)	(924=9)	(925=12)	(926=11)	(927=13), gen(occ_full)
label var occ_full "occupation full"
label define occ_full 1 "Health Care Prof" 2 "Other Health care prof" 3 "Medical Support" 4 "Social Care" 5 "Education" 6 "Police & Protection serv" 7 "Food Workers" 8 "Transport workers" 9 "Other workers" 11 "Factory" 12 "Customer serv" 13 "Hospitality" 20 "Missing/Not in work"
label values occ_full occ_full
tab occ_full

bysort llc_0007_stud_id (occ_full): replace occ_full=occ_full[_n-1] if _n>1 & occ_full==.
sort llc_0007_stud_id study_wave
replace occ_full=20 if occ_full==.
tab occ_full


**gen occupation vars (defined in protocol - reduced)
recode occ_full (1=2) (2=2) (3=2) (4=3) (5=3) (6=4) (7=5) (8=5) (9=1) (11=5) (12=5) (13=5) (20=6), gen(occ_red)
label var occ_red "occupation reduced"
label define occ_red 1 "Non-essential workers" 2 "Health Care workers" 3 "Social and Education" 4 "Police and Protective" 5 "Other essential workers" 6 "Missing/not in wrk"
label values occ_red occ_red
tab occ_red



**generate weekly working hours
gen  wk_worhrs=wrkhoursd
replace wk_worhrs=timeuse1_1_1 if wk_worhrs==.
replace wk_worhrs=timeuse_1*5 if wk_worhrs==.
replace wk_worhrs=wrkhoursb if wk_worhrs==.

tab wk_worhrs study_wave


**employment
recode econactivityd (1=1) (2=1)  (3=1) (4=1) (5=1) (6=1) (7=0) (8=0) (9=0) (10=0) (11=0) (12=0) (13=0), gen(employed)
label var employed "Participant employed during COVID"
label define employed 0 "No" 1 "Yes", replace
label values employed employed
tab employed


**employment
tab wk_worhrs
tab econactivityd
tab wk_worhrs if econactivityd==.

recode econactivityd (1=1) (2=1)  (3=1) (4=1) (5=1) (6=1) (7=3) (8=3) (9=3) (10=3) (11=3) (12=2) (13=3), gen(employment) 
replace employment=3 if wk_worhrs<8 & employment==.
replace employment=1 if wk_worhrs>=8 & wk_worhrs!=. & employment==.

label var employment "Participant employment_status during COVID"
label define employment 1 "Employed/looking for work" 2 "Retired" 3 "Unemployed", replace
label values employment employment
tab employment

tab econactivityd employment, missing


**employment_status
tab wk_worhrs
tab econactivityd

recode econactivityd (1=1) (2=3)  (3=3)(5=3) (6=1) (7=3) (8=4) (9=4) (10=4) (11=4) (12=2) (13=4), gen(employment_status) 
replace employment_status=1 if wk_worhrs<8 & employment_status==.
replace employment_status=1 if wk_worhrs>=8 & wk_worhrs!=. & employment_status==.
replace employment_status=0 if wk_worhrs>=20 & wk_worhrs!=. & employment_status==1


label var employment_status "Participant employment_status during COVID"
label define employment_status 0 "Full-Time employment" 1 "Part-time employment" 2 "Retired" 3 "Employed but not working" 4 "Unemployed", replace
label values employment_status employment_status
tab econactivityd employment_status
tab econactivityd




**Key worker 
tab keyworkerd study_wave

recode keyworkerd (1=1) (2=0), gen(key_worker)
label define key_worker 0 "No" 1 "Yes"
label values key_worker key_worker
tab key_worker


**Home working	 
tab wrklocationd study_wave, missing
gen home_working=wrklocationd
replace home_working=4 if study_wave==1 & wrklocationd==3
recode home_working (2=3) (3=2)
label define home_working 1 "Wrk from hm" 2 "Some" 3 "None" 4 "Other", replace
label values home_working home_working
tab home_working wrklocationd

**Furlough - 
tab econactivityd
gen furlough=1 if inlist(econactivityd, 2, 3)
replace furlough=0 if inlist(econactivityd, 1, 5, 6)
replace furlough=2 if furlough==. & econactivityd!=.
label define furlough 0 "In wrk" 1 "furlough" 2 "other", replace
label values furlough furlough
tab furlough


tab study_wave c19infection_selfreported , row

tab pandemic_timetranche c19infection_selfreported 
tab pandemic_timetranche c19postest_selfreported

**save long version of final MCS file
save "MCS edited\MCS edited long version.dta", replace



***********PREPARE/FORMAT and MERGE NHS TESTING DATA*********************

***************************************	
****MERGING WITH THE NHS TESTING DATA
use "NHS edited\protect_nhs_c19posinfect_temp", clear
ssc instal datesum
count


**drop if within 2 weeks - drops 14,309, leaves 25,125 positive tests
drop if time_sinceprevpos<14 & time_sinceprevpos!=0


***create identification of (MCS) wave in nhs infection data
**Three waves pre-"May 2020", May-"Sep/Oct 2020", Nov20-"Feb/Mar 2021"

gen study_wave=1 if testdate<=date("01/05/2020", "DMY")
replace study_wave=2 if testdate>date("01/05/2020", "DMY") & testdate<=date("31/10/2020", "DMY")
replace study_wave=3 if testdate>date("31/10/2020", "DMY") & testdate<=date("30/03/2021", "DMY")
replace study_wave=. if testdate>date("30/03/2021", "DMY")

label define study_wave 1 "pre-April 2020" 2 "May-Sep/Oct 2020" 3 "Nov20-Feb/Mar 2021", replace
label values study_wave study_wave
tab study_wave
bysort study_wave: datesum testdate


drop if study_wave==.
tab source
sort llc_0007_stud_id study_wave

**Look for within wave repeats
bysort llc_0007_stud_id study_wave: egen seq=seq()
tab seq
gen rep_n=seq
gsort llc_0007_stud_id study_wave -seq
by llc_0007_stud_id study_wave: replace rep_n=rep_n[_n-1] if _n>1
tab rep_n
sort llc_0007_stud_id study_wave seq
list llc_0007_stud_id study_wave testdate seq rep_n if rep_n!=1, sepby(llc_0007_stud_id)
*take first pos test
keep if seq==1
drop seq rep_n

**rename occupation var
rename occupation occupation_nhs

tostring avail_from_dt, replace

**save temporay elsa version of nhs infection data
save "MCS edited\protect_nhs_c19posinfect_temp_mcsver", replace

clear 


**************************************************
**THE 1958 NATIONAL CHILD DEVELOPMENT STUDY (NCDS)
**************************************************

**THE 1958 NATIONAL CHILD DEVELOPMENT STUDY (NCDS)
**Set up - modified from CLS provided codebook
cd "S:\LLC_0007\data\"

use "stata_w_labs\NCDS58_basic_demographic_v0001_20211101", clear
count 
codebook, compact

use "stata_w_labs\NCDS58_ncds9_employment_v0001_20211101", clear
count 
codebook, compact

**housing data here appears to be related to moving house pre pandemic - not useful
use "stata_w_labs\NCDS58_ncds9_housing_v0001_20211101", clear
count 
codebook, compact

use "stata_w_labs\NCDS58_ncds9_qualifications_v0001_20211101", clear
count 
codebook, compact

use "stata_w_labs\NCDS58_COVID_w1_v0001_20211101", clear
count 
codebook, compact

use "stata_w_labs\NCDS58_COVID_w2_v0001_20211101", clear
count 
codebook, compact

use "stata_w_labs\NCDS58_COVID_w3_v0001_20211101", clear
count 
codebook, compact

* Set up Merge files together

*********************************************
***setting up qualifications bc10 data

use "stata_w_labs\NCDS58_ncds9_qualifications_v0001_20211101", clear
count
codebook, compact
numlabel, add

**drop non-reported qualification & repeated qualifications
bysort llc_0007_stud_id n9qualtp: egen seq=seq()
tab seq
drop if seq>1 & seq!=.
drop seq

**identify repeates 
bysort llc_0007_stud_id: egen seq=seq()
gsort llc_0007_stud_id -seq
by llc_0007_stud_id: gen count=seq if _n==1
by llc_0007_stud_id: replace count=count[_n-1] if _n>1
tab seq

sort llc_0007_stud_id seq
list llc_0007_stud_id  n9ewh n9qualtp seq if count>1, sepby(llc_0007_stud_id)

**recode multiple qualifications into highest qualification 
numlabel, add
tab n9qualtp


recode n9qualtp (1=1) (2=1) (3=2) (4=2) (5=2) (6=2) (7=4) (8=4) (9=5) (10=4) (11=2) (12=3)  (13=2) (14=3) (15=4) (16=4) (17=5) (18=5)  (19=3) (20=3) (21=3) (22=3) (23=3) (24=3)  (25=3) (26=3) (27=3) (28=3) (29=3)  (30=3) (31=2) (32=2), gen(highqual)
label define highqual 1 "GCSE" 2 "Alevel eq" 3 "BTEC/HND/GNVQ eq" 4 "Degree eq" 5 "Higher Degree" 
label values highqual highqual
label var highqual "Highest Qualification in NCDS58 BC10"
tab n9qualtp highqual 

gsort llc_0007_stud_id -highqual
by llc_0007_stud_id: egen qualseq=seq()
tab qualseq 

list llc_0007_stud_id highqual qualseq if count>4 , sepby(llc_0007_stud_id)

**keep highest qualifications
keep if qualseq==1

**check no repeates
drop seq
bysort llc_0007_stud_id: egen seq=seq()
tab seq
drop seq
**keep var indicating highest qualification
keep llc_0007_stud_id highqual

save "NCDS58 edited\NCDS58_ncds9_qualifications temp", replace


*********************************************************
***setting up employment n9 data
use "stata_w_labs\NCDS58_ncds9_employment_v0001_20211101", clear
count 
codebook, compact

**drop if not currently active job role
keep if n9acurac==1

**identify repeates 
bysort llc_0007_stud_id ( n9aendy n9aendm): egen seq=seq()
gsort llc_0007_stud_id -seq
by llc_0007_stud_id: gen count=seq if _n==1
by llc_0007_stud_id: replace count=count[_n-1] if _n>1
tab seq

**keep final currentl active job 
keep if seq==count
drop seq count

**keep useful variables
drop avail_from_dt

count

save "NCDS58 edited\NCDS58_ncds9_employ temp", replace


**demographics

use "stata_w_labs\NCDS58_basic_demographic_v0001_20211101", clear

**identify repeates 
bysort llc_0007_stud_id: egen seq=seq()
gsort llc_0007_stud_id -seq
by llc_0007_stud_id: gen count=seq if _n==1
by llc_0007_stud_id: replace count=count[_n-1] if _n>1
tab seq

drop seq count 

save "NCDS58 edited\NCDS58_basic_demographic temp", replace




***************************************************************************
***START BY APPENDING/MERGING THE COVID WAVES
**covid waves

**Wave 1
use "stata_w_labs\NCDS58_COVID_w1_v0001_20211101", clear
rename cw1_* *
gen wave=1
save "NCDS58 edited\NCDS58_COVID_w1_v0001_20211101 temp", replace
**Wave 2
use "stata_w_labs\NCDS58_COVID_w2_v0001_20211101", clear
rename cw2_* *
gen wave=2
save "NCDS58 edited\NCDS58_COVID_w2_v0001_20211101 temp", replace
**Wave 3
use "stata_w_labs\NCDS58_COVID_w3_v0001_20211101", clear
rename cw3_* *
gen wave=3
save "NCDS58 edited\NCDS58_COVID_w3_v0001_20211101 temp", replace

**APPEND WAVE FILES INTO ONE LONG FILE
use "NCDS58 edited\NCDS58_COVID_w1_v0001_20211101 temp", clear
append using "NCDS58 edited\NCDS58_COVID_w2_v0001_20211101 temp"
append using "NCDS58 edited\NCDS58_COVID_w3_v0001_20211101 temp"


***ADD IN THE ADDITIONAL ncds9 DATA
**Add in demographics
merge m:1 llc_0007_stud_id using "stata_w_labs\NCDS58_basic_demographic_v0001_20211101"
tab _merge
drop if _merge==2
drop _merge
**Add in qualifications higest 
merge m:1 llc_0007_stud_id using "NCDS58 edited\NCDS58_ncds9_qualifications temp"
tab _merge
drop if _merge==2
drop _merge
**Add in qualifications higest 
merge m:1 llc_0007_stud_id using "NCDS58 edited\NCDS58_ncds9_employ temp"
tab _merge
drop if _merge==2
drop _merge


*****FORMATTING VARIABLES******
***i.sex i.ethnicity_red  i.hm_location i.housing_composition  i.pandemic_timetranche i.deprivation

numlabel, add

***SEX
rename psex sex
tab sex

***ETHNICITY
**single var = ethnic
tab ethnic
recode ethnic (1=1) (2=1) (3=1) (4=2) (5=2) (6=2) (7=2) (8=2) (9=2) (10=2) (11=2) (12=2) (13=2) (14=2) (15=2) (16=2) (99=9) (.=9), generate(ethnicity_red)
label define ethnicity_red 1 "White/British" 2 "Other" 9 "Missing", replace
label values ethnicity_red ethnicity_red
tab ethnicity_red, missing

**Age at entry 
**all participants born in a single week during 1958 so all are aged 62

***HOUSEHOLD NUMBERS/COMPOSITION
**hhnum_cw1 hhnum_cw2 hhnum_cw3
**should generate a single var when reshaped
**1"partner+kids" 2"only partner" 3"single parent" 4"other" 5"alone"

label define housing_composition 1 "partner and children" 2 "partner no children" 3 "lone parents" 4 "no partner no children" 5 "alone" 9 "missing", replace

***Generate housing_composition
**partner
tab hhnumwh_1 
tab hhnumwh_2 
tab hhnumwh_3 
tab hhnumwh_4 
tab hhnumwh_5 
tab hhnumwh_6 
tab hhnumwh_7 
tab hhnumwh_8 
tab hhnumwh_9
tab hhnum


gen housing_composition=.
**partner and children
replace housing_composition=1 if hhnumwh_1==1 & hhnumwh_2==2
**partner no children
replace housing_composition=2 if hhnumwh_1==1 & hhnumwh_2==1
**lone parents
replace housing_composition=3 if hhnumwh_1==2 & hhnumwh_2==1
**no partner no children/other 
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_3==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_4==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_5==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_6==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_7==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_8==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_9==1
**Alone
replace housing_composition=5 if hhnum==0
bysort llc_0007_stud_id (wave): replace housing_composition=housing_composition[_n-1] if wave==2 & housing_composition==. & housing_composition[_n-1]!=.
bysort llc_0007_stud_id (wave): replace housing_composition=housing_composition[_n-1] if wave==3 & housing_composition==. & housing_composition[_n-1]!=.

bysort llc_0007_stud_id (wave): replace housing_composition=housing_composition[_n+1] if wave==2 & housing_composition==. & housing_composition[_n+1]!=.
bysort llc_0007_stud_id (wave): replace housing_composition=housing_composition[_n+1] if wave==1 & housing_composition==. & housing_composition[_n+1]!=.
replace housing_composition=9 if housing_composition==.

label values housing_composition housing_composition
tab housing_composition, missing



**REGION
**No indicator of living in urban or rural area


***WAVE DATES
label define wave 1 "May 2020" 2 "Sep/Oct 2020" 3 "Feb/Mar 2021", replace
label values wave wave
rename wave study_wave
tab study_wave


***TRANCHE
gen pandemic_timetranche=study_wave
label var pandemic_timetranche "Time-Tranche H&W version"
label define pandemic_timetranche 1 "Apr20-Jun20" 2 "Jul20-Oct20" 3 "Nov20-Mar21", replace
label values pandemic_timetranche pandemic_timetranche
tab pandemic_timetranche



codebook covid_hospad covid19 covidresult covidtest covid19pos covidincresult covidincwhen covidcurresult covidcurwhen covidpasresult covidpaswhen covidtest_1 covidtest_2 covidtest_3 covidtest_4 outcome, compact

foreach var of varlist covid19 covidresult covidtest covid19pos covidincresult covidincwhen covidcurresult covidcurwhen covidpasresult covidpaswhen covidtest_1 covidtest_2 covidtest_3 covidtest_4 {
	tab `var'
}

***SELF-REPORTED INFECTION 
tab covid19 , missing
recode covid19 (1=1) (2=1) (3=0) (4=0), gen(c19infection_selfreported)
label define c19infection_selfreported 0 "No" 1 "Yes", replace
label values c19infection_selfreported c19infection_selfreported
tab c19infection_selfreported

***SELF-REPORTED POSITIVE TEST 
recode covid19 (1=1) (2=0) (3=0) (4=0), gen(c19postest_selfreported)
label define c19postest_selfreported 0 "No" 1 "Yes", replace
label values c19postest_selfreported c19postest_selfreported
tab c19postest_selfreported


***ADD IN OCCUPATIONAL VARS




**SOC 1dig
tab soc2010, nol
replace soc2010=soc2010cur if soc2010==.
gen soc2010_1d=floor(soc2010/100)
label define soc2010_1d 1 "Managers, Directors, & Senior Off" 2 "Prof Occupations" 3 "Associate Prof & Technical Occup" 4 "Administrative and Secretarial" 5 "Skilled Trades" 6 "Caring, Leisure, and Other Service" 7 "Sales and Customer Serv" 8 "Process, Plant, and Machine Operatives" 9 "Elementary Occupations", replace
label values soc2010_1d soc2010_1d
tab soc2010_1d
bysort llc_0007_stud_id (study_wave): egen seq=seq()
bysort llc_0007_stud_id (study_wave): replace soc2010_1d=soc2010_1d[_n-1] if soc2010_1d==. & seq>1



**SOC 2dig
tab soc2010, nol
gen soc2010_2d=floor(soc2010/10)
tab soc2010_2d
label define soc2010_2d 11 "Corporate Managers" 12 "Other Managers and Proprietors in Agriculture and Services" 21 "Science, res, and Tech Prof" 22 "Health Prof" 23 "Teaching and Educa Prof" 24 "Buisness and Public Services Prof" 31 "Science and Tech A-Prof" 32 "Health and Social Welfare A-Prof" 33 "Protective Services" 34 "Culture, Media, Sports Occ" 35 "Buisness and Public Serivces A-Prof" 41 "Administrative Occ" 42 "Secretarial and Related" 51 "Skilled Agricultural Trades" 52 "Skilled Metal and Electrical Trades" 53 "Skilled Construction and Building Trades" 54 "Textiles, Printing, Other skilled Trades" 61 "Caring Personal Services" 62 "Leisure & Other Personal Service Occ" 71 "Sales Occ" 72 "Customer Service" 81  "Process, Plant, and Machine Operative" 82 "Transport, Mobile Macnine Drivers and Operatives" 91 "Elementary Trades, Plant and Storage related Occ" 92 "Elementary Admin and Service Occ", replace 
label values soc2010_2d soc2010_2d
bysort llc_0007_stud_id (study_wave): replace soc2010_2d=soc2010_2d[_n-1] if soc2010_2d==. & seq>1
tab soc2010_2d, missing
drop seq

**SIC??
tab sic3

*gen occupation vars (defined in protocol)
replace soc2010=soc2010cur if soc2010==.
tab soc2010
recode soc2010 (110=9) (111=9) (112=11)	(113=9)	(115=9)	(116=8)	(117=6)	(118=1)	(119=12)	(121=13)	(122=1)	(124=12)	(125=9)	(211=9)	(212=9)	(213=9)	(214=9)	(215=9)	(221=1)	(222=1)	(223=1)	(231=5)	(241=9)	(242=9)	(243=9)	(244=9)	(245=9)	(246=9)	(247=9)	(311=9)	(312=9)	(313=9)	(321=1)	(323=4)	(331=6)	(341=9)	(342=9)	(344=9)	(350=8)	(351=8)	(352=9)	(353=9)	(354=9)	(355=9)	(356=9)	(411=9)	(412=9)	(413=9)	(415=12)	(416=9)	(421=9)	(511=7)	(521=9)	(522=11)	(523=9)	(524=9)	(525=11) (531=9)	(532=9)	(533=9)	(540=9) (541=9)	(542=9)	(543=7)	(544=9)	(612=4)	(613=9)	(614=1)	(621=8)	(622=9)	(623=13)	(624=13)	(711=12)	(712=9)	(713=12) (721=12)	(722=12)	(811=11)	(812=11)	(813=11)	(814=9)	(821=8)	(822=9)	(823=8)	(911=9)	(912=9)	(913=11)	(921=8)	(923=9)	(924=9)	(925=12)	(926=11)	(927=13), gen(occ_full)
label var occ_full "occupation full"
label define occ_full 1 "Health Care Prof" 2 "Other Health care prof" 3 "Medical Support" 4 "Social Care" 5 "Education" 6 "Police & Protection serv" 7 "Food Workers" 8 "Transport workers" 9 "Other workers" 11 "Factory" 12 "Customer serv" 13 "Hospitality" 20 "Missing/Not in work"
label values occ_full occ_full
tab occ_full

bysort llc_0007_stud_id (occ_full): replace occ_full=occ_full[_n-1] if _n>1 & occ_full==.
sort llc_0007_stud_id study_wave
replace occ_full=20 if occ_full==.
tab occ_full


**gen occupation vars (defined in protocol - reduced)
recode occ_full (1=2) (2=2) (3=2) (4=3) (5=3) (6=4) (7=5) (8=5) (9=1) (11=5) (12=5) (13=5) (20=6), gen(occ_red)
label var occ_red "occupation reduced"
label define occ_red 1 "Non-essential workers" 2 "Health Care workers" 3 "Social and Education" 4 "Police and Protective" 5 "Other essential workers" 6 "Missing/not in wrk"
label values occ_red occ_red
tab occ_red



**generate weekly working hours
gen  wk_worhrs=wrkhoursd
replace wk_worhrs=timeuse1_1_1 if wk_worhrs==.
replace wk_worhrs=timeuse_1*5 if wk_worhrs==.
replace wk_worhrs=wrkhoursb if wk_worhrs==.

tab wk_worhrs study_wave


**employment
tab econactivityd
recode econactivityd (1=1) (2=1)  (3=1) (4=1) (5=1) (6=1) (7=0) (8=0) (9=0) (10=0) (11=0) (12=0) (13=0), gen(employed) 
label var employed "Participant employed during COVID"
label define employed 0 "No" 1 "Yes", replace
label values employed employed
tab employed


**employment
tab wk_worhrs
tab econactivityd
tab wk_worhrs if econactivityd==.

recode econactivityd (1=1) (2=1)  (3=1) (4=1) (5=1) (6=1) (7=3) (8=3) (9=3) (10=3) (11=3) (12=2) (13=3), gen(employment) 
replace employment=3 if wk_worhrs<8 & employment==.
replace employment=1 if wk_worhrs>=8 & wk_worhrs!=. & employment==.

label var employment "Participant employment_status during COVID"
label define employment 1 "Employed/looking for work" 2 "Retired" 3 "Unemployed", replace
label values employment employment
tab employment

tab econactivityd employment, missing


**employment_status
tab wk_worhrs
tab econactivityd

recode econactivityd (1=1) (2=3)  (3=3) (4=2) (5=3) (6=1) (7=3) (8=4) (9=4) (10=4) (11=4) (12=2) (13=4), gen(employment_status) 
replace employment_status=1 if wk_worhrs<8 & employment_status==.
replace employment_status=1 if wk_worhrs>=8 & wk_worhrs!=. & employment_status==.
replace employment_status=0 if wk_worhrs>=20 & wk_worhrs!=. & employment_status==1


label var employment_status "Participant employment_status during COVID"
label define employment_status 0 "Full-Time employment" 1 "Part-time employment" 2 "Retired" 3 "Employed but not working" 4 "Unemployed", replace
label values employment_status employment_status
tab econactivityd employment_status



**Key worker 
tab keyworkerd study_wave

recode keyworkerd (1=1) (2=0), gen(key_worker)
label define key_worker 0 "No" 1 "Yes"
label values key_worker key_worker
tab key_worker


**Home working	 
tab wrklocationd study_wave
gen home_working=wrklocationd
replace home_working=4 if study_wave==1 & wrklocationd==3
recode home_working (2=3) (3=2)
label define home_working 1 "Wrk from hm" 2 "Some" 3 "None" 4 "Other", replace
label values home_working home_working
tab home_working

**Furlough - 
tab econactivityd
gen furlough=1 if inlist(econactivityd, 2, 3)
replace furlough=0 if inlist(econactivityd, 1, 5, 6)
replace furlough=2 if furlough==. & econactivityd!=. 
label define furlough 0 "In wrk" 1 "furlough" 2 "other", replace
label values furlough furlough
tab furlough

tab study_wave c19infection_selfreported , row

tab pandemic_timetranche c19infection_selfreported 
tab pandemic_timetranche c19postest_selfreported


**save long version of final NCDS58 file
save "NCDS58 edited\NCDS58 edited long version.dta", replace






***********PREPARE/FORMAT and MERGE NHS TESTING DATA*********************

***************************************	
****MERGING WITH THE NHS TESTING DATA
use "NHS edited\protect_nhs_c19posinfect_temp", clear
count


**drop if within 2 weeks - drops 14,309, leaves 25,125 positive tests
drop if time_sinceprevpos<14 & time_sinceprevpos!=0


***create identification of (BCS1970) wave in nhs infection data
**Three waves pre-"May 2020", May-"Sep/Oct 2020", Nov20-"Feb/Mar 2021"

gen study_wave=1 if testdate<=date("01/05/2020", "DMY")
replace study_wave=2 if testdate>date("01/05/2020", "DMY") & testdate<=date("31/10/2020", "DMY")
replace study_wave=3 if testdate>date("31/10/2020", "DMY") & testdate<=date("30/03/2021", "DMY")
replace study_wave=. if testdate>date("30/03/2021", "DMY")

label define study_wave 1 "pre-April 2020" 2 "May-Sep/Oct 2020" 3 "Nov20-Feb/Mar 2021", replace
label values study_wave study_wave
tab study_wave
bysort study_wave: datesum testdate


drop if study_wave==.
tab source
sort llc_0007_stud_id study_wave

**Look for within wave repeats
bysort llc_0007_stud_id study_wave: egen seq=seq()
tab seq
gen rep_n=seq
gsort llc_0007_stud_id study_wave -seq
by llc_0007_stud_id study_wave: replace rep_n=rep_n[_n-1] if _n>1
tab rep_n
sort llc_0007_stud_id study_wave seq
list llc_0007_stud_id study_wave testdate seq rep_n if rep_n!=1, sepby(llc_0007_stud_id)
*take first pos test
keep if seq==1
drop seq rep_n

**rename occupation var
rename occupation occupation_nhs

tostring avail_from_dt, replace

**save temporay elsa version of nhs infection data
save "NCDS58 edited\protect_nhs_c19posinfect_temp_ncds58ver", replace



clear 


*************************************************************
**NEXT STEPS FROM 1989
**study_id==6
*************************************************************

**Set up - modified from CLS provided codebook
cd "S:\LLC_0007\data\"

use "stata_w_labs\NEXTSTEP_basic_demographic_data_v0001_20211101", clear
count
codebook, compact
use "stata_w_labs\NEXTSTEP_ns8_derived_v0001_20211101", clear
count
codebook, compact

**doesn't appears to be useful - simply details demogrpahics of household members
use "stata_w_labs\NEXTSTEP_ns8_household_members_v0001_20211101", clear
count
codebook, compact

use "stata_w_labs\NEXTSTEP_COVID_w1_v0001_20211101", clear
count
codebook, compact
use "stata_w_labs\NEXTSTEP_COVID_w2_v0001_20211101", clear
count
codebook, compact
use "stata_w_labs\NEXTSTEP_COVID_w3_v0001_20211101", clear
count
codebook, compact






* Set up Merge files together

***************************************************************************
***START BY APPENDING/MERGING THE COVID WAVES
**covid waves

**Wave 1
use "stata_w_labs\NEXTSTEP_COVID_w1_v0001_20211101", clear
rename cw1_* *
gen wave=1
save "NS edited\NS_COVID_w1_v0001_20211101 temp", replace
**Wave 2
use "stata_w_labs\NEXTSTEP_COVID_w2_v0001_20211101", clear
rename cw2_* *
gen wave=2
save "NS edited\NS_COVID_w2_v0001_20211101 temp", replace
**Wave 3
use "stata_w_labs\NEXTSTEP_COVID_w3_v0001_20211101", clear
rename cw3_* *
gen wave=3
save "NS edited\NS_COVID_w3_v0001_20211101 temp", replace

**APPEND WAVE FILES INTO ONE LONG FILE
use "NS edited\NS_COVID_w1_v0001_20211101 temp", clear
append using "NS edited\NS_COVID_w2_v0001_20211101 temp"
append using "NS edited\NS_COVID_w3_v0001_20211101 temp"


***ADD IN THE ADDITIONAL NS DATA
**Add in demographics
merge m:1 llc_0007_stud_id using "stata_w_labs\NEXTSTEP_basic_demographic_data_v0001_20211101"
tab _merge
drop if _merge==2
drop _merge
**Add in derived 
merge m:1 llc_0007_stud_id using "stata_w_labs\NEXTSTEP_ns8_derived_v0001_20211101"
tab _merge
drop if _merge==2
drop _merge


*****FORMATTING VARIABLES******
***i.sex i.ethnicity_red  i.hm_location i.housing_composition  i.pandemic_timetranche i.deprivation

numlabel, add

***SEX
rename psex sex
tab sex

***ETHNICITY
**single var = ethnic
gen ethnic=w8dethn11
tab ethnic
recode ethnic (1=1) (2=2) (3=2) (4=2) (5=2) (6=2) (7=2) (8=2) (9=2) (10=2) (11=2) (12=2) (13=2) (14=2) (15=2) (16=2) (99=9) (.=9), generate(ethnicity_red)
label define ethnicity_red 1 "White/British" 2 "Other" 9 "Missing", replace
label values ethnicity_red ethnicity_red
tab ethnicity_red, missing

**Age at entry 
**all participants born in a single week during 1989 so all are aged 62

***HOUSEHOLD NUMBERS/COMPOSITION
**hhnum_cw1 hhnum_cw2 hhnum_cw3
**should generate a single var when reshaped
**1"partner+kids" 2"only partner" 3"single parent" 4"other" 5"alone"

label define housing_composition 1 "partner and children" 2 "partner no children" 3 "lone parents" 4 "no partner no children" 5 "alone" 9 "missing", replace

***Generate housing_composition
**partner
tab hhnumwh_1 
tab hhnumwh_2 
tab hhnumwh_3 
tab hhnumwh_4 
tab hhnumwh_5 
tab hhnumwh_6 
tab hhnumwh_7 
tab hhnumwh_8 
tab hhnumwh_9
tab hhnum


gen housing_composition=.
**partner and children
replace housing_composition=1 if hhnumwh_1==1 & hhnumwh_2==2
**partner no children
replace housing_composition=2 if hhnumwh_1==1 & hhnumwh_2==1
**lone parents
replace housing_composition=3 if hhnumwh_1==2 & hhnumwh_2==1
**no partner no children/other 
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_3==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_4==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_5==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_6==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_7==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_8==1
replace housing_composition=4 if hhnumwh_1==2 & hhnumwh_2==2 & hhnumwh_9==1
**Alone
replace housing_composition=5 if hhnum==0
bysort llc_0007_stud_id (wave): replace housing_composition=housing_composition[_n-1] if wave==2 & housing_composition==. & housing_composition[_n-1]!=.
bysort llc_0007_stud_id (wave): replace housing_composition=housing_composition[_n-1] if wave==3 & housing_composition==. & housing_composition[_n-1]!=.

bysort llc_0007_stud_id (wave): replace housing_composition=housing_composition[_n+1] if wave==2 & housing_composition==. & housing_composition[_n+1]!=.
bysort llc_0007_stud_id (wave): replace housing_composition=housing_composition[_n+1] if wave==1 & housing_composition==. & housing_composition[_n+1]!=.
replace housing_composition=9 if housing_composition==.

label values housing_composition housing_composition
tab housing_composition, missing



**REGION
**No indicator of living in urban or rural area


***WAVE DATES
label define wave 1 "May 2020" 2 "Sep/Oct 2020" 3 "Feb/Mar 2021", replace
label values wave wave
rename wave study_wave
tab study_wave


***TRANCHE
gen pandemic_timetranche=study_wave
label var pandemic_timetranche "Time-Tranche H&W version"
label define pandemic_timetranche 1 "Apr20-Jun20" 2 "Jul20-Oct20" 3 "Nov20-Mar21", replace
label values pandemic_timetranche pandemic_timetranche
tab pandemic_timetranche



codebook covid_hospad covid19 covidresult covidtest covid19pos covidincresult covidincwhen covidcurresult covidcurwhen covidpasresult covidpaswhen covidtest_1 covidtest_2 covidtest_3 covidtest_4 outcome, compact

foreach var of varlist covid19 covidresult covidtest covid19pos covidincresult covidincwhen covidcurresult covidcurwhen covidpasresult covidpaswhen covidtest_1 covidtest_2 covidtest_3 covidtest_4 {
	tab `var'
}

***SELF-REPORTED INFECTION 
tab covid19 , missing
recode covid19 (1=1) (2=1) (3=0) (4=0), gen(c19infection_selfreported)
label define c19infection_selfreported 0 "No" 1 "Yes", replace
label values c19infection_selfreported c19infection_selfreported
tab c19infection_selfreported

***SELF-REPORTED POSITIVE TEST 
recode covid19 (1=1) (2=0) (3=0) (4=0), gen(c19postest_selfreported)
label define c19postest_selfreported 0 "No" 1 "Yes", replace
label values c19postest_selfreported c19postest_selfreported
tab c19postest_selfreported


bysort study_wave: tab c19infection_selfreported c19postest_selfreported


***ADD IN OCCUPATIONAL VARS

**SOC 3dig
gen soc2010_3d=floor(w8jobdosoccode/10)
replace soc2010_3d=soc2010cur if soc2010_3d==.
replace soc2010_3d=soc2010 if soc2010_3d==.
label values soc2010_3d cw3_soc2010cur
tab soc2010_3d

*SOC 1 digit
gen soc2010_1d=floor(soc2010_3d/100)
label define soc2010_1d 1 "Managers, Directors, & Senior Off" 2 "Prof Occupations" 3 "Associate Prof & Technical Occup" 4 "Administrative and Secretarial" 5 "Skilled Trades" 6 "Caring, Leisure, and Other Service" 7 "Sales and Customer Serv" 8 "Process, Plant, and Machine Operatives" 9 "Elementary Occupations", replace
label values soc2010_1d soc2010_1d
tab soc2010_1d
bysort llc_0007_stud_id (study_wave): egen seq=seq()
bysort llc_0007_stud_id (study_wave): replace soc2010_1d=soc2010_1d[_n-1] if soc2010_1d==. & seq>1



**SOC 2dig
gen soc2010_2d=floor(soc2010_3d/10)
tab soc2010_2d
label define soc2010_2d 11 "Corporate Managers" 12 "Other Managers and Proprietors in Agriculture and Services" 21 "Science, res, and Tech Prof" 22 "Health Prof" 23 "Teaching and Educa Prof" 24 "Buisness and Public Services Prof" 31 "Science and Tech A-Prof" 32 "Health and Social Welfare A-Prof" 33 "Protective Services" 34 "Culture, Media, Sports Occ" 35 "Buisness and Public Serivces A-Prof" 41 "Administrative Occ" 42 "Secretarial and Related" 51 "Skilled Agricultural Trades" 52 "Skilled Metal and Electrical Trades" 53 "Skilled Construction and Building Trades" 54 "Textiles, Printing, Other skilled Trades" 61 "Caring Personal Services" 62 "Leisure & Other Personal Service Occ" 71 "Sales Occ" 72 "Customer Service" 81  "Process, Plant, and Machine Operative" 82 "Transport, Mobile Macnine Drivers and Operatives" 91 "Elementary Trades, Plant and Storage related Occ" 92 "Elementary Admin and Service Occ", replace 
label values soc2010_2d soc2010_2d
bysort llc_0007_stud_id (study_wave): replace soc2010_2d=soc2010_2d[_n-1] if soc2010_2d==. & seq>1
tab soc2010_2d, missing
drop seq

**SIC??
tab sic3

*gen occupation vars (defined in protocol)
replace soc2010=soc2010cur if soc2010==.
tab soc2010
recode soc2010 (110=9) (111=9) (112=11)	(113=9)	(115=9)	(116=8)	(117=6)	(118=1)	(119=12)	(121=13)	(122=1)	(124=12)	(125=9)	(211=9)	(212=9)	(213=9)	(214=9)	(215=9)	(221=1)	(222=1)	(223=1)	(231=5)	(241=9)	(242=9)	(243=9)	(244=9)	(245=9)	(246=9)	(247=9)	(311=9)	(312=9)	(313=9)	(321=1)	(323=4)	(331=6)	(341=9)	(342=9)	(344=9)	(350=8)	(351=8)	(352=9)	(353=9)	(354=9)	(355=9)	(356=9)	(411=9)	(412=9)	(413=9)	(415=12)	(416=9)	(421=9)	(511=7)	(521=9)	(522=11)	(523=9)	(524=9)	(525=11) (531=9)	(532=9)	(533=9)	(540=9) (541=9)	(542=9)	(543=7)	(544=9)	(612=4)	(613=9)	(614=1)	(621=8)	(622=9)	(623=13)	(624=13)	(711=12)	(712=9)	(713=12) (721=12)	(722=12)	(811=11)	(812=11)	(813=11)	(814=9)	(821=8)	(822=9)	(823=8)	(911=9)	(912=9)	(913=11)	(921=8)	(923=9)	(924=9)	(925=12)	(926=11)	(927=13), gen(occ_full)
label var occ_full "occupation full"
label define occ_full 1 "Health Care Prof" 2 "Other Health care prof" 3 "Medical Support" 4 "Social Care" 5 "Education" 6 "Police & Protection serv" 7 "Food Workers" 8 "Transport workers" 9 "Other workers" 11 "Factory" 12 "Customer serv" 13 "Hospitality" 20 "Missing/Not in work"
label values occ_full occ_full
tab occ_full

bysort llc_0007_stud_id (occ_full): replace occ_full=occ_full[_n-1] if _n>1 & occ_full==.
sort llc_0007_stud_id study_wave
replace occ_full=20 if occ_full==.
tab occ_full


**gen occupation vars (defined in protocol - reduced)
recode occ_full (1=2) (2=2) (3=2) (4=3) (5=3) (6=4) (7=5) (8=5) (9=1) (11=5) (12=5) (13=5) (20=6), gen(occ_red)
label var occ_red "occupation reduced"
label define occ_red 1 "Non-essential workers" 2 "Health Care workers" 3 "Social and Education" 4 "Police and Protective" 5 "Other essential workers" 6 "Missing/not in wrk"
label values occ_red occ_red
tab occ_red


**generate weekly working hours
gen  wk_worhrs=wrkhoursd
replace wk_worhrs=timeuse1_1_1 if wk_worhrs==.
replace wk_worhrs=timeuse_1*5 if wk_worhrs==.
replace wk_worhrs=wrkhoursb if wk_worhrs==.

tab wk_worhrs study_wave


**employment
tab econactivityd
recode econactivityd (1=1) (2=1)  (3=1) (4=1) (5=1) (6=1) (7=0) (8=0) (9=0) (10=0) (11=0) (12=0) (13=0), gen(employed) 
label var employed "Participant employed during COVID"
label define employed 0 "No" 1 "Yes", replace
label values employed employed
tab employed


**employment
tab wk_worhrs
tab econactivityd
tab wk_worhrs if econactivityd==.

recode econactivityd (1=1) (2=1)  (3=1) (4=1) (5=1) (6=1) (7=3) (8=3) (9=3) (10=3) (11=3) (12=2) (13=3), gen(employment) 
replace employment=3 if wk_worhrs<8 & employment==.
replace employment=1 if wk_worhrs>=8 & wk_worhrs!=. & employment==.

label var employment "Participant employment_status during COVID"
label define employment 1 "Employed/looking for work" 2 "Retired" 3 "Unemployed", replace
label values employment employment
tab employment

tab econactivityd employment, missing


**employment_status
tab wk_worhrs
tab econactivityd

recode econactivityd (1=1) (2=3)  (3=3) (4=3) (5=3) (6=1) (7=3) (8=4) (9=4) (10=4) (11=4) (12=2) (13=4), gen(employment_status) 
replace employment_status=1 if wk_worhrs<8 & employment_status==.
replace employment_status=1 if wk_worhrs>=8 & wk_worhrs!=. & employment_status==.
replace employment_status=0 if wk_worhrs>=20 & wk_worhrs!=. & employment_status==1


label var employment_status "Participant employment_status during COVID"
label define employment_status 0 "Full-Time employment" 1 "Part-time employment" 2 "Retired" 3 "Employed but not working" 4 "Unemployed", replace
label values employment_status employment_status
tab econactivityd employment_status



tab employment employment_status, missing

**Key worker 
tab keyworkerd study_wave

recode keyworkerd (1=1) (2=0), gen(key_worker)
label define key_worker 0 "No" 1 "Yes"
label values key_worker key_worker
tab key_worker


**Home working	 
tab wrklocationd study_wave
gen home_working=wrklocationd
replace home_working=4 if study_wave==1 & wrklocationd==3
recode home_working (2=3) (3=2)
label define home_working 1 "Wrk from hm" 2 "Some" 3 "None" 4 "Other", replace
label values home_working home_working
tab home_working

**Furlough - 
tab econactivityd
gen furlough=1 if inlist(econactivityd, 2, 3)
replace furlough=0 if inlist(econactivityd, 1, 5, 6)
replace furlough=2 if furlough==. & econactivityd!=. 
label define furlough 0 "In wrk" 1 "furlough" 2 "other", replace
label values furlough furlough
tab furlough

tab study_wave c19infection_selfreported , row

tab pandemic_timetranche c19infection_selfreported 
tab pandemic_timetranche c19postest_selfreported


**save long version of final NS file
save "NS edited\NS edited long version.dta", replace


***********PREPARE/FORMAT and MERGE NHS TESTING DATA*********************

***************************************	
****MERGING WITH THE NHS TESTING DATA
use "NHS edited\protect_nhs_c19posinfect_temp", clear
count


**drop if within 2 weeks - drops 14,309, leaves 25,125 positive tests
drop if time_sinceprevpos<14 & time_sinceprevpos!=0


***create identification of (BCS1970) wave in nhs infection data
**Three waves pre-"May 2020", May-"Sep/Oct 2020", Nov20-"Feb/Mar 2021"

gen study_wave=1 if testdate<=date("01/05/2020", "DMY")
replace study_wave=2 if testdate>date("01/05/2020", "DMY") & testdate<=date("31/10/2020", "DMY")
replace study_wave=3 if testdate>date("31/10/2020", "DMY") & testdate<=date("30/03/2021", "DMY")
replace study_wave=. if testdate>date("30/03/2021", "DMY")

label define study_wave 1 "pre-April 2020" 2 "May-Sep/Oct 2020" 3 "Nov20-Feb/Mar 2021", replace
label values study_wave study_wave
tab study_wave
bysort study_wave: datesum testdate


drop if study_wave==.
tab source
sort llc_0007_stud_id study_wave

**Look for within wave repeats
bysort llc_0007_stud_id study_wave: egen seq=seq()
tab seq
gen rep_n=seq
gsort llc_0007_stud_id study_wave -seq
by llc_0007_stud_id study_wave: replace rep_n=rep_n[_n-1] if _n>1
tab rep_n
sort llc_0007_stud_id study_wave seq
list llc_0007_stud_id study_wave testdate seq rep_n if rep_n!=1, sepby(llc_0007_stud_id)
*take first pos test
keep if seq==1
drop seq rep_n

**rename occupation var
rename occupation occupation_nhs

tostring avail_from_dt, replace

**save temporay elsa version of nhs infection data
save "NS edited\protect_nhs_c19posinfect_temp_NSver", replace



clear 



****************************************************
**BIB - Study_id==7
****************************************************

cd "S:\LLC_0007\data\"

use "stata_w_labs\BIB_CV_W1_v0001_20220118", clear
count
codebook, compact
use "stata_w_labs\BIB_CV_W2_v0001_20220302", clear
count
codebook, compact
use "stata_w_labs\BIB_SOCIODEMO_v0005_20220913", clear
count
codebook, compact


**atempt to merge these files together - and reduce to no children only
**wave 1 very confusing, doesn't seem to have clear coding structure

use "stata_w_labs\BIB_CV_W1_v0001_20220118", clear
gen study_wave=1
save "bib edited\BIB_CV_W1_v0001_20220118", replace 

use "stata_w_labs\BIB_CV_W2_v0001_20220302", clear
gen study_wave=2

rename c19a2_* *, 
rename *_c19a2 *, 


save "bib edited\BIB_CV_W2_v0001_20220302", replace

use "bib edited\BIB_CV_W1_v0001_20220118", clear
append using "bib edited\BIB_CV_W2_v0001_20220302"
save "bib edited\BIB long ver edited", replace


use "stata_w_labs\BIB_SOCIODEMO_v0005_20220913", clear
duplicates report llc_0007_stud_id

sort llc_0007_stud_id
save "bib edited\BIB_SOCIODEMO_v0005_20220913", replace

use "bib edited\BIB long ver edited", clear
merge m:1 llc_0007_stud_id using "bib edited\BIB_SOCIODEMO_v0005_20220913"
tab _merge
drop _merge

**drop those that were the babies in 2007-10
drop if bib_age_y==0

save "bib edited\BIB long ver edited", replace


****FORMAT VARIABLES FOR ANALYSIS
use "bib edited\BIB long ver edited", clear

**Note covid_ is the wave version, covid10_ is the version at 1st wave repeated across all waves (from ALSPAC wave 0)


**study wave
label define study_wave 1 "Apr-June20" 2 "Oct-Dec20" 3 "May-Jul2021", replace
label values study_wave study_wave
tab study_wave


***TRANCHE
recode study_wave (1=1) (2=2) (3=3), gen(pandemic_timetranche) 
label var pandemic_timetranche "Time-Tranche H&W version"
label define pandemic_timetranche 1 "Apr20-Jun20" 2 "Jul20-Oct20" 3 "Nov20-Mar21", replace
label values pandemic_timetranche pandemic_timetranche
tab pandemic_timetranche

**age_entry 
**gen age in 2020
split partial_dob, gen(birth_mth) parse("-")
rename birth_mth1 birth_year
rename birth_mth2 birth_mth
destring birth_mth birth_year, replace
gen age=2020-birth_year
replace age=age-1 if birth_mth>3
tab age
drop if age>65
tab age
egen age_entry=cut(age), at(1,18,34,44,54,64,74,120) icodes
tab age_entry 
label define age_entry 1 "18-34" 2 "35-44" 3 "45-54" 4 "55-64" 5 "65-74" 6 "75+", replace
label values age_entry age_entry
tab age_entry

**age_entry

**sex/gender
recode bib_sex (0=2) (1=1), gen(sex)
tab sex 
label define sex 1 "Female" 2 "Male", replace
label values sex sex
tab sex


*ethnicity_red
tab bib_eth16cat
replace ethnicity=bib_eth16cat
label values ethnicity bib_eth16cat
tab ethnicity

gen ethnicity_red=1 if ethnicity<=3
replace ethnicity_red=3 if inlist(ethnicity,8,9,10)
replace ethnicity_red=2 if ethnicity_red==. & ethnicity!=. 
replace ethnicity_red=9 if ethnicity_red==.
label define ethnicity_red 1 "White/British" 2 "Other" 3 "Indian/Pakistani/Bangladeshi" 9 "Missing", replace
label values ethnicity_red ethnicity_red
tab ethnicity_red, missing


tab bib_cv1_occ_count 
tab bib_cv2_occ_count 
tab cc_living 
tab hh_living
tab hh_nadult 
tab hh_nchild 
tab hh_nchild_04 
tab hh_nchild_1116 
tab hh_nchild_510 
tab hh_living 

*household_size 
gen household_size=bib_cv1_occ_count 
replace household_size=bib_cv2_occ_count if household_size==.
tab household_size
*housing_composition 
label define housing_composition 1 "partner and children" 2 "partner no children" 3 "lone parents" 4 "no partner no children" 5 "alone" 9 "missing", replace

gen housing_composition=1 if hh_living==1 & hh_nchild==1
replace housing_composition=2 if hh_living==1 & hh_nchild==0
replace housing_composition=2 if hh_living==0 & hh_nchild==1
replace housing_composition=4 if hh_living==0 & hh_nchild==0 & household_size>0
replace housing_composition=5 if hh_living==0 & hh_nchild==0 & household_size==0
replace housing_composition=9 if housing_composition==.
label values housing_composition housing_composition
tab housing_composition

*housing_tenure 
label define housing_tenure 1 "Own" 2 "Rent" 3 "Missing", replace
recode yh_own (1=1) (2=1) (3=1) (4=2) (5=2) (6=2) (.=3), gen(housing_tenure)
label values housing_tenure housing_tenure
tab housing_tenure

*education 
tab bib_highest_qual
gen education=bib_highest_qual
*label define education 0 "qualifications" 1 "No Qualifications" 3 "Missing", replace
*label values education education
recode education (7=5) (6=5) 
label values education bib_highest_qual
tab education

*vaccination_status 
*label var vaccination_status "No Vaccine Doses 3rd Wave"


foreach var of varlist bib_cv1_emp_status bib_cv2_emp_status bib_emp_status bib_employment_type bib_gu_employment_type {
	tab `var'
}

*furlough 
tab bib_cv1_emp_status  
tab bib_cv2_emp_status
codebook bib_cv1_emp_status bib_cv2_emp_status

gen furlough=1 if bib_cv1_emp_status==2 
replace furlough=1 if bib_cv2_emp_status==2 & study_wave==2
replace furlough=0 if bib_cv1_emp_status!=2 & bib_cv1_emp_status!=. & study_wave==1
replace furlough=0 if bib_cv2_emp_status!=2 & bib_cv2_emp_status!=. & study_wave==2
tab furlough
label define furlough 0 "No" 1 "Yes", replace
label values furlough furlough
tab furlough


*key_worker 
codebook jbsc_kwrker_myself bib_cv1_key_worker
tab jbsc_kwrker_myself study_wave 
tab bib_cv1_key_worker study_wave
gen keyworker=1 if jbsc_kwrker_myself==1 
replace keyworker=1 if bib_cv1_key_worker==1
replace keyworker=0 if keyworker==. & jbsc_kwrker_myself!=. 
replace keyworker=0 if keyworker==. & bib_cv1_key_worker!=.
tab keyworker cohort
label define keyworker 0 "No" 1 "Yes", replace
label values keyworker keyworker
tab keyworker



foreach var of varlist bib_cv1_emp_status bib_cv2_emp_status bib_emp_status bib_employment_type bib_gu_employment_type {
	tab `var'
}

numlabel, add
tab bib_cv1_emp_status 
tab bib_cv2_emp_status

*employment 
gen employment=1 if inlist(bib_cv1_emp_status,1,2,3,4) & study_wave==1
replace employment=1 if inlist(bib_cv2_emp_status,1,2,3,4,5) & study_wave==2
replace employment=3 if bib_cv1_emp_status==5 & study_wave==1
replace employment=3 if bib_cv1_emp_status==6 & study_wave==2
replace employment=1 if bib_emp_status==1 & employment==.
replace employment=3 if bib_emp_status==2 & employment==.
replace employment=4 if employment==.
label define employed 1 "Yes" 2 "Retired" 3 "Unemployed" 4 "Unknown", replace
label values employment employed
tab employment
replace employment=. if employment==4

*employment_status 
gen employment_status=0 if employment==1
replace employment_status=3 if bib_cv1_emp_status==2
replace employment_status=3 if bib_cv1_emp_status==4
replace employment_status=3 if bib_cv2_emp_status==2 & study_wave==2
replace employment_status=3 if bib_cv2_emp_status==3 & study_wave==2
replace employment_status=3 if bib_cv2_emp_status==5 & study_wave==2
replace employment_status=4 if employment==3
replace employment_status=. if bib_cv1_timestamp=="" & bib_cv2_timestamp=="" 
label define employment_status 0 "Full-Time employment" 1 "Part-time employment" 2 "Retired" 3 "Employed but not working" 4 "Unemployed", replace
label values employment_status employment_status
tab employment_status



*home_working 
tab jbsc_main_hmwfh employment, missing
gen home_working=1 if jbsc_main_hmwfh==1
replace home_working=3 if jbsc_main_hmwfh==2
label define home_working 1 "Wrk from hm" 2 "Some" 3 "None" 4 "Other", replace
label values home_working home_working
tab home_working


*c19infection_selfreported - note for alspac question is have ever had, not since last wave have you had?

foreach var of varlist cv_wt_expsymp cv_wt_sympwhn   {
	tab `var'
}


**Date is messy, clean up
tab cv_wt_sympwhn 
gen covid_date=cv_wt_sympwhn
replace covid_date=subinstr(covid_date,".","/",.)
replace covid_date=subinstr(covid_date,"-","/",.)
replace covid_date="16/02/2020" if covid_date=="16022020"
replace covid_date="20/02/2020" if covid_date=="200220"
replace covid_date="25/09/2020" if covid_date=="25 September 2020"
replace covid_date="21/09/2020" if covid_date=="September 21st 2020"
replace covid_date="07/07/2020" if covid_date=="07/07"
replace covid_date="08/11/2020" if covid_date=="0811/20"
replace covid_date="01/01/2020" if covid_date=="Jan was very poorly but not much info about it then"
replace covid_date=subinstr(covid_date,"/20","/2020",.)
replace covid_date=subinstr(covid_date,"/202020","/2020",.)
replace covid_date=subinstr(covid_date,"/202019","/2019",.)
replace covid_date=subinstr(covid_date,"/19","/2019",.)
replace covid_date=subinstr(covid_date,"21/2019/2020","21/02/2020",.)
replace covid_date=subinstr(covid_date,"sometime in ","",.)
replace covid_date=subinstr(covid_date,"mid ","",.)
replace covid_date=subinstr(covid_date," soon after lockdown","",.)
replace covid_date=subinstr(covid_date,"in","",.)
replace covid_date=subinstr(covid_date,"End of","",.)
replace covid_date=subinstr(covid_date,"end of","",.)
replace covid_date=subinstr(covid_date,"September early October", "October 2020", .)
replace covid_date=subinstr(covid_date,"feb 2020 / start march 2020", "March 2020",.) 
replace covid_date=subinstr(covid_date,"march/begng of april", "April 2020",.)
replace covid_date=subinstr(covid_date,"nov/dec", "December",.)
replace covid_date=subinstr(covid_date,"March 20th", "20/03/2020",.)
replace covid_date=subinstr(covid_date,"April/May", "May",.)
replace covid_date=subinstr(covid_date,"Aug/Sept", "Sept",.)
replace covid_date=subinstr(covid_date,"October time", "October 2020",.)
tab covid_date

split covid_date, p("/" " ")
replace covid_date3=covid_date2 if covid_date2=="2020" | covid_date2=="2019" | covid_date2=="20"
replace covid_date2=covid_date1 if covid_date2=="2020" | covid_date2=="2019" | covid_date2=="20"
replace covid_date3="2020" if covid_date3=="20"
replace covid_date3="2020" if covid_date3=="" & covid_date!=""
replace covid_date2=covid_date1 if covid_date2==""
replace covid_date2="" if covid_date2=="a"
replace covid_date2="" if covid_date2=="know"
drop covid_date1
rename covid_date2 covid_date_mth
rename covid_date3 covid_date_yr
replace covid_date_mth="January" if covid_date_mth=="01"
replace covid_date_mth="Feburary" if covid_date_mth=="02"
replace covid_date_mth="March" if covid_date_mth=="03"
replace covid_date_mth="March" if covid_date_mth=="3"
replace covid_date_mth="April" if covid_date_mth=="04"
replace covid_date_mth="April" if covid_date_mth=="4"
replace covid_date_mth="May" if covid_date_mth=="05"
replace covid_date_mth="June" if covid_date_mth=="06"
replace covid_date_mth="July" if covid_date_mth=="07"
replace covid_date_mth="August" if covid_date_mth=="08"
replace covid_date_mth="August" if covid_date_mth=="8"
replace covid_date_mth="September" if covid_date_mth=="09"
replace covid_date_mth="October" if covid_date_mth=="10"
replace covid_date_mth="November" if covid_date_mth=="11"
replace covid_date_mth="December" if covid_date_mth=="12"

replace covid_date_mth="Feburary" if covid_date_mth=="feb" | covid_date_mth=="Feb" 
replace covid_date_mth="September" if covid_date_mth=="sept" | covid_date_mth=="Sept"
replace covid_date_mth="November" if covid_date_mth=="nov" | covid_date_mth=="Nov"
replace covid_date_mth="December" if covid_date_mth=="dec" | covid_date_mth=="Dec"

replace covid_date_mth=proper(covid_date_mth)

encode covid_date_mth, gen(covid_date_mth2) label(covid_date_mth2) 
numlabel, add detail 
tab covid_date_mth covid_date_yr
tab covid_date_mth2

tab cv_wt_expsymp  
tab study_wave

bysort llc_0007_stud_id (study_wave): replace covid_date_mth2=covid_date_mth2[_n+1] if covid_date_mth2==. & study_wave==1 
bysort llc_0007_stud_id (study_wave): replace covid_date_yr=covid_date_yr[_n+1] if covid_date_yr=="" & study_wave==1 
bysort llc_0007_stud_id (study_wave): replace cv_wt_expsymp=cv_wt_expsymp[_n+1] if cv_wt_expsymp==. & study_wave==1 

gen c19infection_selfreported=1 if inlist(covid_date_mth2,1,4,5,7,8,9) & covid_date_yr=="2020" & study_wave==1
replace c19infection_selfreported=1 if cv_wt_expsymp<4 & covid_date_yr=="2019" & study_wave==1
replace c19infection_selfreported=1 if cv_wt_expsymp<4 & inlist(covid_date_mth2,2,3,6,10,11,12) & covid_date_yr=="2020" & study_wave==2
replace c19infection_selfreported=1 if cv_wt_expsymp<4 & c19infection_selfreported==.


replace c19infection_selfreported=0 if cv_wt_expsymp==4 & c19infection_selfreported==.
**assumes those not reporting an infection but took part in survey were not self-reported infection
replace c19infection_selfreported=0 if c19infection_selfreported==. & bib_cv1_timestamp!="" | c19infection_selfreported==. & bib_cv2_timestamp!="" 

tab c19infection_selfreported
label define c19infection_selfreported 0 "No" 1 "Yes", replace
label values c19infection_selfreported c19infection_selfreported
tab c19infection_selfreported

*c19postest_selfreported
gen c19postest_selfreported=1 if c19infection_selfreported==1 & cv_wt_expsymp==1
replace c19postest_selfreported=0 if c19postest_selfreported==. & c19infection_selfreported!=.
tab c19postest_selfreported
label define c19postest_selfreported 0 "No" 1 "Yes", replace
label values c19postest_selfreported c19postest_selfreported
tab c19postest_selfreported

replace cohort=1 if c19infection_selfreported!=.

save "bib edited\BIB edited long version.dta", replace 



***********PREPARE/FORMAT and MERGE NHS TESTING DATA*********************

***************************************	
****MERGING WITH THE NHS TESTING DATA
use "NHS edited\protect_nhs_c19posinfect_temp", clear
count
ssc install datesum


**drop if within 2 weeks - drops 14,309, leaves 25,125 positive tests
drop if time_sinceprevpos<14 & time_sinceprevpos!=0


***create identification of (alspac) wave in nhs infection data
**Three waves pre-"May 2020", May-"June 2020", Jul-"Oct 20", Nov20-"Feb/Mar 2021"

gen study_wave=1 if testdate<date("01/07/2020", "DMY")
replace study_wave=2 if testdate>=date("01/07/2020", "DMY") & testdate<=date("01/01/2021", "DMY")

label define study_wave 1 "pre-july 2020" 2 "May-Dec 2020", replace
label values study_wave study_wave
tab study_wave
bysort study_wave: datesum testdate

gen testmonth=month(testdate)
gen testyear=year(testdate)

drop if study_wave==.
tab source
sort llc_0007_stud_id study_wave testyear testmonth

**Look for within wave repeats
bysort llc_0007_stud_id study_wave: egen seq=seq()
tab seq
gen rep_n=seq
gsort llc_0007_stud_id study_wave -seq
by llc_0007_stud_id study_wave: replace rep_n=rep_n[_n-1] if _n>1
tab rep_n
sort llc_0007_stud_id study_wave seq
list llc_0007_stud_id study_wave testdate seq rep_n if rep_n!=1, sepby(llc_0007_stud_id)
*take first pos test
keep if seq==1
drop seq rep_n

**rename occupation var
rename occupation occupation_nhs

tostring avail_from_dt, replace

**save temporay elsa version of nhs infection data
save "bib edited\protect_nhs_c19posinfect_temp_bibver", replace

clear 


*****************************************
**GENERATION SCOTLAND - Study_id==8
*****************************************
cd "S:\LLC_0007\data\"


use "stata_w_labs\GENSCOT_COVIDLIFE1_v0001_20211101", clear
count
codebook, compact
use "stata_w_labs\GENSCOT_COVIDLIFE2_v0001_20211101", clear
count
codebook, compact
use "stata_w_labs\GENSCOT_COVIDLIFE3_v0001_20211101", clear
count
codebook, compact
use "stata_w_labs\GENSCOT_DEMOGRAPHICS_v0001_20211101", clear
count
codebook, compact
use "stata_w_labs\GENSCOT_DISEASE_v0001_20211101", clear
count
codebook, compact
use "stata_w_labs\GENSCOT_ETHNIC_v0001_20211101", clear
count
codebook, compact
use "stata_w_labs\GENSCOT_HOUSEHOLD_v0001_20211101", clear
count
codebook, compact
use "stata_w_labs\GENSCOT_OCCUPATION_v0001_20211101", clear
count
codebook, compact
use "Genscot edited\Genscot edited long version.dta", clear 
count
codebook, compact

***Using coded data from REAL
use "Genscot edited\Genscot edited long r version.dta", clear 
count
codebook, compact


**formate wave date which didnt match between R and stata
tostring study_wave_date, replace
replace study_wave_date="Apr 2020" if study_wave==1
replace study_wave_date="Jul 2020" if study_wave==2
replace study_wave_date="Feb 2021" if study_wave==3
tab study_wave_date

**rename LLC_0007_stud_id 
rename LLC_0007_stud_id llc_0007_stud_id

bysort llc_0007_stud_id study_wave: egen seq=seq()
tab seq
gsort llc_0007_stud_id study_wave -seq
by llc_0007_stud_id study_wave: gen count=seq if _n==1
by llc_0007_stud_id study_wave: replace count=count[_n-1] if _n>1 & count==.
tab count seq
sort llc_0007_stud_id study_wave seq
list llc_0007_stud_id study_wave age sex education household_size vaccination_status c19infection_selfreported c19postest_selfreported seq count if count>1, sepby(llc_0007_stud_id) 

count
collapse (firstnm) cohort_id study_wave_date pandemic_timetranche age age_entry sex ethnicity ethnicity_red household_size housing_composition housing_tenure education vaccination_status key_worker furlough employment employment_status home_working c19infection_selfreported c19postest_selfreported seq count, by(llc_0007_stud_id study_wave)
count 

drop seq count

***WAVE DATES
label define study_wave 1 "May 2020" 2 "July 2020" 3 "Feb/Mar 2021", replace
label values study_wave study_wave 
tab study_wave


***TRANCHE
label var pandemic_timetranche "Time-Tranche H&W version"
label define pandemic_timetranche 1 "Apr20-Jun20" 2 "Jul20-Oct20" 3 "Nov20-Mar21", replace
label values pandemic_timetranche pandemic_timetranche
tab pandemic_timetranche


**age_entry 
tab age_entry 
label define age_entry 1 "18-34" 2 "35-44" 3 "45-54" 4 "55-64" 5 "65-74" 6 "75+", replace
label values age_entry age_entry
tab age_entry

**sex
tab sex 
destring sex, replace
label define sex 1 "Female" 2 "Male", replace
label values sex sex
tab sex

*ethnicity 
tab ethnicity
label define ethnicity 1 "White" 2 "Mixed" 3 "South Asian" 4 "Black"  5 "Other Asian" 6 "Other" 7 "Missing" , replace
label values ethnicity ethnicity
tab ethnicity, missing
replace ethnicity=7 if ethnicity==.


*ethnicity_red 
label define ethnicity_red 1 "White/British" 2 "Other" 9 "Missing", replace
label values ethnicity_red ethnicity_red
recode ethnicity_red (3=2) 
tab ethnicity_red, missing

*household_size 
tab household_size
*housing_composition 
label define housing_composition 1 "partner and children" 2 "partner no children" 3 "lone parents" 4 "no partner no children" 5 "alone" 9 "missing", replace
label values housing_composition housing_composition
tab housing_composition

*housing_tenure 
tab housing_tenure
recode housing_tenure (. = 3)
label define housing_tenure 1 "Own" 2 "Rent" 3 "Missing", replace
label values housing_tenure housing_tenure
tab housing_tenure, missing

*education 
tab education
label define education 0 "<degree" 1 "degree+" 3 "Missing", replace
label values education education
tab education

*vaccination_status 
tab vaccination_status
label var vaccination_status "No Vaccine Doses 3rd Wave"

*furlough 
recode furlough (97=.) (98=.) (99=.)
tab furlough
label define furlough 0 "No" 1 "Yes", replace
label values furlough furlough
tab furlough


*key_worker 
tab key_worker
label define key_worker 0 "No" 1 "Yes", replace
label values key_worker key_worker
tab key_worker
rename key_worker keyworker


*employment 
tab employment
label define employed 1 "Yes" 2 "Retired" 3 "Unemployed" 4 "Unknown", replace
label values employment employed
tab employment
replace employment=. if employment==4


*employment_status 
tab employment_status
label define employment_status 0 "Full-Time employment" 1 "Part-time employment" 2 "Retired" 3 "Employed but not working" 4 "Unemployed", replace
label values employment_status employment_status
tab employment_status



*home_working 
label define home_working 1 "Wrk from hm" 2 "Some" 3 "None" 4 "Other", replace
label values home_working home_working
tab home_working

*c19infection_selfreported 
tab c19infection_selfreported
label define c19infection_selfreported 0 "No" 1 "Yes", replace
label values c19infection_selfreported c19infection_selfreported
tab c19infection_selfreported
*c19postest_selfreported
tab c19postest_selfreported
label define c19postest_selfreported 0 "No" 1 "Yes", replace
label values c19postest_selfreported c19postest_selfreported
tab c19postest_selfreported




save "Genscot edited\Genscot edited long version.dta", replace 





***********PREPARE/FORMAT and MERGE NHS TESTING DATA*********************

***************************************	
****MERGING WITH THE NHS TESTING DATA
use "NHS edited\protect_nhs_c19posinfect_temp", clear
count
ssc install datesum


**drop if within 2 weeks - drops 14,309, leaves 25,125 positive tests
drop if time_sinceprevpos<14 & time_sinceprevpos!=0


***create identification of (BCS1970) wave in nhs infection data
**Three waves pre-"May 2020", May-"Sep/Oct 2020", Nov20-"Feb/Mar 2021"

gen study_wave=1 if testdate<=date("01/05/2020", "DMY")
replace study_wave=2 if testdate>date("01/05/2020", "DMY") & testdate<=date("31/10/2020", "DMY")
replace study_wave=3 if testdate>date("31/10/2020", "DMY") & testdate<=date("30/03/2021", "DMY")
replace study_wave=. if testdate>date("30/03/2021", "DMY")

label define study_wave 1 "pre-April 2020" 2 "May-Sep/Oct 2020" 3 "Nov20-Feb/Mar 2021", replace
label values study_wave study_wave
tab study_wave
bysort study_wave: datesum testdate


drop if study_wave==.
tab source
sort llc_0007_stud_id study_wave

**Look for within wave repeats
bysort llc_0007_stud_id study_wave: egen seq=seq()
tab seq
gen rep_n=seq
gsort llc_0007_stud_id study_wave -seq
by llc_0007_stud_id study_wave: replace rep_n=rep_n[_n-1] if _n>1
tab rep_n
sort llc_0007_stud_id study_wave seq
list llc_0007_stud_id study_wave testdate seq rep_n if rep_n!=1, sepby(llc_0007_stud_id)
*take first pos test
keep if seq==1
drop seq rep_n

**rename occupation var
rename occupation occupation_nhs

tostring avail_from_dt, replace

**save temporay elsa version of nhs infection data
save "Genscot edited\protect_nhs_c19posinfect_temp_Genscotver", replace



clear 


******************************************************************************
**THE EXTENDED COHORT FOR E-HEALTH, ENVIRONMENT, AND DNA (EXCEED) - Study_id==9
**waiting for formating of files
******************************************************************************

cd "S:\LLC_0007\data\"

use "stata_w_labs\EXCEED_covid19survey_v0001_20211101", clear
count
codebook, compact

use "stata_w_labs\EXCEED_DemographicCore_v0001_20211101", clear
count
duplicates report llc_0007_stud_id
codebook, compact
use "stata_w_labs\EXCEED_occupation_v0001_20210723", clear
count
duplicates report llc_0007_stud_id
codebook, compact

***combine study data together
use "stata_w_labs\EXCEED_covid19survey_v0001_20211101", clear
split covid19survey_timestamp, parse(" ")
drop covid19survey_timestamp2
replace covid19survey_timestamp1=subinstr(covid19survey_timestamp1,"-","/",.)
gen survey_date=date(covid19survey_timestamp1,"YMD",2020)
format %tdDD/NN/CCYY survey_date
duplicates drop llc_0007_stud_id survey_date, force

label var covid19survey_timestamp "time when the participant submitted the questionnaire"
label var s1_0a_exceed "Leading up to the Covid-19 pandemic, would you say that your physical health was generally:"
label var s1_0b_exceed "Leading up to the Covid-19 pandemic, would you say that your mental health was generally:"
*label var s1_1b "Decrease in appetite"
*label var s1_1c "Nausea and/or vomiting"
*label var s1_1d "Diarrhoea"
*label var s1_1e "Abdominal pain/tummy ache"
*label var s1_1f "Runny nose"
*label var s1_1g "Sneezing"
*label var s1_1h "Blocked nose"
*label var s1_1i "Sore eyes"
*label var s1_1j "Loss of sense of smell"
*label var s1_1k "Loss of sense of taste"
*label var s1_1l "Sore throat"
*label var s1_1m "Hoarse voice"
*label var s1_1n "Headache (if more often or worse than usual)"
*label var s1_1o "Dizziness"
*label var s1_1p "Shortness of breath affecting normal activities"
*label var s1_1q "New  persistent cough"
*label var s1_1r "Tightness in the chest"
*label var s1_1s "Chest pain"
*label var s1_1t "Fever (feeling too hot)"
*label var s1_1u "Chills (feeling too cold)"
*label var s1_1v "Difficulty sleeping"
*label var s1_1w "Felt more tired than normal"
*label var s1_1x "Severe fatigue (e.g. inability to get out of bed)"
*label var s1_1y "Numbness or tingling somewhere in the body"
*label var s1_1z "Feeling of heaviness in arms or legs"
*label var s1_1aa "Achy muscles"
*label var s1_1a "No symptoms at all"
label var s1_2a "When did the <u>first</u> one start?"
label var s1_2b "When did the <u>last</u> one finish?"
label var s1_2c "In the <u>last week</u>, have you had shortness of breath (difficulty breathing)?"
label var s1_2d "<p>Did you seek medical attention for the symptoms you had in the <u>last week</u>?</p>"
*label var s1_2e "If yes, what kind of medical attention did you access?"
*label var s1_2f_exceed "Did you take any medication to treat your symptoms?"
label var s1_3a "In the <u>last week</u>, have you had your temperature taken?"
label var s1_3b "Who took your temperature?"
label var s1_4 "Have you been in close contact with anyone with COVID-19 in the last <u>two weeks</u>?"
label var s1_5a "Do you think that you have or have had COVID-19?"
*label var s1_6a1_17 "<div class=rich-text-field-label><p>Are you, or do you, currently have any of the following? <span style=font-weight: normal;>(tick all that apply)</span></p></div>"
label var s1_6c "<div class=rich-text-field-label><p><span style=font-weight: normal;>Have you been contacted by letter or text message to say you are <strong>at severe risk from COVID-19 due to an underlying health condition</strong> and should be shielding?</span></p></div>"
label var s1_7a "In general, do you have health problems that require you to limit your activities?"
label var s1_7b "Do you need someone to help you on a regular basis?"
label var s1_7c "In general, do you have any health problems that require you to stay at home?"
label var s1_7d "If you need help, can you count on someone close to you?"
label var s1_7e "Do you regularly use a stick, walker or wheelchair to move about?"
label var s1_8 "Do you currently take any regular medication?"
label var s1_8a_exceed_m1_another "Do you take another medication?"
label var s1_8a_exceed_m2_another "Do you take another medication?"
label var s1_8a_exceed_m3_another "Do you take another medication?"
label var s1_8a_exceed_m4_another "Do you take another medication?"
label var s1_8a_exceed_m5_another "Do you take another medication?"
label var s1_8a_exceed_m6_another "Do you take another medication?"
label var s1_8a_exceed_m7_another "Do you take another medication?"
label var s1_8a_exceed_m8_another "Do you take another medication?"
label var s1_8a_exceed_m9_another "Do you take another medication?"
label var s1_8a_exceed_m10_another "Do you take another medication?"
label var s1_8a_exceed_m11_another "Do you take another medication?"
label var s1_8a_exceed_m12_another "Do you take another medication?"
label var s1_9 "<div class=rich-text-field-label><p>Have you had a flu jab in the last 12 months?</p></div>"
label var s1_9_exceed_1 "Do you usually bring up phlegm/sputum/mucus from the lungs, or do you usually feel like you have mucus in your lungs that is difficult to bring up, when you don't have a cold?"
label var s1_9_exceed_2 "If it is feasible for us to send you a kit to collect a finger-prick blood sample at home to do a research test for immunity to COVID, would you be willing to provide such a sample?"
label var s1_10a "Little interest or pleasure in doing things"
label var s1_10b "Feeling down, depressed, or hopeless?"
label var s1_10c "Trouble falling or staying asleep, or sleeping too much?"
label var s1_10d "Feeling tired or having little energy?"
label var s1_10e "Poor appetite or overeating?"
label var s1_10f "Feeling bad about yourself - or that you are a failure or have let yourself or your family down?"
label var s1_10g "Trouble concentrating on things, such as reading the newspaper or watching television?"
label var s1_10h "Moving or speaking so slowly that other people could have noticed? Or the opposite - being so fidgety or restless that you have been moving around a lot more than usual?"
label var s1_11a "Feeling nervous, anxious or on edge?"
label var s1_11b "Not being able to stop or control worrying?"
label var s1_11c "Worrying too much about different things?"
label var s1_11d "Trouble relaxing?"
label var s1_11e "Being so restless that it is hard to sit still?"
label var s1_11f "Becoming easily annoyed or irritable?"
label var s1_11g "Feeling afraid as if something awful might happen?"
*label var s2_1 "<div class=rich-text-field-label><p>Since COVID-19 emerged in January, but <u>before</u> the official lockdown started on March 23rd 2020, did you change your behaviour by doing any of the following? <em>[tick all that apply]</em></p></div>"
label var s2_2a "Amount you sleep"
label var s2_2b "Amount you smoke/vape"
label var s2_2c "Amount of alcohol you drink"
label var s2_2d "Number of hours you work in usual workplace"
label var s2_2e "Number of hours you work at home"
label var s2_2f "Time spent talking to family/friends inside my home"
label var s2_2g "Time spent talking to family/friends outside my home"
label var s2_2h "Time spent talking to work colleagues"
label var s2_2i "Practising relaxation/mindfulness/meditation"
label var s2_2j "Time spent listening to the news on radio or TV"
label var s2_2k "Time spent using other devices with a screen"
label var s2_2l "Time spent doing hobbies/things I enjoy"
label var s2_2m "Amount of fruit you eat"
label var s2_2n "Amount of vegetables you eat"
label var s2_2o "Amount of meat you eat"
label var s2_2p "Amount of fish you eat"
label var s2_2q "Amount of dairy products you eat (e.g. milk, cheese, eggs)"
label var s2_2r "Number of savoury snacks you eat"
label var s2_2s "Number of sweet snacks and confectionery you eat"
label var s2_2t "Amount of other fast food you eat"
label var s2_2u "Amount of sugar sweetened drinks (including tea) you drink"
label var s2_2v "Amount of money you've spent"
label var s2_2w "Amount of physical activity/exercise you do"
label var s2_2x "Time spent travelling on public transport"
label var s2_2y "Time spent travelling in a car"
label var s2_2z "Time spent travelling on a bike"
label var s2_2aa "Time spent outdoors in the open air (e.g. spending time in the garden, in a park, walking, jogging, other sport)"
label var s2_4a_exceed "Do you have children under the age of 18 living in the same household as you?"
label var s2_4a "Amount they sleep"
label var s2_4b "Amount of physical activity/exercise they do"
label var s2_4c "Time they spend learning in the house (including home schooling)"
label var s2_4d "Time they spend playing inside the house"
label var s2_4e "Amount of time they spend outside the home"
label var s2_4f "Amount of time they spend in green spaces such as parks or gardens"
label var s2_4g "Time spent using devices with a screen"
label var s2_4h "Amount of fruits they eat"
label var s2_4i "Amount of vegetables they eat"
label var s2_4j "Amount of meat they eat"
label var s2_4k "Amount of fish they eat"
label var s2_4l "Amount of dairy product they eat (e.g. milk, cheese and eggs)"
label var s2_4m "Amounts of savoury snacks they eat"
label var s2_4n "Amount of sweets, pastry, ice-cream they eat"
label var s2_4o "Amount of other fast-foods they eat"
label var s2_4p "Amount of sugar sweetened beverage including tea they drink"
label var s2_4q "Time spent outdoors in in the open air (e.g. spending time in the garden, in a park, walking, jogging, other sport)"
label var s2_5 "Do you have one or more children in full time education? Include school or college courses and includes children who are schooled at home "
label var s2_6a "My youngest child"
label var s2_6b "My second youngest child"
label var s2_6c "My third youngest child"
label var s2_6d "My fourth youngest child"
label var s2_6e "Any other children"
label var s2_7a "My youngest child"
label var s2_7b "My second youngest child"
label var s2_7c "My third youngest child"
label var s2_7d "My fourth youngest child"
label var s2_7e "Any other children"
*label var s2_8a "My youngest child"
*label var s2_8b "My second youngest child"
*label var s2_8c "My third youngest child"
*label var s2_8d "My fourth youngest child"
*label var s2_8e "Any other children"
label var s2_9 "Do you find the official UK Government guidance on COVID-19 easy to understand?"
label var s2_10 "How would you rate your knowledge about COVID-19?"
label var s3_1 "<div class=rich-text-field-label><p><u>Before</u> the official lockdown was announced on the 23rd March 2020, how well would you say you personally were managing financially?</p></div>"
label var s3_2 "<div class=rich-text-field-label><p>Overall, how do you feel your current financial situation compares to <span style=text-decoration: underline;>before</span> the official lockdown was announced on the 23rd March 2020?</p></div>"
label var s3_3 "I'm worried about my future financial situation"
label var s3_4 "Which of the following statements best describes the food eaten in your household in the last week?"
label var s3_5 "I'm worried about my job security"
label var s3_6 "I'm worried about my partner's job security"
label var s3_7 "<div class=rich-text-field-label><p>Which of these best describes what you were doing just before the lockdown on the 23rd March 2020? <br /><br /><em><span style=font-weight: normal;>If you were doing more than one activity, please choose the activity that you spent most time doing.</span></em></p></div>"
label var s3_8 "Which of these would you say best describes YOUR current situation now?"
label var s3_9 "<div class=rich-text-field-label><p><a style=mso-comment-reference: 'GAL\(_1'; mso-comment-date: 20200506T1522;><strong style=mso-bidi-font-weight: normal;><span style=font-size: 11.0pt; line-height: 107%; font-family: 'Calibri',sans-serif; mso-ascii-theme-font: minor-latin; mso-fareast-font-family: Calibri; mso-hansi-theme-font: minor-latin; mso-bidi-font-family: 'Times New Roman'; mso-bidi-theme-font: minor-bidi; mso-ansi-language: EN-GB; mso-fareast-language: EN-US; mso-bidi-language: AR-SA;>Are you currently fulfilling any of the governmentâ€™s identified â€˜essential workerâ€™ roles?</span></strong></a></p></div>"
label var s3_10 "<div class=rich-text-field-label><p>What sector do you work in?<br /><br /><br /></p></div>"
label var s3_11 "Does your work require you to be in close contact (i.e. within 2 metres) with others, who you do not live with, including while travelling to work? "
label var s3_12 "In your workplace, does your employer provide you with necessary personal protective equipment (PPE)?"
label var s3_12_exceed "In your workplace, do you provide your own personal protective equipment (PPE)?"
label var s3_13 "<div class=rich-text-field-label><p><span style=text-decoration: underline;>If you have a partner</span>, which of these best describes what <span style=text-decoration: underline;>your partner</span> was doing just before the lockdown on the 23rd March 2020?</p> <p><span style=font-weight: normal;><em>If they were doing more than one activity, please choose the activity that they spent most time doing.</em></span></p></div>"
label var s3_14 "<div class=rich-text-field-label><p><span style=text-decoration: underline;>If you have a partner</span>, which of these would you say best describes <span style=text-decoration: underline;>your partner's</span> current situation, now?</p></div>"
*label var s4_1 "Has your living arrangement changed because of the COVID-19 pandemic?"
label var s4_2_i "How often do you feel you lack companionship?"
label var s4_2_ii "How often do you feel left out?"
label var s4_2_iii "How often do you feel isolated from others?"
label var s4_2_iv "How often do you feel alone?"
label var s4_3_i "How often did you feel you lacked companionship?"
label var s4_3_ii "How often did you feel left out?"
label var s4_3_iii "How often did you feel isolated from others?"
label var s4_3_iv "How often did you feel alone?"
label var s4_4_n1 "What best describes your relationship to this person?"
label var s4_6_n1 "In the past week, how would you describe the quality of your relationship with this person?"
label var s4_7_n1 "How would you describe the quality of your relationship with this person before the lockdown (23rd March 2020)?"
label var s4_7exceed_n1 "Do you live with another person?"
label var s4_4_n2 "What best describes your relationship to this person?"
label var s4_6_n2 "In the past week, how would you describe the quality of your relationship with this person?"
label var s4_7_n2 "How would you describe the quality of your relationship with this person before the lockdown (23rd March 2020)?"
label var s4_7exceed_n2 "Do you live with another person?"
label var s4_4_n3 "What best describes your relationship to this person?"
label var s4_6_n3 "In the past week, how would you describe the quality of your relationship with this person?"
label var s4_7_n3 "How would you describe the quality of your relationship with this person before the lockdown (23rd March 2020)?"
label var s4_7exceed_n3 "Do you live with another person?"
label var s4_4_n4 "What best describes your relationship to this person?"
label var s4_6_n4 "In the past week, how would you describe the quality of your relationship with this person?"
label var s4_7_n4 "How would you describe the quality of your relationship with this person before the lockdown (23rd March 2020)?"
label var s4_7exceed_n4 "Do you live with another person?"
label var s4_4_n5 "What best describes your relationship to this person?"
label var s4_6_n5 "In the past week, how would you describe the quality of your relationship with this person?"
label var s4_7_n5 "How would you describe the quality of your relationship with this person before the lockdown (23rd March 2020)?"
label var s4_7exceed_n5 "Do you live with another person?"
label var s4_4_n6 "What best describes your relationship to this person?"
label var s4_6_n6 "In the past week, how would you describe the quality of your relationship with this person?"
label var s4_7_n6 "How would you describe the quality of your relationship with this person before the lockdown (23rd March 2020)?"
label var s4_7exceed_n6 "Do you live with another person?"
label var s4_4_n7 "What best describes your relationship to this person?"
label var s4_6_n7 "In the past week, how would you describe the quality of your relationship with this person?"
label var s4_7_n7 "How would you describe the quality of your relationship with this person before the lockdown (23rd March 2020)?"
label var s4_7exceed_n7 "Do you live with another person?"
label var s4_4_n8 "What best describes your relationship to this person?"
label var s4_6_n8 "In the past week, how would you describe the quality of your relationship with this person?"
label var s4_7_n8 "How would you describe the quality of your relationship with this person before the lockdown (23rd March 2020)?"
label var s4_7exceed_n8 "Do you live with another person?"
label var s4_4_n9 "What best describes your relationship to this person?"
label var s4_6_n9 "In the past week, how would you describe the quality of your relationship with this person?"
label var s4_7_n9 "How would you describe the quality of your relationship with this person before the lockdown (23rd March 2020)?"
label var s4_7exceed_n9 "Do you live with another person?"
label var s4_4_n10 "What best describes your relationship to this person?"
label var s4_6_n10 "In the past week, how would you describe the quality of your relationship with this person?"
label var s4_7_n10 "How would you describe the quality of your relationship with this person before the lockdown (23rd March 2020)?"
label var s4_7exceed_n10 "Do you live with another person?"
label var s4_4_n11 "What best describes your relationship to this person?"
label var s4_6_n11 "In the past week, how would you describe the quality of your relationship with this person?"
label var s4_7_n11 "How would you describe the quality of your relationship with this person before the lockdown (23rd March 2020)?"
label var s4_7exceed_n11 "Do you live with another person?"
label var s4_4_n12 "What best describes your relationship to this person?"
label var s4_6_n12 "In the past week, how would you describe the quality of your relationship with this person?"
label var s4_7_n12 "How would you describe the quality of your relationship with this person before the lockdown (23rd March 2020)?"
label var s4_7exceed_n12 "Do you live with another person?"
label var s4_8 "<div class=rich-text-field-label><p>Were you living with your partner <u>before</u> the 23rd March 2020?</p></div>"
label var s4_9 "<div class=rich-text-field-label><p>Can I check, did you start living with your partner <u>as a result</u> of the lockdown on the 23rd March?</p></div>"
label var s4_10a "Have you given help to someone who you haven't helped before during COVID-19?"
*label var s4_10b "If yes, what help did you give?  (Tick all that apply)"
label var s4_11a "Have you received help that you wouldn't normally receive during the COVID-19 pandemic?"
*label var s4_11b "If yes, what help did you receive? (Tick all that apply)"
label var s5_1 "What type of accommodation do you live in?"
label var s5_2 "Do you have trouble with damp or mould in your home?"
label var s5_3 "Do you have trouble with vermin (e.g. mice, other rodents, cockroaches) in your home? "
label var s5_4 "Does your home have a safe outdoor space  (e.g., a garden or yard) where you can exercise or play?</br>"
label var s5_5 "Is your garden/yard private or shared?"
label var s5_6 "Do you feel that you can experience nature while at home (e.g. by looking out of a window or by accessing an outdoor space)?"
label var s5_7 "Do you receive sunlight in your home? (e.g. through windows or doors)"
label var covid19survey_complete "indicates the completion status"


merge m:1 llc_0007_stud_id using "stata_w_labs\EXCEED_DemographicCore_v0001_20211101", 
tab _merge
drop _merge

label var covid19survey_timestamp "time when the participant submitted the questionnaire - covid19survey_timestamp"
label var s1_10f "Feeling bad about yourself - or that you are a failure or have let yourself or your family down?"
*label var s2_1 "Since COVID-19 emerged in January, but before the official lockdown started on March 23rd 2020, did you change your behaviour by doing any of the following? [tick all that apply]"
label var s2_2d "Number of hours you work in usual workplace"
label var s2_2e "Number of hours you work at home"
label var s2_2f "Time spent talking to family/friends inside my home"
label var s2_2g "Time spent talking to family/friends outside my home"
label var s2_2h "Time spent talking to work colleagues"
label var s2_2v "Amount of money you've spent"
label var s2_4a_exceed "Do you have children under the age of 18 living in the same household as you?"
label var s2_4a "Amount they sleep"
label var s2_4b "Amount of physical activity/exercise they do"
label var s2_4c "Time they spend learning in the house (including home schooling)"
label var s2_4d "Time they spend playing inside the house"
label var s2_4e "Amount of time they spend outside the home"
label var s2_4f "Amount of time they spend in green spaces such as parks or gardens"
label var s2_4g "Time spent using devices with a screen"
label var s2_4h "Amount of fruits they eat"
label var s2_4i "Amount of vegetables they eat"
label var s2_4j "Amount of meat they eat"
label var s2_4k "Amount of fish they eat"
label var s2_4l "Amount of dairy product they eat (e.g. milk, cheese and eggs)"
label var s2_4m "Amounts of savoury snacks they eat"
label var s2_4n "Amount of sweets, pastry, ice-cream they eat"
label var s2_4o "Amount of other fast-foods they eat"
label var s2_4p "Amount of sugar sweetened beverage including tea they drink"
label var s2_4q "Time spent outdoors in in the open air (e.g. spending time in the garden, in a park, walking, jogging, other sport)"
label var s2_5 "Do you have one or more children in full time education? Include school or college courses and includes children who are schooled at home "
label var s2_6a "My youngest child"
label var s2_6b "My second youngest child"
label var s2_6c "My third youngest child"
label var s2_6d "My fourth youngest child"
label var s2_6e "Any other children"
label var s2_7a "My youngest child"
label var s2_7b "My second youngest child"
label var s2_7c "My third youngest child"
label var s2_7d "My fourth youngest child"
label var s2_7e "Any other children"
*label var s2_8a "My youngest child"
*label var s2_8b "My second youngest child"
*label var s2_8c "My third youngest child"
*label var s2_8d "My fourth youngest child"
*label var s2_8e "Any other children"
label var s3_1 "Before the official lockdown was announced on the 23rd March 2020, how well would you say you personally were managing financially?"
label var s3_2 "Overall, how do you feel your current financial situation compares to before the official lockdown was announced on the 23rd March 2020?"
label var s3_3 "I'm worried about my future financial situation"
label var s3_5 "I'm worried about my job security"
label var s3_6 "I'm worried about my partner's job security"
label var s3_7 "Which of these best describes what you were doing just before the lockdown on the 23rd March 2020? If you were doing more than one activity, please choose the activity that you spent most time doing."
label var s3_8 "Which of these would you say best describes YOUR current situation now?"
label var s3_9 "Are you currently fulfilling any of the governmentâ€™s identified â€˜essential workerâ€™ roles?"
label var s3_10 "What sector do you work in?"
label var s3_11 "Does your work require you to be in close contact (i.e. within 2 metres) with others, who you do not live with, including while travelling to work? "
label var s3_12 "In your workplace, does your employer provide you with necessary personal protective equipment (PPE)?"
label var s3_12_exceed "In your workplace, do you provide your own personal protective equipment (PPE)?"
label var s3_13 "If you have a partner, which of these best describes what your partner was doing just before the lockdown on the 23rd March 2020? If they were doing more than one activity, please choose the activity that they spent most time doing."
label var s3_14 "If you have a partner, which of these would you say best describes your partner's current situation, now?"
*label var s4_1 "Has your living arrangement changed because of the COVID-19 pandemic?"
label var s4_4_n1 "What best describes your relationship to this person?"
label var s4_6_n1 "In the past week, how would you describe the quality of your relationship with this person?"
label var s4_7_n1 "How would you describe the quality of your relationship with this person before the lockdown (23rd March 2020)?"
label var s4_8 "Were you living with your partner before the 23rd March 2020?"
label var s4_9 "Can I check, did you start living with your partner as a result of the lockdown on the 23rd March?"
label var covid19survey_complete "indicates the completion status"
label var timestamp "time when the participant submitted the questionnaire - exceed_selfcompletion_questionnaire"
label var gen2 "Which of the following best describes you?"
label var gen2b "What was your sex assigned at birth?"
label var gen5 "What is your ethnic group?"
label var gen6 "What is your father's ethnic group?"
label var gen7 "What is your mother's ethnic group?"
label var sm29 "Prior to cigars/cigarillos/pipes/shisha smoking, did you previously smoke cigarettes on most or all days?"
label var complete "indicates the completion status"

merge m:1 llc_0007_stud_id using  "stata_w_labs\EXCEED_occupation_v0001_20210723", 
tab _merge
keep if _merge==3
drop _merge

label var date_entered "when participant submitted the survey"
label var soc2010 "soc2010 code for the selected job title"
label var never_worked "participant has never worked"



**add in core data that contains birth year/month
merge m:1 llc_0007_stud_id using "stata_w_labs\CORE_nhsd_derived_indicator_v0004_20221101", 
tab _merge
drop if _merge==2
drop _merge

save "exceed edited\exceed edited long version.dta", replace 


 ***WAVE DATES
duplicates report llc_0007_stud_id
duplicates tag llc_0007_stud_id, gen(duplicate)

gen study_wave=1 if survey_date<date("01/07/2020", "DMY")
replace study_wave=2 if inrange(survey_date,date("01/07/2020", "DMY"),date("31/10/2020", "DMY"))
replace study_wave=3 if inrange(survey_date,date("01/11/2020", "DMY"),date("31/05/2021", "DMY"))
label define study_wave 1 "Apr20-Jun20" 2 "Jul20-Oct20" 3 "Nov20-Mar21", replace
label values study_wave study_wave
tab study_wave


***TRANCHE
gen pandemic_timetranche=1 if survey_date<date("01/07/2020", "DMY")
replace pandemic_timetranche=2 if inrange(survey_date,date("01/07/2020", "DMY"),date("31/10/2020", "DMY"))
replace pandemic_timetranche=3 if inrange(survey_date,date("01/11/2020", "DMY"),date("31/05/2021", "DMY"))
label var pandemic_timetranche "Time-Tranche H&W version"
label define pandemic_timetranche 1 "Apr20-Jun20" 2 "Jul20-Oct20" 3 "Nov20-Mar21", replace
label values pandemic_timetranche pandemic_timetranche
tab survey_date pandemic_timetranche

**Age? Cannot find age query this? Exceed recruted between 40-65 in 2013 so should be present?
**Use the core data as a substitute
**age_entry 
tostring dob_year_month, replace
gen dob_yr=substr(dob_year_month,1,4)
destring dob_yr, replace
tab dob_yr
gen dob_mth=substr(dob_year_month,5,2) 
destring dob_mth, replace 
tab dob_mth
gen age=2020-dob_yr
replace age=age-1 if dob_mth>03
tab age
drop if age>65 & age!=.
egen age_entry=cut(age), at(0,18,34,44,54,66) icodes
tabstat age, stat(min max) by(age_entry)
tab age_entry , missing
replace age_entry=9 if age==.
label define age_entry 1 "18-34" 2 "35-44" 3 "45-54" 4 "55-64" 5 "65-74" 6 "75+" 9 "Miss", replace
label values age_entry age_entry
tab age_entry

**sex
**gender
tab gen2, missing
rename sex sex_core
encode gen2, gen(sex)
recode sex (1=2) (2=1)
*label define sex 1 "Female" 2 "Male", replace
*label values sex sex
tab sex 
tab sex sex_core, missing


**ethnicity
tab gen5, missing
encode gen5, gen(ethnicity)
*numlabel, add
tab ethnicity
recode ethnicity (1=5) (2=6) (3=1) (4=3) (5=3) (6=4) (7=4) (8=5) (9=7) (10=3) (11=3) (12=6) (13=3) (14=7) (15=1) (16=2) (17=2) 
tab ethnicity
label define ethnicity 1 "White" 2 "Mixed" 3 "South Asian" 4 "Black"  5 "Other Asian" 6 "Other" 7 "Missing" , replace
label values ethnicity ethnicity
tab ethnicity, missing
replace ethnicity=7 if ethnicity==.


*ethnicity_red 
recode ethnicity (1=1) (2/6=2) (7=9), gen(ethnicity_red)
label define ethnicity_red 1 "White/British" 2 "Other" 9 "Missing", replace
label values ethnicity_red ethnicity_red
tab ethnicity_red, missing

***Check back here
******************************

*s2_4a_exceed s4_1_0 s4_1_1 s4_1_2 s4_1_3 s4_1_99 s4_8 s4_9 s4_7exceed s4_4_
gen housing_composition=1 if s4_8==1 & s2_4a_exceed==1
replace housing_composition=2 if s4_8==1 & s2_4a_exceed==0
replace housing_composition=3 if s4_8!=1 & s2_4a_exceed==1
foreach var of varlist s4_4_n1 s4_4_n2 s4_4_n3 s4_4_n4 s4_4_n5 s4_4_n6 s4_4_n7 s4_4_n8 s4_4_n9 s4_4_n10 s4_4_n11 s4_4_n12 {
	replace `var'=3 if `var'>=3 & `var'!=.
}
replace housing_composition=4 if s4_8==0 & s2_4a_exceed==0 & inlist(3, s4_4_n1, s4_4_n2, s4_4_n3, s4_4_n4, s4_4_n5, s4_4_n6, s4_4_n7, s4_4_n8, s4_4_n9, s4_4_n10, s4_4_n11, s4_4_n12)
replace housing_composition=5 if s4_8==0 & s2_4a_exceed==0 & s4_7exceed_n1==0
replace housing_composition=9 if housing_composition==.

*household_size 
*tab household_size
*housing_composition 
label define housing_composition 1 "partner and children" 2 "partner no children" 3 "lone parents" 4 "no partner no children" 5 "alone" 9 "missing", replace
label values housing_composition housing_composition
tab housing_composition, missing

*housing_tenure 
*tab housing_tenure
*recode housing_tenure (. = 3)
*label define housing_tenure 1 "Own" 2 "Rent" 3 "Missing", replace
*label values housing_tenure housing_tenure
*tab housing_tenure, missing

*education 
*tab education
*label define education 0 "<degree" 1 "degree+" 3 "Missing", replace
*label values education education
*tab education

*vaccination_status 
*tab vaccination_status
*label var vaccination_status "No Vaccine Doses 3rd Wave"

 

**no furlough
gen furlough=1 if s3_8==3
replace furlough=0 if s3_8!=3
recode furlough (97=.) (98=.) (99=.)
tab furlough
label define furlough 0 "No" 1 "Yes", replace
label values furlough furlough
tab furlough


*s3_9 do you work in a government designated essential job so keyworker?
gen keyworker=s3_9
*key_worker 
tab keyworker
label define keyworker 0 "No" 1 "Yes", replace
label values keyworker key_worker
tab keyworker

**var s2_2d s2_2e  refer to number of hours worked in usual place, number hours worked from home compared to before, but don't have the before? 
**not useful
*never_worked s3_10 soc2010
*label define s2_2d 1 "Decreased alot" 2 "Decreased a little" 3 "Stayed same" 4 "Increased a little" 5 "Increased a lot" 0 "Not applicable" 99 "Prefer not", replace
*label value s2_2d s2_2d
*tab s2_2d

*N=3705
**No of hours worked from home 
tab s2_2e

**pre-lockdown employment status 
label values s3_7 s3_7
tab s3_7 

**current employment status 
label values s3_8 s3_8
tab s3_8
*employment 
gen employment=1 if inlist(s3_8, 1,2,3,4,5,7)
replace employment=2 if inlist(s3_8,13)
replace employment=3 if inlist(s3_8,6,8,9,10,11,12,99)
tab employment
label define employed 1 "Yes" 2 "Retired" 3 "Unemployed" 4 "Unknown", replace
label values employment employed
tab employment


*employment_status - not able to work out full/part time or home working just that it was higher/lower than before
*tab s2_2d 
*tab s2_2e
*s3_8

*tab employment_status
*label define employment_status 0 "Full-Time employment" 1 "Part-time employment" 2 "Retired" 3 "Employed but not working" 4 "Unemployed", replace
*label values employment_status employment_status
*tab employment_status

*home_working 
*label define home_working 1 "Wrk from hm" 2 "Some" 3 "None" 4 "Other", replace
*label values home_working home_working
*tab home_working

**tidying up employment
*tab employment employment_status, missing

**Employed if stating in full time work
*replace employment=1 if employment_status==0
**Unemployed if stated unemployed
*replace employment=3 if employment_status==4 & employment==.
*replace employment_status=4 if employment==3 & employment_status==.
**Retired if stated retired
*replace employment_status=2 if employment==2 & employment_status==.
*replace employment_status=2 if employment==2 & employment_status==4 
*replace employment_status=2 if employment==2 & employment_status==3
*replace employment=2 if employment_status==2 & employment==1
**economically active (employed in some form or looking for work) if stated so
*replace employment=1 if employment_status==3 & employment==.
*replace employment=1 if employment_status==3 & employment==3

**economically active if doing part-time/full time work 
*replace employment=1 if employment_status==0 | employment_status==1 

*tab employment employment_status, missing

*c19infection_selfreported 
tab s1_5a
label define s1_5a 1 "Yes, confirmed by pos test" 2 "Yes, suspected by doctor not tested" 3 "Yes, own suspicion" 0 "No, not to my knowledge" 99 "Prefer not to answer", replace
label values s1_5a s1_5a
tab s1_5a

gen c19infection_selfreported=0
replace c19infection_selfreported=1 if inlist(s1_5a,1,2,3)
tab c19infection_selfreported
label define c19infection_selfreported 0 "No" 1 "Yes", replace
label values c19infection_selfreported c19infection_selfreported
tab c19infection_selfreported

*c19postest_selfreported
gen c19postest_selfreported=0
replace c19postest_selfreported=1 if inlist(s1_5a,1)
tab c19postest_selfreported
tab c19postest_selfreported
label define c19postest_selfreported 0 "No" 1 "Yes", replace
label values c19postest_selfreported c19postest_selfreported
tab c19postest_selfreported




**job as text - sector working in?
label values s3_10 s3_10
tab s3_10 

***ADD IN OCCUPATIONAL VARS

**SOC 1dig
tab soc2010, nol
gen soc2010_1d=floor(soc2010/1000)
label define soc2010_1d 1 "Managers, Directors, & Senior Off" 2 "Prof Occupations" 3 "Associate Prof & Technical Occup" 4 "Administrative and Secretarial" 5 "Skilled Trades" 6 "Caring, Leisure, and Other Service" 7 "Sales and Customer Serv" 8 "Process, Plant, and Machine Operatives" 9 "Elementary Occupations", replace
label values soc2010_1d soc2010_1d
tab soc2010_1d


**SOC 2dig
tab soc2010, nol
gen soc2010_2d=floor(soc2010/100)
tab soc2010_2d
label define soc2010_2d 11 "Corporate Managers" 12 "Other Managers and Proprietors in Agriculture and Services" 21 "Science, res, and Tech Prof" 22 "Health Prof" 23 "Teaching and Educa Prof" 24 "Buisness and Public Services Prof" 31 "Science and Tech A-Prof" 32 "Health and Social Welfare A-Prof" 33 "Protective Services" 34 "Culture, Media, Sports Occ" 35 "Buisness and Public Serivces A-Prof" 41 "Administrative Occ" 42 "Secretarial and Related" 51 "Skilled Agricultural Trades" 52 "Skilled Metal and Electrical Trades" 53 "Skilled Construction and Building Trades" 54 "Textiles, Printing, Other skilled Trades" 61 "Caring Personal Services" 62 "Leisure & Other Personal Service Occ" 71 "Sales Occ" 72 "Customer Service" 81  "Process, Plant, and Machine Operative" 82 "Transport, Mobile Macnine Drivers and Operatives" 91 "Elementary Trades, Plant and Storage related Occ" 92 "Elementary Admin and Service Occ", replace 
label values soc2010_2d soc2010_2d
tab soc2010_2d, missing

preserve
*gen occupation vars (defined in protocol)
replace soc2010=floor(soc2010/10)
tab soc2010
recode soc2010 (110=9) (111=9) (112=11)	(113=9)	(115=9)	(116=8)	(117=6)	(118=1)	(119=12)	(121=13)	(122=1)	(124=12)	(125=9)	(211=9)	(212=9)	(213=9)	(214=9)	(215=9)	(221=1)	(222=1)	(223=1)	(231=5)	(241=9)	(242=9)	(243=9)	(244=9)	(245=9)	(246=9)	(247=9)	(311=9)	(312=9)	(313=9)	(321=1)	(323=4)	(331=6)	(341=9)	(342=9)	(344=9)	(350=8)	(351=8)	(352=9)	(353=9)	(354=9)	(355=9)	(356=9)	(411=9)	(412=9)	(413=9)	(415=12)	(416=9)	(421=9)	(511=7)	(521=9)	(522=11)	(523=9)	(524=9)	(525=11) (531=9)	(532=9)	(533=9)	(540=9) (541=9)	(542=9)	(543=7)	(544=9)	(612=4)	(613=9)	(614=1)	(621=8)	(622=9)	(623=13)	(624=13)	(711=12)	(712=9)	(713=12) (721=12)	(722=12)	(811=11)	(812=11)	(813=11)	(814=9)	(821=8)	(822=9)	(823=8)	(911=9)	(912=9)	(913=11)	(921=8)	(923=9)	(924=9)	(925=12)	(926=11)	(927=13), gen(occ_full)
label var occ_full "occupation full"
label define occ_full 1 "Health Care Prof" 2 "Other Health care prof" 3 "Medical Support" 4 "Social Care" 5 "Education" 6 "Police & Protection serv" 7 "Food Workers" 8 "Transport workers" 9 "Other workers" 11 "Factory" 12 "Customer serv" 13 "Hospitality" 20 "Missing/Not in work"
label values occ_full occ_full
tab occ_full

bysort llc_0007_stud_id (occ_full): replace occ_full=occ_full[_n-1] if _n>1 & occ_full==.
sort llc_0007_stud_id study_wave
replace occ_full=20 if occ_full==.
tab occ_full


**gen occupation vars (defined in protocol - reduced)
recode occ_full (1=2) (2=2) (3=2) (4=3) (5=3) (6=4) (7=5) (8=5) (9=1) (11=5) (12=5) (13=5) (20=6), gen(occ_red)
label var occ_red "occupation reduced"
label define occ_red 1 "Non-essential workers" 2 "Health Care workers" 3 "Social and Education" 4 "Police and Protective" 5 "Other essential workers" 6 "Missing/not in wrk"
label values occ_red occ_red
tab occ_red



save "exceed edited\exceed edited long version.dta", replace 


***********PREPARE/FORMAT and MERGE NHS TESTING DATA*********************

***************************************	
****MERGING WITH THE NHS TESTING DATA
use "NHS edited\protect_nhs_c19posinfect_temp", clear
count
ssc install datesum

**drop if within 2 weeks - drops 14,309, leaves 25,125 positive tests
drop if time_sinceprevpos<14 & time_sinceprevpos!=0


***create identification of (alspac) wave in nhs infection data
**Three waves pre-"May 2020", May-"June 2020", Jul-"Oct 20", Nov20-"Feb/Mar 2021"

gen study_wave=1 if testdate<date("01/07/2020", "DMY")
replace study_wave=2 if inrange(testdate,date("01/07/2020", "DMY"),date("31/10/2020", "DMY"))
replace study_wave=3 if inrange(testdate,date("01/11/2020", "DMY"),date("31/05/2021", "DMY"))
label define study_wave 1 "Apr20-Jun20" 2 "Jul20-Oct20" 3 "Nov20-Mar21", replace
label values study_wave study_wave
tab study_wave

bysort study_wave: datesum testdate

gen testmonth=month(testdate)
gen testyear=year(testdate)

drop if study_wave==.
tab source
sort llc_0007_stud_id study_wave testyear testmonth

**Look for within wave repeats
bysort llc_0007_stud_id study_wave: egen seq=seq()
tab seq
gen rep_n=seq
gsort llc_0007_stud_id study_wave -seq
by llc_0007_stud_id study_wave: replace rep_n=rep_n[_n-1] if _n>1
tab rep_n
sort llc_0007_stud_id study_wave seq
list llc_0007_stud_id study_wave testdate seq rep_n if rep_n!=1, sepby(llc_0007_stud_id)
*take first pos test
keep if seq==1
drop seq rep_n

**rename occupation var
rename occupation occupation_nhs

tostring avail_from_dt, replace

**save temporay elsa version of nhs infection data
save "exceed edited\protect_nhs_c19posinfect_temp_exceedver", replace

clear 



******************************************************************************
**NORTHERN IRELAND COHORT FOR THE LONGITUDINAL STUDY OF AGEING (NICOLA) - Study_id==10
******************************************************************************

cd "S:\LLC_0007\data\"


use "stata_w_labs\NICOLA_Covid_19Questionnaire_v0001_20211101", clear
count
codebook, compact
duplicates report
use "stata_w_labs\NICOLA_Wave1CAPI_v0001_20211101", clear
count
codebook, compact
duplicates report
use "stata_w_labs\NICOLA_Wave2CAPI_v0001_20220302", clear
count
codebook, compact
duplicates report


**wave 1 and 2 are pre covid (wave 2 has both so link wave 2 to covid questionaire)
**note covid questionarie is from 2021 doesnt have date of covid just have they had covid test, and symptoms

**merge with the covid questionaire
use "stata_w_labs\NICOLA_Wave1CAPI_v0001_20211101", clear
sort llc_
merge 1:1 llc_0007_stud_id using "stata_w_labs\NICOLA_Wave2CAPI_v0001_20220302",
drop _merge
sort llc_
merge 1:1 llc_0007_stud_id using "stata_w_labs\NICOLA_Covid_19Questionnaire_v0001_20211101", 
tab _merge
drop if _merge==2
*as no linked data drop if master only (i.e. no covid data)
drop if _merge==1
drop _merge




***WAVE DATES
gen study_wave=3
label define study_wave 1 "May 2020" 2 "July 2020" 3 "Feb/Mar 2021", replace
label values study_wave study_wave 
tab study_wave




**age_entry 
tab dn002
tab dn003
replace dn002=w2_dn002 if dn002==. | dn002==99
replace dn003=w2_dn003 if dn003==. | dn003==9999
gen age=2020-dn003
replace age=age-1 if dn002>3
hist age
egen age_entry=cut(age), at(0,18,34,44,54,64,74,120) icodes
tabstat age, stat(min max) by(age_entry)
tab age_entry , missing
replace age_entry=9 if age==.
label define age_entry 1 "18-34" 2 "35-44" 3 "45-54" 4 "55-64" 5 "65-74" 6 "75+" 9 "Miss", replace
label values age_entry age_entry
tab age_entry



**sex - not available?? variable contain only hundreds of individuals
*tab sex 
*destring sex, replace
*label define sex 1 "Female" 2 "Male", replace
*label values sex sex
*tab sex

*ethnicity - not available? no variable
*tab ethnicity
*label define ethnicity 1 "White" 2 "Mixed" 3 "South Asian" 4 "Black"  5 "Other Asian" 6 "Other" 7 "Missing" , replace
*label values ethnicity ethnicity
*tab ethnicity, missing
*replace ethnicity=7 if ethnicity==.


*ethnicity_red 
*label define ethnicity_red 1 "White/British" 2 "Other" 9 "Missing", replace
*label values ethnicity_red ethnicity_red
*recode ethnicity_red (3=2) 
*tab ethnicity_red, missing

*household_size 
tab q127_livewith 
tab hhnumdum
tab q2_manypeople
replace hhnumdum=q2_manypeople if hhnumdum==.
replace hhnumdum=. if hhnumdum==999
rename hhnumdum household_size
tab household_size

*housing_composition - not avilable not enough information - replace with household size and live with parter/spouse
*label define housing_composition 1 "partner and children" 2 "partner no children" 3 "lone parents" 4 "no partner no children" 5 "alone" 9 "missing", replace
*label values housing_composition housing_composition
*tab housing_composition

tab q127_livewith 
rename q127_livewith livepartner
tab livepartner


*housing_tenure 
numlabel w2_hostat, add
tab w2_hostat
recode w2_hostat (1=1) (2=1) (3=2) (4=2) (5=2) (98=3) (99=3), gen(housing_tenure)
tab housing_tenure
recode housing_tenure (. = 3)
label define housing_tenure 1 "Own" 2 "Rent" 3 "Missing", replace
label values housing_tenure housing_tenure
tab housing_tenure, missing

*education 
replace w2_dm001=dm001 if w2_dm001==.
numlabel w2_dm001, add
tab w2_dm001
recode w2_dm001 (1=0) (2=0) (3=0) (4=0) (5=0) (6=1) (7=1) (96=3) (98=3) (99=3), gen(education)
tab education
label define education 0 "<degree" 1 "degree+" 3 "Missing", replace
label values education education
tab education

*vaccination_status no info
*tab vaccination_status
*label var vaccination_status "No Vaccine Doses 3rd Wave"



*furlough 
numlabel q66_currentsituation, add 
tab q66_currentsituation 
recode q66_currentsituation (1=0) (2=0) (3=1) (4=0) (5=0) (6=0) (7=0) (8=0) (9=0) (97=.) (98=.) (99=.), gen(furlough)
tab furlough
label define furlough 0 "No" 1 "Yes", replace
label values furlough furlough
tab furlough

*key_worker 
numlabel q70_keyworker, add
tab q70_keyworker
recode q70_keyworker (1=1) (2=0) (8=.) (9=.), gen(keyworker)
tab keyworker
label define key_worker 0 "No" 1 "Yes", replace
label values keyworker key_worker
tab keyworker


*employment 
tab q66_currentsituation 
recode q66_currentsituation (1=1) (2=1) (3=1) (4=3) (5=3) (6=3) (7=2) (8=3) (9=3) (97=4) (98=4) (99=4), gen(employment)
tab employment
label define employed 1 "Yes" 2 "Retired" 3 "Unemployed" 4 "Unknown", replace
label values employment employed
tab employment


*employment_status 
tab q66_currentsituation 
tab q67_hoursworknow, nol
gen partfull=(q67_hoursworknow>=30) if q67_hoursworknow<800
tab partfull
gen employment_status=employment if employment<=2
replace employment_status=0 if partfull==1 & employment_status==1
replace employment_status=3 if inlist(q66_currentsituation, 3, 5)
replace employment_status=4 if inlist(q66_currentsituation, 6, 8,9)
tab employment_status
label define employment_status 0 "Full-Time employment" 1 "Part-time employment" 2 "Retired" 3 "Employed but not working" 4 "Unemployed", replace
label values employment_status employment_status
tab employment_status


tab employment employment_status, missing


*home_working - no info on home working
*label define home_working 1 "Wrk from hm" 2 "Some" 3 "None" 4 "Other", replace
*label values home_working home_working
*tab home_working

**occupation variable
label define occupation 1	"(A)Agriculture, forestry and fishing" 10	"(J)Information and communication" 11	"(K)Financial and insurance activities" 12	"(L)Real estate activities" 13	"(M)Professional, scientific and technical activities" 14	"(N)Administrative and support service activities" 15	"(O)Public administration and defence;compulsory social security" 16	"(P)Education" 17	"(Q)Human health and social work activities" 18	"(R)Arts, entertainment and recreation" 19	"(S)Other service activities" 2	"(B)Mining and quarrying" 20	"(T)Activities of households as employers;undifferentiated goods - and services-producing activities of households for o" 21	"(U)Activities of extra territorial organisations and bodies" 22	"CANNOT CLASSIFY" 3	"(C)Manufacturing" 4	"(D)Electricity,gas,steam and air conditioning supply" 5	"(E)Water supply;sewerage,waste management and remediation activities" 6	"(F)Construction" 7	"(G)Wholesale and retail trade;repair of motor vehicles and motorcycles" 8	"(H)Transportation and storage" 9	"(I)Accommodation and food service activities" 98	"Don't know" 99	"Refusal", replace 
label values we110x occupation
label values we617x occupation
tab we110x we617x, missing

gen occupation=we617x
replace occupation=we110x if occupation==.
label values occupation occupation
tab occupation 






*c19postest_selfreported
numlabel q54_testresult q53_beentested, add
tab q54_testresult q53_beentested
recode q54_testresult (1=1) (2=0) (3=0) (4=0) (8=.) (9=.), gen(c19postest_selfreported)
tab c19postest_selfreported
label define c19postest_selfreported 0 "No" 1 "Yes", replace
label values c19postest_selfreported c19postest_selfreported
tab c19postest_selfreported


*c19infection_selfreported - note based on self-reported symptoms
numlabel q45_hightemp q46_newcough q47_shortbreath q48_fatigue q49_smelltaste q50_diarrhoea q51_abdominalpain q52_lossofappetite, add
foreach var of varlist q45_hightemp q46_newcough q47_shortbreath q48_fatigue q49_smelltaste q50_diarrhoea q51_abdominalpain q52_lossofappetite {
	tab `var'
	recode `var' (2=0) (9=.)
	}
egen c19infection_selfreported=rowtotal(q45_hightemp q46_newcough q47_shortbreath q48_fatigue q49_smelltaste)
tab c19infection_selfreported
replace c19infection_selfreported=1 if c19infection_selfreported>=1
replace c19infection_selfreported=1 if c19postest_selfreported==1
tab c19infection_selfreported
label define c19infection_selfreported 0 "No" 1 "Yes", replace
label values c19infection_selfreported c19infection_selfreported
tab c19infection_selfreported



save "nicola edited\nicola edited long version.dta", replace 




****NICOLA IS NORTHERN IRELAND, SO NOT POSSIBLE TO LINK TO TESTING DATA





******************************************************************************************
**THE NIHR BIOREASOURCE COVID-19 PSYCHIATRY AND NEUROLOGICAL GENETICS (COPING) STUDY - Study_id==11
******************************************************************************************

cd "S:\LLC_0007\data\"


use "stata_w_labs\NIHRBIO_COPING_Bioresource_v0001_20210719", clear
*N=13,821 
count
codebook, compact
duplicates report llc_0007_stud_id

** dates startdate_coping startdate_prepandemic
drop if startdate_coping==" "
**covert startdate_coping
split startdate_coping, parse(" ")
drop startdate_coping2
gen survey_date=date(startdate_coping1,"DMY",2020)
format %tdDD/NN/CCYY survey_date
duplicates drop llc_0007_stud_id survey_date, force
hist survey_date
gen survey_mth=month(survey_date)
gen survey_yr=year(survey_date)

save "coping edited\coping edited long version.dta", replace 


 ***WAVE DATES
*No waves only one response each - May to July 2020
gen study_wave=1
label define study_wave 1 "June/Jul 2020" 2 "Mar 2021", replace
label values study_wave study_wave
tab study_wave


***TRANCHE
gen pandemic_timetranche=1 if survey_date<date("01/07/2020", "DMY")
replace pandemic_timetranche=2 if inrange(survey_date,date("01/07/2020", "DMY"),date("31/10/2020", "DMY"))
replace pandemic_timetranche=3 if inrange(survey_date,date("01/11/2020", "DMY"),date("31/05/2021", "DMY"))
label var pandemic_timetranche "Time-Tranche H&W version"
label define pandemic_timetranche 1 "Apr20-Jun20" 2 "Jul20-Oct20" 3 "Nov20-Mar21", replace
label values pandemic_timetranche pandemic_timetranche
tab survey_date pandemic_timetranche

**Age? Cannot find age query this? Exceed recruted between 40-65 in 2013 so should be present?
**Use the core data as a substitute
**age_entry 
rename age age_provided
tab age_provided 
tab age_category  
gen age=2020-birthyear_numeric
replace age=age-1 if birthmonth_numeric>03
tab age
sum age_provided age
drop if age<18 | age>65 & age!=.
egen age_entry=cut(age), at(0,18,34,44,54,66) icodes
tabstat age, stat(min max) by(age_entry)
tab age_entry , missing
replace age_entry=9 if age==.
label define age_entry 1 "18-34" 2 "35-44" 3 "45-54" 4 "55-65" 5 "65-74" 6 "75+" 9 "Miss", replace
label values age_entry age_entry
tab age_entry

**sex
**gender
rename sex sex_original
encode sex_original, gen(sex)
label define sex 1 "Female" 2 "Male", replace
label values sex sex
tab sex


**ethnicity
rename ethnicity ethnicty_text
tab ethnicity 
tab ethnicity_numeric
replace ethnicity_numeric="7" if ethnicity=="NA"
encode ethnicity_numeric, gen(ethnicity)
numlabel, add
label define ethnicity 1 "White" 2 "Mixed" 3 "South Asian" 4 "Black"  5 "Other Asian" 6 "Other" 7 "Missing" , replace
label values ethnicity ethnicity
tab ethnicity, missing


*ethnicity_red 
recode ethnicity (1=1) (2/6=2) (7=9), gen(ethnicity_red)
label define ethnicity_red 1 "White/British" 2 "Other" 9 "Missing", replace
label values ethnicity_red ethnicity_red
tab ethnicity_red, missing

***Check back here
******************************

**no houseold related variables
*household_size 
*tab household_size
*housing_composition 
*label define housing_composition 1 "partner and children" 2 "partner no children" 3 "lone parents" 4 "no partner no children" 5 "alone" 9 "missing",
*label values housing_composition housing_composition
*tab housing_composition

*housing_tenure 
*tab housing_tenure
*recode housing_tenure (. = 3)
*label define housing_tenure 1 "Own" 2 "Rent" 3 "Missing", replace
*label values housing_tenure housing_tenure
*tab housing_tenure, missing

*education 
tab highest_education 
encode highest_education, gen(education)
numlabel, add
tab education
recode education (1=0) (2=0) (3=3) (4=0) (5=1)
label define education 0 "<degree" 1 "degree+" 3 "Missing", replace
label values education education
tab education

*vaccination_status 
*tab vaccination_status
*label var vaccination_status "No Vaccine Doses 3rd Wave"

*furlough 
tab employment_paid_leave_furloughed 
encode employment_paid_leave_furloughed, gen(furlough)
numlabel, add
tab furlough
recode furlough (1=1) (3=0) (2=.)
tab furlough
label define furlough 0 "No" 1 "Yes", replace
label values furlough furlough
tab furlough

*key_worker 
rename key_worker key_worker2
encode key_worker2, gen(key_worker)
numlabel, add
tab key_worker
recode key_worker (1=1) (2=.) (3=0)
label define key_worker 0 "No" 1 "Yes", replace
label values key_worker key_worker
tab key_worker
rename key_worker keyworker


foreach var of varlist employment_became_employed  employment_became_unemployed employment_change employment_contract_or_freelance  employment_fulltime_employed employment_furloughed_or_paid_le employment_my_employment_status_ employment_paid_leave_furloughed employment_parttime_employed employment_retired employment_stayathome_parent_or_ employment_unemployed {
	tab `var'
}

*employment 
encode employment_unemployed, gen(employment)
numlabel, add
tab employment
recode employment (1=4) (2=1) (3=3)
label define employed 1 "Yes" 2 "Retired" 3 "Unemployed" 4 "Unknown", replace
label values employment employed
tab employment_retired employment
replace employment=2 if employment_retired=="Retired"
tab employment
replace employment=. if employment==4
tab employment_parttime_employed

*employment_status 
gen employment_status=employment
replace employment_status=4 if employment==3
replace employment_status=3 if employment_furloughed_or_paid_le=="Furloughed or paid leave (Company funded)"
replace employment_status=3 if furlough==1
replace employment_status=0 if employment_fulltime_employed=="Full-time employed"
replace employment_status=1 if employment_parttime_employed=="Part-time employed"
tab employment_status
label define employment_status 0 "Full-Time employment" 1 "Part-time employment" 2 "Retired" 3 "Employed but not working" 4 "Unemployed", replace
label values employment_status employment_status
tab employment_status



tab employment employment_status, missing

*home_working - no home working recorded
*label define home_working 1 "Wrk from hm" 2 "Some" 3 "None" 4 "Other", replace
*label values home_working home_working
*tab home_working

**DON'T APPEAR TO HAVE ASKED IF THEY HAD COVID??

*c19infection_selfreported 
*tab c19infection_selfreported
*label define c19infection_selfreported 0 "No" 1 "Yes", replace
*label values c19infection_selfreported c19infection_selfreported
*tab c19infection_selfreported
*c19postest_selfreported
*tab c19postest_selfreported
*label define c19postest_selfreported 0 "No" 1 "Yes", replace
*label values c19postest_selfreported c19postest_selfreported
*tab c19postest_selfreported


save "coping edited\coping edited long version.dta", replace 


***********PREPARE/FORMAT and MERGE NHS TESTING DATA*********************

***************************************	
****MERGING WITH THE NHS TESTING DATA
use "NHS edited\protect_nhs_c19posinfect_temp", clear
count
ssc install datesum
**drop if within 2 weeks - drops 14,309, leaves 25,125 positive tests
drop if time_sinceprevpos<14 & time_sinceprevpos!=0


**Two waves (ish) pre-"June/Jul 2020", Aug-"Sep/Oct 2020", Nov20-"Feb/Mar 2021"

gen study_wave=1 if testdate<=date("01/08/2020", "DMY")
replace study_wave=2 if testdate>date("01/08/2020", "DMY") & testdate<=date("30/03/2021", "DMY")
replace study_wave=. if testdate>date("30/03/2021", "DMY")

label define study_wave 1 "pre-July 2020" 2 "Jul20-Feb/Mar 2021", replace
label values study_wave study_wave
tab study_wave
bysort study_wave: datesum testdate


drop if study_wave==.
tab source
sort llc_0007_stud_id study_wave

**Look for within wave repeats
bysort llc_0007_stud_id study_wave: egen seq=seq()
tab seq
gen rep_n=seq
gsort llc_0007_stud_id study_wave -seq
by llc_0007_stud_id study_wave: replace rep_n=rep_n[_n-1] if _n>1
tab rep_n
sort llc_0007_stud_id study_wave seq
list llc_0007_stud_id study_wave testdate seq rep_n if rep_n!=1, sepby(llc_0007_stud_id)
*take first pos test
keep if seq==1
drop seq rep_n

**rename occupation var
rename occupation occupation_nhs

tostring avail_from_dt, replace

**save temporay elsa version of nhs infection data
save "coping edited\protect_nhs_c19posinfect_temp_copingver", replace



clear 

*******************************************************************************
**THE GENETIC LINKS TO ANXEITY AND DEPRESSION (GLAD) STUDY - Study_id==12
*******************************************************************************

cd "S:\LLC_0007\data\"


use "stata_w_labs\GLAD_FILE2_v0001_20211101", clear
count
codebook, compact
duplicates report llc_

*N=36,922
*N=13,100 with covid response
*startdate_coping startdate_prepandemic

** dates startdate_coping startdate_prepandemic
drop if startdate_coping==""
**covert startdate_coping
split startdate_coping, parse("T")
drop startdate_coping2
gen survey_date=date(startdate_coping1,"YMD",2020)
format %tdDD/NN/CCYY survey_date
duplicates drop llc_0007_stud_id survey_date, force
hist survey_date
gen survey_mth=month(survey_date)
gen survey_yr=year(survey_date)

save "glad edited\glad edited long version.dta", replace 


***WAVE DATES
*No waves only one response each - May to July 2020
gen study_wave=1
replace study_wave=2 if survey_date>date("01/08/2020", "DMY")
label define study_wave 1 "June/Jul 2020" 2 "Mar 2021", replace
label values study_wave study_wave
tab study_wave


***TRANCHE
gen pandemic_timetranche=1 if survey_date<date("01/07/2020", "DMY")
replace pandemic_timetranche=2 if inrange(survey_date,date("01/07/2020", "DMY"),date("31/10/2020", "DMY"))
replace pandemic_timetranche=3 if inrange(survey_date,date("01/11/2020", "DMY"),date("31/05/2021", "DMY"))
label var pandemic_timetranche "Time-Tranche H&W version"
label define pandemic_timetranche 1 "Apr20-Jun20" 2 "Jul20-Oct20" 3 "Nov20-Mar21", replace
label values pandemic_timetranche pandemic_timetranche
tab survey_date pandemic_timetranche


**age_entry 
tab age
tab age_category  
drop if age<18 | age>65 & age!=.
egen age_entry=cut(age), at(0,18,34,44,54,66) icodes
tabstat age, stat(min max) by(age_entry)
tab age_entry , missing
replace age_entry=9 if age==.
label define age_entry 1 "18-34" 2 "35-44" 3 "45-54" 4 "55-65" 5 "65-74" 6 "75+" 9 "Miss", replace
label values age_entry age_entry
tab age_entry

**sex
**gender
rename sex sex_string
rename sex_numeric sex
label define sex 1 "Female" 0 "Male", replace
label values sex sex
tab sex


**ethnicity
rename ethnicity ethnicity_text
rename ethnicity_numeric ethnicity
tab ethnicity 
tab ethnicity_text
replace ethnicity=7 if ethnicity==.
label define ethnicity 1 "White" 2 "Mixed" 3 "South Asian" 4 "Black"  5 "Other Asian" 6 "Other" 7 "Missing" , replace
label values ethnicity ethnicity
tab ethnicity, missing


*ethnicity_red 
recode ethnicity (1=1) (2/6=2) (7=9), gen(ethnicity_red)
label define ethnicity_red 1 "White/British" 2 "Other" 9 "Missing", replace
label values ethnicity_red ethnicity_red
tab ethnicity_red, missing


*education 
tab highest_education 
encode highest_education, gen(education)
numlabel, add
tab education
recode education (1=0) (2=0) (3=0) (4=1) (.=3)
label define education 0 "<degree" 1 "degree+" 3 "Missing", replace
label values education education
tab education

***Check back here
******************************

**no houseold related variables
*household_size 
*tab household_size
*housing_composition 
*label define housing_composition 1 "partner and children" 2 "partner no children" 3 "lone parents" 4 "no partner no children" 5 "alone" 9 "missing",
*label values housing_composition housing_composition
*tab housing_composition

*housing_tenure 
*tab housing_tenure
*recode housing_tenure (. = 3)
*label define housing_tenure 1 "Own" 2 "Rent" 3 "Missing", replace
*label values housing_tenure housing_tenure
*tab housing_tenure, missing


*vaccination_status 
*tab vaccination_status
*label var vaccination_status "No Vaccine Doses 3rd Wave"



**key woker status
tab key_worker , nol
tab employment_government_work_key_w

*key_worker 
rename key_worker key_worker2
encode key_worker2, gen(key_worker)
numlabel, add
tab key_worker
recode key_worker (1=1) (2=0) 
label define key_worker 0 "No" 1 "Yes", replace
label values key_worker key_worker
tab key_worker
rename key_worker keyworker


**furlough
*furlough 
tab employment_paid_leave_furloughed 
encode employment_paid_leave_furloughed, gen(furlough)
numlabel, add
tab furlough
recode furlough (1=1) (2=0) 
tab furlough
label define furlough 0 "No" 1 "Yes", replace
label values furlough furlough
tab furlough


**emplyment status

foreach var of varlist employment_became_employed  employment_became_unemployed employment_change employment_contract_or_freelance  employment_fulltime_employed employment_furloughed_or_paid_le employment_my_employment_status_ employment_paid_leave_furloughed employment_parttime_employed employment_retired employment_stayathome_parent_or_ employment_unemployed {
	tab `var'
}

*employment 
encode employment_unemployed, gen(employment)
numlabel, add
tab employment
recode employment (1=1) (2=3) 
label define employed 1 "Yes" 2 "Retired" 3 "Unemployed" 4 "Unknown", replace
label values employment employed
tab employment_retired employment
replace employment=2 if employment_retired=="Retired"
tab employment

tab employment_parttime_employed

*employment_status 
gen employment_status=employment
replace employment_status=4 if employment==3
replace employment_status=3 if employment_furloughed_or_paid_le=="Furloughed or paid leave (Company funded)"
replace employment_status=3 if furlough==1
replace employment_status=0 if employment_fulltime_employed=="Full-time employed"
replace employment_status=1 if employment_parttime_employed=="Part-time employed"
tab employment_status
label define employment_status 0 "Full-Time employment" 1 "Part-time employment" 2 "Retired" 3 "Employed but not working" 4 "Unemployed", replace
label values employment_status employment_status
tab employment_status




tab employment employment_status, missing

*home_working - no home working recorded
*label define home_working 1 "Wrk from hm" 2 "Some" 3 "None" 4 "Other", replace
*label values home_working home_working
*tab home_working

**DON'T APPEAR TO HAVE ASKED IF THEY HAD COVID??

*c19infection_selfreported 
*tab c19infection_selfreported
*label define c19infection_selfreported 0 "No" 1 "Yes", replace
*label values c19infection_selfreported c19infection_selfreported
*tab c19infection_selfreported
*c19postest_selfreported
*tab c19postest_selfreported
*label define c19postest_selfreported 0 "No" 1 "Yes", replace
*label values c19postest_selfreported c19postest_selfreported
*tab c19postest_selfreported


save "glad edited\glad edited long version.dta", replace 




***********PREPARE/FORMAT and MERGE NHS TESTING DATA*********************

***************************************	
****MERGING WITH THE NHS TESTING DATA
use "NHS edited\protect_nhs_c19posinfect_temp", clear
count
ssc install datesum
**drop if within 6 months - drops 15,812, leaves 23,622 positive tests
*drop if time_sinceprevpos<180

**drop if within 3 months - drops 15,812, leaves 23,622 positive tests
*drop if time_sinceprevpos<90

**drop if within 1 months - drops 15,091, leaves 24,343 positive tests
*drop if time_sinceprevpos<30

**drop if within 2 weeks - drops 14,309, leaves 25,125 positive tests
drop if time_sinceprevpos<14 & time_sinceprevpos!=0


**Two waves (ish) pre-"June/Jul 2020", Aug-"Sep/Oct 2020", Nov20-"Feb/Mar 2021"

gen study_wave=1 if testdate<=date("01/08/2020", "DMY")
replace study_wave=2 if testdate>date("01/08/2020", "DMY") & testdate<=date("30/03/2021", "DMY")
replace study_wave=. if testdate>date("30/03/2021", "DMY")

label define study_wave 1 "pre-July 2020" 2 "Jul20-Feb/Mar 2021", replace
label values study_wave study_wave
tab study_wave
bysort study_wave: datesum testdate


drop if study_wave==.
tab source
sort llc_0007_stud_id study_wave

**Look for within wave repeats
bysort llc_0007_stud_id study_wave: egen seq=seq()
tab seq
gen rep_n=seq
gsort llc_0007_stud_id study_wave -seq
by llc_0007_stud_id study_wave: replace rep_n=rep_n[_n-1] if _n>1
tab rep_n
sort llc_0007_stud_id study_wave seq
list llc_0007_stud_id study_wave testdate seq rep_n if rep_n!=1, sepby(llc_0007_stud_id)
*take first pos test
keep if seq==1
drop seq rep_n

**rename occupation var
rename occupation occupation_nhs

tostring avail_from_dt, replace

**save temporay elsa version of nhs infection data
save "glad edited\protect_nhs_c19posinfect_temp_gladver", replace



clear 






*******************************************************************************
*THE TRACK COVID-19 STUDY - Study_id==13
*******************************************************************************

cd "S:\LLC_0007\data\"


*baseline assessment of covid infection self-reported
use "stata_w_labs\TRACKC19_baseline_v0001_20210915", clear
*N=18,134
count
codebook, compact
duplicates report llc_

use "stata_w_labs\TRACKC19_basicInfo_v0001_20210915", clear
*N=19,635
count
codebook, compact
duplicates report llc_

tab ethnicity 
tab age 
tab sex

use "stata_w_labs\TRACKC19_followUp_v0001_20210915", clear
*N=161,073 (multiple responses per peron, appears monthly between July 2020 and oct 2021
count
*N=16,014 individuals
codebook, compact
duplicates report llc_
tab follnum

**********NOT SUITABLE DUE TO NO OCCUPATIONAL DATA*************


************************************************
**TWINS UK STUDY - Study_id==13
************************************************

cd "S:\LLC_0007\data\"





use "stata_w_labs\TWINSUK_COPE1_v0001_20211101", clear
count
codebook, compact
duplicates report
generate study_wave=1
append using "stata_w_labs\TWINSUK_COPE2_v0002_20220302", force
count
codebook, compact
duplicates report
replace study_wave=2 if study_wave==.
append using "stata_w_labs\TWINSUK_COPE3_v0001_20220531", force
count
codebook, compact
duplicates report
replace study_wave=3 if study_wave==.
tab study_wave
rename * cw_*
rename cw_llc_0007_stud_id llc_0007_stud_id
rename cw_study_wave study_wave

merge m:1 llc_0007_stud_id using "stata_w_labs\TWINSUK_DEMOGRAPHICS_v0005_20220913", 
tab _merge
drop if _merge==2 
drop _merge
count
codebook, compact
duplicates report
tab study_wave
rename * d_*
rename d_cw_* cw_*
rename d_llc_0007_stud_id llc_0007_stud_id
rename d_study_wave study_wave

merge m:1 llc_0007_stud_id using "stata_w_labs\TWINSUK_FAMILY_v0002_20220531",
tab _merge
drop if _merge==2 
drop _merge
count
codebook, compact
duplicates report
tab study_wave
rename * f_*
rename f_cw_* cw_*
rename f_d_* d_*
rename f_llc_0007_stud_id llc_0007_stud_id
rename f_study_wave study_wave

merge m:1 llc_0007_stud_id using "stata_w_labs\TWINSUK_INFECTION_v0001_20220302",
tab _merge
drop if _merge==2 
drop _merge
count
codebook, compact
duplicates report
tab study_wave

rename * in_*
rename in_cw_* cw_*
rename in_d_* d_*
rename in_f_* f_*
rename in_llc_0007_stud_id llc_0007_stud_id
rename in_study_wave study_wave


save "twinsuk edited\twinsuk edited long version.dta", replace 

use "twinsuk edited\twinsuk edited long version.dta", clear


count
*N=3623 individuals
*codebook, compact
duplicates report llc_

replace cw_study_date=cw_responsedate if cw_study_date==""
gen study_date=date(cw_study_date,"DMY")
format %tdDD/NN/CCYY study_date


**study wave - only one study wave
label define study_wave 1 "Apr-May20" 2 "july-Aug20" 3 "Oct-Nov20", replace
label values study_wave study_wave
tab study_wave 


***TRANCHE
gen pandemic_timetranche=1 if study_date<date("01/07/2020", "DMY")
replace pandemic_timetranche=2 if study_date>=date("01/07/2020", "DMY") & study_date<=date("31/10/2020", "DMY")
replace pandemic_timetranche=3 if study_date>=date("01/11/2020", "DMY") & study_date<=date("01/03/2021", "DMY")
label var pandemic_timetranche "Time-Tranche H&W version"
label define pandemic_timetranche 1 "Apr20-Jun20" 2 "Jul20-Oct20" 3 "Nov20-Mar21", replace
label values pandemic_timetranche pandemic_timetranche
tab pandemic_timetranche

**age d_a3 seems to be birth year
tab d_a3
gen age=2020-d_a3
egen age_entry=cut(age), at(1,18,34,44,54,64,74,120) icodes
replace age_entry=9 if age==.
tab age_entry 
label define age_entry 1 "18-34" 2 "35-44" 3 "45-54" 4 "55-64" 5 "65-74" 6 "75+" 9 "Miss", replace
label values age_entry age_entry
tab age_entry

**sex d_a2 seems to be gender
recode d_a2 (1=2) (2=1) (.=9), gen(sex)
label define sex 1 "female" 2 "male" 9 "Miss", modify
label values sex
tab sex

**Ethnicity
tab d_a5
gen ethnicity_red=(d_a5=="White")
replace ethnicity_red=9 if d_a5=="999906" 
tab ethnicity_red
recode ethnicity_red (0=2)
label define ethnicity_red 1 "White/British" 2 "Other" 9 "Missing", replace
label values ethnicity_red ethnicity_red
tab ethnicity_red, missing


**Live with
tab cw_d79 
bysort llc_0007_stud_id (study_wave): replace cw_d79=cw_d79[_n-1] if study_wave!=1 & cw_d79==.
replace cw_d79=9 if cw_d79==999906 | cw_d79==999911
label define cw_d79 1 "I live with others" 2 "I live alone" 9 "Miss", replace
label values cw_d79 cw_d79
tab cw_d79

tab cw_e101
replace cw_e101=cw_g101 if cw_e101==.
bysort llc_0007_stud_id (study_wave): replace cw_e101=cw_e101[_n-1] if study_wave!=1 & cw_e101==.
replace cw_e101=9 if cw_e101==999906 | cw_e101==999911 | cw_e101==. | cw_e101==999905
label define cw_e101 1 "Single/Never married" 2 "Single/Divorced" 3 "Relationship/Married apart" 4 "Relationship/Cohabit" 9 "missing", replace
label values cw_e101 cw_e101
tab cw_e101 


*household_size 
tab cw_d80
bysort llc_0007_stud_id (study_wave): replace cw_d80=cw_d80[_n-1] if study_wave!=1 & cw_d80==""
replace cw_d80="Miss" if cw_d80=="999906" | cw_d80=="999911" | cw_d80==""
encode cw_d80, gen(household_size)
tab household_size

tab household_size cw_d79, nol

*housing_composition 
gen housing_composition=1 if cw_e101==4 & household_size>1
replace housing_composition=2 if cw_e101==4 & household_size==1
replace housing_composition=3 if cw_e101==2 & household_size>1 | cw_e101==3 & household_size>1
replace housing_composition=4 if cw_e101==1 & household_size>1 
replace housing_composition=5 if housing_composition==. & household_size==1
replace housing_composition=5 if housing_composition==. & cw_d79==2
replace housing_composition=9 if housing_composition==.
label define housing_composition 1 "partner and children" 2 "partner no children" 3 "lone parents" 4 "no partner no children" 5 "alone" 9 "missing", replace
label values housing_composition housing_composition
tab housing_composition, missing


*housing_tenure 
numlabel, add
tab cw_d69,
bysort llc_0007_stud_id (study_wave): replace cw_d69=cw_d69[_n-1] if study_wave!=1 & cw_d69==.
recode cw_d69 (1=1) (2=1) (3=1) (4=2) (5=2) (6=3) (999906=3) (999911=3) (.=3), gen(housing_tenure)
label define housing_tenure 1 "Own" 2 "Rent" 3 "Missing", replace
label values housing_tenure housing_tenure
tab housing_tenure


tab cw_e104
bysort llc_0007_stud_id (study_wave): replace cw_e104=cw_e104[_n-1] if study_wave!=1 & cw_e104==.
label define cw_e104 1	"No qualification" 2	"NVQ1/SVQ1" 3	"O-level/GCSE/NVQ2/SVQ2/Scottish intermediate" 4	"Scottish Higher, NVQ3, City and Guilds, Pitman" 5	"A-level, Scottish Advanced Higher" 6	"Higher vocational training (e.g. Diploma, NVQ4, SVQ4)" 7	"Undergraduate degree" 8	"Postgraduate degree (e.g. Masters or PhD), NVQ5, SVQ5" 999906	"Question seen but not answered", replace 
label values cw_e104 cw_e104
tab cw_e104

*education 
recode cw_e104 (1=0) (2=0) (3=0) (4=0) (5=0) (6=0) (7=1) (8=1) (999906=3), gen(education)
replace education=3 if education==.
tab education
label define education 0 "No degree" 1 "Degree+" 3 "Missing", replace
label values education education
tab education

*vaccination_status 
*label var vaccination_status "No Vaccine Doses 3rd Wave"

*furlough 
*label define furlough 0 "No" 1 "Yes", replace
*label values furlough furlough
*tab furlough


*key_worker 
foreach var of varlist cw_e98_1 cw_e98_2 cw_e98_3 cw_e98_4 cw_e98_6 cw_e98_7 cw_e98_8 cw_e98_9 {
	bysort llc_0007_stud_id (study_wave): replace `var'=`var'[_n-1] if study_wave!=1 & `var'==.
}
gen keyworker=inlist(1, cw_e98_1, cw_e98_2, cw_e98_3, cw_e98_4, cw_e98_6, cw_e98_7, cw_e98_8, cw_e98_9)
tab keyworker
label define keyworker 0 "No" 1 "Yes", replace
label values keyworker keyworker
tab keyworker


label define cw_e98_1 0 "No" 1 "Health & Social Care", replace 
label define cw_e98_2 0 "No" 1 "Teacher or Childcare", replace 
label define cw_e98_3 0 "No" 1 "Transport worker",  replace 
label define cw_e98_4 0 "No" 1 "Food Chain worker", replace 
label define cw_e98_6 0 "No" 1 "Key Public Serivces",replace 
label define cw_e98_7 0 "No" 1 "Local/National Government", replace 
label define cw_e98_8 0 "No" 1 "Utilities (energy, sewage)", replace 
label define cw_e98_9 0 "No" 1 "Medicines/Protective equip",replace 
foreach var of varlist cw_e98_* {
	label values `var' `var'
	tab `var'
	}



*employment
tab cw_e97
bysort llc_0007_stud_id (study_wave): replace cw_e97=cw_e97[_n-1] if study_wave!=1 & cw_e97==.
recode cw_e97 (1=1) (2=1) (3=1) (4=3) (5=3) (6=3) (7=3) (8=2) (9=4) (999906=4) (.=4) , gen(employment)
label define employed 1 "Yes" 2 "Retired" 3 "Unemployed" 4 "Unknown", replace
label values employment employed
tab employment


*employment_status 
*label define employment_status 0 "Full-Time employment" 1 "Part-time employment" 2 "Retired" 3 "Employed but not working" 4 "Unemployed", replace
*label values employment_status employment_status
*tab employment_status


*home_working 
*label define home_working 1 "Wrk from hm" 2 "Some" 3 "None" 4 "Other", replace
*label values home_working home_working
*tab home_working


*c19infection_selfreported - 
tab cw_a1
replace cw_a1 = cw_b13 if study_wave==2
replace cw_a1 = cw_a3 if study_wave==3
label define cw_a1 0	"No" 1	"Yes, tested positive by swab/saliva only" 2 "Yes, tested positive by antibody test (blood test, including by TwinsUK) only" 3	"Yes, tested positive by both swab/saliva and antibody test" 4	"Not tested or tested negative but suspected" 999904	"Inconsistent answer (Inconsistency between answers given)" 999906	"Question seen but not answered" 999914	"Undefined response due to the questionnaire design (implicit no or didn't answer)", replace
label values cw_a1 cw_a1
tab cw_a1

gen c19infection_selfreported=1 if cw_a1>0 & cw_a1<100
replace c19infection_selfreported=0 if cw_a1==0
tab c19infection_selfreported
label define c19infection_selfreported 0 "No" 1 "Yes", replace
label values c19infection_selfreported c19infection_selfreported
tab c19infection_selfreported cw_a1

*c19postest_selfreported
gen c19postest_selfreported=1 if cw_a1>=1 & cw_a1<=3
replace c19postest_selfreported=0 if cw_a1==0 | cw_a1==4 | cw_a1==5
tab c19postest_selfreported
label define c19postest_selfreported 0 "No" 1 "Yes", replace
label values c19postest_selfreported c19postest_selfreported
tab c19postest_selfreported cw_a1, nol

save "twinsuk edited\twinsuk edited long version.dta", replace 



***********PREPARE/FORMAT and MERGE NHS TESTING DATA*********************

***************************************	
****MERGING WITH THE NHS TESTING DATA
use "NHS edited\protect_nhs_c19posinfect_temp", clear
count
ssc install datesum

**drop if within 2 weeks - drops 14,309, leaves 25,125 positive tests
drop if time_sinceprevpos<14 & time_sinceprevpos!=0


***create identification of (alspac) wave in nhs infection data
**Three waves pre-"May 2020", May-"June 2020", Jul-"Oct 20", Nov20-"Feb/Mar 2021"

gen study_wave=1 if testdate<=date("31/05/2020", "DMY")
replace study_wave=2 if testdate>date("31/05/2020", "DMY") & testdate<=date("30/08/2020", "DMY")
replace study_wave=3 if testdate>date("01/09/2020", "DMY") & testdate<=date("31/11/2020", "DMY")
replace study_wave=. if testdate>date("31/11/2020", "DMY")

label define study_wave 1 "pre-Jun 2020" 2 "Jun-Aug 2020" 3 "Sep-Nov20" , replace
label values study_wave study_wave
tab study_wave
bysort study_wave: datesum testdate

gen testmonth=month(testdate)
gen testyear=year(testdate)

drop if study_wave==.
tab source
sort llc_0007_stud_id study_wave testyear testmonth

**Look for within wave repeats
bysort llc_0007_stud_id study_wave: egen seq=seq()
tab seq
gen rep_n=seq
gsort llc_0007_stud_id study_wave -seq
by llc_0007_stud_id study_wave: replace rep_n=rep_n[_n-1] if _n>1
tab rep_n
sort llc_0007_stud_id study_wave seq
list llc_0007_stud_id study_wave testdate seq rep_n if rep_n!=1, sepby(llc_0007_stud_id)
*take first pos test
keep if seq==1
drop seq rep_n

**rename occupation var
rename occupation occupation_nhs

tostring avail_from_dt, replace

**save temporay elsa version of nhs infection data
save "twinsuk edited\protect_nhs_c19posinfect_temp_twinsukver", replace

clear 

****************************************************
**ALSPAC - study_id==15
****************************************************

cd "S:\LLC_0007\data\"

**notes four covid questionarie waves 1 "Apr-May20" 2 "May-Jun20" 3 "Oct20" 4 "Nov20-Mar21"
**two groups m = mothers (age 46+), y = cohort (age 28-30)
**Note wave 0 is demgraphics


**Create cohorts for append/merge
use "stata_w_labs\ALSPAC_wave1m_v0001_20211101", clear
gen study_wave=1
**1 = Mothers
gen cohort=1
rename covid1m_* covid_*
save "alspac edited\alspac wave1m", replace

use "stata_w_labs\ALSPAC_wave2m_v0001_20211101", clear
gen study_wave=2
**2 = Mothers
gen cohort=1
rename covid2m_* covid_*
save "alspac edited\alspac wave2m", replace


use "stata_w_labs\ALSPAC_wave3m_v0001_20211101", clear
gen study_wave=3
**1 = Mothers
gen cohort=1
rename covid3m_* covid_*
save "alspac edited\alspac wave3m", replace

use "stata_w_labs\ALSPAC_wave4m_v0001_20220531", clear
gen study_wave=4
**1 = Mothers
gen cohort=1
rename covid4m_* covid_*
save "alspac edited\alspac wave4m", replace

**repeat for members
use "stata_w_labs\ALSPAC_wave1y_v0001_20211101", clear
gen study_wave=1
**2 = Members
gen cohort=2
rename covid1yp_* covid_*
save "alspac edited\alspac wave1y", replace

use "stata_w_labs\ALSPAC_wave2y_v0001_20211101", clear
gen study_wave=2
**2 = Members
gen cohort=2
rename covid2yp_* covid_*
save "alspac edited\alspac wave2y", replace

use "stata_w_labs\ALSPAC_wave3y_v0001_20211101", clear
gen study_wave=3
**2 = Members
gen cohort=2
rename covid3yp_* covid_*
save "alspac edited\alspac wave3y", replace

use "stata_w_labs\ALSPAC_wave4y_v0001_20220531", clear
gen study_wave=4
**2 = Members
gen cohort=2
rename covid4yp_* covid_*
save "alspac edited\alspac wave4y", replace


****wave 0 is socio-demographics pre covid??
use "stata_w_labs\ALSPAC_wave0m_v0001_20220531", clear
**1 = Mothers
gen cohort=1
rename *m_* *0_*
save "alspac edited\alspac wave0m", replace

use "stata_w_labs\ALSPAC_wave0y_v0001_20220531", clear
**2 = Members
gen cohort=2
rename *yp_* *0_*
save "alspac edited\alspac wave0y", replace

**apend wave zero
use "alspac edited\alspac wave0m", clear
append using "alspac edited\alspac wave0y", 
tab cohort
save "alspac edited\alspac wave0my", replace

bysort llc_0007_stud_id: egen seq=seq()
gsort llc_0007_stud_id -seq
by llc_0007_stud_id: gen count=seq if _n==1
by llc_0007_stud_id: replace count=count[_n-1] if _n>1
tab count
*list llc_0007_stud_id seq covid1m_9650 kz021 yph2012 covid1m_9620 covid1m_9621 covid1m_9622 if count>1, sepby(llc_0007_stud_id)
keep if count==1 | count>1 & covid10_9650!=.
drop seq
bysort llc_0007_stud_id: egen seq=seq()
tab seq
keep if seq==1
drop seq count
save "alspac edited\alspac wave0my", replace

**Serology post covid Apr 2021 to June 2022
use "stata_w_labs\ALSPAC_serology1m_v0001_20220531", clear
**1 = Mothers
gen cohort=1
rename serom_* sero_*
save "alspac edited\alspac sero_m", replace

use "stata_w_labs\ALSPAC_serology1y_v0001_20220531", clear
**2 = Members
gen cohort=2
rename seroyp_* sero_*
save "alspac edited\alspac sero_y", replace

*append sero together
use "alspac edited\alspac sero_m", clear
append using "alspac edited\alspac sero_y", 
tab cohort
save "alspac edited\alspac sero_ym", replace


***occupational data
use "stata_w_labs\ALSPAC_custom_occupationm_v0001_20220810", clear
count 
codebook, compact
gen cohort=1
rename occ_g0 soc2000
rename y9990 socmth
rename y9991 socyr
save "alspac edited\alspac occ_y", replace

use "stata_w_labs\ALSPAC_custom_occupationy_v0001_20220810", clear
count 
codebook, compact
gen cohort=2
rename occ_g1 soc2000
rename ypg7011 socmth
rename ypg7012 socyr
save "alspac edited\alspac occ_m", replace


*append occ together
use "alspac edited\alspac occ_m", clear
append using "alspac edited\alspac occ_y", 
tab cohort

duplicates report llc_0007_stud_id
duplicates list llc_0007_stud_id soc2000 socmth socyr
**remove older occupation code
bysort llc_0007_stud_id (socyr socmth): egen seq=seq()
tab seq
drop if seq==1 & seq[_n+1]==2
drop seq
duplicates report llc_0007_stud_id


save "alspac edited\alspac occ_ym", replace


***combine datasets together
**mothers
use "alspac edited\alspac wave1m", clear
append using "alspac edited\alspac wave2m"
append using "alspac edited\alspac wave3m"
append using "alspac edited\alspac wave4m"
**add in cohort members
append using "alspac edited\alspac wave1y"
append using "alspac edited\alspac wave2y"
append using "alspac edited\alspac wave3y"
append using "alspac edited\alspac wave4y"


**merge in wave 0 
merge m:1 llc_0007_stud_id using "alspac edited\alspac wave0my"
tab _merge
drop _merge

**merge in serology
merge m:1 llc_0007_stud_id using "alspac edited\alspac sero_ym"
tab _merge
drop _merge

**merge in occupation data
merge m:1 llc_0007_stud_id using "alspac edited\alspac occ_ym"
tab _merge
drop _merge

save "alspac edited\alspac edited long version", replace


****FORMAT VARIABLES FOR ANALYSIS
use "alspac edited\alspac edited long version", clear

**Note covid_ is the wave version, covid10_ is the version at 1st wave repeated across all waves (from ALSPAC wave 0)


***label cohort and wave
label define cohort 1 "Cohort Mothers" 2 "Cohort Member", replace
label values cohort cohort
tab cohort
**study wave
label define study_wave 1 "Apr-May20" 2 "May-Jun20" 3 "Oct20" 4 "Nov20-Mar21", replace
label values study_wave study_wave
tab study_wave cohort


***TRANCHE
recode study_wave (1=1) (2=1) (3=2) (4=3), gen(pandemic_timetranche) 
label var pandemic_timetranche "Time-Tranche H&W version"
label define pandemic_timetranche 1 "Apr20-Jun20" 2 "Jul20-Oct20" 3 "Nov20-Mar21", replace
label values pandemic_timetranche pandemic_timetranche
tab pandemic_timetranche

**age_entry 
gen age=covid10_9650 
replace age=covid20_9650 if age==.
replace age=covid30_9650 if age==.
replace age=covid40_9650 if age==.
replace age=sero_9650 if age==.
tab age
egen age_entry=cut(age), at(1,18,34,44,54,64,74,120) icodes
tab age_entry 
label define age_entry 1 "18-34" 2 "35-44" 3 "45-54" 4 "55-64" 5 "65-74" 6 "75+", replace
label values age_entry age_entry
tab age_entry



**sex/gender
recode kz021 (1=2) (2=1), gen(sex)
replace sex=1 if cohort==1 & sex==.
tab sex 
label define sex 1 "Female" 2 "Male", replace
label values sex sex
tab sex

tab covid_0500 
tab covid_0501 
tab covid_0502 
tab covid40_0501

*ethnicity_red 
gen ethnicity_red=yph2012
replace ethnicity_red=covid_0502 if ethnicity_red==.
replace ethnicity_red=9 if ethnicity_red==.
label define ethnicity_red 1 "White/British" 2 "Other" 9 "Missing", replace
label values ethnicity_red ethnicity_red
tab ethnicity_red, missing


codebook  covid_5015 covid_5016 covid_5017 covid_5018 covid_5014 covid_5022 covid_5024 covid_5027  covid_6013 covid_6014 covid_6015 covid_6016 covid_6017 covid10_5015 covid10_5016 covid10_5017 covid10_5018 covid20_5021 covid20_5023 covid20_5024 covid20_5025 covid20_5026 covid20_5027 covid40_6010 covid40_6011 covid40_6013 covid40_6014 covid40_6015 covid40_6016 covid40_6017, compact

*household_size 
egen household_size=rowtotal(covid10_5015 covid10_5016 covid10_5017 covid10_5018)
tab household_size
*housing_composition 
label define housing_composition 1 "partner and children" 2 "partner no children" 3 "lone parents" 4 "no partner no children" 5 "alone" 9 "missing", replace
foreach var of varlist covid40_6010 covid40_6011 covid40_6013 covid40_6014 covid40_6015 covid40_6016 covid40_6017 {
	gen `var'g=(`var'>0) if `var'!=.
	}
egen hcomp=rowtotal(covid40_6010 covid40_6011 covid40_6013 covid40_6014 covid40_6015 covid40_6016 covid40_6017)
gen housing_composition=5 if hcomp==0
drop hcomp
replace housing_composition=1 if covid40_6010g==1 & covid40_6011g==0 & covid40_6013g==1 & covid40_6014g==0 & covid40_6015g==0 & covid40_6016g==0 & covid40_6017g==0
replace housing_composition=2 if covid40_6010g==1 & covid40_6011g==0 & covid40_6013g==0 & covid40_6014g==0 & covid40_6015g==0 & covid40_6016g==0 & covid40_6017g==0
replace housing_composition=3 if covid40_6010g==0 & covid40_6011g==0 & covid40_6013g==1 & covid40_6014g==0 & covid40_6015g==0 & covid40_6016g==0 & covid40_6017g==0
replace housing_composition=4 if inlist(1, covid40_6011, covid40_6014, covid40_6015, covid40_6016, covid40_6017) & covid40_6010g==0 &  covid40_6013==0
replace housing_composition=9 if housing_composition==.
label values housing_composition housing_composition

tab housing_composition

*housing_tenure 
*label define housing_tenure 1 "Own" 2 "Rent" 3 "Missing", replace
*label values housing_tenure housing_tenure

*education 
gen education=ypf7510
replace education=3 if education==.
tab education
label define education 0 "qualifications" 1 "No Qualifications" 3 "Missing", replace
label values education education
tab education

*vaccination_status 
*label var vaccination_status "No Vaccine Doses 3rd Wave"

*furlough 
tab covid20_6020 
tab covid40_6200
gen furlough=1 if covid20_6020==4 
replace furlough=0 if covid20_6020!=4 & covid20_6020!=.
replace furlough=1 if covid40_6200==4 & study_wave>2
tab furlough
label define furlough 0 "No" 1 "Yes", replace
label values furlough furlough
tab furlough


*key_worker 
codebook covid_5045 covid_6030 covid10_5045 covid20_6030, compact
gen key_worker=(covid10_5045==1) 
replace key_worker=. if covid10_5045==9 | covid10_5045==.
replace key_worker=1 if covid20_6030==1 & key_worker==.
tab key_worker cohort
label define key_worker 0 "No" 1 "Yes", replace
label values key_worker key_worker
tab key_worker
rename key_worker keyworker


label define covid20_6020 1 "Employed & working same hrs" 2 "Employed & working reduced hrs" 3 "Employed & working more hrs" 4"Emp but Furlough" 5 "Emp but unpaid leave" 6 "Apprentiships" 7 "Unpaid/Vol work" 8 "Self-emp & working" 9 "Self-emp & not working" 10 "Unemployed" 11 "Per sick/disab" 12 "Looking after fam" 13 "In education" 14 "Retired" -1 "Miss" -6  "YPP data disclosive" -9 "Did not complete sec E" -10 "Did not complete Q" -11 "Trips/Quads" -9999 "Consent withdrawn", replace
label values covid20_6020 covid20_6020
label values covid40_6200 covid20_6020
tab covid20_6020 
tab covid40_6200

*employment 
recode covid20_6020 (1=1) (2=1) (3=1) (4=1) (5=1) (6=1) (7=3) (8=1) (9=3) (10=3) (11=3) (12=3) (13=3) (14=2), gen(employment) 
recode covid40_6200 (1=1) (2=1) (3=1) (4=1) (5=1) (6=1) (7=3) (8=1) (9=3) (10=3) (11=3) (12=3) (13=3) (14=2) (.=4), gen(employment2) 
replace employment=employment2 if study_wave>2 & employment2!=4 | employment==.
drop employment2
label define employed 1 "Yes" 2 "Retired" 3 "Unemployed" 4 "Unknown", replace
label values employment employed




tab covid_6000 
tab covid20_6000,

*employment_status 
gen employment_status=0 if employment==1 & covid20_6000==1
replace employment_status=1 if employment_status==. & employment==1
replace employment_status=2 if employment_status==. & employment==2
replace employment_status=3 if covid20_6020==4 | covid20_6020==5 | covid20_6020==9
replace employment_status=3 if study_wave>2 & (covid40_6200==4 | covid40_6200==5 | covid40_6200==9)
replace employment_status=4 if employment_status==. & employment==3
tab employment_status
label define employment_status 0 "Full-Time employment" 1 "Part-time employment" 2 "Retired" 3 "Employed but not working" 4 "Unemployed", replace
label values employment_status employment_status
tab employment_status



*home_working 
gen home_working=1 if covid_6300>=5 & covid_6300!=.
replace home_working=2 if covid_6300>=1 & covid_6300<=4
replace home_working=3 if covid_6300==0 
replace home_working=4 if employment==1 & covid_6300==. 
label define home_working 1 "Wrk from hm" 2 "Some" 3 "None" 4 "Other", replace
label values home_working home_working
tab home_working


**SOC 2000 1 digit
replace soc2000=. if soc2000==9999

**SOC2000 1 digit
gen soc_1d=floor(soc2000/1000)
replace soc_1d=1 if soc_1d<1
tab soc_1d

label define soc_1d 1 "Managers and Senior Officals" 2 "Professional Occupations" 3 "Associate Professional and Technical" 4 "Administrative and Secretarial" 5 "Skilled Trades" 6 "Personal Service" 7 "Sales and Customer Services" 8 "Process, Plant and Machine Operative" 9 "Elementary Occ", replace  
label values soc_1d soc_1d
tab soc_1d study_wave, missing


**SOC2000 2 digit
gen soc_2d=floor(soc2000/100)
replace soc_2d=1 if soc_2d<1
tab soc_2d

label define soc_2d 11 "Corporate Managers" 12 "Managers and Proprietors in Agriculture and Services" 21 "Science and Tech Prof" 22 "Health Prof" 23 "Teaching and Research Prof" 24 "Buisness and Public Services Prof" 31 "Science and Tech A-Prof" 32 "Health and Social Welfare A-Prof" 33 "Protective Services" 34 "Culture, Media, Sports Occ" 35 "Buisness and Public Serivces A-Prof" 41 "Administrative Occ" 42 "Secretarial and Related" 51 "Skilled Agricultural Trades" 52 "Skilled Metal and Electrical Trades" 53 "Skilled Construction and Building Trades" 54 "Textiles, Printing, Other skilled Trades" 61 "Caring Personal Services" 62 "Leisure & Other Personal Service Occ" 71 "Sales Occ" 72 "Customer Service" 81  "Process, Plant, and Machine Operative" 82 "Transport, Mobile Macnine Drivers and Operatives" 91 "Elementary Trades, Plant and Storage related Occ" 92 "Elementary Admin and Service Occ", replace 
label values soc_2d soc_2d
tab soc_2d study_wave, missing


*gen occupation vars (defined in protocol)
replace soc2000=floor(soc2000/10)
replace soc2000=. if soc2000==0
tab soc2000
recode soc2000 (110=9) (111=9) (112=11)	(113=9)	(114=12) (115=9)	(116=8)	(117=6)	(118=1)	(119=12)	(121=13)	(122=1) (123=9)	(124=12)	(125=9)	(211=9)	(212=9)	(213=9)	(214=9)	(215=9)	(221=1)	(222=1)	(223=1)	(231=5) (232=9)	(241=9)	(242=9)	(243=9)	(244=9)	(245=9)	(246=9)	(247=9)	(311=9)	(312=9)	(313=9)	(321=1) (322=1)	(323=4)	(331=6)	(341=9)	(342=9) (343=9)	(344=9)	(350=8)	(351=8)	(352=9)	(353=9)	(354=9)	(355=9)	(356=9)	(411=9)	(412=9)	(413=9) (414=9)	(415=12)	(416=9)	(421=9)	(511=7)	(521=9)	(522=11)	(523=9)	(524=9)	(525=11) (531=9)	(532=9)	(533=9)	(540=9) (541=9)	(542=9)	(543=7)	(544=9) (549=9) (611=1)	(612=4)	(613=9)	(614=1)	(621=8)	(622=9)	(623=13)	(624=13) (629=9)	(711=12)	(712=9)	(713=12) (721=12)	(722=12)	(811=11)	(812=11)	(813=11)	(814=9)	(821=8)	(822=9)	(823=8)	(911=9)	(912=9)	(913=11) (914=11) (921=8) (922=9)	(923=9)	(924=9)	(925=12)	(926=11)	(927=13), gen(occ_full)
label var occ_full "occupation full"
label define occ_full 1 "Health Care Prof" 2 "Other Health care prof" 3 "Medical Support" 4 "Social Care" 5 "Education" 6 "Police & Protection serv" 7 "Food Workers" 8 "Transport workers" 9 "Other workers" 11 "Factory" 12 "Customer serv" 13 "Hospitality" 20 "Missing/Not in work"
label values occ_full occ_full
tab occ_full

bysort llc_0007_stud_id (occ_full): replace occ_full=occ_full[_n-1] if _n>1 & occ_full==.
sort llc_0007_stud_id study_wave
replace occ_full=20 if occ_full==.
tab occ_full


**gen occupation vars (defined in protocol - reduced)
recode occ_full (1=2) (2=2) (3=2) (4=3) (5=3) (6=4) (7=5) (8=5) (9=1) (11=5) (12=5) (13=5) (20=6), gen(occ_red)
label var occ_red "occupation reduced"
label define occ_red 1 "Non-essential workers" 2 "Health Care workers" 3 "Social and Education" 4 "Police and Protective" 5 "Other essential workers" 6 "Missing/not in wrk"
label values occ_red occ_red
tab occ_red


*c19infection_selfreported - note for alspac question is have ever had, not since last wave have you had?

tab covid_2580 
tab covid_3010 
tab covid_1060, 
tab covid_1061, 

tab covid_1060 covid_1061

gen c19infection_selfreported=1 if inlist(covid_2580,1,2) | inlist(covid_1061,1,2)
replace c19infection_selfreported=0 if c19infection_selfreported==.
tab c19infection_selfreported
label define c19infection_selfreported 0 "No" 1 "Yes", replace
label values c19infection_selfreported c19infection_selfreported
tab c19infection_selfreported

*c19postest_selfreported
gen c19postest_selfreported=1 if inlist(covid_2580,1) | inlist(covid_1061,1)
replace c19postest_selfreported=0 if c19postest_selfreported==.
tab c19postest_selfreported
label define c19postest_selfreported 0 "No" 1 "Yes", replace
label values c19postest_selfreported c19postest_selfreported
tab c19postest_selfreported


save "alspac edited\alspac edited long version.dta", replace 





***********PREPARE/FORMAT and MERGE NHS TESTING DATA*********************

***************************************	
****MERGING WITH THE NHS TESTING DATA
use "NHS edited\protect_nhs_c19posinfect_temp", clear
count
ssc install datesum


**drop if within 2 weeks - drops 14,309, leaves 25,125 positive tests
drop if time_sinceprevpos<14 & time_sinceprevpos!=0


***create identification of (alspac) wave in nhs infection data
**Three waves pre-"May 2020", May-"June 2020", Jul-"Oct 20", Nov20-"Feb/Mar 2021"

gen study_wave=1 if testdate<=date("01/05/2020", "DMY")
replace study_wave=2 if testdate>date("01/05/2020", "DMY") & testdate<=date("30/06/2020", "DMY")
replace study_wave=3 if testdate>date("01/07/2020", "DMY") & testdate<=date("31/10/2020", "DMY")
replace study_wave=4 if testdate>date("01/11/2020", "DMY") & testdate<=date("30/03/2021", "DMY")
replace study_wave=. if testdate>date("30/03/2021", "DMY")

label define study_wave 1 "pre-may 2020" 2 "May-June 2020" 3 "July-Oct2020" 4 "Nov20-Feb/Mar 2021", replace
label values study_wave study_wave
tab study_wave
bysort study_wave: datesum testdate

gen testmonth=month(testdate)
gen testyear=year(testdate)

drop if study_wave==.
tab source
sort llc_0007_stud_id study_wave testyear testmonth

**Look for within wave repeats
bysort llc_0007_stud_id study_wave: egen seq=seq()
tab seq
gen rep_n=seq
gsort llc_0007_stud_id study_wave -seq
by llc_0007_stud_id study_wave: replace rep_n=rep_n[_n-1] if _n>1
tab rep_n
sort llc_0007_stud_id study_wave seq
list llc_0007_stud_id study_wave testdate seq rep_n if rep_n!=1, sepby(llc_0007_stud_id)
*take first pos test
keep if seq==1
drop seq rep_n

**rename occupation var
rename occupation occupation_nhs

tostring avail_from_dt, replace

**save temporay elsa version of nhs infection data
save "alspac edited\protect_nhs_c19posinfect_temp_alspacver", replace

clear 










********STOP HERE*******
***ADD IN OCCUPATIONAL VARS




**SOC 1dig
tab soc2010, nol
replace soc2010=soc2010cur if soc2010==.
gen soc2010_1d=floor(soc2010/100)
label define soc2010_1d 1 "Managers, Directors, & Senior Off" 2 "Prof Occupations" 3 "Associate Prof & Technical Occup" 4 "Administrative and Secretarial" 5 "Skilled Trades" 6 "Caring, Leisure, and Other Service" 7 "Sales and Customer Serv" 8 "Process, Plant, and Machine Operatives" 9 "Elementary Occupations", replace
label values soc2010_1d soc2010_1d
tab soc2010_1d
bysort llc_0007_stud_id (study_wave): egen seq=seq()
bysort llc_0007_stud_id (study_wave): replace soc2010_1d=soc2010_1d[_n-1] if soc2010_1d==. & seq>1



**SOC 2dig
tab soc2010, nol
gen soc2010_2d=floor(soc2010/10)
tab soc2010_2d
label define soc2010_2d 11 "Corporate Managers" 12 "Other Managers and Proprietors in Agriculture and Services" 21 "Science, res, and Tech Prof" 22 "Health Prof" 23 "Teaching and Educa Prof" 24 "Buisness and Public Services Prof" 31 "Science and Tech A-Prof" 32 "Health and Social Welfare A-Prof" 33 "Protective Services" 34 "Culture, Media, Sports Occ" 35 "Buisness and Public Serivces A-Prof" 41 "Administrative Occ" 42 "Secretarial and Related" 51 "Skilled Agricultural Trades" 52 "Skilled Metal and Electrical Trades" 53 "Skilled Construction and Building Trades" 54 "Textiles, Printing, Other skilled Trades" 61 "Caring Personal Services" 62 "Leisure & Other Personal Service Occ" 71 "Sales Occ" 72 "Customer Service" 81  "Process, Plant, and Machine Operative" 82 "Transport, Mobile Macnine Drivers and Operatives" 91 "Elementary Trades, Plant and Storage related Occ" 92 "Elementary Admin and Service Occ", replace 
label values soc2010_2d soc2010_2d
bysort llc_0007_stud_id (study_wave): replace soc2010_2d=soc2010_2d[_n-1] if soc2010_2d==. & seq>1
tab soc2010_2d, missing
drop seq

**SIC??
tab sic3


**generate weekly working hours
gen  wk_worhrs=wrkhoursd
replace wk_worhrs=timeuse1_1_1 if wk_worhrs==.
replace wk_worhrs=timeuse_1*5 if wk_worhrs==.
replace wk_worhrs=wrkhoursb if wk_worhrs==.

tab wk_worhrs study_wave


**employment
tab econactivityd
recode econactivityd (1=1) (2=1)  (3=1) (4=1) (5=1) (6=1) (7=0) (8=0) (9=0) (10=0) (11=0) (12=0) (13=0), gen(employed) 
label var employed "Participant employed during COVID"
label define employed 0 "No" 1 "Yes", replace
label values employed employed
tab employed


**employment
tab wk_worhrs
tab econactivityd
tab wk_worhrs if econactivityd==.

recode econactivityd (1=1) (2=1)  (3=1) (4=1) (5=1) (6=1) (7=3) (8=3) (9=3) (10=3) (11=3) (12=2) (13=3), gen(employment) 
replace employment=3 if wk_worhrs<8 & employment==.
replace employment=1 if wk_worhrs>=8 & wk_worhrs!=. & employment==.

label var employment "Participant employment_status during COVID"
label define employment 1 "Employed/looking for work" 2 "Retired" 3 "Unemployed", replace
label values employment employment
tab employment

tab econactivityd employment, missing


**employment_status
tab wk_worhrs
tab econactivityd

recode econactivityd (1=1) (2=3)  (3=3) (4=2) (5=3) (6=1) (7=3) (8=4) (9=4) (10=4) (11=4) (12=2) (13=4), gen(employment_status) 
replace employment_status=1 if wk_worhrs<8 & employment_status==.
replace employment_status=1 if wk_worhrs>=8 & wk_worhrs!=. & employment_status==.
replace employment_status=0 if wk_worhrs>=20 & wk_worhrs!=. & employment_status==1


label var employment_status "Participant employment_status during COVID"
label define employment_status 0 "Full-Time employment" 1 "Part-time employment" 2 "Retired" 3 "Employed but not working" 4 "Unemployed", replace
label values employment_status employment_status
tab econactivityd employment_status


**Key worker 
tab keyworkerd study_wave

recode keyworkerd (1=1) (2=0), gen(key_worker)
label define key_worker 0 "No" 1 "Yes"
label values key_worker key_worker
tab key_worker


**Home working	 
tab wrklocationd study_wave
gen home_working=wrklocationd
replace home_working=4 if study_wave==1 & wrklocationd==3
recode home_working (2=3) (3=2)
label define home_working 1 "Wrk from hm" 2 "Some" 3 "None" 4 "Other", replace
label values home_working home_working
tab home_working

**Furlough - 
tab econactivityd
gen furlough=1 if inlist(econactivityd, 2, 3)
replace furlough=0 if inlist(econactivityd, 1, 5, 6)
replace furlough=2 if furlough==. & econactivityd!=. 
label define furlough 0 "In wrk" 1 "furlough" 2 "other", replace
label values furlough furlough
tab furlough

tab study_wave c19infection_selfreported , row

tab pandemic_timetranche c19infection_selfreported 
tab pandemic_timetranche c19postest_selfreported





********************************************************************************************************
******STOP HERE***********
**FOLLOWING IS LIST OF DATASETS AND EARLY SUMMARY STAT INVESTIGATONS 
**FOR USE IN ABOVE IF NEEDED TO EDIT AND MANIPULATE FILES NOT PROVIDED BY H&W


**THE 1970 BRITISH COHORT STUDY
use "stata_w_labs\BCS70_basic_demographic_v0001_20211101", clear
use "stata_w_labs\BCS70_bcs10_employment_v0001_20211101", clear
use "stata_w_labs\BCS70_bcs10_housing_v0001_20211101", clear
use "stata_w_labs\BCS70_bcs10_qualifications_v0001_20211101", clear
use "stata_w_labs\BCS70_COVID_w1_v0001_20211101", clear
use "stata_w_labs\BCS70_COVID_w2_v0001_20211101", clear
use "stata_w_labs\BCS70_COVID_w3_v0001_20211101", clear



**THE ENGLISH LONGITUDINAL STUDY OF AGEING
use "stata_w_labs\ELSA_elsa_covid_w1_eul_v0001_20211101", clear
use "stata_w_labs\ELSA_elsa_covid_w2_eul_v0001_20211101", clear
use "stata_w_labs\ELSA_wave_9_elsa_data_eul_fq_v0001_20211101", clear
use "stata_w_labs\ELSA_wave_9_elsa_data_eul_heps_v0001_20211101", clear
use "stata_w_labs\ELSA_wave_9_elsa_data_eul_wp_v0001_20211101", clear




**************************
**THE EXTENDED COHORT FOR E-HEALTH, ENVIRONMENT, AND DNA (EXCEED)
use "stata_w_labs\EXCEED_covid19survey_v0001_20211101", clear
*N=3705
**No of hours worked from home 
tab s2_2e

**pre-lockdown employment status 
tab s3_7 
**current employment status 
tab s3_8

**job as text - sector working in?
tab s3_10 

use "stata_w_labs\EXCEED_DemographicCore_v0001_20211101", clear
*N=9,919
**Age? Cannot find age query this? Exceed recruted between 40-65 in 2013 so should be present?
**Education? Cannot find age query this? Exceed recruted between 40-65 in 2013 so should be present?

**gender
tab gen2
**ethnicity
tab gen5
**living arrangement?
tab s4_1_0 
tab s4_1_1 
tab s4_1_2 
tab s4_1_3 
tab s4_1_99
tab s2_4a_exceed 
tab s4_8 
tab s4_9


use "stata_w_labs\EXCEED_occupation_v0001_20210723", clear
**N= 3526
**SOC2010 4 digit for entered job -dates say entered during pandemic.  
tab soc2010


*********************************
**GENERATION SCOTLAND
use "stata_w_labs\GENSCOT_COVIDLIFE1_v0001_20211101", clear
use "stata_w_labs\GENSCOT_COVIDLIFE2_v0001_20211101", clear
use "stata_w_labs\GENSCOT_COVIDLIFE3_v0001_20211101", clear
use "stata_w_labs\GENSCOT_DEMOGRAPHICS_v0001_20211101", clear
use "stata_w_labs\GENSCOT_DISEASE_v0001_20211101", clear
use "stata_w_labs\GENSCOT_ETHNIC_v0001_20211101", clear
use "stata_w_labs\GENSCOT_HOUSEHOLD_v0001_20211101", clear
use "stata_w_labs\GENSCOT_OCCUPATION_v0001_20211101", clear

*********************************
**THE GENETIC LINKS TO ANXEITY AND DEPRESSION (GLAD) STUDY
use "stata_w_labs\GLAD_FILE2_v0001_20211101", clear
*N=36,922
*N=13,100 with covid response
*startdate_coping startdate_prepandemic

**Age
tab age if startdate_coping!=""
tab age_category if startdate_coping!=""


**sex/gender
tab sex if startdate_coping!=""
tab gender if startdate_coping!=""

**ethnicity
tab ethnicity

**education/qualifications 
tab eduyrs 
tab highest_education 
tab highest_education_prepan

**key woker status
tab key_worker 
tab employment_government_work_key_w

**furlough
tab employment_furloughed_or_paid_le 
tab v71 
tab v72 
tab v73 
tab employment_paid_leave_furloughed 
tab v89

**emplyment status
foreach var of varlist employment_became_employed employment_became_unemployed employment_change employment_contract_or_freelance employment_fulltime_employed employment_furloughed_or_paid_le v72 employment_government_work_key_w employment_increased_hours employment_increased_salary employment_my_employment_status_ employment_parttime_employed employment_retired employment_selfemployed employment_small_business_owner_ employment_stayathome_parent_or_ employment_student_gcse_or_a_lev employment_student_university employment_unemployed employment_zerohours_contract {
	tab `var'
}


**********************************
**THE MILLENIUM COHORT
use "stata_w_labs\MCS_basic_demographic_cm_v0001_20211101", clear
use "stata_w_labs\MCS_basic_demographic_parent_v0001_20211101", clear
use "stata_w_labs\MCS_COVID_w1_v0001_20211101", clear
use "stata_w_labs\MCS_COVID_w2_v0001_20211101", clear
use "stata_w_labs\MCS_COVID_w3_v0001_20211101", clear
use "stata_w_labs\MCS_mcs7_cm_interview_v0001_20211101", clear


**THE 1958 NATIONAL CHILD DEVELOPMENT STUDY (NCDS)
use "stata_w_labs\NCDS58_basic_demographic_v0001_20211101", clear
use "stata_w_labs\NCDS58_COVID_w1_v0001_20211101", clear
use "stata_w_labs\NCDS58_COVID_w2_v0001_20211101", clear
use "stata_w_labs\NCDS58_COVID_w3_v0001_20211101", clear
use "stata_w_labs\NCDS58_ncds9_derived_v0001_20211101", clear
use "stata_w_labs\NCDS58_ncds9_employment_v0001_20211101", clear
use "stata_w_labs\NCDS58_ncds9_housing_v0001_20211101", clear
use "stata_w_labs\NCDS58_ncds9_qualifications_v0001_20211101", clear



**THE NEXT STEPS
use "stata_w_labs\NEXTSTEP_basic_demographic_data_v0001_20211101", clear
use "stata_w_labs\NEXTSTEP_COVID_w1_v0001_20211101", clear
use "stata_w_labs\NEXTSTEP_COVID_w2_v0001_20211101", clear
use "stata_w_labs\NEXTSTEP_COVID_w3_v0001_20211101", clear
use "stata_w_labs\NEXTSTEP_ns8_derived_v0001_20211101", clear
use "stata_w_labs\NEXTSTEP_ns8_household_members_v0001_20211101", clear

**NORTHERN IRELAND COHORT FOR THE LONGITUDINAL STUDY OF AGEING (NICOLA)
*use "stata_w_labs\NICOLA_Covid_19Questionnaire_v0001_20211101", clear
*use "stata_w_labs\NICOLA_Wave1CAPI_v0001_20211101", clear
*use "stata_w_labs\NICOLA_Wave2CAPI_v0001_20220302", clear

**THE NIHR BIOREASOURCE COVID-19 PSYCHIATRY AND NEUROLOGICAL GENETICS (COPING) STUDY
use "stata_w_labs\NIHRBIO_COPING_Bioresource_v0001_20210719", clear
*N=13,821 
count
** dates startdate_coping startdate_prepandemic
count if startdate_coping!=""


**Age
tab age 
tab age_category if startdate_coping!="" 

**sex/gender
tab sex if startdate_coping!="" 
tab gender if startdate_coping!="" 

**ethnicity
tab ethnicity

**education/qualifications 
tab eduyrs 
tab highest_education 
tab highest_education_prepan

**key woker status
tab key_worker 
tab employment_government_work_key_w

**furlough
tab employment_furloughed_or_paid_le 
tab v71 
tab v72 
tab v73 
tab employment_paid_leave_furloughed 
tab v89

**emplyment status
foreach var of varlist employment_became_employed employment_became_unemployed employment_change employment_contract_or_freelance employment_fulltime_employed employment_furloughed_or_paid_le v72 employment_government_work_key_w employment_increased_hours employment_increased_salary employment_my_employment_status_ employment_parttime_employed employment_retired employment_selfemployed employment_small_business_owner_ employment_stayathome_parent_or_ employment_student_gcse_or_a_lev employment_student_university employment_unemployed employment_zerohours_contract {
	tab `var'
}


************************************************
*THE TRACK COVID-19 STUDY

*baseline assessment of covid infection self-reported
use "stata_w_labs\TRACKC19_baseline_v0001_20210915", clear
*N=18,134
count


use "stata_w_labs\TRACKC19_basicInfo_v0001_20210915", clear
*N=19,635
count

tab ethnicity 
tab age 
tab sex

use "stata_w_labs\TRACKC19_followUp_v0001_20210915", clear
*N=161,073 (multiple responses per peron, appears monthly between July 2020 and oct 2021
count
*N=16,014 individuals
tab follnum




************************************************
**TWINS UK STUDY
use "stata_w_labs\TWINSUK_COPE1_v0001_20211101", clear



**NHS DATA
use "stata_w_labs\nhsd_CHESS_v0001", clear
use "stata_w_labs\nhsd_COVIDSGSS_v0001", clear
use "stata_w_labs\nhsd_CVS_v0001", clear
use "stata_w_labs\nhsd_DEMOGRAPHICS_20220106", clear
use "stata_w_labs\nhsd_DEMOGRAPHICS_SUB_20220302", clear
use "stata_w_labs\nhsd_GDPPR_v0001", clear
use "stata_w_labs\nhsd_IELISA_v0001", clear
use "stata_w_labs\nhsd_MORTALITY_20220106", clear
use "stata_w_labs\nhsd_NPEX_v0001", clear
