

********************************************************************************
**DATA FORMATING AND MANIPULATION 
********************************************************************************

cd "S:\LLC_0007\data\"


**********************************************************************************
**NHS DATA - Format and Set up

*Notes
**Pillar 1 - Health Care worker swab testing 
**Pillar 2 - Gen Pop swab testing 
**Pillar 3 - serology C19 antibody testing 



********************************************************************************
**Demographics - not currently needed
use "stata_w_labs\nhsd_DEMOGRAPHICS_20220106", clear
**Domgraphic info inc dob, gender and some derived variables including dod (year and mth)
count
codebook, compact

use "stata_w_labs\nhsd_DEMOGRAPHICS_SUB_20220302", clear
**Simply DOB Y/M, and gender 
count
codebook, compact


************************************************************************************
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

**Gen Any positive test - Note CHESS only hosptialised patients with COVID so all positive
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

**appear to be be multiple responses per person - all data appears the same in each for now keep first
keep if testno_chess==1


**Number of within peron positive test - same as person tests and should be one per person
bysort c19positive_chess llc_0007_stud_id: egen testposno_chess=seq() 
label var testposno_chess "Num of positive tests per person"
tab testposno_chess

**Create Source id
gen source=4
label define source 1 "NPEX (P2)" 2 "IELISA (P3)" 3 "SSGS (P1/2)" 4 "CHESS (hosp)", replace
label values source source

bysort llc_0007_stud_id testdate: egen repeated=seq()
tab repeated
list llc_0007_stud_id if repeated>10

**create focused data for merge
*remove tag for later merge
keep llc_0007_stud_id *_chess source 
rename *_npex *
sort llc_0007_stud_id


save "NHS edited\CHESS_protect_temp", replace






********************************************************************************
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

**create focused data for merge
keep llc_0007_stud_id vaccination_procedure_term_cvs site_of_vaccination_term_cvs vaccination_procedure_term_cvs vaccine_product_term_cvs event_received_ts_cvs dose_sequence
rename *_cvs *
sort llc_0007_stud_id
save "NHS edited\CVS_protect_temp", replace




********************************************************************************
**NHS Digital GDPPR Data for Pandemic Planning and Reserach (C-19)
**Not sure this is useful, contains mostly repeated demographic info
use "stata_w_labs\nhsd_GDPPR_v0001", clear
count
codebook, compact



********************************************************************************
**Mortality - NHS Digital Civil Registration - Death
use "stata_w_labs\nhsd_MORTALITY_20220106", clear
count
codebook, compact

**date of death
tostring reg_date_of_death, replace 
gen reg_date_of_death_mor=date(reg_date_of_death, "YMD")
format %td reg_date_of_death_mor

hist reg_date_of_death_mor if reg_date_of_death_mor>=date("01/01/2020", "DMY")

**create focused data for merge
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

**possible worker info - cannot find any coding info for this
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

**Create source id
gen source=1
label define source 1 "NPEX (P2)" 2 "IELISA (P3)" 3 "SSGS (P1/2)"  4 "CHESS (hosp)", replace
label values source source

bysort llc_0007_stud_id testdate: egen repeated=seq()
tab repeated
list llc_0007_stud_id if repeated>10

**Create focused data for merge
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

**Create source id
gen source=2
label define source 1 "NPEX (P2)" 2 "IELISA (P3)" 3 "SSGS (P1/2)"  4 "CHESS (hosp)", replace
label values source source
tab source

bysort llc_0007_stud_id testdate: egen repeated=seq()
tab repeated
list llc_0007_stud_id if repeated>10

**Create foused data for merge
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


**Seems to have been used to identify only those with SARS-CoV2 (as Identified by SSGS Pillar 1 and Pillar 2) 
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

**Create source id variable
gen source=3
label define source 1 "NPEX (P2)" 2 "IELISA (P3)" 3 "SSGS (P1/2)" 4 "CHESS (hosp)", replace
label values source source
tab source

**focus data for merge
keep llc_0007_stud_id *_ssgs source
rename *_ssgs *
sort llc_0007_stud_id
save "NHS edited\ssgs_protect_temp", replace
