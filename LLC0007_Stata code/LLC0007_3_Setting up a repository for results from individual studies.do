
 
 
********************************************************************************
**SETTING UP REPOSTITORY OF RESULTS FILE
**STORING THE OVERALL META-EFFECT ESTIMATE FOR META-ANALYSIS COMBINATION
******************************************************************************** 
 
clear
set obs 40
gen id=_n
gen effect_id=_n

label define effect_id 1 "kw_sr_ua" 2 "kw_sr_aj" 3 "kw_lr_ua" 4 "kw_lr_aj" 5 "ret_sr_ua" 6 "ret_sr_aj" 7 "ret_lr_ua" 8 "ret_lr_aj" 9 "un_sr_ua" 10 "un_sr_aj" 11 "un_lr_ua" 12 "un_lr_aj" 13 "pt_sr_ua" 14 "pt_sr_aj" 15 "pt_lr_ua" 16 "pt_lr_aj" 17 "rt_sr_ua" 18 "rt_sr_aj" 19 "rt_lr_ua" 20 "rt_lr_aj" 21 "nw_sr_ua" 22 "nw_sr_aj" 23 "nw_lr_ua" 24 "nw_lr_aj" 25 "une_sr_ua" 26 "une_sr_aj" 27 "une_lr_ua" 28 "une_lr_aj" 29 "sh_sr_ua" 30 "sh_sr_aj" 31 "sh_lr_ua" 32 "sh_lr_aj" 33 "nh_sr_ua" 34 "nh_sr_aj" 35 "nh_lr_ua" 36 "nh_lr_aj" 37 "fr_sr_ua" 38 "fr_sr_aj" 39 "fr_lr_ua" 40 "fr_lr_aj", replace 
label values effect_id effect_id


expand 3
bysort effect_id: egen time_tranche=seq()
label define time_tranche 1 "Overall" 2 "Apr-Oct20" 3 "Nov-Mar21", replace
label values time_tranche time_tranche
tab time_tranche
gen effect=.
gen se=.

*keyworker
*retired v employed
*unemployed vs employed
*part time v full time
*retired v full time
*Employed but not working v fulltime 
*Unemployed v fulltime
*Some v all hm working
*none v all hm working
*furlough


save "S:\LLC_0007\data\metaresults_datafile time-tranche", replace


********************************************************************************
**SETTING UP SECOND STAGE FILE
**STORING THE EFFECT ESTIMATE FOR META-ANALYSIS COMBINATION
********************************************************************************

clear

set obs 19
gen id=_n
gen study_id=_n

label define study_id 0 "Total" 1 "ELSA" 2 "UKHLS" 3 "BCS70" 4 "MCS" 5 "NCDS58" 6 "NextSteps" 7 "BIB" 8 "GENSCOT" 9 "EXCEED" 10 "NICOLA"  11 "COPING" 12 "GLAD" 13 "TRACK-C19" 14 "TWINSUK" 15 "ALSPAC" 16 "MCS-Member" 17 "MCS-Parents" 18 "ALSPAC-Mem" 19 "ALSPAC-Mothers", replace 
label values study_id study_id


gen study_lab=""
replace study_lab="English Longitudinal Study of Ageing" if study_id==1
replace study_lab="Understanding Society" if study_id==2
replace study_lab="British Cohort Study 1970" if study_id==3
replace study_lab="Milenium Cohort Study-All" if study_id==4
replace study_lab="National Child Development Study 1958" if study_id==5
replace study_lab="Next Steps" if study_id==6
replace study_lab="Born in Bradford" if study_id==7
replace study_lab="Generation Scotlant" if study_id==8
replace study_lab="The Extended Cohort for E-health, Envirnoment, and DNA (EXCEED)" if study_id==9
replace study_lab="Nortern Ireland Cohort for the Longitudinal Study of Ageing" if study_id==10
replace study_lab="The NIHR Bioresource COVID-19 Psychiatry and Neurological Genetics(COPING) Study" if study_id==11
replace study_lab="The Genetic Links to Anxeity and Depression (GLAD) Study" if study_id==12
replace study_lab="The Track COVID-19 Study" if study_id==13
replace study_lab="TWINS UK Study" if study_id==14
replace study_lab="Avon Longitudinal Study of Parents & Children" if study_id==15
replace study_lab="Millenium Cohort Study-Cohort Members" if study_id==16
replace study_lab="Millenium Cohort Study-Parents" if study_id==17
replace study_lab="Avon Longitudinal Study of Parents & Children-Members" if study_id==18
replace study_lab="Avon Longitudinal Study of Parents & Children-Mothers" if study_id==19


label var study_lab "Study Name/details"

**Gen decoded version to aid meta-analysis
decode study_id, gen(study_name)

**Generate Variables represented results - to be filled

gen sample_n = .
label var sample_n "No. Participants"
gen entry_n = .
label var entry_n "No. entries i.e participants*waves"
gen selfinf_n=.
label var selfinf_n "No. Report Self-Infection"
gen selfpos_no=.
label var selfpos_no "No. Report Pos-test"
gen linkpos_no=.
label var selfpos_no "No. NHS linked data Pos-test"

expand 6
bysort study_id: egen time_tranche=seq()
label define time_tranche 1 "Overall" 2 "Apr-June20" 3 "Jul-Oct20" 4 "Nov20-Mar21" 5 "Apr-Oct20" 6 "Nov20-Mar21"
label values time_tranche time_tranche
label var time_tranche "Define time-period effect relates to"
sort time_tranche study_id 

order id time_tranche study_id

****************************
***SOC 2010 1d

*1. Managers, Directors, & Senior Off ==REF Cat
*2. Prof Occupations 
**Self-Reported Infection
**unadjusted
gen sr_s101d2_eff=.
label var sr_s101d2_eff "Self-rep unadjusted effect (Prof Occupations v SOC1-Managers)"
gen sr_s101d2_se=.
label var sr_s101d2_se "Self-rep unadjusted S.E (Prof Occupations v SOC1-Managers)"


**adjusted
gen sr_s101d2_adj_eff=.
label var sr_s101d2_adj_eff "Self-rep adjusted effect (Prof Occupations v SOC1-Managers)"
gen sr_s101d2_adj_se=.
label var sr_s101d2_adj_se "Self-rep adjusted SE (Prof Occupations v SOC1-Managers)"

**Linked Positive Test
**unadjusted
gen lr_s101d2_eff=.
label var lr_s101d2_eff "link_pos unadjusted effect (Prof Occupations v SOC1-Managers)"
gen lr_s101d2_se=.
label var lr_s101d2_eff "link_pos unadjusted S.E (Prof Occupations v SOC1-Managers)"

**adjusted
gen lr_s101d2_adj_eff=.
label var lr_s101d2_adj_eff "link_pos adjusted effect (Prof Occupations v SOC1-Managers)"
gen lr_s101d2_adj_se=.
label var lr_s101d2_adj_se "link_pos adjusted SE (Prof Occupations v SOC1-Managers)"

*3. Associate Prof & Technical Occup 
**Self-Reported Infection
**unadjusted
gen sr_s101d3_eff=.
label var sr_s101d3_eff "Self-rep unadjusted effect (Associate Prof & Technical Occup  v SOC1-Managers)"
gen sr_s101d3_se=.
label var sr_s101d3_se "Self-rep unadjusted S.E (Associate Prof & Technical Occup  v SOC1-Managers)"


**adjusted
gen sr_s101d3_adj_eff=.
label var sr_s101d3_adj_eff "Self-rep adjusted effect (Associate Prof & Technical Occup  v SOC1-Managers)"
gen sr_s101d3_adj_se=.
label var sr_s101d3_adj_se "Self-rep adjusted SE (Associate Prof & Technical Occup  v SOC1-Managers)"

**Linked Positive Test
**unadjusted
gen lr_s101d3_eff=.
label var lr_s101d3_eff "link_pos unadjusted effect (Associate Prof & Technical Occup  v SOC1-Managers)"
gen lr_s101d3_se=.
label var lr_s101d3_eff "link_pos unadjusted S.E (Associate Prof & Technical Occup  v SOC1-Managers)"

**adjusted
gen lr_s101d3_adj_eff=.
label var lr_s101d3_adj_eff "link_pos adjusted effect (Associate Prof & Technical Occup  v SOC1-Managers)"
gen lr_s101d3_adj_se=.
label var lr_s101d3_adj_se "link_pos adjusted SE (Associate Prof & Technical Occup  v SOC1-Managers)"
*4. Administrative and Secretarial 
**Self-Reported Infection
**unadjusted
gen sr_s101d4_eff=.
label var sr_s101d4_eff "Self-rep unadjusted effect (Administrative and Secretarial  v SOC1-Managers)"
gen sr_s101d4_se=.
label var sr_s101d4_se "Self-rep unadjusted S.E (Administrative and Secretarial  v SOC1-Managers)"


**adjusted
gen sr_s101d4_adj_eff=.
label var sr_s101d4_adj_eff "Self-rep adjusted effect (Administrative and Secretarial  v SOC1-Managers)"
gen sr_s101d4_adj_se=.
label var sr_s101d4_adj_se "Self-rep adjusted SE (Administrative and Secretarial  v SOC1-Managers)"

**Linked Positive Test
**unadjusted
gen lr_s101d4_eff=.
label var lr_s101d4_eff "link_pos unadjusted effect (Administrative and Secretarial  v SOC1-Managers)"
gen lr_s101d4_se=.
label var lr_s101d4_eff "link_pos unadjusted S.E (Administrative and Secretarial  v SOC1-Managers)"

**adjusted
gen lr_s101d4_adj_eff=.
label var lr_s101d4_adj_eff "link_pos adjusted effect (Administrative and Secretarial  v SOC1-Managers)"
gen lr_s101d4_adj_se=.
label var lr_s101d4_adj_se "link_pos adjusted SE (Administrative and Secretarial  v SOC1-Managers)"
*5. Skilled Trades 
**Self-Reported Infection
**unadjusted
gen sr_s101d5_eff=.
label var sr_s101d5_eff "Self-rep unadjusted effect (Skilled Trades v SOC1-Managers)"
gen sr_s101d5_se=.
label var sr_s101d5_se "Self-rep unadjusted S.E (Skilled Trades v SOC1-Managers)"


**adjusted
gen sr_s101d5_adj_eff=.
label var sr_s101d5_adj_eff "Self-rep adjusted effect (Skilled Trades v SOC1-Managers)"
gen sr_s101d5_adj_se=.
label var sr_s101d5_adj_se "Self-rep adjusted SE (Skilled Trades v SOC1-Managers)"

**Linked Positive Test
**unadjusted
gen lr_s101d5_eff=.
label var lr_s101d5_eff "link_pos unadjusted effect (Skilled Trades v SOC1-Managers)"
gen lr_s101d5_se=.
label var lr_s101d5_eff "link_pos unadjusted S.E (Skilled Trades v SOC1-Managers)"

**adjusted
gen lr_s101d5_adj_eff=.
label var lr_s101d5_adj_eff "link_pos adjusted effect (Skilled Trades v SOC1-Managers)"
gen lr_s101d5_adj_se=.
label var lr_s101d5_adj_se "link_pos adjusted SE (Skilled Trades v SOC1-Managers)"
*6. Caring, Leisure, and Other Service 
**Self-Reported Infection
**unadjusted
gen sr_s101d6_eff=.
label var sr_s101d6_eff "Self-rep unadjusted effect (Caring, Leisure, and Other Service  v SOC1-Managers)"
gen sr_s101d6_se=.
label var sr_s101d6_se "Self-rep unadjusted S.E (Caring, Leisure, and Other Service  v SOC1-Managers)"


**adjusted
gen sr_s101d6_adj_eff=.
label var sr_s101d6_adj_eff "Self-rep adjusted effect (Caring, Leisure, and Other Service  v SOC1-Managers)"
gen sr_s101d6_adj_se=.
label var sr_s101d6_adj_se "Self-rep adjusted SE (Caring, Leisure, and Other Service  v SOC1-Managers)"

**Linked Positive Test
**unadjusted
gen lr_s101d6_eff=.
label var lr_s101d6_eff "link_pos unadjusted effect (Caring, Leisure, and Other Service  v SOC1-Managers)"
gen lr_s101d6_se=.
label var lr_s101d6_eff "link_pos unadjusted S.E (Caring, Leisure, and Other Service  v SOC1-Managers)"

**adjusted
gen lr_s101d6_adj_eff=.
label var lr_s101d6_adj_eff "link_pos adjusted effect (Caring, Leisure, and Other Service  v SOC1-Managers)"
gen lr_s101d6_adj_se=.
label var lr_s101d6_adj_se "link_pos adjusted SE (Caring, Leisure, and Other Service  v SOC1-Managers)"
*7. Sales and Customer Serv 
**Self-Reported Infection
**unadjusted
gen sr_s101d7_eff=.
label var sr_s101d7_eff "Self-rep unadjusted effect (Sales and Customer Serv v SOC1-Managers)"
gen sr_s101d7_se=.
label var sr_s101d7_se "Self-rep unadjusted S.E (Sales and Customer Serv v SOC1-Managers)"


**adjusted
gen sr_s101d7_adj_eff=.
label var sr_s101d7_adj_eff "Self-rep adjusted effect (Sales and Customer Serv v SOC1-Managers)"
gen sr_s101d7_adj_se=.
label var sr_s101d7_adj_se "Self-rep adjusted SE (Sales and Customer Serv v SOC1-Managers)"

**Linked Positive Test
**unadjusted
gen lr_s101d7_eff=.
label var lr_s101d7_eff "link_pos unadjusted effect (Sales and Customer Serv v SOC1-Managers)"
gen lr_s101d7_se=.
label var lr_s101d7_eff "link_pos unadjusted S.E (Sales and Customer Serv v SOC1-Managers)"

**adjusted
gen lr_s101d7_adj_eff=.
label var lr_s101d7_adj_eff "link_pos adjusted effect (Sales and Customer Serv v SOC1-Managers)"
gen lr_s101d7_adj_se=.
label var lr_s101d7_adj_se "link_pos adjusted SE (Sales and Customer Serv v SOC1-Managers)"
*8. Process, Plant, and Machine Operativ 
**Self-Reported Infection
**unadjusted
gen sr_s101d8_eff=.
label var sr_s101d8_eff "Self-rep unadjusted effect (Process, Plant, and Machine Operativ v SOC1-Managers)"
gen sr_s101d8_se=.
label var sr_s101d8_se "Self-rep unadjusted S.E (Process, Plant, and Machine Operativ v SOC1-Managers)"


**adjusted
gen sr_s101d8_adj_eff=.
label var sr_s101d8_adj_eff "Self-rep adjusted effect (Process, Plant, and Machine Operativ v SOC1-Managers)"
gen sr_s101d8_adj_se=.
label var sr_s101d8_adj_se "Self-rep adjusted SE (Process, Plant, and Machine Operativ v SOC1-Managers)"

**Linked Positive Test
**unadjusted
gen lr_s101d8_eff=.
label var lr_s101d8_eff "link_pos unadjusted effect (Process, Plant, and Machine Operativ v SOC1-Managers)"
gen lr_s101d8_se=.
label var lr_s101d8_eff "link_pos unadjusted S.E (Process, Plant, and Machine Operativ v SOC1-Managers)"

**adjusted
gen lr_s101d8_adj_eff=.
label var lr_s101d8_adj_eff "link_pos adjusted effect (Process, Plant, and Machine Operativ v SOC1-Managers)"
gen lr_s101d8_adj_se=.
label var lr_s101d8_adj_se "link_pos adjusted SE (Process, Plant, and Machine Operativ v SOC1-Managers)"
*9. Elementary Occupations
**Self-Reported Infection
**unadjusted
gen sr_s101d9_eff=.
label var sr_s101d9_eff "Self-rep unadjusted effect (Elementary Occupations v SOC1-Managers)"
gen sr_s101d9_se=.
label var sr_s101d9_se "Self-rep unadjusted S.E (Elementary Occupations v SOC1-Managers)"


**adjusted
gen sr_s101d9_adj_eff=.
label var sr_s101d9_adj_eff "Self-rep adjusted effect (Elementary Occupations v SOC1-Managers)"
gen sr_s101d9_adj_se=.
label var sr_s101d9_adj_se "Self-rep adjusted SE (Elementary Occupations v SOC1-Managers)"

**Linked Positive Test
**unadjusted
gen lr_s101d9_eff=.
label var lr_s101d9_eff "link_pos unadjusted effect (Elementary Occupations v SOC1-Managers)"
gen lr_s101d9_se=.
label var lr_s101d9_eff "link_pos unadjusted S.E (Elementary Occupations v SOC1-Managers)"

**adjusted
gen lr_s101d9_adj_eff=.
label var lr_s101d9_adj_eff "link_pos adjusted effect (Elementary Occupations v SOC1-Managers)"
gen lr_s101d9_adj_se=.
label var lr_s101d9_adj_se "link_pos adjusted SE (Elementary Occupations v SOC1-Managers)"


****************************
***SOC 2010 2d

*11. Corporate Managers = REF Cat
*12. Other Managers and Proprietors in A
**Self-Reported Infection
**unadjusted
gen sr_s102d12_eff=.
label var sr_s102d12_eff "Self-rep unadjusted effect (Other Managers and Proprietors in A v SOC11-Corporate Man)"
gen sr_s102d12_se=.
label var sr_s102d12_se "Self-rep unadjusted S.E (Other Managers and Proprietors in A v SOC11-Corporate Man)"


**adjusted
gen sr_s102d12_adj_eff=.
label var sr_s102d12_adj_eff "Self-rep adjusted effect (Other Managers and Proprietors in A v SOC11-Corporate Man)"
gen sr_s102d12_adj_se=.
label var sr_s102d12_adj_se "Self-rep adjusted SE (Other Managers and Proprietors in A v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d12_eff=.
label var lr_s102d12_eff "link_pos unadjusted effect (Other Managers and Proprietors in A v SOC11-Corporate Man)"
gen lr_s102d12_se=.
label var lr_s102d12_eff "link_pos unadjusted S.E (Other Managers and Proprietors in A v SOC11-Corporate Man)"

**adjusted
gen lr_s102d12_adj_eff=.
label var lr_s102d12_adj_eff "link_pos adjusted effect (Other Managers and Proprietors in A v SOC11-Corporate Man)"
gen lr_s102d12_adj_se=.
label var lr_s102d12_adj_se "link_pos adjusted SE (Other Managers and Proprietors in A v SOC11-Corporate Man)"

*21. Science, res, and Tech Prof
**Self-Reported Infection
**unadjusted
gen sr_s102d21_eff=.
label var sr_s102d21_eff "Self-rep unadjusted effect (Science, res, and Tech Prof v SOC11-Corporate Man)"
gen sr_s102d21_se=.
label var sr_s102d21_se "Self-rep unadjusted S.E (Science, res, and Tech Prof v SOC11-Corporate Man)"


**adjusted
gen sr_s102d21_adj_eff=.
label var sr_s102d21_adj_eff "Self-rep adjusted effect (Science, res, and Tech Prof v SOC11-Corporate Man)"
gen sr_s102d21_adj_se=.
label var sr_s102d21_adj_se "Self-rep adjusted SE (Science, res, and Tech Prof v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d21_eff=.
label var lr_s102d21_eff "link_pos unadjusted effect (Science, res, and Tech Prof v SOC11-Corporate Man)"
gen lr_s102d21_se=.
label var lr_s102d21_eff "link_pos unadjusted S.E (Science, res, and Tech Prof v SOC11-Corporate Man)"

**adjusted
gen lr_s102d21_adj_eff=.
label var lr_s102d21_adj_eff "link_pos adjusted effect (Science, res, and Tech Prof v SOC11-Corporate Man)"
gen lr_s102d21_adj_se=.
label var lr_s102d21_adj_se "link_pos adjusted SE (Science, res, and Tech Prof v SOC11-Corporate Man)"

*22. Health Prof
**Self-Reported Infection
**unadjusted
gen sr_s102d22_eff=.
label var sr_s102d22_eff "Self-rep unadjusted effect (Health Prof v SOC11-Corporate Man)"
gen sr_s102d22_se=.
label var sr_s102d22_se "Self-rep unadjusted S.E (Health Prof v SOC11-Corporate Man)"


**adjusted
gen sr_s102d22_adj_eff=.
label var sr_s102d22_adj_eff "Self-rep adjusted effect (Health Prof v SOC11-Corporate Man)"
gen sr_s102d22_adj_se=.
label var sr_s102d22_adj_se "Self-rep adjusted SE (Health Prof v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d22_eff=.
label var lr_s102d22_eff "link_pos unadjusted effect (Health Prof v SOC11-Corporate Man)"
gen lr_s102d22_se=.
label var lr_s102d22_eff "link_pos unadjusted S.E (Health Prof v SOC11-Corporate Man)"

**adjusted
gen lr_s102d22_adj_eff=.
label var lr_s102d22_adj_eff "link_pos adjusted effect (Health Prof v SOC11-Corporate Man)"
gen lr_s102d22_adj_se=.
label var lr_s102d22_adj_se "link_pos adjusted SE (Health Prof v SOC11-Corporate Man)"

*23. Teaching and Educa Prof
**Self-Reported Infection
**unadjusted
gen sr_s102d23_eff=.
label var sr_s102d23_eff "Self-rep unadjusted effect (Teaching and Educa Prof v SOC11-Corporate Man)"
gen sr_s102d23_se=.
label var sr_s102d23_se "Self-rep unadjusted S.E (Teaching and Educa Prof v SOC11-Corporate Man)"


**adjusted
gen sr_s102d23_adj_eff=.
label var sr_s102d23_adj_eff "Self-rep adjusted effect (Teaching and Educa Prof v SOC11-Corporate Man)"
gen sr_s102d23_adj_se=.
label var sr_s102d23_adj_se "Self-rep adjusted SE (Teaching and Educa Prof v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d23_eff=.
label var lr_s102d23_eff "link_pos unadjusted effect (Teaching and Educa Prof v SOC11-Corporate Man)"
gen lr_s102d23_se=.
label var lr_s102d23_eff "link_pos unadjusted S.E (Teaching and Educa Prof v SOC11-Corporate Man)"

**adjusted
gen lr_s102d23_adj_eff=.
label var lr_s102d23_adj_eff "link_pos adjusted effect (Teaching and Educa Prof v SOC11-Corporate Man)"
gen lr_s102d23_adj_se=.
label var lr_s102d23_adj_se "link_pos adjusted SE (Teaching and Educa Prof v SOC11-Corporate Man)"

*24. Buisness and Public Services Prof
**Self-Reported Infection
**unadjusted
gen sr_s102d24_eff=.
label var sr_s102d24_eff "Self-rep unadjusted effect (Buisness and Public Services Prof v SOC11-Corporate Man)"
gen sr_s102d24_se=.
label var sr_s102d24_se "Self-rep unadjusted S.E (Buisness and Public Services Prof v SOC11-Corporate Man)"


**adjusted
gen sr_s102d24_adj_eff=.
label var sr_s102d24_adj_eff "Self-rep adjusted effect (Buisness and Public Services Prof v SOC11-Corporate Man)"
gen sr_s102d24_adj_se=.
label var sr_s102d24_adj_se "Self-rep adjusted SE (Buisness and Public Services Prof v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d24_eff=.
label var lr_s102d24_eff "link_pos unadjusted effect (Buisness and Public Services Prof v SOC11-Corporate Man)"
gen lr_s102d24_se=.
label var lr_s102d24_eff "link_pos unadjusted S.E (Buisness and Public Services Prof v SOC11-Corporate Man)"

**adjusted
gen lr_s102d24_adj_eff=.
label var lr_s102d24_adj_eff "link_pos adjusted effect (Buisness and Public Services Prof v SOC11-Corporate Man)"
gen lr_s102d24_adj_se=.
label var lr_s102d24_adj_se "link_pos adjusted SE (Buisness and Public Services Prof v SOC11-Corporate Man)"

*31. Science and Tech A-Prof
**Self-Reported Infection
**unadjusted
gen sr_s102d31_eff=.
label var sr_s102d31_eff "Self-rep unadjusted effect (Science and Tech A-Prof v SOC11-Corporate Man)"
gen sr_s102d31_se=.
label var sr_s102d31_se "Self-rep unadjusted S.E (Science and Tech A-Prof v SOC11-Corporate Man)"


**adjusted
gen sr_s102d31_adj_eff=.
label var sr_s102d31_adj_eff "Self-rep adjusted effect (Science and Tech A-Prof v SOC11-Corporate Man)"
gen sr_s102d31_adj_se=.
label var sr_s102d31_adj_se "Self-rep adjusted SE (Science and Tech A-Prof v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d31_eff=.
label var lr_s102d31_eff "link_pos unadjusted effect (Science and Tech A-Prof v SOC11-Corporate Man)"
gen lr_s102d31_se=.
label var lr_s102d31_eff "link_pos unadjusted S.E (Science and Tech A-Prof v SOC11-Corporate Man)"

**adjusted
gen lr_s102d31_adj_eff=.
label var lr_s102d31_adj_eff "link_pos adjusted effect (Science and Tech A-Prof v SOC11-Corporate Man)"
gen lr_s102d31_adj_se=.
label var lr_s102d31_adj_se "link_pos adjusted SE (Science and Tech A-Prof v SOC11-Corporate Man)"

*32. Health and Social Welfare A-Prof
**Self-Reported Infection
**unadjusted
gen sr_s102d32_eff=.
label var sr_s102d32_eff "Self-rep unadjusted effect (Health and Social Welfare A-Prof v SOC11-Corporate Man)"
gen sr_s102d32_se=.
label var sr_s102d32_se "Self-rep unadjusted S.E (Health and Social Welfare A-Prof v SOC11-Corporate Man)"


**adjusted
gen sr_s102d32_adj_eff=.
label var sr_s102d32_adj_eff "Self-rep adjusted effect (Health and Social Welfare A-Prof v SOC11-Corporate Man)"
gen sr_s102d32_adj_se=.
label var sr_s102d32_adj_se "Self-rep adjusted SE (Health and Social Welfare A-Prof v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d32_eff=.
label var lr_s102d32_eff "link_pos unadjusted effect (Health and Social Welfare A-Prof v SOC11-Corporate Man)"
gen lr_s102d32_se=.
label var lr_s102d32_eff "link_pos unadjusted S.E (Health and Social Welfare A-Prof v SOC11-Corporate Man)"

**adjusted
gen lr_s102d32_adj_eff=.
label var lr_s102d32_adj_eff "link_pos adjusted effect (Health and Social Welfare A-Prof v SOC11-Corporate Man)"
gen lr_s102d32_adj_se=.
label var lr_s102d32_adj_se "link_pos adjusted SE (Health and Social Welfare A-Prof v SOC11-Corporate Man)"

*33. Protective Services
**Self-Reported Infection
**unadjusted
gen sr_s102d33_eff=.
label var sr_s102d33_eff "Self-rep unadjusted effect (Protective Services v SOC11-Corporate Man)"
gen sr_s102d33_se=.
label var sr_s102d33_se "Self-rep unadjusted S.E (Protective Services v SOC11-Corporate Man)"


**adjusted
gen sr_s102d33_adj_eff=.
label var sr_s102d33_adj_eff "Self-rep adjusted effect (Protective Services v SOC11-Corporate Man)"
gen sr_s102d33_adj_se=.
label var sr_s102d33_adj_se "Self-rep adjusted SE (Protective Services v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d33_eff=.
label var lr_s102d33_eff "link_pos unadjusted effect (Protective Services v SOC11-Corporate Man)"
gen lr_s102d33_se=.
label var lr_s102d33_eff "link_pos unadjusted S.E (Protective Services v SOC11-Corporate Man)"

**adjusted
gen lr_s102d33_adj_eff=.
label var lr_s102d33_adj_eff "link_pos adjusted effect (Protective Services v SOC11-Corporate Man)"
gen lr_s102d33_adj_se=.
label var lr_s102d33_adj_se "link_pos adjusted SE (Protective Services v SOC11-Corporate Man)"

*34. Culture, Media, Sports Occ
**Self-Reported Infection
**unadjusted
gen sr_s102d34_eff=.
label var sr_s102d34_eff "Self-rep unadjusted effect (Culture, Media, Sports Occ v SOC11-Corporate Man)"
gen sr_s102d34_se=.
label var sr_s102d34_se "Self-rep unadjusted S.E (Culture, Media, Sports Occ v SOC11-Corporate Man)"


**adjusted
gen sr_s102d34_adj_eff=.
label var sr_s102d34_adj_eff "Self-rep adjusted effect (Culture, Media, Sports Occ v SOC11-Corporate Man)"
gen sr_s102d34_adj_se=.
label var sr_s102d34_adj_se "Self-rep adjusted SE (Culture, Media, Sports Occ v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d34_eff=.
label var lr_s102d34_eff "link_pos unadjusted effect (Culture, Media, Sports Occ v SOC11-Corporate Man)"
gen lr_s102d34_se=.
label var lr_s102d34_eff "link_pos unadjusted S.E (Culture, Media, Sports Occ v SOC11-Corporate Man)"

**adjusted
gen lr_s102d34_adj_eff=.
label var lr_s102d34_adj_eff "link_pos adjusted effect (Culture, Media, Sports Occ v SOC11-Corporate Man)"
gen lr_s102d34_adj_se=.
label var lr_s102d34_adj_se "link_pos adjusted SE (Culture, Media, Sports Occ v SOC11-Corporate Man)"

*35. Buisness and Public Serivces A-Prof
**Self-Reported Infection
**unadjusted
gen sr_s102d35_eff=.
label var sr_s102d35_eff "Self-rep unadjusted effect (Buisness and Public Serivces A-Prof v SOC11-Corporate Man)"
gen sr_s102d35_se=.
label var sr_s102d35_se "Self-rep unadjusted S.E (Buisness and Public Serivces A-Prof v SOC11-Corporate Man)"


**adjusted
gen sr_s102d35_adj_eff=.
label var sr_s102d35_adj_eff "Self-rep adjusted effect (Buisness and Public Serivces A-Prof v SOC11-Corporate Man)"
gen sr_s102d35_adj_se=.
label var sr_s102d35_adj_se "Self-rep adjusted SE (Buisness and Public Serivces A-Prof v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d35_eff=.
label var lr_s102d35_eff "link_pos unadjusted effect (Buisness and Public Serivces A-Prof v SOC11-Corporate Man)"
gen lr_s102d35_se=.
label var lr_s102d35_eff "link_pos unadjusted S.E (Buisness and Public Serivces A-Prof v SOC11-Corporate Man)"

**adjusted
gen lr_s102d35_adj_eff=.
label var lr_s102d35_adj_eff "link_pos adjusted effect (Buisness and Public Serivces A-Prof v SOC11-Corporate Man)"
gen lr_s102d35_adj_se=.
label var lr_s102d35_adj_se "link_pos adjusted SE (Buisness and Public Serivces A-Prof v SOC11-Corporate Man)"

*41. Administrative Occ
**Self-Reported Infection
**unadjusted
gen sr_s102d41_eff=.
label var sr_s102d41_eff "Self-rep unadjusted effect (Administrative Occ v SOC11-Corporate Man)"
gen sr_s102d41_se=.
label var sr_s102d41_se "Self-rep unadjusted S.E (Administrative Occ v SOC11-Corporate Man)"


**adjusted
gen sr_s102d41_adj_eff=.
label var sr_s102d41_adj_eff "Self-rep adjusted effect (Administrative Occ v SOC11-Corporate Man)"
gen sr_s102d41_adj_se=.
label var sr_s102d41_adj_se "Self-rep adjusted SE (Administrative Occ v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d41_eff=.
label var lr_s102d41_eff "link_pos unadjusted effect (Administrative Occ v SOC11-Corporate Man)"
gen lr_s102d41_se=.
label var lr_s102d41_eff "link_pos unadjusted S.E (Administrative Occ v SOC11-Corporate Man)"

**adjusted
gen lr_s102d41_adj_eff=.
label var lr_s102d41_adj_eff "link_pos adjusted effect (Administrative Occ v SOC11-Corporate Man)"
gen lr_s102d41_adj_se=.
label var lr_s102d41_adj_se "link_pos adjusted SE (Administrative Occ v SOC11-Corporate Man)"

*42. Secretarial and Related
**Self-Reported Infection
**unadjusted
gen sr_s102d42_eff=.
label var sr_s102d42_eff "Self-rep unadjusted effect (Secretarial and Related v SOC11-Corporate Man)"
gen sr_s102d42_se=.
label var sr_s102d42_se "Self-rep unadjusted S.E (Secretarial and Related v SOC11-Corporate Man)"


**adjusted
gen sr_s102d42_adj_eff=.
label var sr_s102d42_adj_eff "Self-rep adjusted effect (Secretarial and Related v SOC11-Corporate Man)"
gen sr_s102d42_adj_se=.
label var sr_s102d42_adj_se "Self-rep adjusted SE (Secretarial and Related v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d42_eff=.
label var lr_s102d42_eff "link_pos unadjusted effect (Secretarial and Related v SOC11-Corporate Man)"
gen lr_s102d42_se=.
label var lr_s102d42_eff "link_pos unadjusted S.E (Secretarial and Related v SOC11-Corporate Man)"

**adjusted
gen lr_s102d42_adj_eff=.
label var lr_s102d42_adj_eff "link_pos adjusted effect (Secretarial and Related v SOC11-Corporate Man)"
gen lr_s102d42_adj_se=.
label var lr_s102d42_adj_se "link_pos adjusted SE (Secretarial and Related v SOC11-Corporate Man)"

*51. Skilled Agricultural Trades
**Self-Reported Infection
**unadjusted
gen sr_s102d51_eff=.
label var sr_s102d51_eff "Self-rep unadjusted effect (Skilled Agricultural Trades v SOC11-Corporate Man)"
gen sr_s102d51_se=.
label var sr_s102d51_se "Self-rep unadjusted S.E (Skilled Agricultural Trades v SOC11-Corporate Man)"


**adjusted
gen sr_s102d51_adj_eff=.
label var sr_s102d51_adj_eff "Self-rep adjusted effect (Skilled Agricultural Trades v SOC11-Corporate Man)"
gen sr_s102d51_adj_se=.
label var sr_s102d51_adj_se "Self-rep adjusted SE (Skilled Agricultural Trades v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d51_eff=.
label var lr_s102d51_eff "link_pos unadjusted effect (Skilled Agricultural Trades v SOC11-Corporate Man)"
gen lr_s102d51_se=.
label var lr_s102d51_eff "link_pos unadjusted S.E (Skilled Agricultural Trades v SOC11-Corporate Man)"

**adjusted
gen lr_s102d51_adj_eff=.
label var lr_s102d51_adj_eff "link_pos adjusted effect (Skilled Agricultural Trades v SOC11-Corporate Man)"
gen lr_s102d51_adj_se=.
label var lr_s102d51_adj_se "link_pos adjusted SE (Skilled Agricultural Trades v SOC11-Corporate Man)"

*52. Skilled Metal and Electrical Trades
**Self-Reported Infection
**unadjusted
gen sr_s102d52_eff=.
label var sr_s102d52_eff "Self-rep unadjusted effect (Skilled Metal and Electrical Trades v SOC11-Corporate Man)"
gen sr_s102d52_se=.
label var sr_s102d52_se "Self-rep unadjusted S.E (Skilled Metal and Electrical Trades v SOC11-Corporate Man)"


**adjusted
gen sr_s102d52_adj_eff=.
label var sr_s102d52_adj_eff "Self-rep adjusted effect (Skilled Metal and Electrical Trades v SOC11-Corporate Man)"
gen sr_s102d52_adj_se=.
label var sr_s102d52_adj_se "Self-rep adjusted SE (Skilled Metal and Electrical Trades v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d52_eff=.
label var lr_s102d52_eff "link_pos unadjusted effect (Skilled Metal and Electrical Trades v SOC11-Corporate Man)"
gen lr_s102d52_se=.
label var lr_s102d52_eff "link_pos unadjusted S.E (Skilled Metal and Electrical Trades v SOC11-Corporate Man)"

**adjusted
gen lr_s102d52_adj_eff=.
label var lr_s102d52_adj_eff "link_pos adjusted effect (Skilled Metal and Electrical Trades v SOC11-Corporate Man)"
gen lr_s102d52_adj_se=.
label var lr_s102d52_adj_se "link_pos adjusted SE (Skilled Metal and Electrical Trades v SOC11-Corporate Man)"

*53. Skilled Construction and Building T
**Self-Reported Infection
**unadjusted
gen sr_s102d53_eff=.
label var sr_s102d53_eff "Self-rep unadjusted effect (Skilled Construction and Building v SOC11-Corporate Man)"
gen sr_s102d53_se=.
label var sr_s102d53_se "Self-rep unadjusted S.E (Skilled Construction and Building v SOC11-Corporate Man)"


**adjusted
gen sr_s102d53_adj_eff=.
label var sr_s102d53_adj_eff "Self-rep adjusted effect (Skilled Construction and Building v SOC11-Corporate Man)"
gen sr_s102d53_adj_se=.
label var sr_s102d53_adj_se "Self-rep adjusted SE (Skilled Construction and Building v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d53_eff=.
label var lr_s102d53_eff "link_pos unadjusted effect (Skilled Construction and Building v SOC11-Corporate Man)"
gen lr_s102d53_se=.
label var lr_s102d53_eff "link_pos unadjusted S.E (Skilled Construction and Building v SOC11-Corporate Man)"

**adjusted
gen lr_s102d53_adj_eff=.
label var lr_s102d53_adj_eff "link_pos adjusted effect (Skilled Construction and Building v SOC11-Corporate Man)"
gen lr_s102d53_adj_se=.
label var lr_s102d53_adj_se "link_pos adjusted SE (Skilled Construction and Building v SOC11-Corporate Man)"

*54. Textiles, Printing, Other skilled T
**Self-Reported Infection
**unadjusted
gen sr_s102d54_eff=.
label var sr_s102d54_eff "Self-rep unadjusted effect (Textiles, Printing, Other skilled v SOC11-Corporate Man)"
gen sr_s102d54_se=.
label var sr_s102d54_se "Self-rep unadjusted S.E (Textiles, Printing, Other skilled v SOC11-Corporate Man)"


**adjusted
gen sr_s102d54_adj_eff=.
label var sr_s102d54_adj_eff "Self-rep adjusted effect (Textiles, Printing, Other skilled v SOC11-Corporate Man)"
gen sr_s102d54_adj_se=.
label var sr_s102d54_adj_se "Self-rep adjusted SE (Textiles, Printing, Other skilled v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d54_eff=.
label var lr_s102d54_eff "link_pos unadjusted effect (Textiles, Printing, Other skilled v SOC11-Corporate Man)"
gen lr_s102d54_se=.
label var lr_s102d54_eff "link_pos unadjusted S.E (Textiles, Printing, Other skilled v SOC11-Corporate Man)"

**adjusted
gen lr_s102d54_adj_eff=.
label var lr_s102d54_adj_eff "link_pos adjusted effect (Textiles, Printing, Other skilled v SOC11-Corporate Man)"
gen lr_s102d54_adj_se=.
label var lr_s102d54_adj_se "link_pos adjusted SE (Textiles, Printing, Other skilled v SOC11-Corporate Man)"

*61. Caring Personal Services
**Self-Reported Infection
**unadjusted
gen sr_s102d61_eff=.
label var sr_s102d61_eff "Self-rep unadjusted effect (Caring Personal Services v SOC11-Corporate Man)"
gen sr_s102d61_se=.
label var sr_s102d61_se "Self-rep unadjusted S.E (Caring Personal Services v SOC11-Corporate Man)"


**adjusted
gen sr_s102d61_adj_eff=.
label var sr_s102d61_adj_eff "Self-rep adjusted effect (Caring Personal Services v SOC11-Corporate Man)"
gen sr_s102d61_adj_se=.
label var sr_s102d61_adj_se "Self-rep adjusted SE (Caring Personal Services v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d61_eff=.
label var lr_s102d61_eff "link_pos unadjusted effect (Caring Personal Services v SOC11-Corporate Man)"
gen lr_s102d61_se=.
label var lr_s102d61_eff "link_pos unadjusted S.E (Caring Personal Services v SOC11-Corporate Man)"

**adjusted
gen lr_s102d61_adj_eff=.
label var lr_s102d61_adj_eff "link_pos adjusted effect (Caring Personal Services v SOC11-Corporate Man)"
gen lr_s102d61_adj_se=.
label var lr_s102d61_adj_se "link_pos adjusted SE (Caring Personal Services v SOC11-Corporate Man)"

*62. Leisure & Other Personal Service Oc
**Self-Reported Infection
**unadjusted
gen sr_s102d62_eff=.
label var sr_s102d62_eff "Self-rep unadjusted effect (Leisure & Other Personal Service v SOC11-Corporate Man)"
gen sr_s102d62_se=.
label var sr_s102d62_se "Self-rep unadjusted S.E (Leisure & Other Personal Service v SOC11-Corporate Man)"


**adjusted
gen sr_s102d62_adj_eff=.
label var sr_s102d62_adj_eff "Self-rep adjusted effect (Leisure & Other Personal Service v SOC11-Corporate Man)"
gen sr_s102d62_adj_se=.
label var sr_s102d62_adj_se "Self-rep adjusted SE (Leisure & Other Personal Service v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d62_eff=.
label var lr_s102d62_eff "link_pos unadjusted effect (Leisure & Other Personal Service v SOC11-Corporate Man)"
gen lr_s102d62_se=.
label var lr_s102d62_eff "link_pos unadjusted S.E (Leisure & Other Personal Service v SOC11-Corporate Man)"

**adjusted
gen lr_s102d62_adj_eff=.
label var lr_s102d62_adj_eff "link_pos adjusted effect (Leisure & Other Personal Service v SOC11-Corporate Man)"
gen lr_s102d62_adj_se=.
label var lr_s102d62_adj_se "link_pos adjusted SE (Leisure & Other Personal Service v SOC11-Corporate Man)"

*71. Sales Occ
**Self-Reported Infection
**unadjusted
gen sr_s102d71_eff=.
label var sr_s102d71_eff "Self-rep unadjusted effect (Sales Occ v SOC11-Corporate Man)"
gen sr_s102d71_se=.
label var sr_s102d71_se "Self-rep unadjusted S.E (Sales Occ v SOC11-Corporate Man)"


**adjusted
gen sr_s102d71_adj_eff=.
label var sr_s102d71_adj_eff "Self-rep adjusted effect (Sales Occ v SOC11-Corporate Man)"
gen sr_s102d71_adj_se=.
label var sr_s102d71_adj_se "Self-rep adjusted SE (Sales Occ v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d71_eff=.
label var lr_s102d71_eff "link_pos unadjusted effect (Sales Occ v SOC11-Corporate Man)"
gen lr_s102d71_se=.
label var lr_s102d71_eff "link_pos unadjusted S.E (Sales Occ v SOC11-Corporate Man)"

**adjusted
gen lr_s102d71_adj_eff=.
label var lr_s102d71_adj_eff "link_pos adjusted effect (Sales Occ v SOC11-Corporate Man)"
gen lr_s102d71_adj_se=.
label var lr_s102d71_adj_se "link_pos adjusted SE (Sales Occ v SOC11-Corporate Man)"

*72. Customer Service
**Self-Reported Infection
**unadjusted
gen sr_s102d72_eff=.
label var sr_s102d72_eff "Self-rep unadjusted effect (Customer Service v SOC11-Corporate Man)"
gen sr_s102d72_se=.
label var sr_s102d72_se "Self-rep unadjusted S.E (Customer Service v SOC11-Corporate Man)"


**adjusted
gen sr_s102d72_adj_eff=.
label var sr_s102d72_adj_eff "Self-rep adjusted effect (Customer Service v SOC11-Corporate Man)"
gen sr_s102d72_adj_se=.
label var sr_s102d72_adj_se "Self-rep adjusted SE (Customer Service v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d72_eff=.
label var lr_s102d72_eff "link_pos unadjusted effect (Customer Service v SOC11-Corporate Man)"
gen lr_s102d72_se=.
label var lr_s102d72_eff "link_pos unadjusted S.E (Customer Service v SOC11-Corporate Man)"

**adjusted
gen lr_s102d72_adj_eff=.
label var lr_s102d72_adj_eff "link_pos adjusted effect (Customer Service v SOC11-Corporate Man)"
gen lr_s102d72_adj_se=.
label var lr_s102d72_adj_se "link_pos adjusted SE (Customer Service v SOC11-Corporate Man)"

*81. Process, Plant, and Machine Operati
**Self-Reported Infection
**unadjusted
gen sr_s102d81_eff=.
label var sr_s102d81_eff "Self-rep unadjusted effect (Self-Reported Infection v SOC11-Corporate Man)"
gen sr_s102d81_se=.
label var sr_s102d81_se "Self-rep unadjusted S.E (Self-Reported Infection v SOC11-Corporate Man)"


**adjusted
gen sr_s102d81_adj_eff=.
label var sr_s102d81_adj_eff "Self-rep adjusted effect (Self-Reported Infection v SOC11-Corporate Man)"
gen sr_s102d81_adj_se=.
label var sr_s102d81_adj_se "Self-rep adjusted SE (Self-Reported Infection v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d81_eff=.
label var lr_s102d81_eff "link_pos unadjusted effect (Self-Reported Infection v SOC11-Corporate Man)"
gen lr_s102d81_se=.
label var lr_s102d81_eff "link_pos unadjusted S.E (Self-Reported Infection v SOC11-Corporate Man)"

**adjusted
gen lr_s102d81_adj_eff=.
label var lr_s102d81_adj_eff "link_pos adjusted effect (Self-Reported Infection v SOC11-Corporate Man)"
gen lr_s102d81_adj_se=.
label var lr_s102d81_adj_se "link_pos adjusted SE (Self-Reported Infection v SOC11-Corporate Man)"

*82. Transport, Mobile Macnine Drivers a
**Self-Reported Infection
**unadjusted
gen sr_s102d82_eff=.
label var sr_s102d82_eff "Self-rep unadjusted effect (Transport, Mobile Macnine Drivers v SOC11-Corporate Man)"
gen sr_s102d82_se=.
label var sr_s102d82_se "Self-rep unadjusted S.E (Transport, Mobile Macnine Drivers v SOC11-Corporate Man)"


**adjusted
gen sr_s102d82_adj_eff=.
label var sr_s102d82_adj_eff "Self-rep adjusted effect (Transport, Mobile Macnine Drivers v SOC11-Corporate Man)"
gen sr_s102d82_adj_se=.
label var sr_s102d82_adj_se "Self-rep adjusted SE (Transport, Mobile Macnine Drivers v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d82_eff=.
label var lr_s102d82_eff "link_pos unadjusted effect (Transport, Mobile Macnine Drivers v SOC11-Corporate Man)"
gen lr_s102d82_se=.
label var lr_s102d82_eff "link_pos unadjusted S.E (Transport, Mobile Macnine Drivers v SOC11-Corporate Man)"

**adjusted
gen lr_s102d82_adj_eff=.
label var lr_s102d82_adj_eff "link_pos adjusted effect (Transport, Mobile Macnine Drivers v SOC11-Corporate Man)"
gen lr_s102d82_adj_se=.
label var lr_s102d82_adj_se "link_pos adjusted SE (Transport, Mobile Macnine Drivers v SOC11-Corporate Man)"

*91. Elementary Trades, Plant and Storag
**Self-Reported Infection
**unadjusted
gen sr_s102d91_eff=.
label var sr_s102d91_eff "Self-rep unadjusted effect (Elementary Trades, Plant and Storag v SOC11-Corporate Man)"
gen sr_s102d91_se=.
label var sr_s102d91_se "Self-rep unadjusted S.E (Elementary Trades, Plant and Storag v SOC11-Corporate Man)"


**adjusted
gen sr_s102d91_adj_eff=.
label var sr_s102d91_adj_eff "Self-rep adjusted effect (Elementary Trades, Plant and Storag v SOC11-Corporate Man)"
gen sr_s102d91_adj_se=.
label var sr_s102d91_adj_se "Self-rep adjusted SE (Elementary Trades, Plant and Storag v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d91_eff=.
label var lr_s102d91_eff "link_pos unadjusted effect (Elementary Trades, Plant and Storag v SOC11-Corporate Man)"
gen lr_s102d91_se=.
label var lr_s102d91_eff "link_pos unadjusted S.E (Elementary Trades, Plant and Storag v SOC11-Corporate Man)"

**adjusted
gen lr_s102d91_adj_eff=.
label var lr_s102d91_adj_eff "link_pos adjusted effect (Elementary Trades, Plant and Storag v SOC11-Corporate Man)"
gen lr_s102d91_adj_se=.
label var lr_s102d91_adj_se "link_pos adjusted SE (Elementary Trades, Plant and Storag v SOC11-Corporate Man)"

*92. Elementary Admin and Service Occ
**Self-Reported Infection
**unadjusted
gen sr_s102d92_eff=.
label var sr_s102d92_eff "Self-rep unadjusted effect (Elementary Admin and Service Occ v SOC11-Corporate Man)"
gen sr_s102d92_se=.
label var sr_s102d92_se "Self-rep unadjusted S.E (Elementary Admin and Service Occ v SOC11-Corporate Man)"


**adjusted
gen sr_s102d92_adj_eff=.
label var sr_s102d92_adj_eff "Self-rep adjusted effect (Elementary Admin and Service Occ v SOC11-Corporate Man)"
gen sr_s102d92_adj_se=.
label var sr_s102d92_adj_se "Self-rep adjusted SE (Elementary Admin and Service Occ v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d92_eff=.
label var lr_s102d92_eff "link_pos unadjusted effect (Elementary Admin and Service Occ v SOC11-Corporate Man)"
gen lr_s102d92_se=.
label var lr_s102d92_eff "link_pos unadjusted S.E (Elementary Admin and Service Occ v SOC11-Corporate Man)"

**adjusted
gen lr_s102d92_adj_eff=.
label var lr_s102d92_adj_eff "link_pos adjusted effect (Elementary Admin and Service Occ v SOC11-Corporate Man)"
gen lr_s102d92_adj_se=.
label var lr_s102d92_adj_se "link_pos adjusted SE (Elementary Admin and Service Occ v SOC11-Corporate Man)"



****************************
***KEY WORKER

**Self-Reported Infection
**Key-Worker Results - unadjusted
gen sr_kw_eff=.
label var sr_kw_eff "Self-rep unadjusted effect (Key_worker v not)"
gen sr_kw_se=.
label var sr_kw_se "Self-rep unadjusted S.E (Key_worker v not)"
gen sr_kw_lc=.
label var sr_kw_eff "Self-rep unadjusted LCI (Key_worker v not)"
gen sr_kw_uc=.
label var sr_kw_eff "Self-rep unadjusted UCI (Key_worker v not)"

**Key-Worker Results - adjusted
gen sr_kw_adj_eff=.
label var sr_kw_adj_eff "Self-rep adjusted effect (Key_worker v not)"
gen sr_kw_adj_se=.
label var sr_kw_adj_se "Self-rep adjusted SE (Key_worker v not)"
gen sr_kw_adj_lc=.
label var sr_kw_adj_lc "Self-rep adjusted LCI (Key_worker v not)"
gen sr_kw_adj_uc=.
label var sr_kw_adj_uc "Self-rep adjusted UCI (Key_worker v not)"

**Linked Positive Test
**Key-Worker Results - unadjusted
gen lr_kw_eff=.
label var lr_kw_eff "link_pos unadjusted effect (Key_worker v not)"
gen lr_kw_se=.
label var lr_kw_eff "link_pos unadjusted S.E (Key_worker v not)"
gen lr_kw_lc=.
label var lr_kw_eff "link_pos unadjusted LCI (Key_worker v not)"
gen lr_kw_uc=.
label var lr_kw_eff "link_pos unadjusted UCI (Key_worker v not)"

**Key-Worker Results - adjusted
gen lr_kw_adj_eff=.
label var lr_kw_adj_eff "link_pos adjusted effect (Key_worker v not)"
gen lr_kw_adj_se=.
label var lr_kw_adj_se "link_pos adjusted SE (Key_worker v not)"
gen lr_kw_adj_lc=.
label var lr_kw_adj_lc "link_pos adjusted LCI (Key_worker v not)"
gen lr_kw_adj_uc=.
label var lr_kw_adj_uc "link_pos adjusted UCI (Key_worker v not)"


***************************
**employment status
*employment (Employed / Retired / Unemployed) 

**Retired vs employed
**- unadjusted
gen sr_re_eff=.
label var sr_re_eff "Self-rep unadjusted effect (Retired v Employed)"
gen sr_re_se=.
label var sr_re_se "Self-rep unadjusted S.E (Retired v Employed)"
gen sr_re_lc=.
label var sr_re_eff "Self-rep unadjusted LCI (Retired v Employed)"
gen sr_re_uc=.
label var sr_re_eff "Self-rep unadjusted UCI (Retired v Employed)"

**- adjusted
gen sr_re_adj_eff=.
label var sr_re_adj_eff "Self-rep adjusted effect (Retired v Employed)"
gen sr_re_adj_se=.
label var sr_re_adj_se "Self-rep adjusted SE (Retired v Employed)"
gen sr_re_adj_lc=.
label var sr_re_adj_lc "Self-rep adjusted LCI (Retired v Employed)"
gen sr_re_adj_uc=.
label var sr_re_adj_uc "Self-rep adjusted UCI (Retired v Employed)"

**Linked Positive Test
** - unadjusted
gen lr_re_eff=.
label var lr_re_eff "link_pos unadjusted effect (Retired v Employed)"
gen lr_re_se=.
label var lr_re_eff "link_pos unadjusted S.E (Retired v Employed)"
gen lr_re_lc=.
label var lr_re_eff "link_pos unadjusted LCI (Retired v Employed)"
gen lr_re_uc=.
label var lr_re_eff "link_pos unadjusted UCI (Retired v Employed)"

** - adjusted
gen lr_re_adj_eff=.
label var lr_re_adj_eff "link_pos adjusted effect (Retired v Employed)"
gen lr_re_adj_se=.
label var lr_re_adj_se "link_pos adjusted SE (Retired v Employed)"
gen lr_re_adj_lc=.
label var lr_re_adj_lc "link_pos adjusted LCI (Retired v Employed)"
gen lr_re_adj_uc=.
label var lr_re_adj_uc "link_pos adjusted UCI (Retired v Employed)"


**Unemployed vs employed
**- unadjusted
gen sr_un_eff=.
label var sr_un_eff "Self-rep unadjusted effect (Unemployed v Employed)"
gen sr_un_se=.
label var sr_un_se "Self-rep unadjusted S.E (Unemployed v Employed)"
gen sr_un_lc=.
label var sr_un_eff "Self-rep unadjusted LCI (Unemployed v Employed)"
gen sr_un_uc=.
label var sr_un_eff "Self-rep unadjusted UCI (Unemployed v Employed)"

**- adjusted
gen sr_un_adj_eff=.
label var sr_un_adj_eff "Self-rep adjusted effect (Unemployed v Employed)"
gen sr_un_adj_se=.
label var sr_un_adj_se "Self-rep adjusted SE (Unemployed v Employed)"
gen sr_un_adj_lc=.
label var sr_un_adj_lc "Self-rep adjusted LCI (Unemployed v Employed)"
gen sr_un_adj_uc=.
label var sr_un_adj_uc "Self-rep adjusted UCI (Unemployed v Employed)"

**Linked Positive Test
** - unadjusted
gen lr_un_eff=.
label var lr_un_eff "link_pos unadjusted effect (Unemployed v Employed)"
gen lr_un_se=.
label var lr_un_eff "link_pos unadjusted S.E (Unemployed v Employed)"
gen lr_un_lc=.
label var lr_un_eff "link_pos unadjusted LCI (Unemployed v Employed)"
gen lr_un_uc=.
label var lr_un_eff "link_pos unadjusted UCI (Unemployed v Employed)"

** - adjusted
gen lr_un_adj_eff=.
label var lr_un_adj_eff "link_pos adjusted effect (Unemployed v Employed)"
gen lr_un_adj_se=.
label var lr_un_adj_se "link_pos adjusted SE (Unemployed v Employed)"
gen lr_un_adj_lc=.
label var lr_un_adj_lc "link_pos adjusted LCI (Unemployed v Employed)"
gen lr_un_adj_uc=.
label var lr_un_adj_uc "link_pos adjusted UCI (Unemployed v Employed)"




************************************************************
*employment_status  (full-time/part/retired/emply but not working/unemployed)

**Part-time vs full-time
**- unadjusted
gen sr_pt_eff=.
label var sr_pt_eff "Self-rep unadjusted effect (Part-time vs full-time)"
gen sr_pt_se=.
label var sr_pt_se "Self-rep unadjusted S.E (Part-time vs full-time)"
gen sr_pt_lc=.
label var sr_pt_eff "Self-rep unadjusted LCI (Part-time vs full-time)"
gen sr_pt_uc=.
label var sr_pt_eff "Self-rep unadjusted UCI (Part-time vs full-time)"

**- adjusted
gen sr_pt_adj_eff=.
label var sr_pt_adj_eff "Self-rep adjusted effect (Part-time vs full-time)"
gen sr_pt_adj_se=.
label var sr_pt_adj_se "Self-rep adjusted SE (Part-time vs full-time)"
gen sr_pt_adj_lc=.
label var sr_pt_adj_lc "Self-rep adjusted LCI (Part-time vs full-time)"
gen sr_pt_adj_uc=.
label var sr_pt_adj_uc "Self-rep adjusted UCI (Part-time vs full-time)"

**Linked Positive Test
** - unadjusted
gen lr_pt_eff=.
label var lr_pt_eff "link_pos unadjusted effect (Part-time vs full-time)"
gen lr_pt_se=.
label var lr_pt_eff "link_pos unadjusted S.E (Part-time vs full-time)"
gen lr_pt_lc=.
label var lr_pt_eff "link_pos unadjusted LCI (Part-time vs full-time)"
gen lr_pt_uc=.
label var lr_pt_eff "link_pos unadjusted UCI (Part-time vs full-time)"

** - adjusted
gen lr_pt_adj_eff=.
label var lr_pt_adj_eff "link_pos adjusted effect (Part-time vs full-time)"
gen lr_pt_adj_se=.
label var lr_pt_adj_se "link_pos adjusted SE (Part-time vs full-time)"
gen lr_pt_adj_lc=.
label var lr_pt_adj_lc "link_pos adjusted LCI (Part-time vs full-time)"
gen lr_pt_adj_uc=.
label var lr_pt_adj_uc "link_pos adjusted UCI (Part-time vs full-time)"



**Retired vs full-time
**- unadjusted
gen sr_ret_eff=.
label var sr_ret_eff "Self-rep unadjusted effect (Retired vs full-time)"
gen sr_ret_se=.
label var sr_ret_se "Self-rep unadjusted S.E (Retired vs full-time)"
gen sr_ret_lc=.
label var sr_ret_eff "Self-rep unadjusted LCI (Retired vs full-time)"
gen sr_ret_uc=.
label var sr_ret_eff "Self-rep unadjusted UCI (Retired vs full-time)"

**- adjusted
gen sr_ret_adj_eff=.
label var sr_ret_adj_eff "Self-rep adjusted effect (Retired vs full-time)"
gen sr_ret_adj_se=.
label var sr_ret_adj_se "Self-rep adjusted SE (Retired vs full-time)"
gen sr_ret_adj_lc=.
label var sr_ret_adj_lc "Self-rep adjusted LCI (Retired vs full-time)"
gen sr_ret_adj_uc=.
label var sr_ret_adj_uc "Self-rep adjusted UCI (Retired vs full-time)"

**Linked Positive Test
** - unadjusted
gen lr_ret_eff=.
label var lr_ret_eff "link_pos unadjusted effect (Retired vs full-time)"
gen lr_ret_se=.
label var lr_ret_eff "link_pos unadjusted S.E (Retired vs full-time)"
gen lr_ret_lc=.
label var lr_ret_eff "link_pos unadjusted LCI (Retired vs full-time)"
gen lr_ret_uc=.
label var lr_ret_eff "link_pos unadjusted UCI (Retired vs full-time)"

** - adjusted
gen lr_ret_adj_eff=.
label var lr_ret_adj_eff "link_pos adjusted effect (Retired vs full-time)"
gen lr_ret_adj_se=.
label var lr_ret_adj_se "link_pos adjusted SE (Retired vs full-time)"
gen lr_ret_adj_lc=.
label var lr_ret_adj_lc "link_pos adjusted LCI (Retired vs full-time)"
gen lr_ret_adj_uc=.
label var lr_ret_adj_uc "link_pos adjusted UCI (Retired vs full-time)"



**Employed but not working vs full-time
**- unadjusted
gen sr_nw_eff=.
label var sr_nw_eff "Self-rep unadjusted effect (Emp but not working vs full-time)"
gen sr_nw_se=.
label var sr_nw_se "Self-rep unadjusted S.E (Emp but not working vs full-time)"
gen sr_nw_lc=.
label var sr_nw_eff "Self-rep unadjusted LCI (Emp but not working vs full-time)"
gen sr_nw_uc=.
label var sr_nw_eff "Self-rep unadjusted UCI (Emp but not working vs full-time)"

**- adjusted
gen sr_nw_adj_eff=.
label var sr_nw_adj_eff "Self-rep adjusted effect (Emp but not working vs full-time)"
gen sr_nw_adj_se=.
label var sr_nw_adj_se "Self-rep adjusted SE (Emp but not working vs full-time)"
gen sr_nw_adj_lc=.
label var sr_nw_adj_lc "Self-rep adjusted LCI (Emp but not working vs full-time)"
gen sr_nw_adj_uc=.
label var sr_nw_adj_uc "Self-rep adjusted UCI (Emp but not working vs full-time)"

**Linked Positive Test
** - unadjusted
gen lr_nw_eff=.
label var lr_nw_eff "link_pos unadjusted effect (Emp but not working vs full-time)"
gen lr_nw_se=.
label var lr_nw_eff "link_pos unadjusted S.E (Emp but not working vs full-time)"
gen lr_nw_lc=.
label var lr_nw_eff "link_pos unadjusted LCI (Emp but not working vs full-time)"
gen lr_nw_uc=.
label var lr_nw_eff "link_pos unadjusted UCI (Emp but not working vs full-time)"

** - adjusted
gen lr_nw_adj_eff=.
label var lr_nw_adj_eff "link_pos adjusted effect (Emp but not working vs full-time)"
gen lr_nw_adj_se=.
label var lr_nw_adj_se "link_pos adjusted SE (Emp but not working vs full-time)"
gen lr_nw_adj_lc=.
label var lr_nw_adj_lc "link_pos adjusted LCI (Emp but not working vs full-time)"
gen lr_nw_adj_uc=.
label var lr_nw_adj_uc "link_pos adjusted UCI (Emp but not working vs full-time)"


**Unemployed v full time 
**- unadjusted
gen sr_une_eff=.
label var sr_une_eff "Self-rep unadjusted effect (Unemployed vs full-time)"
gen sr_une_se=.
label var sr_une_se "Self-rep unadjusted S.E (Unemployed vs full-time)"
gen sr_une_lc=.
label var sr_une_eff "Self-rep unadjusted LCI (Unemployed vs full-time)"
gen sr_une_uc=.
label var sr_une_eff "Self-rep unadjusted UCI (Unemployed vs full-time)"

**- adjusted
gen sr_une_adj_eff=.
label var sr_une_adj_eff "Self-rep adjusted effect (Unemployed vs full-time)"
gen sr_une_adj_se=.
label var sr_une_adj_se "Self-rep adjusted SE (Unemployed vs full-time)"
gen sr_une_adj_lc=.
label var sr_une_adj_lc "Self-rep adjusted LCI (Unemployed vs full-time)"
gen sr_une_adj_uc=.
label var sr_une_adj_uc "Self-rep adjusted UCI (Unemployed vs full-time)"

**Linked Positive Test
** - unadjusted
gen lr_une_eff=.
label var lr_une_eff "link_pos unadjusted effect (Unemployed vs full-time)"
gen lr_une_se=.
label var lr_une_eff "link_pos unadjusted S.E (Unemployed vs full-time)"
gen lr_une_lc=.
label var lr_une_eff "link_pos unadjusted LCI (Unemployed vs full-time)"
gen lr_une_uc=.
label var lr_une_eff "link_pos unadjusted UCI (Unemployed vs full-time)"

** - adjusted
gen lr_une_adj_eff=.
label var lr_une_adj_eff "link_pos adjusted effect (Unemployed vs full-time)"
gen lr_une_adj_se=.
label var lr_une_adj_se "link_pos adjusted SE (Unemployed vs full-time)"
gen lr_une_adj_lc=.
label var lr_une_adj_lc "link_pos adjusted LCI (Unemployed vs full-time)"
gen lr_une_adj_uc=.
label var lr_une_adj_uc "link_pos adjusted UCI (Unemployed vs full-time)"



*****************************************************
**Home working	
*home_working  (all/some/none)


**Some v All home working 
**- unadjusted
gen sr_sm_eff=.
label var sr_sm_eff "Self-rep unadjusted effect (Some v All home working)"
gen sr_sm_se=.
label var sr_sm_se "Self-rep unadjusted S.E (Some v All home working)"
gen sr_sm_lc=.
label var sr_sm_eff "Self-rep unadjusted LCI (Some v All home working)"
gen sr_sm_uc=.
label var sr_sm_eff "Self-rep unadjusted UCI (Some v All home working)"

**- adjusted
gen sr_sm_adj_eff=.
label var sr_sm_adj_eff "Self-rep adjusted effect (Some v All home working)"
gen sr_sm_adj_se=.
label var sr_sm_adj_se "Self-rep adjusted SE (Some v All home working)"
gen sr_sm_adj_lc=.
label var sr_sm_adj_lc "Self-rep adjusted LCI (Some v All home working)"
gen sr_sm_adj_uc=.
label var sr_sm_adj_uc "Self-rep adjusted UCI (Some v All home working)"

**Linked Positive Test
** - unadjusted
gen lr_sm_eff=.
label var lr_sm_eff "link_pos unadjusted effect (Some v All home working)"
gen lr_sm_se=.
label var lr_sm_eff "link_pos unadjusted S.E (Some v All home working)"
gen lr_sm_lc=.
label var lr_sm_eff "link_pos unadjusted LCI (Some v All home working)"
gen lr_sm_uc=.
label var lr_sm_eff "link_pos unadjusted UCI (Some v All home working)"

** - adjusted
gen lr_sm_adj_eff=.
label var lr_sm_adj_eff "link_pos adjusted effect (Some v All home working)"
gen lr_sm_adj_se=.
label var lr_sm_adj_se "link_pos adjusted SE (Some v All home working)"
gen lr_sm_adj_lc=.
label var lr_sm_adj_lc "link_pos adjusted LCI (Some v All home working)"
gen lr_sm_adj_uc=.
label var lr_sm_adj_uc "link_pos adjusted UCI (Some v All home working)"


**None v All home working 
**- unadjusted
gen sr_no_eff=.
label var sr_no_eff "Self-rep unadjusted effect (None v All home working)"
gen sr_no_se=.
label var sr_no_se "Self-rep unadjusted S.E (None v All home working)"
gen sr_no_lc=.
label var sr_no_eff "Self-rep unadjusted LCI (None v All home working)"
gen sr_no_uc=.
label var sr_no_eff "Self-rep unadjusted UCI (None v All home working)"

**- adjusted
gen sr_no_adj_eff=.
label var sr_no_adj_eff "Self-rep adjusted effect (None v All home working)"
gen sr_no_adj_se=.
label var sr_no_adj_se "Self-rep adjusted SE (None v All home working)"
gen sr_no_adj_lc=.
label var sr_no_adj_lc "Self-rep adjusted LCI (None v All home working)"
gen sr_no_adj_uc=.
label var sr_no_adj_uc "Self-rep adjusted UCI (None v All home working)"

**Linked Positive Test
** - unadjusted
gen lr_no_eff=.
label var lr_no_eff "link_pos unadjusted effect (None v All home working)"
gen lr_no_se=.
label var lr_no_eff "link_pos unadjusted S.E (None v All home working)"
gen lr_no_lc=.
label var lr_no_eff "link_pos unadjusted LCI (None v All home working)"
gen lr_no_uc=.
label var lr_no_eff "link_pos unadjusted UCI (None v All home working)"

** - adjusted
gen lr_no_adj_eff=.
label var lr_no_adj_eff "link_pos adjusted effect (None v All home working)"
gen lr_no_adj_se=.
label var lr_no_adj_se "link_pos adjusted SE (None v All home working)"
gen lr_no_adj_lc=.
label var lr_no_adj_lc "link_pos adjusted LCI (None v All home working)"
gen lr_no_adj_uc=.
label var lr_no_adj_uc "link_pos adjusted UCI (None v All home working)"


****************************************
**Furlough
*furlough (no/yes)
**Self-Reported Infection
**- unadjusted
gen sr_fr_eff=.
label var sr_fr_eff "Self-rep unadjusted effect (Furlough v not)"
gen sr_fr_se=.
label var sr_fr_se "Self-rep unadjusted S.E (Furlough v not)"
gen sr_fr_lc=.
label var sr_fr_eff "Self-rep unadjusted LCI (Furlough v not)"
gen sr_fr_uc=.
label var sr_fr_eff "Self-rep unadjusted UCI (Furlough v not)"

**- adjusted
gen sr_fr_adj_eff=.
label var sr_fr_adj_eff "Self-rep adjusted effect (Furlough v not)"
gen sr_fr_adj_se=.
label var sr_fr_adj_se "Self-rep adjusted SE (Furlough v not)"
gen sr_fr_adj_lc=.
label var sr_fr_adj_lc "Self-rep adjusted LCI (Furlough v not)"
gen sr_fr_adj_uc=.
label var sr_fr_adj_uc "Self-rep adjusted UCI (Furlough v not)"

**Linked Positive Test
** - unadjusted
gen lr_fr_eff=.
label var lr_fr_eff "link_pos unadjusted effect (Furlough v not)"
gen lr_fr_se=.
label var lr_fr_eff "link_pos unadjusted S.E (Furlough v not)"
gen lr_fr_lc=.
label var lr_fr_eff "link_pos unadjusted LCI (Furlough v not)"
gen lr_fr_uc=.
label var lr_fr_eff "link_pos unadjusted UCI (Furlough v not)"

** - adjusted
gen lr_fr_adj_eff=.
label var lr_fr_adj_eff "link_pos adjusted effect (Furlough v not)"
gen lr_fr_adj_se=.
label var lr_fr_adj_se "link_pos adjusted SE (Furlough v not)"
gen lr_fr_adj_lc=.
label var lr_fr_adj_lc "link_pos adjusted LCI (Furlough v not)"
gen lr_fr_adj_uc=.
label var lr_fr_adj_uc "link_pos adjusted UCI (Furlough v not)"


save "S:\LLC_0007\data\results_datafile time-tranche", replace




********************************************************************************
**SEPERATE REPOSITIORY FOR THE MODEL ADJUSTED FOR VACCINATION ANALYSIS 
********************************************************************************


 
 
********************************************************************************
**SETTING UP THIRD STAGE FILE
**STORING THE OVERALL META-EFFECT ESTIMATE FOR META-ANALYSIS COMBINATION
******************************************************************************** 
 
clear
set obs 40
gen id=_n
gen effect_id=_n

label define effect_id 1 "kw_sr_ua" 2 "kw_sr_aj" 3 "kw_lr_ua" 4 "kw_lr_aj" 5 "ret_sr_ua" 6 "ret_sr_aj" 7 "ret_lr_ua" 8 "ret_lr_aj" 9 "un_sr_ua" 10 "un_sr_aj" 11 "un_lr_ua" 12 "un_lr_aj" 13 "pt_sr_ua" 14 "pt_sr_aj" 15 "pt_lr_ua" 16 "pt_lr_aj" 17 "rt_sr_ua" 18 "rt_sr_aj" 19 "rt_lr_ua" 20 "rt_lr_aj" 21 "nw_sr_ua" 22 "nw_sr_aj" 23 "nw_lr_ua" 24 "nw_lr_aj" 25 "une_sr_ua" 26 "une_sr_aj" 27 "une_lr_ua" 28 "une_lr_aj" 29 "sh_sr_ua" 30 "sh_sr_aj" 31 "sh_lr_ua" 32 "sh_lr_aj" 33 "nh_sr_ua" 34 "nh_sr_aj" 35 "nh_lr_ua" 36 "nh_lr_aj" 37 "fr_sr_ua" 38 "fr_sr_aj" 39 "fr_lr_ua" 40 "fr_lr_aj", replace 
label values effect_id effect_id


expand 3
bysort effect_id: egen time_tranche=seq()
label define time_tranche 1 "Overall" 2 "Apr-Oct20" 3 "Nov-Mar21", replace
label values time_tranche time_tranche
tab time_tranche
gen effect=.
gen se=.

*keyworker
*retired v employed
*unemployed vs employed
*part time v full time
*retired v full time
*Employed but not working v fulltime 
*Unemployed v fulltime
*Some v all hm working
*none v all hm working
*furlough


save "S:\LLC_0007\data\metaresults_datafile time-tranche vacc", replace


********************************************************************************
**SETTING UP SECOND STAGE FILE
**STORING THE EFFECT ESTIMATE FOR META-ANALYSIS COMBINATION
********************************************************************************

clear

set obs 19
gen id=_n
gen study_id=_n

label define study_id 0 "Total" 1 "ELSA" 2 "UKHLS" 3 "BCS70" 4 "MCS" 5 "NCDS58" 6 "NextSteps" 7 "BIB" 8 "GENSCOT" 9 "EXCEED" 10 "NICOLA"  11 "COPING" 12 "GLAD" 13 "TRACK-C19" 14 "TWINSUK" 15 "ALSPAC" 16 "MCS-Member" 17 "MCS-Parents" 18 "ALSPAC-Mem" 19 "ALSPAC-Mothers", replace 
label values study_id study_id


gen study_lab=""
replace study_lab="English Longitudinal Study of Ageing" if study_id==1
replace study_lab="Understanding Society" if study_id==2
replace study_lab="British Cohort Study 1970" if study_id==3
replace study_lab="Milenium Cohort Study-All" if study_id==4
replace study_lab="National Child Development Study 1958" if study_id==5
replace study_lab="Next Steps" if study_id==6
replace study_lab="Born in Bradford" if study_id==7
replace study_lab="Generation Scotlant" if study_id==8
replace study_lab="The Extended Cohort for E-health, Envirnoment, and DNA (EXCEED)" if study_id==9
replace study_lab="Nortern Ireland Cohort for the Longitudinal Study of Ageing" if study_id==10
replace study_lab="The NIHR Bioresource COVID-19 Psychiatry and Neurological Genetics(COPING) Study" if study_id==11
replace study_lab="The Genetic Links to Anxeity and Depression (GLAD) Study" if study_id==12
replace study_lab="The Track COVID-19 Study" if study_id==13
replace study_lab="TWINS UK Study" if study_id==14
replace study_lab="Avon Longitudinal Study of Parents & Children" if study_id==15
replace study_lab="Millenium Cohort Study-Cohort Members" if study_id==16
replace study_lab="Millenium Cohort Study-Parents" if study_id==17
replace study_lab="Avon Longitudinal Study of Parents & Children-Members" if study_id==18
replace study_lab="Avon Longitudinal Study of Parents & Children-Mothers" if study_id==19


label var study_lab "Study Name/details"

**Gen decoded version to aid meta-analysis
decode study_id, gen(study_name)

**Generate Variables represented results - to be filled

gen sample_n = .
label var sample_n "No. Participants"
gen entry_n = .
label var entry_n "No. entries i.e participants*waves"
gen selfinf_n=.
label var selfinf_n "No. Report Self-Infection"
gen selfpos_no=.
label var selfpos_no "No. Report Pos-test"
gen linkpos_no=.
label var selfpos_no "No. NHS linked data Pos-test"

expand 6
bysort study_id: egen time_tranche=seq()
label define time_tranche 1 "Overall" 2 "Apr-June20" 3 "Jul-Oct20" 4 "Nov20-Mar21" 5 "Apr-Oct20" 6 "Nov20-Mar21"
label values time_tranche time_tranche
label var time_tranche "Define time-period effect relates to"
sort time_tranche study_id 

order id time_tranche study_id

****************************
***SOC 2010 1d

*1. Managers, Directors, & Senior Off ==REF Cat
*2. Prof Occupations 
**Self-Reported Infection
**unadjusted
gen sr_s101d2_eff=.
label var sr_s101d2_eff "Self-rep unadjusted effect (Prof Occupations v SOC1-Managers)"
gen sr_s101d2_se=.
label var sr_s101d2_se "Self-rep unadjusted S.E (Prof Occupations v SOC1-Managers)"


**adjusted
gen sr_s101d2_adjv_eff=.
label var sr_s101d2_adjv_eff "Self-rep adjusted effect (Prof Occupations v SOC1-Managers)"
gen sr_s101d2_adjv_se=.
label var sr_s101d2_adjv_se "Self-rep adjusted SE (Prof Occupations v SOC1-Managers)"

**Linked Positive Test
**unadjusted
gen lr_s101d2_eff=.
label var lr_s101d2_eff "link_pos unadjusted effect (Prof Occupations v SOC1-Managers)"
gen lr_s101d2_se=.
label var lr_s101d2_eff "link_pos unadjusted S.E (Prof Occupations v SOC1-Managers)"

**adjusted
gen lr_s101d2_adjv_eff=.
label var lr_s101d2_adjv_eff "link_pos adjusted effect (Prof Occupations v SOC1-Managers)"
gen lr_s101d2_adjv_se=.
label var lr_s101d2_adjv_se "link_pos adjusted SE (Prof Occupations v SOC1-Managers)"

*3. Associate Prof & Technical Occup 
**Self-Reported Infection
**unadjusted
gen sr_s101d3_eff=.
label var sr_s101d3_eff "Self-rep unadjusted effect (Associate Prof & Technical Occup  v SOC1-Managers)"
gen sr_s101d3_se=.
label var sr_s101d3_se "Self-rep unadjusted S.E (Associate Prof & Technical Occup  v SOC1-Managers)"


**adjusted
gen sr_s101d3_adjv_eff=.
label var sr_s101d3_adjv_eff "Self-rep adjusted effect (Associate Prof & Technical Occup  v SOC1-Managers)"
gen sr_s101d3_adjv_se=.
label var sr_s101d3_adjv_se "Self-rep adjusted SE (Associate Prof & Technical Occup  v SOC1-Managers)"

**Linked Positive Test
**unadjusted
gen lr_s101d3_eff=.
label var lr_s101d3_eff "link_pos unadjusted effect (Associate Prof & Technical Occup  v SOC1-Managers)"
gen lr_s101d3_se=.
label var lr_s101d3_eff "link_pos unadjusted S.E (Associate Prof & Technical Occup  v SOC1-Managers)"

**adjusted
gen lr_s101d3_adjv_eff=.
label var lr_s101d3_adjv_eff "link_pos adjusted effect (Associate Prof & Technical Occup  v SOC1-Managers)"
gen lr_s101d3_adjv_se=.
label var lr_s101d3_adjv_se "link_pos adjusted SE (Associate Prof & Technical Occup  v SOC1-Managers)"
*4. Administrative and Secretarial 
**Self-Reported Infection
**unadjusted
gen sr_s101d4_eff=.
label var sr_s101d4_eff "Self-rep unadjusted effect (Administrative and Secretarial  v SOC1-Managers)"
gen sr_s101d4_se=.
label var sr_s101d4_se "Self-rep unadjusted S.E (Administrative and Secretarial  v SOC1-Managers)"


**adjusted
gen sr_s101d4_adjv_eff=.
label var sr_s101d4_adjv_eff "Self-rep adjusted effect (Administrative and Secretarial  v SOC1-Managers)"
gen sr_s101d4_adjv_se=.
label var sr_s101d4_adjv_se "Self-rep adjusted SE (Administrative and Secretarial  v SOC1-Managers)"

**Linked Positive Test
**unadjusted
gen lr_s101d4_eff=.
label var lr_s101d4_eff "link_pos unadjusted effect (Administrative and Secretarial  v SOC1-Managers)"
gen lr_s101d4_se=.
label var lr_s101d4_eff "link_pos unadjusted S.E (Administrative and Secretarial  v SOC1-Managers)"

**adjusted
gen lr_s101d4_adjv_eff=.
label var lr_s101d4_adjv_eff "link_pos adjusted effect (Administrative and Secretarial  v SOC1-Managers)"
gen lr_s101d4_adjv_se=.
label var lr_s101d4_adjv_se "link_pos adjusted SE (Administrative and Secretarial  v SOC1-Managers)"
*5. Skilled Trades 
**Self-Reported Infection
**unadjusted
gen sr_s101d5_eff=.
label var sr_s101d5_eff "Self-rep unadjusted effect (Skilled Trades v SOC1-Managers)"
gen sr_s101d5_se=.
label var sr_s101d5_se "Self-rep unadjusted S.E (Skilled Trades v SOC1-Managers)"


**adjusted
gen sr_s101d5_adjv_eff=.
label var sr_s101d5_adjv_eff "Self-rep adjusted effect (Skilled Trades v SOC1-Managers)"
gen sr_s101d5_adjv_se=.
label var sr_s101d5_adjv_se "Self-rep adjusted SE (Skilled Trades v SOC1-Managers)"

**Linked Positive Test
**unadjusted
gen lr_s101d5_eff=.
label var lr_s101d5_eff "link_pos unadjusted effect (Skilled Trades v SOC1-Managers)"
gen lr_s101d5_se=.
label var lr_s101d5_eff "link_pos unadjusted S.E (Skilled Trades v SOC1-Managers)"

**adjusted
gen lr_s101d5_adjv_eff=.
label var lr_s101d5_adjv_eff "link_pos adjusted effect (Skilled Trades v SOC1-Managers)"
gen lr_s101d5_adjv_se=.
label var lr_s101d5_adjv_se "link_pos adjusted SE (Skilled Trades v SOC1-Managers)"
*6. Caring, Leisure, and Other Service 
**Self-Reported Infection
**unadjusted
gen sr_s101d6_eff=.
label var sr_s101d6_eff "Self-rep unadjusted effect (Caring, Leisure, and Other Service  v SOC1-Managers)"
gen sr_s101d6_se=.
label var sr_s101d6_se "Self-rep unadjusted S.E (Caring, Leisure, and Other Service  v SOC1-Managers)"


**adjusted
gen sr_s101d6_adjv_eff=.
label var sr_s101d6_adjv_eff "Self-rep adjusted effect (Caring, Leisure, and Other Service  v SOC1-Managers)"
gen sr_s101d6_adjv_se=.
label var sr_s101d6_adjv_se "Self-rep adjusted SE (Caring, Leisure, and Other Service  v SOC1-Managers)"

**Linked Positive Test
**unadjusted
gen lr_s101d6_eff=.
label var lr_s101d6_eff "link_pos unadjusted effect (Caring, Leisure, and Other Service  v SOC1-Managers)"
gen lr_s101d6_se=.
label var lr_s101d6_eff "link_pos unadjusted S.E (Caring, Leisure, and Other Service  v SOC1-Managers)"

**adjusted
gen lr_s101d6_adjv_eff=.
label var lr_s101d6_adjv_eff "link_pos adjusted effect (Caring, Leisure, and Other Service  v SOC1-Managers)"
gen lr_s101d6_adjv_se=.
label var lr_s101d6_adjv_se "link_pos adjusted SE (Caring, Leisure, and Other Service  v SOC1-Managers)"
*7. Sales and Customer Serv 
**Self-Reported Infection
**unadjusted
gen sr_s101d7_eff=.
label var sr_s101d7_eff "Self-rep unadjusted effect (Sales and Customer Serv v SOC1-Managers)"
gen sr_s101d7_se=.
label var sr_s101d7_se "Self-rep unadjusted S.E (Sales and Customer Serv v SOC1-Managers)"


**adjusted
gen sr_s101d7_adjv_eff=.
label var sr_s101d7_adjv_eff "Self-rep adjusted effect (Sales and Customer Serv v SOC1-Managers)"
gen sr_s101d7_adjv_se=.
label var sr_s101d7_adjv_se "Self-rep adjusted SE (Sales and Customer Serv v SOC1-Managers)"

**Linked Positive Test
**unadjusted
gen lr_s101d7_eff=.
label var lr_s101d7_eff "link_pos unadjusted effect (Sales and Customer Serv v SOC1-Managers)"
gen lr_s101d7_se=.
label var lr_s101d7_eff "link_pos unadjusted S.E (Sales and Customer Serv v SOC1-Managers)"

**adjusted
gen lr_s101d7_adjv_eff=.
label var lr_s101d7_adjv_eff "link_pos adjusted effect (Sales and Customer Serv v SOC1-Managers)"
gen lr_s101d7_adjv_se=.
label var lr_s101d7_adjv_se "link_pos adjusted SE (Sales and Customer Serv v SOC1-Managers)"
*8. Process, Plant, and Machine Operativ 
**Self-Reported Infection
**unadjusted
gen sr_s101d8_eff=.
label var sr_s101d8_eff "Self-rep unadjusted effect (Process, Plant, and Machine Operativ v SOC1-Managers)"
gen sr_s101d8_se=.
label var sr_s101d8_se "Self-rep unadjusted S.E (Process, Plant, and Machine Operativ v SOC1-Managers)"


**adjusted
gen sr_s101d8_adjv_eff=.
label var sr_s101d8_adjv_eff "Self-rep adjusted effect (Process, Plant, and Machine Operativ v SOC1-Managers)"
gen sr_s101d8_adjv_se=.
label var sr_s101d8_adjv_se "Self-rep adjusted SE (Process, Plant, and Machine Operativ v SOC1-Managers)"

**Linked Positive Test
**unadjusted
gen lr_s101d8_eff=.
label var lr_s101d8_eff "link_pos unadjusted effect (Process, Plant, and Machine Operativ v SOC1-Managers)"
gen lr_s101d8_se=.
label var lr_s101d8_eff "link_pos unadjusted S.E (Process, Plant, and Machine Operativ v SOC1-Managers)"

**adjusted
gen lr_s101d8_adjv_eff=.
label var lr_s101d8_adjv_eff "link_pos adjusted effect (Process, Plant, and Machine Operativ v SOC1-Managers)"
gen lr_s101d8_adjv_se=.
label var lr_s101d8_adjv_se "link_pos adjusted SE (Process, Plant, and Machine Operativ v SOC1-Managers)"
*9. Elementary Occupations
**Self-Reported Infection
**unadjusted
gen sr_s101d9_eff=.
label var sr_s101d9_eff "Self-rep unadjusted effect (Elementary Occupations v SOC1-Managers)"
gen sr_s101d9_se=.
label var sr_s101d9_se "Self-rep unadjusted S.E (Elementary Occupations v SOC1-Managers)"


**adjusted
gen sr_s101d9_adjv_eff=.
label var sr_s101d9_adjv_eff "Self-rep adjusted effect (Elementary Occupations v SOC1-Managers)"
gen sr_s101d9_adjv_se=.
label var sr_s101d9_adjv_se "Self-rep adjusted SE (Elementary Occupations v SOC1-Managers)"

**Linked Positive Test
**unadjusted
gen lr_s101d9_eff=.
label var lr_s101d9_eff "link_pos unadjusted effect (Elementary Occupations v SOC1-Managers)"
gen lr_s101d9_se=.
label var lr_s101d9_eff "link_pos unadjusted S.E (Elementary Occupations v SOC1-Managers)"

**adjusted
gen lr_s101d9_adjv_eff=.
label var lr_s101d9_adjv_eff "link_pos adjusted effect (Elementary Occupations v SOC1-Managers)"
gen lr_s101d9_adjv_se=.
label var lr_s101d9_adjv_se "link_pos adjusted SE (Elementary Occupations v SOC1-Managers)"


****************************
***SOC 2010 2d

*11. Corporate Managers = REF Cat
*12. Other Managers and Proprietors in A
**Self-Reported Infection
**unadjusted
gen sr_s102d12_eff=.
label var sr_s102d12_eff "Self-rep unadjusted effect (Other Managers and Proprietors in A v SOC11-Corporate Man)"
gen sr_s102d12_se=.
label var sr_s102d12_se "Self-rep unadjusted S.E (Other Managers and Proprietors in A v SOC11-Corporate Man)"


**adjusted
gen sr_s102d12_adjv_eff=.
label var sr_s102d12_adjv_eff "Self-rep adjusted effect (Other Managers and Proprietors in A v SOC11-Corporate Man)"
gen sr_s102d12_adjv_se=.
label var sr_s102d12_adjv_se "Self-rep adjusted SE (Other Managers and Proprietors in A v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d12_eff=.
label var lr_s102d12_eff "link_pos unadjusted effect (Other Managers and Proprietors in A v SOC11-Corporate Man)"
gen lr_s102d12_se=.
label var lr_s102d12_eff "link_pos unadjusted S.E (Other Managers and Proprietors in A v SOC11-Corporate Man)"

**adjusted
gen lr_s102d12_adjv_eff=.
label var lr_s102d12_adjv_eff "link_pos adjusted effect (Other Managers and Proprietors in A v SOC11-Corporate Man)"
gen lr_s102d12_adjv_se=.
label var lr_s102d12_adjv_se "link_pos adjusted SE (Other Managers and Proprietors in A v SOC11-Corporate Man)"

*21. Science, res, and Tech Prof
**Self-Reported Infection
**unadjusted
gen sr_s102d21_eff=.
label var sr_s102d21_eff "Self-rep unadjusted effect (Science, res, and Tech Prof v SOC11-Corporate Man)"
gen sr_s102d21_se=.
label var sr_s102d21_se "Self-rep unadjusted S.E (Science, res, and Tech Prof v SOC11-Corporate Man)"


**adjusted
gen sr_s102d21_adjv_eff=.
label var sr_s102d21_adjv_eff "Self-rep adjusted effect (Science, res, and Tech Prof v SOC11-Corporate Man)"
gen sr_s102d21_adjv_se=.
label var sr_s102d21_adjv_se "Self-rep adjusted SE (Science, res, and Tech Prof v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d21_eff=.
label var lr_s102d21_eff "link_pos unadjusted effect (Science, res, and Tech Prof v SOC11-Corporate Man)"
gen lr_s102d21_se=.
label var lr_s102d21_eff "link_pos unadjusted S.E (Science, res, and Tech Prof v SOC11-Corporate Man)"

**adjusted
gen lr_s102d21_adjv_eff=.
label var lr_s102d21_adjv_eff "link_pos adjusted effect (Science, res, and Tech Prof v SOC11-Corporate Man)"
gen lr_s102d21_adjv_se=.
label var lr_s102d21_adjv_se "link_pos adjusted SE (Science, res, and Tech Prof v SOC11-Corporate Man)"

*22. Health Prof
**Self-Reported Infection
**unadjusted
gen sr_s102d22_eff=.
label var sr_s102d22_eff "Self-rep unadjusted effect (Health Prof v SOC11-Corporate Man)"
gen sr_s102d22_se=.
label var sr_s102d22_se "Self-rep unadjusted S.E (Health Prof v SOC11-Corporate Man)"


**adjusted
gen sr_s102d22_adjv_eff=.
label var sr_s102d22_adjv_eff "Self-rep adjusted effect (Health Prof v SOC11-Corporate Man)"
gen sr_s102d22_adjv_se=.
label var sr_s102d22_adjv_se "Self-rep adjusted SE (Health Prof v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d22_eff=.
label var lr_s102d22_eff "link_pos unadjusted effect (Health Prof v SOC11-Corporate Man)"
gen lr_s102d22_se=.
label var lr_s102d22_eff "link_pos unadjusted S.E (Health Prof v SOC11-Corporate Man)"

**adjusted
gen lr_s102d22_adjv_eff=.
label var lr_s102d22_adjv_eff "link_pos adjusted effect (Health Prof v SOC11-Corporate Man)"
gen lr_s102d22_adjv_se=.
label var lr_s102d22_adjv_se "link_pos adjusted SE (Health Prof v SOC11-Corporate Man)"

*23. Teaching and Educa Prof
**Self-Reported Infection
**unadjusted
gen sr_s102d23_eff=.
label var sr_s102d23_eff "Self-rep unadjusted effect (Teaching and Educa Prof v SOC11-Corporate Man)"
gen sr_s102d23_se=.
label var sr_s102d23_se "Self-rep unadjusted S.E (Teaching and Educa Prof v SOC11-Corporate Man)"


**adjusted
gen sr_s102d23_adjv_eff=.
label var sr_s102d23_adjv_eff "Self-rep adjusted effect (Teaching and Educa Prof v SOC11-Corporate Man)"
gen sr_s102d23_adjv_se=.
label var sr_s102d23_adjv_se "Self-rep adjusted SE (Teaching and Educa Prof v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d23_eff=.
label var lr_s102d23_eff "link_pos unadjusted effect (Teaching and Educa Prof v SOC11-Corporate Man)"
gen lr_s102d23_se=.
label var lr_s102d23_eff "link_pos unadjusted S.E (Teaching and Educa Prof v SOC11-Corporate Man)"

**adjusted
gen lr_s102d23_adjv_eff=.
label var lr_s102d23_adjv_eff "link_pos adjusted effect (Teaching and Educa Prof v SOC11-Corporate Man)"
gen lr_s102d23_adjv_se=.
label var lr_s102d23_adjv_se "link_pos adjusted SE (Teaching and Educa Prof v SOC11-Corporate Man)"

*24. Buisness and Public Services Prof
**Self-Reported Infection
**unadjusted
gen sr_s102d24_eff=.
label var sr_s102d24_eff "Self-rep unadjusted effect (Buisness and Public Services Prof v SOC11-Corporate Man)"
gen sr_s102d24_se=.
label var sr_s102d24_se "Self-rep unadjusted S.E (Buisness and Public Services Prof v SOC11-Corporate Man)"


**adjusted
gen sr_s102d24_adjv_eff=.
label var sr_s102d24_adjv_eff "Self-rep adjusted effect (Buisness and Public Services Prof v SOC11-Corporate Man)"
gen sr_s102d24_adjv_se=.
label var sr_s102d24_adjv_se "Self-rep adjusted SE (Buisness and Public Services Prof v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d24_eff=.
label var lr_s102d24_eff "link_pos unadjusted effect (Buisness and Public Services Prof v SOC11-Corporate Man)"
gen lr_s102d24_se=.
label var lr_s102d24_eff "link_pos unadjusted S.E (Buisness and Public Services Prof v SOC11-Corporate Man)"

**adjusted
gen lr_s102d24_adjv_eff=.
label var lr_s102d24_adjv_eff "link_pos adjusted effect (Buisness and Public Services Prof v SOC11-Corporate Man)"
gen lr_s102d24_adjv_se=.
label var lr_s102d24_adjv_se "link_pos adjusted SE (Buisness and Public Services Prof v SOC11-Corporate Man)"

*31. Science and Tech A-Prof
**Self-Reported Infection
**unadjusted
gen sr_s102d31_eff=.
label var sr_s102d31_eff "Self-rep unadjusted effect (Science and Tech A-Prof v SOC11-Corporate Man)"
gen sr_s102d31_se=.
label var sr_s102d31_se "Self-rep unadjusted S.E (Science and Tech A-Prof v SOC11-Corporate Man)"


**adjusted
gen sr_s102d31_adjv_eff=.
label var sr_s102d31_adjv_eff "Self-rep adjusted effect (Science and Tech A-Prof v SOC11-Corporate Man)"
gen sr_s102d31_adjv_se=.
label var sr_s102d31_adjv_se "Self-rep adjusted SE (Science and Tech A-Prof v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d31_eff=.
label var lr_s102d31_eff "link_pos unadjusted effect (Science and Tech A-Prof v SOC11-Corporate Man)"
gen lr_s102d31_se=.
label var lr_s102d31_eff "link_pos unadjusted S.E (Science and Tech A-Prof v SOC11-Corporate Man)"

**adjusted
gen lr_s102d31_adjv_eff=.
label var lr_s102d31_adjv_eff "link_pos adjusted effect (Science and Tech A-Prof v SOC11-Corporate Man)"
gen lr_s102d31_adjv_se=.
label var lr_s102d31_adjv_se "link_pos adjusted SE (Science and Tech A-Prof v SOC11-Corporate Man)"

*32. Health and Social Welfare A-Prof
**Self-Reported Infection
**unadjusted
gen sr_s102d32_eff=.
label var sr_s102d32_eff "Self-rep unadjusted effect (Health and Social Welfare A-Prof v SOC11-Corporate Man)"
gen sr_s102d32_se=.
label var sr_s102d32_se "Self-rep unadjusted S.E (Health and Social Welfare A-Prof v SOC11-Corporate Man)"


**adjusted
gen sr_s102d32_adjv_eff=.
label var sr_s102d32_adjv_eff "Self-rep adjusted effect (Health and Social Welfare A-Prof v SOC11-Corporate Man)"
gen sr_s102d32_adjv_se=.
label var sr_s102d32_adjv_se "Self-rep adjusted SE (Health and Social Welfare A-Prof v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d32_eff=.
label var lr_s102d32_eff "link_pos unadjusted effect (Health and Social Welfare A-Prof v SOC11-Corporate Man)"
gen lr_s102d32_se=.
label var lr_s102d32_eff "link_pos unadjusted S.E (Health and Social Welfare A-Prof v SOC11-Corporate Man)"

**adjusted
gen lr_s102d32_adjv_eff=.
label var lr_s102d32_adjv_eff "link_pos adjusted effect (Health and Social Welfare A-Prof v SOC11-Corporate Man)"
gen lr_s102d32_adjv_se=.
label var lr_s102d32_adjv_se "link_pos adjusted SE (Health and Social Welfare A-Prof v SOC11-Corporate Man)"

*33. Protective Services
**Self-Reported Infection
**unadjusted
gen sr_s102d33_eff=.
label var sr_s102d33_eff "Self-rep unadjusted effect (Protective Services v SOC11-Corporate Man)"
gen sr_s102d33_se=.
label var sr_s102d33_se "Self-rep unadjusted S.E (Protective Services v SOC11-Corporate Man)"


**adjusted
gen sr_s102d33_adjv_eff=.
label var sr_s102d33_adjv_eff "Self-rep adjusted effect (Protective Services v SOC11-Corporate Man)"
gen sr_s102d33_adjv_se=.
label var sr_s102d33_adjv_se "Self-rep adjusted SE (Protective Services v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d33_eff=.
label var lr_s102d33_eff "link_pos unadjusted effect (Protective Services v SOC11-Corporate Man)"
gen lr_s102d33_se=.
label var lr_s102d33_eff "link_pos unadjusted S.E (Protective Services v SOC11-Corporate Man)"

**adjusted
gen lr_s102d33_adjv_eff=.
label var lr_s102d33_adjv_eff "link_pos adjusted effect (Protective Services v SOC11-Corporate Man)"
gen lr_s102d33_adjv_se=.
label var lr_s102d33_adjv_se "link_pos adjusted SE (Protective Services v SOC11-Corporate Man)"

*34. Culture, Media, Sports Occ
**Self-Reported Infection
**unadjusted
gen sr_s102d34_eff=.
label var sr_s102d34_eff "Self-rep unadjusted effect (Culture, Media, Sports Occ v SOC11-Corporate Man)"
gen sr_s102d34_se=.
label var sr_s102d34_se "Self-rep unadjusted S.E (Culture, Media, Sports Occ v SOC11-Corporate Man)"


**adjusted
gen sr_s102d34_adjv_eff=.
label var sr_s102d34_adjv_eff "Self-rep adjusted effect (Culture, Media, Sports Occ v SOC11-Corporate Man)"
gen sr_s102d34_adjv_se=.
label var sr_s102d34_adjv_se "Self-rep adjusted SE (Culture, Media, Sports Occ v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d34_eff=.
label var lr_s102d34_eff "link_pos unadjusted effect (Culture, Media, Sports Occ v SOC11-Corporate Man)"
gen lr_s102d34_se=.
label var lr_s102d34_eff "link_pos unadjusted S.E (Culture, Media, Sports Occ v SOC11-Corporate Man)"

**adjusted
gen lr_s102d34_adjv_eff=.
label var lr_s102d34_adjv_eff "link_pos adjusted effect (Culture, Media, Sports Occ v SOC11-Corporate Man)"
gen lr_s102d34_adjv_se=.
label var lr_s102d34_adjv_se "link_pos adjusted SE (Culture, Media, Sports Occ v SOC11-Corporate Man)"

*35. Buisness and Public Serivces A-Prof
**Self-Reported Infection
**unadjusted
gen sr_s102d35_eff=.
label var sr_s102d35_eff "Self-rep unadjusted effect (Buisness and Public Serivces A-Prof v SOC11-Corporate Man)"
gen sr_s102d35_se=.
label var sr_s102d35_se "Self-rep unadjusted S.E (Buisness and Public Serivces A-Prof v SOC11-Corporate Man)"


**adjusted
gen sr_s102d35_adjv_eff=.
label var sr_s102d35_adjv_eff "Self-rep adjusted effect (Buisness and Public Serivces A-Prof v SOC11-Corporate Man)"
gen sr_s102d35_adjv_se=.
label var sr_s102d35_adjv_se "Self-rep adjusted SE (Buisness and Public Serivces A-Prof v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d35_eff=.
label var lr_s102d35_eff "link_pos unadjusted effect (Buisness and Public Serivces A-Prof v SOC11-Corporate Man)"
gen lr_s102d35_se=.
label var lr_s102d35_eff "link_pos unadjusted S.E (Buisness and Public Serivces A-Prof v SOC11-Corporate Man)"

**adjusted
gen lr_s102d35_adjv_eff=.
label var lr_s102d35_adjv_eff "link_pos adjusted effect (Buisness and Public Serivces A-Prof v SOC11-Corporate Man)"
gen lr_s102d35_adjv_se=.
label var lr_s102d35_adjv_se "link_pos adjusted SE (Buisness and Public Serivces A-Prof v SOC11-Corporate Man)"

*41. Administrative Occ
**Self-Reported Infection
**unadjusted
gen sr_s102d41_eff=.
label var sr_s102d41_eff "Self-rep unadjusted effect (Administrative Occ v SOC11-Corporate Man)"
gen sr_s102d41_se=.
label var sr_s102d41_se "Self-rep unadjusted S.E (Administrative Occ v SOC11-Corporate Man)"


**adjusted
gen sr_s102d41_adjv_eff=.
label var sr_s102d41_adjv_eff "Self-rep adjusted effect (Administrative Occ v SOC11-Corporate Man)"
gen sr_s102d41_adjv_se=.
label var sr_s102d41_adjv_se "Self-rep adjusted SE (Administrative Occ v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d41_eff=.
label var lr_s102d41_eff "link_pos unadjusted effect (Administrative Occ v SOC11-Corporate Man)"
gen lr_s102d41_se=.
label var lr_s102d41_eff "link_pos unadjusted S.E (Administrative Occ v SOC11-Corporate Man)"

**adjusted
gen lr_s102d41_adjv_eff=.
label var lr_s102d41_adjv_eff "link_pos adjusted effect (Administrative Occ v SOC11-Corporate Man)"
gen lr_s102d41_adjv_se=.
label var lr_s102d41_adjv_se "link_pos adjusted SE (Administrative Occ v SOC11-Corporate Man)"

*42. Secretarial and Related
**Self-Reported Infection
**unadjusted
gen sr_s102d42_eff=.
label var sr_s102d42_eff "Self-rep unadjusted effect (Secretarial and Related v SOC11-Corporate Man)"
gen sr_s102d42_se=.
label var sr_s102d42_se "Self-rep unadjusted S.E (Secretarial and Related v SOC11-Corporate Man)"


**adjusted
gen sr_s102d42_adjv_eff=.
label var sr_s102d42_adjv_eff "Self-rep adjusted effect (Secretarial and Related v SOC11-Corporate Man)"
gen sr_s102d42_adjv_se=.
label var sr_s102d42_adjv_se "Self-rep adjusted SE (Secretarial and Related v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d42_eff=.
label var lr_s102d42_eff "link_pos unadjusted effect (Secretarial and Related v SOC11-Corporate Man)"
gen lr_s102d42_se=.
label var lr_s102d42_eff "link_pos unadjusted S.E (Secretarial and Related v SOC11-Corporate Man)"

**adjusted
gen lr_s102d42_adjv_eff=.
label var lr_s102d42_adjv_eff "link_pos adjusted effect (Secretarial and Related v SOC11-Corporate Man)"
gen lr_s102d42_adjv_se=.
label var lr_s102d42_adjv_se "link_pos adjusted SE (Secretarial and Related v SOC11-Corporate Man)"

*51. Skilled Agricultural Trades
**Self-Reported Infection
**unadjusted
gen sr_s102d51_eff=.
label var sr_s102d51_eff "Self-rep unadjusted effect (Skilled Agricultural Trades v SOC11-Corporate Man)"
gen sr_s102d51_se=.
label var sr_s102d51_se "Self-rep unadjusted S.E (Skilled Agricultural Trades v SOC11-Corporate Man)"


**adjusted
gen sr_s102d51_adjv_eff=.
label var sr_s102d51_adjv_eff "Self-rep adjusted effect (Skilled Agricultural Trades v SOC11-Corporate Man)"
gen sr_s102d51_adjv_se=.
label var sr_s102d51_adjv_se "Self-rep adjusted SE (Skilled Agricultural Trades v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d51_eff=.
label var lr_s102d51_eff "link_pos unadjusted effect (Skilled Agricultural Trades v SOC11-Corporate Man)"
gen lr_s102d51_se=.
label var lr_s102d51_eff "link_pos unadjusted S.E (Skilled Agricultural Trades v SOC11-Corporate Man)"

**adjusted
gen lr_s102d51_adjv_eff=.
label var lr_s102d51_adjv_eff "link_pos adjusted effect (Skilled Agricultural Trades v SOC11-Corporate Man)"
gen lr_s102d51_adjv_se=.
label var lr_s102d51_adjv_se "link_pos adjusted SE (Skilled Agricultural Trades v SOC11-Corporate Man)"

*52. Skilled Metal and Electrical Trades
**Self-Reported Infection
**unadjusted
gen sr_s102d52_eff=.
label var sr_s102d52_eff "Self-rep unadjusted effect (Skilled Metal and Electrical Trades v SOC11-Corporate Man)"
gen sr_s102d52_se=.
label var sr_s102d52_se "Self-rep unadjusted S.E (Skilled Metal and Electrical Trades v SOC11-Corporate Man)"


**adjusted
gen sr_s102d52_adjv_eff=.
label var sr_s102d52_adjv_eff "Self-rep adjusted effect (Skilled Metal and Electrical Trades v SOC11-Corporate Man)"
gen sr_s102d52_adjv_se=.
label var sr_s102d52_adjv_se "Self-rep adjusted SE (Skilled Metal and Electrical Trades v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d52_eff=.
label var lr_s102d52_eff "link_pos unadjusted effect (Skilled Metal and Electrical Trades v SOC11-Corporate Man)"
gen lr_s102d52_se=.
label var lr_s102d52_eff "link_pos unadjusted S.E (Skilled Metal and Electrical Trades v SOC11-Corporate Man)"

**adjusted
gen lr_s102d52_adjv_eff=.
label var lr_s102d52_adjv_eff "link_pos adjusted effect (Skilled Metal and Electrical Trades v SOC11-Corporate Man)"
gen lr_s102d52_adjv_se=.
label var lr_s102d52_adjv_se "link_pos adjusted SE (Skilled Metal and Electrical Trades v SOC11-Corporate Man)"

*53. Skilled Construction and Building T
**Self-Reported Infection
**unadjusted
gen sr_s102d53_eff=.
label var sr_s102d53_eff "Self-rep unadjusted effect (Skilled Construction and Building v SOC11-Corporate Man)"
gen sr_s102d53_se=.
label var sr_s102d53_se "Self-rep unadjusted S.E (Skilled Construction and Building v SOC11-Corporate Man)"


**adjusted
gen sr_s102d53_adjv_eff=.
label var sr_s102d53_adjv_eff "Self-rep adjusted effect (Skilled Construction and Building v SOC11-Corporate Man)"
gen sr_s102d53_adjv_se=.
label var sr_s102d53_adjv_se "Self-rep adjusted SE (Skilled Construction and Building v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d53_eff=.
label var lr_s102d53_eff "link_pos unadjusted effect (Skilled Construction and Building v SOC11-Corporate Man)"
gen lr_s102d53_se=.
label var lr_s102d53_eff "link_pos unadjusted S.E (Skilled Construction and Building v SOC11-Corporate Man)"

**adjusted
gen lr_s102d53_adjv_eff=.
label var lr_s102d53_adjv_eff "link_pos adjusted effect (Skilled Construction and Building v SOC11-Corporate Man)"
gen lr_s102d53_adjv_se=.
label var lr_s102d53_adjv_se "link_pos adjusted SE (Skilled Construction and Building v SOC11-Corporate Man)"

*54. Textiles, Printing, Other skilled T
**Self-Reported Infection
**unadjusted
gen sr_s102d54_eff=.
label var sr_s102d54_eff "Self-rep unadjusted effect (Textiles, Printing, Other skilled v SOC11-Corporate Man)"
gen sr_s102d54_se=.
label var sr_s102d54_se "Self-rep unadjusted S.E (Textiles, Printing, Other skilled v SOC11-Corporate Man)"


**adjusted
gen sr_s102d54_adjv_eff=.
label var sr_s102d54_adjv_eff "Self-rep adjusted effect (Textiles, Printing, Other skilled v SOC11-Corporate Man)"
gen sr_s102d54_adjv_se=.
label var sr_s102d54_adjv_se "Self-rep adjusted SE (Textiles, Printing, Other skilled v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d54_eff=.
label var lr_s102d54_eff "link_pos unadjusted effect (Textiles, Printing, Other skilled v SOC11-Corporate Man)"
gen lr_s102d54_se=.
label var lr_s102d54_eff "link_pos unadjusted S.E (Textiles, Printing, Other skilled v SOC11-Corporate Man)"

**adjusted
gen lr_s102d54_adjv_eff=.
label var lr_s102d54_adjv_eff "link_pos adjusted effect (Textiles, Printing, Other skilled v SOC11-Corporate Man)"
gen lr_s102d54_adjv_se=.
label var lr_s102d54_adjv_se "link_pos adjusted SE (Textiles, Printing, Other skilled v SOC11-Corporate Man)"

*61. Caring Personal Services
**Self-Reported Infection
**unadjusted
gen sr_s102d61_eff=.
label var sr_s102d61_eff "Self-rep unadjusted effect (Caring Personal Services v SOC11-Corporate Man)"
gen sr_s102d61_se=.
label var sr_s102d61_se "Self-rep unadjusted S.E (Caring Personal Services v SOC11-Corporate Man)"


**adjusted
gen sr_s102d61_adjv_eff=.
label var sr_s102d61_adjv_eff "Self-rep adjusted effect (Caring Personal Services v SOC11-Corporate Man)"
gen sr_s102d61_adjv_se=.
label var sr_s102d61_adjv_se "Self-rep adjusted SE (Caring Personal Services v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d61_eff=.
label var lr_s102d61_eff "link_pos unadjusted effect (Caring Personal Services v SOC11-Corporate Man)"
gen lr_s102d61_se=.
label var lr_s102d61_eff "link_pos unadjusted S.E (Caring Personal Services v SOC11-Corporate Man)"

**adjusted
gen lr_s102d61_adjv_eff=.
label var lr_s102d61_adjv_eff "link_pos adjusted effect (Caring Personal Services v SOC11-Corporate Man)"
gen lr_s102d61_adjv_se=.
label var lr_s102d61_adjv_se "link_pos adjusted SE (Caring Personal Services v SOC11-Corporate Man)"

*62. Leisure & Other Personal Service Oc
**Self-Reported Infection
**unadjusted
gen sr_s102d62_eff=.
label var sr_s102d62_eff "Self-rep unadjusted effect (Leisure & Other Personal Service v SOC11-Corporate Man)"
gen sr_s102d62_se=.
label var sr_s102d62_se "Self-rep unadjusted S.E (Leisure & Other Personal Service v SOC11-Corporate Man)"


**adjusted
gen sr_s102d62_adjv_eff=.
label var sr_s102d62_adjv_eff "Self-rep adjusted effect (Leisure & Other Personal Service v SOC11-Corporate Man)"
gen sr_s102d62_adjv_se=.
label var sr_s102d62_adjv_se "Self-rep adjusted SE (Leisure & Other Personal Service v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d62_eff=.
label var lr_s102d62_eff "link_pos unadjusted effect (Leisure & Other Personal Service v SOC11-Corporate Man)"
gen lr_s102d62_se=.
label var lr_s102d62_eff "link_pos unadjusted S.E (Leisure & Other Personal Service v SOC11-Corporate Man)"

**adjusted
gen lr_s102d62_adjv_eff=.
label var lr_s102d62_adjv_eff "link_pos adjusted effect (Leisure & Other Personal Service v SOC11-Corporate Man)"
gen lr_s102d62_adjv_se=.
label var lr_s102d62_adjv_se "link_pos adjusted SE (Leisure & Other Personal Service v SOC11-Corporate Man)"

*71. Sales Occ
**Self-Reported Infection
**unadjusted
gen sr_s102d71_eff=.
label var sr_s102d71_eff "Self-rep unadjusted effect (Sales Occ v SOC11-Corporate Man)"
gen sr_s102d71_se=.
label var sr_s102d71_se "Self-rep unadjusted S.E (Sales Occ v SOC11-Corporate Man)"


**adjusted
gen sr_s102d71_adjv_eff=.
label var sr_s102d71_adjv_eff "Self-rep adjusted effect (Sales Occ v SOC11-Corporate Man)"
gen sr_s102d71_adjv_se=.
label var sr_s102d71_adjv_se "Self-rep adjusted SE (Sales Occ v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d71_eff=.
label var lr_s102d71_eff "link_pos unadjusted effect (Sales Occ v SOC11-Corporate Man)"
gen lr_s102d71_se=.
label var lr_s102d71_eff "link_pos unadjusted S.E (Sales Occ v SOC11-Corporate Man)"

**adjusted
gen lr_s102d71_adjv_eff=.
label var lr_s102d71_adjv_eff "link_pos adjusted effect (Sales Occ v SOC11-Corporate Man)"
gen lr_s102d71_adjv_se=.
label var lr_s102d71_adjv_se "link_pos adjusted SE (Sales Occ v SOC11-Corporate Man)"

*72. Customer Service
**Self-Reported Infection
**unadjusted
gen sr_s102d72_eff=.
label var sr_s102d72_eff "Self-rep unadjusted effect (Customer Service v SOC11-Corporate Man)"
gen sr_s102d72_se=.
label var sr_s102d72_se "Self-rep unadjusted S.E (Customer Service v SOC11-Corporate Man)"


**adjusted
gen sr_s102d72_adjv_eff=.
label var sr_s102d72_adjv_eff "Self-rep adjusted effect (Customer Service v SOC11-Corporate Man)"
gen sr_s102d72_adjv_se=.
label var sr_s102d72_adjv_se "Self-rep adjusted SE (Customer Service v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d72_eff=.
label var lr_s102d72_eff "link_pos unadjusted effect (Customer Service v SOC11-Corporate Man)"
gen lr_s102d72_se=.
label var lr_s102d72_eff "link_pos unadjusted S.E (Customer Service v SOC11-Corporate Man)"

**adjusted
gen lr_s102d72_adjv_eff=.
label var lr_s102d72_adjv_eff "link_pos adjusted effect (Customer Service v SOC11-Corporate Man)"
gen lr_s102d72_adjv_se=.
label var lr_s102d72_adjv_se "link_pos adjusted SE (Customer Service v SOC11-Corporate Man)"

*81. Process, Plant, and Machine Operati
**Self-Reported Infection
**unadjusted
gen sr_s102d81_eff=.
label var sr_s102d81_eff "Self-rep unadjusted effect (Self-Reported Infection v SOC11-Corporate Man)"
gen sr_s102d81_se=.
label var sr_s102d81_se "Self-rep unadjusted S.E (Self-Reported Infection v SOC11-Corporate Man)"


**adjusted
gen sr_s102d81_adjv_eff=.
label var sr_s102d81_adjv_eff "Self-rep adjusted effect (Self-Reported Infection v SOC11-Corporate Man)"
gen sr_s102d81_adjv_se=.
label var sr_s102d81_adjv_se "Self-rep adjusted SE (Self-Reported Infection v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d81_eff=.
label var lr_s102d81_eff "link_pos unadjusted effect (Self-Reported Infection v SOC11-Corporate Man)"
gen lr_s102d81_se=.
label var lr_s102d81_eff "link_pos unadjusted S.E (Self-Reported Infection v SOC11-Corporate Man)"

**adjusted
gen lr_s102d81_adjv_eff=.
label var lr_s102d81_adjv_eff "link_pos adjusted effect (Self-Reported Infection v SOC11-Corporate Man)"
gen lr_s102d81_adjv_se=.
label var lr_s102d81_adjv_se "link_pos adjusted SE (Self-Reported Infection v SOC11-Corporate Man)"

*82. Transport, Mobile Macnine Drivers a
**Self-Reported Infection
**unadjusted
gen sr_s102d82_eff=.
label var sr_s102d82_eff "Self-rep unadjusted effect (Transport, Mobile Macnine Drivers v SOC11-Corporate Man)"
gen sr_s102d82_se=.
label var sr_s102d82_se "Self-rep unadjusted S.E (Transport, Mobile Macnine Drivers v SOC11-Corporate Man)"


**adjusted
gen sr_s102d82_adjv_eff=.
label var sr_s102d82_adjv_eff "Self-rep adjusted effect (Transport, Mobile Macnine Drivers v SOC11-Corporate Man)"
gen sr_s102d82_adjv_se=.
label var sr_s102d82_adjv_se "Self-rep adjusted SE (Transport, Mobile Macnine Drivers v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d82_eff=.
label var lr_s102d82_eff "link_pos unadjusted effect (Transport, Mobile Macnine Drivers v SOC11-Corporate Man)"
gen lr_s102d82_se=.
label var lr_s102d82_eff "link_pos unadjusted S.E (Transport, Mobile Macnine Drivers v SOC11-Corporate Man)"

**adjusted
gen lr_s102d82_adjv_eff=.
label var lr_s102d82_adjv_eff "link_pos adjusted effect (Transport, Mobile Macnine Drivers v SOC11-Corporate Man)"
gen lr_s102d82_adjv_se=.
label var lr_s102d82_adjv_se "link_pos adjusted SE (Transport, Mobile Macnine Drivers v SOC11-Corporate Man)"

*91. Elementary Trades, Plant and Storag
**Self-Reported Infection
**unadjusted
gen sr_s102d91_eff=.
label var sr_s102d91_eff "Self-rep unadjusted effect (Elementary Trades, Plant and Storag v SOC11-Corporate Man)"
gen sr_s102d91_se=.
label var sr_s102d91_se "Self-rep unadjusted S.E (Elementary Trades, Plant and Storag v SOC11-Corporate Man)"


**adjusted
gen sr_s102d91_adjv_eff=.
label var sr_s102d91_adjv_eff "Self-rep adjusted effect (Elementary Trades, Plant and Storag v SOC11-Corporate Man)"
gen sr_s102d91_adjv_se=.
label var sr_s102d91_adjv_se "Self-rep adjusted SE (Elementary Trades, Plant and Storag v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d91_eff=.
label var lr_s102d91_eff "link_pos unadjusted effect (Elementary Trades, Plant and Storag v SOC11-Corporate Man)"
gen lr_s102d91_se=.
label var lr_s102d91_eff "link_pos unadjusted S.E (Elementary Trades, Plant and Storag v SOC11-Corporate Man)"

**adjusted
gen lr_s102d91_adjv_eff=.
label var lr_s102d91_adjv_eff "link_pos adjusted effect (Elementary Trades, Plant and Storag v SOC11-Corporate Man)"
gen lr_s102d91_adjv_se=.
label var lr_s102d91_adjv_se "link_pos adjusted SE (Elementary Trades, Plant and Storag v SOC11-Corporate Man)"

*92. Elementary Admin and Service Occ
**Self-Reported Infection
**unadjusted
gen sr_s102d92_eff=.
label var sr_s102d92_eff "Self-rep unadjusted effect (Elementary Admin and Service Occ v SOC11-Corporate Man)"
gen sr_s102d92_se=.
label var sr_s102d92_se "Self-rep unadjusted S.E (Elementary Admin and Service Occ v SOC11-Corporate Man)"


**adjusted
gen sr_s102d92_adjv_eff=.
label var sr_s102d92_adjv_eff "Self-rep adjusted effect (Elementary Admin and Service Occ v SOC11-Corporate Man)"
gen sr_s102d92_adjv_se=.
label var sr_s102d92_adjv_se "Self-rep adjusted SE (Elementary Admin and Service Occ v SOC11-Corporate Man)"

**Linked Positive Test
**unadjusted
gen lr_s102d92_eff=.
label var lr_s102d92_eff "link_pos unadjusted effect (Elementary Admin and Service Occ v SOC11-Corporate Man)"
gen lr_s102d92_se=.
label var lr_s102d92_eff "link_pos unadjusted S.E (Elementary Admin and Service Occ v SOC11-Corporate Man)"

**adjusted
gen lr_s102d92_adjv_eff=.
label var lr_s102d92_adjv_eff "link_pos adjusted effect (Elementary Admin and Service Occ v SOC11-Corporate Man)"
gen lr_s102d92_adjv_se=.
label var lr_s102d92_adjv_se "link_pos adjusted SE (Elementary Admin and Service Occ v SOC11-Corporate Man)"



****************************
***SIC 2010 1d


****************************
***SOC 2010 1d





****************************
***KEY WORKER

**Self-Reported Infection
**Key-Worker Results - unadjusted
gen sr_kw_eff=.
label var sr_kw_eff "Self-rep unadjusted effect (Key_worker v not)"
gen sr_kw_se=.
label var sr_kw_se "Self-rep unadjusted S.E (Key_worker v not)"
gen sr_kw_lc=.
label var sr_kw_eff "Self-rep unadjusted LCI (Key_worker v not)"
gen sr_kw_uc=.
label var sr_kw_eff "Self-rep unadjusted UCI (Key_worker v not)"

**Key-Worker Results - adjusted
gen sr_kw_adjv_eff=.
label var sr_kw_adjv_eff "Self-rep adjusted effect (Key_worker v not)"
gen sr_kw_adjv_se=.
label var sr_kw_adjv_se "Self-rep adjusted SE (Key_worker v not)"
gen sr_kw_adjv_lc=.
label var sr_kw_adjv_lc "Self-rep adjusted LCI (Key_worker v not)"
gen sr_kw_adjv_uc=.
label var sr_kw_adjv_uc "Self-rep adjusted UCI (Key_worker v not)"

**Linked Positive Test
**Key-Worker Results - unadjusted
gen lr_kw_eff=.
label var lr_kw_eff "link_pos unadjusted effect (Key_worker v not)"
gen lr_kw_se=.
label var lr_kw_eff "link_pos unadjusted S.E (Key_worker v not)"
gen lr_kw_lc=.
label var lr_kw_eff "link_pos unadjusted LCI (Key_worker v not)"
gen lr_kw_uc=.
label var lr_kw_eff "link_pos unadjusted UCI (Key_worker v not)"

**Key-Worker Results - adjusted
gen lr_kw_adjv_eff=.
label var lr_kw_adjv_eff "link_pos adjusted effect (Key_worker v not)"
gen lr_kw_adjv_se=.
label var lr_kw_adjv_se "link_pos adjusted SE (Key_worker v not)"
gen lr_kw_adjv_lc=.
label var lr_kw_adjv_lc "link_pos adjusted LCI (Key_worker v not)"
gen lr_kw_adjv_uc=.
label var lr_kw_adjv_uc "link_pos adjusted UCI (Key_worker v not)"


***************************
**employment status
*employment (Employed / Retired / Unemployed) 

**Retired vs employed
**- unadjusted
gen sr_re_eff=.
label var sr_re_eff "Self-rep unadjusted effect (Retired v Employed)"
gen sr_re_se=.
label var sr_re_se "Self-rep unadjusted S.E (Retired v Employed)"
gen sr_re_lc=.
label var sr_re_eff "Self-rep unadjusted LCI (Retired v Employed)"
gen sr_re_uc=.
label var sr_re_eff "Self-rep unadjusted UCI (Retired v Employed)"

**- adjusted
gen sr_re_adjv_eff=.
label var sr_re_adjv_eff "Self-rep adjusted effect (Retired v Employed)"
gen sr_re_adjv_se=.
label var sr_re_adjv_se "Self-rep adjusted SE (Retired v Employed)"
gen sr_re_adjv_lc=.
label var sr_re_adjv_lc "Self-rep adjusted LCI (Retired v Employed)"
gen sr_re_adjv_uc=.
label var sr_re_adjv_uc "Self-rep adjusted UCI (Retired v Employed)"

**Linked Positive Test
** - unadjusted
gen lr_re_eff=.
label var lr_re_eff "link_pos unadjusted effect (Retired v Employed)"
gen lr_re_se=.
label var lr_re_eff "link_pos unadjusted S.E (Retired v Employed)"
gen lr_re_lc=.
label var lr_re_eff "link_pos unadjusted LCI (Retired v Employed)"
gen lr_re_uc=.
label var lr_re_eff "link_pos unadjusted UCI (Retired v Employed)"

** - adjusted
gen lr_re_adjv_eff=.
label var lr_re_adjv_eff "link_pos adjusted effect (Retired v Employed)"
gen lr_re_adjv_se=.
label var lr_re_adjv_se "link_pos adjusted SE (Retired v Employed)"
gen lr_re_adjv_lc=.
label var lr_re_adjv_lc "link_pos adjusted LCI (Retired v Employed)"
gen lr_re_adjv_uc=.
label var lr_re_adjv_uc "link_pos adjusted UCI (Retired v Employed)"


**Unemployed vs employed
**- unadjusted
gen sr_un_eff=.
label var sr_un_eff "Self-rep unadjusted effect (Unemployed v Employed)"
gen sr_un_se=.
label var sr_un_se "Self-rep unadjusted S.E (Unemployed v Employed)"
gen sr_un_lc=.
label var sr_un_eff "Self-rep unadjusted LCI (Unemployed v Employed)"
gen sr_un_uc=.
label var sr_un_eff "Self-rep unadjusted UCI (Unemployed v Employed)"

**- adjusted
gen sr_un_adjv_eff=.
label var sr_un_adjv_eff "Self-rep adjusted effect (Unemployed v Employed)"
gen sr_un_adjv_se=.
label var sr_un_adjv_se "Self-rep adjusted SE (Unemployed v Employed)"
gen sr_un_adjv_lc=.
label var sr_un_adjv_lc "Self-rep adjusted LCI (Unemployed v Employed)"
gen sr_un_adjv_uc=.
label var sr_un_adjv_uc "Self-rep adjusted UCI (Unemployed v Employed)"

**Linked Positive Test
** - unadjusted
gen lr_un_eff=.
label var lr_un_eff "link_pos unadjusted effect (Unemployed v Employed)"
gen lr_un_se=.
label var lr_un_eff "link_pos unadjusted S.E (Unemployed v Employed)"
gen lr_un_lc=.
label var lr_un_eff "link_pos unadjusted LCI (Unemployed v Employed)"
gen lr_un_uc=.
label var lr_un_eff "link_pos unadjusted UCI (Unemployed v Employed)"

** - adjusted
gen lr_un_adjv_eff=.
label var lr_un_adjv_eff "link_pos adjusted effect (Unemployed v Employed)"
gen lr_un_adjv_se=.
label var lr_un_adjv_se "link_pos adjusted SE (Unemployed v Employed)"
gen lr_un_adjv_lc=.
label var lr_un_adjv_lc "link_pos adjusted LCI (Unemployed v Employed)"
gen lr_un_adjv_uc=.
label var lr_un_adjv_uc "link_pos adjusted UCI (Unemployed v Employed)"




************************************************************
*employment_status  (full-time/part/retired/emply but not working/unemployed)

**Part-time vs full-time
**- unadjusted
gen sr_pt_eff=.
label var sr_pt_eff "Self-rep unadjusted effect (Part-time vs full-time)"
gen sr_pt_se=.
label var sr_pt_se "Self-rep unadjusted S.E (Part-time vs full-time)"
gen sr_pt_lc=.
label var sr_pt_eff "Self-rep unadjusted LCI (Part-time vs full-time)"
gen sr_pt_uc=.
label var sr_pt_eff "Self-rep unadjusted UCI (Part-time vs full-time)"

**- adjusted
gen sr_pt_adjv_eff=.
label var sr_pt_adjv_eff "Self-rep adjusted effect (Part-time vs full-time)"
gen sr_pt_adjv_se=.
label var sr_pt_adjv_se "Self-rep adjusted SE (Part-time vs full-time)"
gen sr_pt_adjv_lc=.
label var sr_pt_adjv_lc "Self-rep adjusted LCI (Part-time vs full-time)"
gen sr_pt_adjv_uc=.
label var sr_pt_adjv_uc "Self-rep adjusted UCI (Part-time vs full-time)"

**Linked Positive Test
** - unadjusted
gen lr_pt_eff=.
label var lr_pt_eff "link_pos unadjusted effect (Part-time vs full-time)"
gen lr_pt_se=.
label var lr_pt_eff "link_pos unadjusted S.E (Part-time vs full-time)"
gen lr_pt_lc=.
label var lr_pt_eff "link_pos unadjusted LCI (Part-time vs full-time)"
gen lr_pt_uc=.
label var lr_pt_eff "link_pos unadjusted UCI (Part-time vs full-time)"

** - adjusted
gen lr_pt_adjv_eff=.
label var lr_pt_adjv_eff "link_pos adjusted effect (Part-time vs full-time)"
gen lr_pt_adjv_se=.
label var lr_pt_adjv_se "link_pos adjusted SE (Part-time vs full-time)"
gen lr_pt_adjv_lc=.
label var lr_pt_adjv_lc "link_pos adjusted LCI (Part-time vs full-time)"
gen lr_pt_adjv_uc=.
label var lr_pt_adjv_uc "link_pos adjusted UCI (Part-time vs full-time)"



**Retired vs full-time
**- unadjusted
gen sr_ret_eff=.
label var sr_ret_eff "Self-rep unadjusted effect (Retired vs full-time)"
gen sr_ret_se=.
label var sr_ret_se "Self-rep unadjusted S.E (Retired vs full-time)"
gen sr_ret_lc=.
label var sr_ret_eff "Self-rep unadjusted LCI (Retired vs full-time)"
gen sr_ret_uc=.
label var sr_ret_eff "Self-rep unadjusted UCI (Retired vs full-time)"

**- adjusted
gen sr_ret_adjv_eff=.
label var sr_ret_adjv_eff "Self-rep adjusted effect (Retired vs full-time)"
gen sr_ret_adjv_se=.
label var sr_ret_adjv_se "Self-rep adjusted SE (Retired vs full-time)"
gen sr_ret_adjv_lc=.
label var sr_ret_adjv_lc "Self-rep adjusted LCI (Retired vs full-time)"
gen sr_ret_adjv_uc=.
label var sr_ret_adjv_uc "Self-rep adjusted UCI (Retired vs full-time)"

**Linked Positive Test
** - unadjusted
gen lr_ret_eff=.
label var lr_ret_eff "link_pos unadjusted effect (Retired vs full-time)"
gen lr_ret_se=.
label var lr_ret_eff "link_pos unadjusted S.E (Retired vs full-time)"
gen lr_ret_lc=.
label var lr_ret_eff "link_pos unadjusted LCI (Retired vs full-time)"
gen lr_ret_uc=.
label var lr_ret_eff "link_pos unadjusted UCI (Retired vs full-time)"

** - adjusted
gen lr_ret_adjv_eff=.
label var lr_ret_adjv_eff "link_pos adjusted effect (Retired vs full-time)"
gen lr_ret_adjv_se=.
label var lr_ret_adjv_se "link_pos adjusted SE (Retired vs full-time)"
gen lr_ret_adjv_lc=.
label var lr_ret_adjv_lc "link_pos adjusted LCI (Retired vs full-time)"
gen lr_ret_adjv_uc=.
label var lr_ret_adjv_uc "link_pos adjusted UCI (Retired vs full-time)"



**Employed but not working vs full-time
**- unadjusted
gen sr_nw_eff=.
label var sr_nw_eff "Self-rep unadjusted effect (Emp but not working vs full-time)"
gen sr_nw_se=.
label var sr_nw_se "Self-rep unadjusted S.E (Emp but not working vs full-time)"
gen sr_nw_lc=.
label var sr_nw_eff "Self-rep unadjusted LCI (Emp but not working vs full-time)"
gen sr_nw_uc=.
label var sr_nw_eff "Self-rep unadjusted UCI (Emp but not working vs full-time)"

**- adjusted
gen sr_nw_adjv_eff=.
label var sr_nw_adjv_eff "Self-rep adjusted effect (Emp but not working vs full-time)"
gen sr_nw_adjv_se=.
label var sr_nw_adjv_se "Self-rep adjusted SE (Emp but not working vs full-time)"
gen sr_nw_adjv_lc=.
label var sr_nw_adjv_lc "Self-rep adjusted LCI (Emp but not working vs full-time)"
gen sr_nw_adjv_uc=.
label var sr_nw_adjv_uc "Self-rep adjusted UCI (Emp but not working vs full-time)"

**Linked Positive Test
** - unadjusted
gen lr_nw_eff=.
label var lr_nw_eff "link_pos unadjusted effect (Emp but not working vs full-time)"
gen lr_nw_se=.
label var lr_nw_eff "link_pos unadjusted S.E (Emp but not working vs full-time)"
gen lr_nw_lc=.
label var lr_nw_eff "link_pos unadjusted LCI (Emp but not working vs full-time)"
gen lr_nw_uc=.
label var lr_nw_eff "link_pos unadjusted UCI (Emp but not working vs full-time)"

** - adjusted
gen lr_nw_adjv_eff=.
label var lr_nw_adjv_eff "link_pos adjusted effect (Emp but not working vs full-time)"
gen lr_nw_adjv_se=.
label var lr_nw_adjv_se "link_pos adjusted SE (Emp but not working vs full-time)"
gen lr_nw_adjv_lc=.
label var lr_nw_adjv_lc "link_pos adjusted LCI (Emp but not working vs full-time)"
gen lr_nw_adjv_uc=.
label var lr_nw_adjv_uc "link_pos adjusted UCI (Emp but not working vs full-time)"


**Unemployed v full time 
**- unadjusted
gen sr_une_eff=.
label var sr_une_eff "Self-rep unadjusted effect (Unemployed vs full-time)"
gen sr_une_se=.
label var sr_une_se "Self-rep unadjusted S.E (Unemployed vs full-time)"
gen sr_une_lc=.
label var sr_une_eff "Self-rep unadjusted LCI (Unemployed vs full-time)"
gen sr_une_uc=.
label var sr_une_eff "Self-rep unadjusted UCI (Unemployed vs full-time)"

**- adjusted
gen sr_une_adjv_eff=.
label var sr_une_adjv_eff "Self-rep adjusted effect (Unemployed vs full-time)"
gen sr_une_adjv_se=.
label var sr_une_adjv_se "Self-rep adjusted SE (Unemployed vs full-time)"
gen sr_une_adjv_lc=.
label var sr_une_adjv_lc "Self-rep adjusted LCI (Unemployed vs full-time)"
gen sr_une_adjv_uc=.
label var sr_une_adjv_uc "Self-rep adjusted UCI (Unemployed vs full-time)"

**Linked Positive Test
** - unadjusted
gen lr_une_eff=.
label var lr_une_eff "link_pos unadjusted effect (Unemployed vs full-time)"
gen lr_une_se=.
label var lr_une_eff "link_pos unadjusted S.E (Unemployed vs full-time)"
gen lr_une_lc=.
label var lr_une_eff "link_pos unadjusted LCI (Unemployed vs full-time)"
gen lr_une_uc=.
label var lr_une_eff "link_pos unadjusted UCI (Unemployed vs full-time)"

** - adjusted
gen lr_une_adjv_eff=.
label var lr_une_adjv_eff "link_pos adjusted effect (Unemployed vs full-time)"
gen lr_une_adjv_se=.
label var lr_une_adjv_se "link_pos adjusted SE (Unemployed vs full-time)"
gen lr_une_adjv_lc=.
label var lr_une_adjv_lc "link_pos adjusted LCI (Unemployed vs full-time)"
gen lr_une_adjv_uc=.
label var lr_une_adjv_uc "link_pos adjusted UCI (Unemployed vs full-time)"



*****************************************************
**Home working	
*home_working  (all/some/none)


**Some v All home working 
**- unadjusted
gen sr_sm_eff=.
label var sr_sm_eff "Self-rep unadjusted effect (Some v All home working)"
gen sr_sm_se=.
label var sr_sm_se "Self-rep unadjusted S.E (Some v All home working)"
gen sr_sm_lc=.
label var sr_sm_eff "Self-rep unadjusted LCI (Some v All home working)"
gen sr_sm_uc=.
label var sr_sm_eff "Self-rep unadjusted UCI (Some v All home working)"

**- adjusted
gen sr_sm_adjv_eff=.
label var sr_sm_adjv_eff "Self-rep adjusted effect (Some v All home working)"
gen sr_sm_adjv_se=.
label var sr_sm_adjv_se "Self-rep adjusted SE (Some v All home working)"
gen sr_sm_adjv_lc=.
label var sr_sm_adjv_lc "Self-rep adjusted LCI (Some v All home working)"
gen sr_sm_adjv_uc=.
label var sr_sm_adjv_uc "Self-rep adjusted UCI (Some v All home working)"

**Linked Positive Test
** - unadjusted
gen lr_sm_eff=.
label var lr_sm_eff "link_pos unadjusted effect (Some v All home working)"
gen lr_sm_se=.
label var lr_sm_eff "link_pos unadjusted S.E (Some v All home working)"
gen lr_sm_lc=.
label var lr_sm_eff "link_pos unadjusted LCI (Some v All home working)"
gen lr_sm_uc=.
label var lr_sm_eff "link_pos unadjusted UCI (Some v All home working)"

** - adjusted
gen lr_sm_adjv_eff=.
label var lr_sm_adjv_eff "link_pos adjusted effect (Some v All home working)"
gen lr_sm_adjv_se=.
label var lr_sm_adjv_se "link_pos adjusted SE (Some v All home working)"
gen lr_sm_adjv_lc=.
label var lr_sm_adjv_lc "link_pos adjusted LCI (Some v All home working)"
gen lr_sm_adjv_uc=.
label var lr_sm_adjv_uc "link_pos adjusted UCI (Some v All home working)"


**None v All home working 
**- unadjusted
gen sr_no_eff=.
label var sr_no_eff "Self-rep unadjusted effect (None v All home working)"
gen sr_no_se=.
label var sr_no_se "Self-rep unadjusted S.E (None v All home working)"
gen sr_no_lc=.
label var sr_no_eff "Self-rep unadjusted LCI (None v All home working)"
gen sr_no_uc=.
label var sr_no_eff "Self-rep unadjusted UCI (None v All home working)"

**- adjusted
gen sr_no_adjv_eff=.
label var sr_no_adjv_eff "Self-rep adjusted effect (None v All home working)"
gen sr_no_adjv_se=.
label var sr_no_adjv_se "Self-rep adjusted SE (None v All home working)"
gen sr_no_adjv_lc=.
label var sr_no_adjv_lc "Self-rep adjusted LCI (None v All home working)"
gen sr_no_adjv_uc=.
label var sr_no_adjv_uc "Self-rep adjusted UCI (None v All home working)"

**Linked Positive Test
** - unadjusted
gen lr_no_eff=.
label var lr_no_eff "link_pos unadjusted effect (None v All home working)"
gen lr_no_se=.
label var lr_no_eff "link_pos unadjusted S.E (None v All home working)"
gen lr_no_lc=.
label var lr_no_eff "link_pos unadjusted LCI (None v All home working)"
gen lr_no_uc=.
label var lr_no_eff "link_pos unadjusted UCI (None v All home working)"

** - adjusted
gen lr_no_adjv_eff=.
label var lr_no_adjv_eff "link_pos adjusted effect (None v All home working)"
gen lr_no_adjv_se=.
label var lr_no_adjv_se "link_pos adjusted SE (None v All home working)"
gen lr_no_adjv_lc=.
label var lr_no_adjv_lc "link_pos adjusted LCI (None v All home working)"
gen lr_no_adjv_uc=.
label var lr_no_adjv_uc "link_pos adjusted UCI (None v All home working)"


****************************************
**Furlough
*furlough (no/yes)
**Self-Reported Infection
**- unadjusted
gen sr_fr_eff=.
label var sr_fr_eff "Self-rep unadjusted effect (Furlough v not)"
gen sr_fr_se=.
label var sr_fr_se "Self-rep unadjusted S.E (Furlough v not)"
gen sr_fr_lc=.
label var sr_fr_eff "Self-rep unadjusted LCI (Furlough v not)"
gen sr_fr_uc=.
label var sr_fr_eff "Self-rep unadjusted UCI (Furlough v not)"

**- adjusted
gen sr_fr_adjv_eff=.
label var sr_fr_adjv_eff "Self-rep adjusted effect (Furlough v not)"
gen sr_fr_adjv_se=.
label var sr_fr_adjv_se "Self-rep adjusted SE (Furlough v not)"
gen sr_fr_adjv_lc=.
label var sr_fr_adjv_lc "Self-rep adjusted LCI (Furlough v not)"
gen sr_fr_adjv_uc=.
label var sr_fr_adjv_uc "Self-rep adjusted UCI (Furlough v not)"

**Linked Positive Test
** - unadjusted
gen lr_fr_eff=.
label var lr_fr_eff "link_pos unadjusted effect (Furlough v not)"
gen lr_fr_se=.
label var lr_fr_eff "link_pos unadjusted S.E (Furlough v not)"
gen lr_fr_lc=.
label var lr_fr_eff "link_pos unadjusted LCI (Furlough v not)"
gen lr_fr_uc=.
label var lr_fr_eff "link_pos unadjusted UCI (Furlough v not)"

** - adjusted
gen lr_fr_adjv_eff=.
label var lr_fr_adjv_eff "link_pos adjusted effect (Furlough v not)"
gen lr_fr_adjv_se=.
label var lr_fr_adjv_se "link_pos adjusted SE (Furlough v not)"
gen lr_fr_adjv_lc=.
label var lr_fr_adjv_lc "link_pos adjusted LCI (Furlough v not)"
gen lr_fr_adjv_uc=.
label var lr_fr_adjv_uc "link_pos adjusted UCI (Furlough v not)"


save "S:\LLC_0007\data\results_datafile time-tranche vacc", replace

