

********************************************************************************
**SETTING UP THIRD STAGE FILE
**STORING THE OVERALL META EFFECT ESTIMATES FOR META-ANALYSIS COMBINATIONS COMPARISONS
******************************************************************************** 
 

clear
set obs 156
gen id=_n
gen effect_id=_n

label define effect_id 1 "kw_sr_ua" 2 "kw_sr_adj" 3 "kw_sr_vadj" 4 "kw_lr_ua" 5 "kw_lr_adj" 6 "kw_lr_vadj" 7 "ret_sr_ua" 8 "ret_sr_adj" 9 "ret_sr_vadj" 10 "ret_lr_ua" 11 "ret_lr_adj" 12 "ret_lr_vadj" 13 "un_sr_ua" 14 "un_sr_adj" 15 "un_sr_vadj" 16 "un_lr_ua" 17 "un_lr_adj" 18 "un_lr_vadj" 19 "pt_sr_ua" 20 "pt_sr_adj" 21 "pt_sr_vadj" 22 "pt_lr_ua" 23 "pt_lr_adj" 24 "pt_lr_vadj" 25 "rt_sr_ua" 26 "rt_sr_adj" 27 "rt_sr_vadj" 28 "rt_lr_ua" 29 "rt_lr_adj" 30 "rt_lr_vadj" 31 "nw_sr_ua" 32 "nw_sr_adj" 33 "nw_sr_vadj" 34 "nw_lr_ua" 35 "nw_lr_adj" 36 "nw_lr_vadj" 37 "une_sr_ua" 38 "une_sr_adj" 39 "une_sr_vadj" 40 "une_lr_ua" 41 "une_lr_adj" 42 "une_lr_vadj" 43 "sh_sr_ua" 44 "sh_sr_adj" 45 "sh_sr_vadj" 46 "sh_lr_ua" 47 "sh_lr_adj" 48 "sh_lr_vadj" 49 "nh_sr_ua" 50 "nh_sr_adj" 51 "nh_sr_vadj" 52 "nh_lr_ua" 53 "nh_lr_adj" 54 "nh_lr_vadj" 55 "fr_sr_ua" 56 "fr_sr_adj" 57 "fr_sr_vadj" 58 "fr_lr_ua" 59 "fr_lr_adj" 60 "fr_lr_vadj" 61 "occf1_sr_ua" 62 "occf1_sr_adj" 63 "occf1_sr_vadj" 64 "occf1_lr_ua" 65 "occf1_lr_adj" 66 "occf1_lr_vadj" 67 "occf4_sr_ua" 68 "occf4_sr_adj" 69 "occf4_sr_vadj" 70 "occf4_lr_ua" 71 "occf4_lr_adj" 72 "occf4_lr_vadj" 73 "occf5_sr_ua" 74 "occf5_sr_adj" 75 "occf5_sr_vadj" 76 "occf5_lr_ua" 77 "occf5_lr_adj" 78 "occf5_lr_vadj" 79 "occf6_sr_ua" 80 "occf6_sr_adj" 81 "occf6_sr_vadj" 82 "occf6_lr_ua" 83 "occf6_lr_adj" 84 "occf6_lr_vadj" 85 "occf7_sr_ua" 86 "occf7_sr_adj" 87 "occf7_sr_vadj" 88 "occf7_lr_ua" 89 "occf7_lr_adj" 90 "occf7_lr_vadj" 91 "occf8_sr_ua" 92 "occf8_sr_adj" 93 "occf8_sr_vadj" 94 "occf8_lr_ua" 95 "occf8_lr_adj" 96 "occf8_lr_vadj" 97 "occf11_sr_ua" 98 "occf11_sr_adj" 99 "occf11_sr_vadj" 100 "occf11_lr_ua" 101 "occf11_lr_adj" 102 "occf11_lr_vadj" 103 "occf12_sr_ua" 104 "occf12_sr_adj" 105 "occf12_sr_vadj" 106 "occf12_lr_ua" 107 "occf12_lr_adj" 108 "occf12_lr_vadj" 109 "occf13_sr_ua" 110 "occf13_sr_adj" 111 "occf13_sr_vadj" 112 "occf13_lr_ua" 113 "occf13_lr_adj" 114 "occf13_lr_vadj" 115 "occf20_sr_ua" 116 "occf20_sr_adj" 117 "occf20_sr_vadj" 118 "occf20_lr_ua" 119 "occf20_lr_adj" 120 "occf20_lr_vadj" 121 "occr1_sr_ua" 122 "occr1_sr_adj" 123 "occr1_sr_vadj" 124 "occr1_lr_ua" 125 "occr1_lr_adj" 126 "occr1_lr_vadj" 127 "occr2_sr_ua" 128 "occr2_sr_adj" 129 "occr2_sr_vadj" 130 "occr2_lr_ua" 131 "occr2_lr_adj" 132 "occr2_lr_vadj" 133 "occr3_sr_ua" 134 "occr3_sr_adj" 135 "occr3_sr_vadj" 136 "occr3_lr_ua" 137 "occr3_lr_adj" 138 "occr3_lr_vadj" 139 "occr4_sr_ua" 140 "occr4_sr_adj" 141 "occr4_sr_vadj" 142 "occr4_lr_ua" 143 "occr4_lr_adj" 144 "occr4_lr_vadj" 145 "occr5_sr_ua" 146 "occr5_sr_adj" 147 "occr5_sr_vadj" 148 "occr5_lr_ua" 149 "occr5_lr_adj" 150 "occr5_lr_vadj" 151 "occr6_sr_ua" 152 "occr6_sr_adj" 153 "occr6_sr_vadj" 154 "occr6_lr_ua" 155 "occr6_lr_adj" 156 "occr6_lr_vadj", replace 
label values effect_id effect_id


expand 3
bysort effect_id: egen time_tranche=seq()
label define time_tranche 1 "Overall" 2 "Apr-Oct20" 3 "Nov-Mar21", replace
label values time_tranche time_tranche
tab time_tranche
gen effect=.
gen se=.
gen q=.
gen pq=.
gen tau2=.
gen i2=.
gen h2=.


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


save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace




********************************************************************************
***Combining and analysing Results Files
********************************************************************************


***Main analysis, includes all occupational characteristics, unadjusted and adjusted for age, gender, and ethncity only 
use "S:\LLC_0007\data\results_datafile time-tranche", clear
codebook, compact

***Main analysis, includes all occupational characteristics,, unadjusted and adjusted for age, gender, and ethncity only + vaccination status and household living situation where possible 
use "S:\LLC_0007\data\results_datafile time-tranche vacc", clear
codebook, compact




**merge into one
use "S:\LLC_0007\data\results_datafile time-tranche", clear
codebook, compact
quietly describe
di r(k)
**remove SOCs
drop *s10* *_lc *_uc
quietly describe
di r(k)

**add in main analysis with vacc adjustment
merge 1:1 study_id time_tranche using "S:\LLC_0007\data\results_datafile time-tranche vacc"
drop _merge
quietly describe
di r(k)
drop *s10* *_lc *_uc
quietly describe
di r(k)


**add in occupation analysis -
merge 1:1 study_id time_tranche using "S:\LLC_0007\data\results_datafile occupation only time-tranche"
drop _merge
quietly describe
di r(k)

**add in occupation analysis adj for vacc
merge 1:1 study_id time_tranche using "S:\LLC_0007\data\results_datafile occupation only time-tranche vacc"
drop _merge
quietly describe
di r(k)


**Keep the pandemic time-tranche is Overall, Apr-Oct 2020, and Nov20-Mar21
keep if inlist(time_tranche, 1,5,6)


****Combined analysis prep
replace linkpos_no=. if study_id==8

preserve 
*set obs 115
replace study_id=0 if study_id==.
replace time_tranche=1 if time_tranche==.
foreach var of varlist sample_n entry_n selfinf_n selfpos_no linkpos_no {
sum `var' if time_tranche==1 & study_id<=15
replace `var'=r(sum) if time_tranche==1 & study_id==0
}
list study_id sample_n entry_n selfinf_n selfpos_no linkpos_no if time_tranche==1, sepby(time_tranche)
restore

foreach v in sr_kw sr_kw_adj sr_kw_adjv lr_kw lr_kw_adj lr_kw_adjv sr_ret sr_ret_adj sr_ret_adjv lr_ret lr_ret_adj lr_ret_adjv sr_un sr_un_adj sr_un_adjv lr_un lr_un_adj lr_un_adjv sr_pt sr_pt_adj sr_pt_adjv lr_pt lr_pt_adj lr_pt_adjv sr_re sr_re_adj sr_re_adjv lr_re lr_re_adj lr_re_adjv sr_nw sr_nw_adj sr_nw_adjv lr_nw lr_nw_adj lr_nw_adjv sr_une sr_une_adj sr_une_adjv lr_une lr_une_adj lr_une_adjv sr_sm sr_sm_adj sr_sm_adjv lr_sm lr_sm_adj lr_sm_adjv sr_no sr_no_adj sr_no_adjv lr_no lr_no_adj lr_no_adjv sr_fr sr_fr_adj sr_fr_adjv lr_fr lr_fr_adj lr_fr_adjv sr_occf1 sr_occf1_adj sr_occf1_adjv lr_occf1 lr_occf1_adj lr_occf1_adjv sr_occf4 sr_occf4_adj sr_occf4_adjv lr_occf4 lr_occf4_adj lr_occf4_adjv sr_occf5 sr_occf5_adj sr_occf5_adjv lr_occf5 lr_occf5_adj lr_occf5_adjv sr_occf6 sr_occf6_adj sr_occf6_adjv lr_occf6 lr_occf6_adj lr_occf6_adjv sr_occf7 sr_occf7_adj sr_occf7_adjv lr_occf7 lr_occf7_adj lr_occf7_adjv sr_occf8 sr_occf8_adj sr_occf8_adjv lr_occf8 lr_occf8_adj lr_occf8_adjv sr_occf11 sr_occf11_adj sr_occf11_adjv lr_occf11 lr_occf11_adj lr_occf11_adjv sr_occf12 sr_occf12_adj sr_occf12_adjv lr_occf12 lr_occf12_adj lr_occf12_adjv sr_occf13 sr_occf13_adj sr_occf13_adjv lr_occf13 lr_occf13_adj lr_occf13_adjv sr_occf20 sr_occf20_adj sr_occf20_adjv lr_occf20 lr_occf20_adj lr_occf20_adjv sr_occr1 sr_occr1_adj sr_occr1_adjv lr_occr1 lr_occr1_adj lr_occr1_adjv sr_occr2 sr_occr2_adj sr_occr2_adjv lr_occr2 lr_occr2_adj lr_occr2_adjv sr_occr3 sr_occr3_adj sr_occr3_adjv lr_occr3 lr_occr3_adj lr_occr3_adjv sr_occr4 sr_occr4_adj sr_occr4_adjv lr_occr4 lr_occr4_adj lr_occr4_adjv sr_occr5 sr_occr5_adj sr_occr5_adjv lr_occr5 lr_occr5_adj lr_occr5_adjv sr_occr6 sr_occr6_adj sr_occr6_adjv lr_occr6 lr_occr6_adj lr_occr6_adjv  {
	replace `v'_se=. if `v'_eff<-2.3
	replace `v'_eff=. if `v'_eff<-2.3
	replace `v'_se=. if `v'_eff>3
	replace `v'_eff=. if `v'_eff>3
	
}

numlabel study_id, add










****************************
***KEY WORKER & study_id!=4 & study_id!=12

**Self-Reported Infection 
**Key-Worker Results - unadjusted xmlabel(0.6 0.8 1.0 1.2 1.4 1.6)
meta set sr_kw_eff sr_kw_se, studylabel(study_name) eslabel("Key worker v not")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=12, 

meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow
matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]


preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==1 & time_tranche==`i' 
replace se=`se`i'' if effect_id==1 & time_tranche==`i' 
replace q=`q`i'' if effect_id==1 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==1 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==1 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==1 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==1 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore





**Key-Worker Results - adjusted a/s/e
meta set sr_kw_adj_eff sr_kw_adj_se, studylabel(study_name) eslabel("Key-Worker v not")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==2 & time_tranche==`i' 
replace se=`se`i'' if effect_id==2 & time_tranche==`i' 
replace q=`q`i'' if effect_id==2 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==2 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==2 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==2 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==2 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**Key-Worker Results - adjusted a/s/e + vacc etc
meta set sr_kw_adjv_eff sr_kw_adjv_se, studylabel(study_name) eslabel("Key-Worker v not")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==3 & time_tranche==`i' 
replace se=`se`i'' if effect_id==3 & time_tranche==`i' 
replace q=`q`i'' if effect_id==3 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==3 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==3 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==3 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==3 & time_tranche==`i'

}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**Linked Positive Test
**Key-Worker Results - unadjusted
meta set lr_kw_eff lr_kw_se, studylabel(study_name) eslabel("Key-Worker v not")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==4 & time_tranche==`i' 
replace se=`se`i'' if effect_id==4 & time_tranche==`i' 
replace q=`q`i'' if effect_id==4 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==4 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==4 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==4 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==4 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**Key-Worker Results - adjusted a/s/e
meta set lr_kw_adj_eff lr_kw_adj_se, studylabel(study_name) eslabel("Key-Worker v not")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==5 & time_tranche==`i' 
replace se=`se`i'' if effect_id==5 & time_tranche==`i' 
replace q=`q`i'' if effect_id==5 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==5 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==5 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==5 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==5 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Key-Worker Results - adjusted a/s/e + vacc etc
meta set lr_kw_adjv_eff lr_kw_adjv_se, studylabel(study_name) eslabel("Key-Worker v not")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==6 & time_tranche==`i' 
replace se=`se`i'' if effect_id==6 & time_tranche==`i' 
replace q=`q`i'' if effect_id==6 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==6 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==6 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==6 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==6 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

***************************
**employment status
*employment (Employed / Retired / Unemployed) 

**Retired vs employed
**- unadjusted
meta set sr_re_eff sr_re_se, studylabel(study_name) eslabel("Ret v Employed")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==7 & time_tranche==`i' 
replace se=`se`i'' if effect_id==7 & time_tranche==`i' 
replace q=`q`i'' if effect_id==7 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==7 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==7 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==7 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==7 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_re_adj_eff sr_re_adj_se, studylabel(study_name) eslabel("Ret v Employed")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==8 & time_tranche==`i' 
replace se=`se`i'' if effect_id==8 & time_tranche==`i' 
replace q=`q`i'' if effect_id==8 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==8 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==8 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==8 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==8 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**- adjusted a/s/e + vacc etc
meta set sr_re_adjv_eff sr_re_adjv_se, studylabel(study_name) eslabel("Ret v Employed")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==9 & time_tranche==`i' 
replace se=`se`i'' if effect_id==9 & time_tranche==`i' 
replace q=`q`i'' if effect_id==9 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==9 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==9 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==9 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==9 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
*drop if study_id==15 & time_tranche==5
meta set lr_re_eff lr_re_se, studylabel(study_name) eslabel("Ret v Employed")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==10 & time_tranche==`i' 
replace se=`se`i'' if effect_id==10 & time_tranche==`i' 
replace q=`q`i'' if effect_id==10 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==10 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==10 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==10 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==10 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_re_adj_eff lr_re_adj_se, studylabel(study_name) eslabel("Ret v Employed")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==11 & time_tranche==`i' 
replace se=`se`i'' if effect_id==11 & time_tranche==`i' 
replace q=`q`i'' if effect_id==11 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==11 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==11 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==11 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==11 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_re_adjv_eff lr_re_adjv_se, studylabel(study_name) eslabel("Ret v Employed")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==12 & time_tranche==`i' 
replace se=`se`i'' if effect_id==12 & time_tranche==`i' 
replace q=`q`i'' if effect_id==12 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==12 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==12 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==12 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==12 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Unemployed vs employed
**- unadjusted
meta set sr_un_eff sr_un_se, studylabel(study_name) eslabel("Unemp v Employed")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==13 & time_tranche==`i' 
replace se=`se`i'' if effect_id==13 & time_tranche==`i' 
replace q=`q`i'' if effect_id==13 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==13 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==13 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==13 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==13 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_un_adj_eff sr_un_adj_se, studylabel(study_name) eslabel("Unemp v Employed")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==14 & time_tranche==`i' 
replace se=`se`i'' if effect_id==14 & time_tranche==`i' 
replace q=`q`i'' if effect_id==14 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==14 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==14 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==14 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==14 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**- adjusted a/s/e + vacc etc
meta set sr_un_adjv_eff sr_un_adjv_se, studylabel(study_name) eslabel("Unemp v Employed")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==15 & time_tranche==`i' 
replace se=`se`i'' if effect_id==15 & time_tranche==`i' 
replace q=`q`i'' if effect_id==15 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==15 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==15 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==15 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==15 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_un_eff lr_un_se, studylabel(study_name) eslabel("Unemp v Employed")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==16 & time_tranche==`i' 
replace se=`se`i'' if effect_id==16 & time_tranche==`i' 
replace q=`q`i'' if effect_id==16 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==16 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==16 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==16 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==16 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_un_adj_eff lr_un_adj_se, studylabel(study_name) eslabel("Unemp v Employed")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==17 & time_tranche==`i' 
replace se=`se`i'' if effect_id==17 & time_tranche==`i' 
replace q=`q`i'' if effect_id==17 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==17 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==17 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==17 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==17 & time_tranche==`i'

}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


** - adjusted a/s/e + vacc etc
meta set lr_un_adjv_eff lr_un_adjv_se, studylabel(study_name) eslabel("Unemp v Employed")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==18 & time_tranche==`i' 
replace se=`se`i'' if effect_id==18 & time_tranche==`i' 
replace q=`q`i'' if effect_id==18 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==18 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==18 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==18 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==18 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

************************************************************
*employment_status  (full-time/part/retired/emply but not working/unemployed)

**Part-time vs full-time
**- unadjusted
meta set sr_pt_eff sr_pt_se, studylabel(study_name) eslabel("Part-time v full")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==19 & time_tranche==`i' 
replace se=`se`i'' if effect_id==19 & time_tranche==`i' 
replace q=`q`i'' if effect_id==19 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==19 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==19 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==19 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==19 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_pt_adj_eff sr_pt_adj_se, studylabel(study_name) eslabel("Part-time v full")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==20 & time_tranche==`i' 
replace se=`se`i'' if effect_id==20 & time_tranche==`i' 
replace q=`q`i'' if effect_id==20 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==20 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==20 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==20 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==20 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**- adjusted a/s/e + vacc etc
meta set sr_pt_adjv_eff sr_pt_adjv_se, studylabel(study_name) eslabel("Part-time v full")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==21 & time_tranche==`i' 
replace se=`se`i'' if effect_id==21 & time_tranche==`i' 
replace q=`q`i'' if effect_id==21 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==21 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==21 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==21 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==21 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_pt_eff lr_pt_se, studylabel(study_name) eslabel("Part-time v full")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==22 & time_tranche==`i' 
replace se=`se`i'' if effect_id==22 & time_tranche==`i' 
replace q=`q`i'' if effect_id==22 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==22 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==22 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==22 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==22 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore
** - adjusted a/s/e
meta set lr_pt_adj_eff lr_pt_adj_se, studylabel(study_name) eslabel("Part-time v full")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot

meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==23 & time_tranche==`i' 
replace se=`se`i'' if effect_id==23 & time_tranche==`i' 
replace q=`q`i'' if effect_id==23 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==23 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==23 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==23 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==23 & time_tranche==`i'

}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_pt_adjv_eff lr_pt_adjv_se, studylabel(study_name) eslabel("Part-time v full")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot

meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==24 & time_tranche==`i' 
replace se=`se`i'' if effect_id==24 & time_tranche==`i' 
replace q=`q`i'' if effect_id==24 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==24 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==24 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==24 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==24 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**Retired vs full-time
**- unadjusted
meta set sr_ret_eff sr_ret_se, studylabel(study_name) eslabel("Ret v full-time")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==25 & time_tranche==`i' 
replace se=`se`i'' if effect_id==25 & time_tranche==`i' 
replace q=`q`i'' if effect_id==25 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==25 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==25 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==25 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==25 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_ret_adj_eff sr_ret_adj_se, studylabel(study_name) eslabel("Ret v full-time")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==26 & time_tranche==`i' 
replace se=`se`i'' if effect_id==26 & time_tranche==`i' 
replace q=`q`i'' if effect_id==26 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==26 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==26 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==26 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==26 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e + vacc etc
meta set sr_ret_adjv_eff sr_ret_adjv_se, studylabel(study_name) eslabel("Ret v full-time")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==27 & time_tranche==`i' 
replace se=`se`i'' if effect_id==27 & time_tranche==`i' 
replace q=`q`i'' if effect_id==27 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==27 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==27 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==27 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==27 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**Linked Positive Test
** - unadjusted
meta set lr_ret_eff lr_ret_se, studylabel(study_name) eslabel("Ret v full-time")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==28 & time_tranche==`i' 
replace se=`se`i'' if effect_id==28 & time_tranche==`i' 
replace q=`q`i'' if effect_id==28 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==28 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==28 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==28 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==28 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_ret_adj_eff lr_ret_adj_se, studylabel(study_name) eslabel("Ret v full-time")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==29 & time_tranche==`i' 
replace se=`se`i'' if effect_id==29 & time_tranche==`i' 
replace q=`q`i'' if effect_id==29 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==29 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==29 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==29 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==29 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_ret_adjv_eff lr_ret_adjv_se, studylabel(study_name) eslabel("Ret v full-time")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==30 & time_tranche==`i' 
replace se=`se`i'' if effect_id==30 & time_tranche==`i' 
replace q=`q`i'' if effect_id==30 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==30 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==30 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==30 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==30 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**Employed but not working vs full-time
**- unadjusted
meta set sr_nw_eff sr_nw_se, studylabel(study_name) eslabel("Emp Not working v full-time")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==31 & time_tranche==`i' 
replace se=`se`i'' if effect_id==31 & time_tranche==`i' 
replace q=`q`i'' if effect_id==31 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==31 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==31 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==31 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==31 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_nw_adj_eff sr_nw_adj_se, studylabel(study_name) eslabel("Emp Not working v full-time")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==32 & time_tranche==`i' 
replace se=`se`i'' if effect_id==32 & time_tranche==`i' 
replace q=`q`i'' if effect_id==32 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==32 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==32 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==32 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==32 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**- adjusted a/s/e + vacc etc
meta set sr_nw_adjv_eff sr_nw_adjv_se, studylabel(study_name) eslabel("Emp Not working v full-time")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==33 & time_tranche==`i' 
replace se=`se`i'' if effect_id==33 & time_tranche==`i' 
replace q=`q`i'' if effect_id==33 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==33 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==33 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==33 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==33 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_nw_eff lr_nw_se, studylabel(study_name) eslabel("Emp Not working v full-time")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==34 & time_tranche==`i' 
replace se=`se`i'' if effect_id==34 & time_tranche==`i' 
replace q=`q`i'' if effect_id==34 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==34 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==34 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==34 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==34 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_nw_adj_eff lr_nw_adj_se, studylabel(study_name) eslabel("Emp Not working v full-time")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==35 & time_tranche==`i' 
replace se=`se`i'' if effect_id==35 & time_tranche==`i' 
replace q=`q`i'' if effect_id==35 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==35 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==35 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==35 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==35 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_nw_adjv_eff lr_nw_adjv_se, studylabel(study_name) eslabel("Emp Not working v full-time")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==36 & time_tranche==`i' 
replace se=`se`i'' if effect_id==36 & time_tranche==`i' 
replace q=`q`i'' if effect_id==36 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==36 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==36 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==36 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==36 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**Unemployed v full time 
**- unadjusted
meta set sr_une_eff sr_une_se, studylabel(study_name) eslabel("Unemp v full-time")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==37 & time_tranche==`i' 
replace se=`se`i'' if effect_id==37 & time_tranche==`i' 
replace q=`q`i'' if effect_id==37 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==37 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==37 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==37 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==37 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_une_adj_eff sr_une_adj_se, studylabel(study_name) eslabel("Unemp v full-time")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==38 & time_tranche==`i' 
replace se=`se`i'' if effect_id==38 & time_tranche==`i' 
replace q=`q`i'' if effect_id==38 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==38 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==38 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==38 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==38 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e + vacc etc
meta set sr_une_adjv_eff sr_une_adjv_se, studylabel(study_name) eslabel("Unemp v full-time")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==39 & time_tranche==`i' 
replace se=`se`i'' if effect_id==39 & time_tranche==`i' 
replace q=`q`i'' if effect_id==39 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==39 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==39 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==39 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==39 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**Linked Positive Test
** - unadjusted
meta set lr_une_eff lr_une_se, studylabel(study_name) eslabel("Unemp v full-time")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot

meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow
matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==40 & time_tranche==`i' 
replace se=`se`i'' if effect_id==40 & time_tranche==`i' 
replace q=`q`i'' if effect_id==40 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==40 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==40 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==40 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==40 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore
** - adjusted a/s/e
meta set lr_une_adj_eff lr_une_adj_se, studylabel(study_name) eslabel("Unemp v full-time")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot

meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow
matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==41 & time_tranche==`i' 
replace se=`se`i'' if effect_id==41 & time_tranche==`i' 
replace q=`q`i'' if effect_id==41 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==41 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==41 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==41 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==41 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


** - adjusted a/s/e + vacc etc
meta set lr_une_adjv_eff lr_une_adjv_se, studylabel(study_name) eslabel("Unemp v full-time")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name) random(mle)

*meta funnelplot

meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow random(mle)
matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==42 & time_tranche==`i' 
replace se=`se`i'' if effect_id==42 & time_tranche==`i' 
replace q=`q`i'' if effect_id==42 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==42 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==42 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==42 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==42 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

*****************************************************
**Home working	
*home_working  (all/some/none)


**Some v All home working 
**- unadjusted
meta set sr_sm_eff sr_sm_se, studylabel(study_name) eslabel("Some hm wrk v All hm")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow
matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==43 & time_tranche==`i' 
replace se=`se`i'' if effect_id==43 & time_tranche==`i' 
replace q=`q`i'' if effect_id==43 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==43 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==43 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==43 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==43 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_sm_adj_eff sr_sm_adj_se, studylabel(study_name) eslabel("Some hm wrk v All hm")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==44 & time_tranche==`i' 
replace se=`se`i'' if effect_id==44 & time_tranche==`i' 
replace q=`q`i'' if effect_id==44 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==44 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==44 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==44 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==44 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**- adjusted a/s/e + vacc etc
meta set sr_sm_adjv_eff sr_sm_adjv_se, studylabel(study_name) eslabel("Some hm wrk v All hm")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==45 & time_tranche==`i' 
replace se=`se`i'' if effect_id==45 & time_tranche==`i' 
replace q=`q`i'' if effect_id==45 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==45 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==45 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==45 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==45 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_sm_eff lr_sm_se, studylabel(study_name) eslabel("Some hm wrk v All hm")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==46 & time_tranche==`i' 
replace se=`se`i'' if effect_id==46 & time_tranche==`i' 
replace q=`q`i'' if effect_id==46 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==46 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==46 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==46 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==46 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_sm_adj_eff lr_sm_adj_se, studylabel(study_name) eslabel("Some hm wrk v All hm")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==47 & time_tranche==`i' 
replace se=`se`i'' if effect_id==47 & time_tranche==`i' 
replace q=`q`i'' if effect_id==47 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==47 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==47 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==47 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==47 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_sm_adjv_eff lr_sm_adjv_se, studylabel(study_name) eslabel("Some hm wrk v All hm")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==48 & time_tranche==`i' 
replace se=`se`i'' if effect_id==48 & time_tranche==`i' 
replace q=`q`i'' if effect_id==48 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==48 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==48 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==48 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==48 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**None v All home working 
**- unadjusted
meta set sr_no_eff sr_no_se, studylabel(study_name) eslabel("No hm wrk v All hm")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==49 & time_tranche==`i' 
replace se=`se`i'' if effect_id==49 & time_tranche==`i' 
replace q=`q`i'' if effect_id==49 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==49 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==49 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==49 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==49 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_no_adj_eff sr_no_adj_se, studylabel(study_name) eslabel("No hm wrk v All hm")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==50 & time_tranche==`i' 
replace se=`se`i'' if effect_id==50 & time_tranche==`i' 
replace q=`q`i'' if effect_id==50 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==50 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==50 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==50 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==50 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**- adjusted a/s/e + vacc etc
meta set sr_no_adjv_eff sr_no_adjv_se, studylabel(study_name) eslabel("No hm wrk v All hm")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==51 & time_tranche==`i' 
replace se=`se`i'' if effect_id==51 & time_tranche==`i' 
replace q=`q`i'' if effect_id==51 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==51 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==51 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==51 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==51 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_no_eff lr_no_se, studylabel(study_name) eslabel("No hm wrk v All hm")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==52 & time_tranche==`i' 
replace se=`se`i'' if effect_id==52 & time_tranche==`i' 
replace q=`q`i'' if effect_id==52 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==52 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==52 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==52 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==52 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e 
meta set lr_no_adj_eff lr_no_adj_se, studylabel(study_name) eslabel("No hm wrk v All hm")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name) random(mle)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow random(mle)

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==53 & time_tranche==`i' 
replace se=`se`i'' if effect_id==53 & time_tranche==`i' 
replace q=`q`i'' if effect_id==53 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==53 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==53 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==53 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==53 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


** - adjusted a/s/e + vacc etc
meta set lr_no_adjv_eff lr_no_adjv_se, studylabel(study_name) eslabel("No hm wrk v All hm")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==54 & time_tranche==`i' 
replace se=`se`i'' if effect_id==54 & time_tranche==`i' 
replace q=`q`i'' if effect_id==54 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==54 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==54 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==54 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==54 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

****************************************
**Furlough
*furlough (no/yes)
**Self-Reported Infection
**- unadjusted
meta set sr_fr_eff sr_fr_se, studylabel(study_name) eslabel("Furlough v not")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==55 & time_tranche==`i' 
replace se=`se`i'' if effect_id==55 & time_tranche==`i' 
replace q=`q`i'' if effect_id==55 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==55 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==55 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==55 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==55 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_fr_adj_eff sr_fr_adj_se, studylabel(study_name) eslabel("Furlough v not")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==56 & time_tranche==`i' 
replace se=`se`i'' if effect_id==56 & time_tranche==`i' 
replace q=`q`i'' if effect_id==56 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==56 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==56 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==56 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==56 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e + vacc etc
meta set sr_fr_adjv_eff sr_fr_adjv_se, studylabel(study_name) eslabel("Furlough v not")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==57 & time_tranche==`i' 
replace se=`se`i'' if effect_id==57 & time_tranche==`i' 
replace q=`q`i'' if effect_id==57 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==57 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==57 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==57 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==57 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_fr_eff lr_fr_se, studylabel(study_name) eslabel("Furlough v not")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==58 & time_tranche==`i' 
replace se=`se`i'' if effect_id==58 & time_tranche==`i' 
replace q=`q`i'' if effect_id==58 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==58 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==58 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==58 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==58 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_fr_adj_eff lr_fr_adj_se, studylabel(study_name) eslabel("Furlough v not")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==59 & time_tranche==`i' 
replace se=`se`i'' if effect_id==59 & time_tranche==`i' 
replace q=`q`i'' if effect_id==59 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==59 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==59 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==59 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==59 & time_tranche==`i'

}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_fr_adjv_eff lr_fr_adjv_se, studylabel(study_name) eslabel("Furlough v not")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==60 & time_tranche==`i' 
replace se=`se`i'' if effect_id==60 & time_tranche==`i' 
replace q=`q`i'' if effect_id==60 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==60 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==60 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==60 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==60 & time_tranche==`i'

}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore



****************************************
**Occupation Full version 


*occ1 Heath Care v Other
**Self-Reported Infection
**- unadjusted
meta set sr_occf1_eff sr_occf1_se, studylabel(study_name) eslabel("Health Care v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==61 & time_tranche==`i' 
replace se=`se`i'' if effect_id==61 & time_tranche==`i' 
replace q=`q`i'' if effect_id==61 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==61 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==61 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==61 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==61 & time_tranche==`i'

}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_occf1_adj_eff sr_occf1_adj_se, studylabel(study_name) eslabel("Health Care v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==62 & time_tranche==`i' 
replace se=`se`i'' if effect_id==62 & time_tranche==`i' 
replace q=`q`i'' if effect_id==62 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==62 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==62 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==62 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==62 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e + vacc etc
meta set sr_occf1_adjv_eff sr_occf1_adjv_se, studylabel(study_name) eslabel("Health Care v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==63 & time_tranche==`i' 
replace se=`se`i'' if effect_id==63 & time_tranche==`i' 
replace q=`q`i'' if effect_id==63 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==63 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==63 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==63 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==63 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_occf1_eff lr_occf1_se, studylabel(study_name) eslabel("Health Care v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==64 & time_tranche==`i' 
replace se=`se`i'' if effect_id==64 & time_tranche==`i' 
replace q=`q`i'' if effect_id==64 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==64 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==64 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==64 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==64 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_occf1_adj_eff lr_occf1_adj_se, studylabel(study_name) eslabel("Health Care v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==65 & time_tranche==`i' 
replace se=`se`i'' if effect_id==65 & time_tranche==`i' 
replace q=`q`i'' if effect_id==65 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==65 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==65 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==65 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==65 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_occf1_adjv_eff lr_occf1_adjv_se, studylabel(study_name) eslabel("Health Care v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==66 & time_tranche==`i' 
replace se=`se`i'' if effect_id==66 & time_tranche==`i' 
replace q=`q`i'' if effect_id==66 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==66 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==66 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==66 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==66 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore



*occf4 Social Care v Other
**Self-Reported Infection
**- unadjusted
meta set sr_occf4_eff sr_occf4_se, studylabel(study_name) eslabel("Social Care v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==67 & time_tranche==`i' 
replace se=`se`i'' if effect_id==67 & time_tranche==`i' 
replace q=`q`i'' if effect_id==67 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==67 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==67 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==67 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==67 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_occf4_adj_eff sr_occf4_adj_se, studylabel(study_name) eslabel("Social Care v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==68 & time_tranche==`i' 
replace se=`se`i'' if effect_id==68 & time_tranche==`i' 
replace q=`q`i'' if effect_id==68 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==68 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==68 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==68 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==68 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e + vacc etc
meta set sr_occf4_adjv_eff sr_occf4_adjv_se, studylabel(study_name) eslabel("Social Care v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==69 & time_tranche==`i' 
replace se=`se`i'' if effect_id==69 & time_tranche==`i' 
replace q=`q`i'' if effect_id==69 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==69 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==69 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==69 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==69 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_occf4_eff lr_occf4_se, studylabel(study_name) eslabel("Social Care v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==70 & time_tranche==`i' 
replace se=`se`i'' if effect_id==70 & time_tranche==`i' 
replace q=`q`i'' if effect_id==70 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==70 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==70 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==70 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==70 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_occf4_adj_eff lr_occf4_adj_se, studylabel(study_name) eslabel("Social Care v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==71 & time_tranche==`i' 
replace se=`se`i'' if effect_id==71 & time_tranche==`i' 
replace q=`q`i'' if effect_id==71 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==71 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==71 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==71 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==71 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_occf4_adjv_eff lr_occf4_adjv_se, studylabel(study_name) eslabel("Social Care v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==72 & time_tranche==`i' 
replace se=`se`i'' if effect_id==72 & time_tranche==`i' 
replace q=`q`i'' if effect_id==72 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==72 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==72 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==72 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==72 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


*occf5 Education v Other
**Self-Reported Infection
**- unadjusted
meta set sr_occf5_eff sr_occf5_se, studylabel(study_name) eslabel("Education v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==73 & time_tranche==`i' 
replace se=`se`i'' if effect_id==73 & time_tranche==`i' 
replace q=`q`i'' if effect_id==73 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==73 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==73 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==73 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==73 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_occf5_adj_eff sr_occf5_adj_se, studylabel(study_name) eslabel("Education v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==74 & time_tranche==`i' 
replace se=`se`i'' if effect_id==74 & time_tranche==`i' 
replace q=`q`i'' if effect_id==74 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==74 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==74 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==74 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==74 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e + vacc etc
meta set sr_occf5_adjv_eff sr_occf5_adjv_se, studylabel(study_name) eslabel("Education v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==75 & time_tranche==`i' 
replace se=`se`i'' if effect_id==75 & time_tranche==`i' 
replace q=`q`i'' if effect_id==75 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==75 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==75 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==75 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==75 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_occf5_eff lr_occf5_se, studylabel(study_name) eslabel("Education v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==76 & time_tranche==`i' 
replace se=`se`i'' if effect_id==76 & time_tranche==`i' 
replace q=`q`i'' if effect_id==76 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==76 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==76 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==76 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==76 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_occf5_adj_eff lr_occf5_adj_se, studylabel(study_name) eslabel("Education v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==77 & time_tranche==`i' 
replace se=`se`i'' if effect_id==77 & time_tranche==`i' 
replace q=`q`i'' if effect_id==77 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==77 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==77 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==77 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==77 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_occf5_adjv_eff lr_occf5_adjv_se, studylabel(study_name) eslabel("Education v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==78 & time_tranche==`i' 
replace se=`se`i'' if effect_id==78 & time_tranche==`i' 
replace q=`q`i'' if effect_id==78 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==78 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==78 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==78 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==78 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

*occf6 Police & Protect v Other
**Self-Reported Infection
**- unadjusted
meta set sr_occf6_eff sr_occf6_se, studylabel(study_name) eslabel("Police & Protect v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==79 & time_tranche==`i' 
replace se=`se`i'' if effect_id==79 & time_tranche==`i' 
replace q=`q`i'' if effect_id==79 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==79 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==79 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==79 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==79 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_occf6_adj_eff sr_occf6_adj_se, studylabel(study_name) eslabel("Police & Protect v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==80 & time_tranche==`i' 
replace se=`se`i'' if effect_id==80 & time_tranche==`i' 
replace q=`q`i'' if effect_id==80 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==80 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==80 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==80 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==80 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e + vacc etc
meta set sr_occf6_adjv_eff sr_occf6_adjv_se, studylabel(study_name) eslabel("Police & Protect v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==81 & time_tranche==`i' 
replace se=`se`i'' if effect_id==81 & time_tranche==`i' 
replace q=`q`i'' if effect_id==81 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==81 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==81 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==81 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==81 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_occf6_eff lr_occf6_se, studylabel(study_name) eslabel("Police & Protect v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==82 & time_tranche==`i' 
replace se=`se`i'' if effect_id==82 & time_tranche==`i' 
replace q=`q`i'' if effect_id==82 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==82 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==82 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==82 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==82 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_occf6_adj_eff lr_occf6_adj_se, studylabel(study_name) eslabel("Police & Protect v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==83 & time_tranche==`i' 
replace se=`se`i'' if effect_id==83 & time_tranche==`i' 
replace q=`q`i'' if effect_id==83 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==83 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==83 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==83 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==83 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_occf6_adjv_eff lr_occf6_adjv_se, studylabel(study_name) eslabel("Police & Protect v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==84 & time_tranche==`i' 
replace se=`se`i'' if effect_id==84 & time_tranche==`i' 
replace q=`q`i'' if effect_id==84 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==84 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==84 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==84 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==84 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


*occf7 Food Worker v Other
**Self-Reported Infection
**- unadjusted
meta set sr_occf7_eff sr_occf7_se, studylabel(study_name) eslabel("Food Worker v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==85 & time_tranche==`i' 
replace se=`se`i'' if effect_id==85 & time_tranche==`i' 
replace q=`q`i'' if effect_id==85 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==85 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==85 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==85 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==85 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_occf7_adj_eff sr_occf7_adj_se, studylabel(study_name) eslabel("Food Worker v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==86 & time_tranche==`i' 
replace se=`se`i'' if effect_id==86 & time_tranche==`i' 
replace q=`q`i'' if effect_id==86 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==86 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==86 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==86 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==86 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e + vacc etc
meta set sr_occf7_adjv_eff sr_occf7_adjv_se, studylabel(study_name) eslabel("Food Worker v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==87 & time_tranche==`i' 
replace se=`se`i'' if effect_id==87 & time_tranche==`i' 
replace q=`q`i'' if effect_id==87 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==87 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==87 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==87 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==87 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_occf7_eff lr_occf7_se, studylabel(study_name) eslabel("Food Worker v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==88 & time_tranche==`i' 
replace se=`se`i'' if effect_id==88 & time_tranche==`i' 
replace q=`q`i'' if effect_id==88 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==88 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==88 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==88 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==88 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_occf7_adj_eff lr_occf7_adj_se, studylabel(study_name) eslabel("Food Worker v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==89 & time_tranche==`i' 
replace se=`se`i'' if effect_id==89 & time_tranche==`i' 
replace q=`q`i'' if effect_id==89 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==89 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==89 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==89 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==89 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_occf7_adjv_eff lr_occf7_adjv_se, studylabel(study_name) eslabel("Food Worker v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==90 & time_tranche==`i' 
replace se=`se`i'' if effect_id==90 & time_tranche==`i' 
replace q=`q`i'' if effect_id==90 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==90 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==90 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==90 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==90 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore



*occf8 Transport v Other
**Self-Reported Infection
**- unadjusted
meta set sr_occf8_eff sr_occf8_se, studylabel(study_name) eslabel("Transport v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==91 & time_tranche==`i' 
replace se=`se`i'' if effect_id==91 & time_tranche==`i' 
replace q=`q`i'' if effect_id==91 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==91 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==91 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==91 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==91 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_occf8_adj_eff sr_occf8_adj_se, studylabel(study_name) eslabel("Transport v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==92 & time_tranche==`i' 
replace se=`se`i'' if effect_id==92 & time_tranche==`i' 
replace q=`q`i'' if effect_id==92 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==92 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==92 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==92 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==92 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e + vacc etc
meta set sr_occf8_adjv_eff sr_occf8_adjv_se, studylabel(study_name) eslabel("Transport v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==93 & time_tranche==`i' 
replace se=`se`i'' if effect_id==93 & time_tranche==`i' 
replace q=`q`i'' if effect_id==93 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==93 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==93 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==93 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==93 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_occf8_eff lr_occf8_se, studylabel(study_name) eslabel("Transport v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==94 & time_tranche==`i' 
replace se=`se`i'' if effect_id==94 & time_tranche==`i' 
replace q=`q`i'' if effect_id==94 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==94 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==94 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==94 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==94 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_occf8_adj_eff lr_occf8_adj_se, studylabel(study_name) eslabel("Transport v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==95 & time_tranche==`i' 
replace se=`se`i'' if effect_id==95 & time_tranche==`i' 
replace q=`q`i'' if effect_id==95 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==95 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==95 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==95 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==95 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_occf8_adjv_eff lr_occf8_adjv_se, studylabel(study_name) eslabel("Transport v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==96 & time_tranche==`i' 
replace se=`se`i'' if effect_id==96 & time_tranche==`i' 
replace q=`q`i'' if effect_id==96 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==96 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==96 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==96 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==96 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

*occf11 Factory v Other
**Self-Reported Infection
**- unadjusted
meta set sr_occf11_eff sr_occf11_se, studylabel(study_name) eslabel("Factory v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==97 & time_tranche==`i' 
replace se=`se`i'' if effect_id==97 & time_tranche==`i' 
replace q=`q`i'' if effect_id==97 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==97 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==97 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==97 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==97 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_occf11_adj_eff sr_occf11_adj_se, studylabel(study_name) eslabel("Factory v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==98 & time_tranche==`i' 
replace se=`se`i'' if effect_id==98 & time_tranche==`i' 
replace q=`q`i'' if effect_id==98 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==98 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==98 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==98 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==98 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e + vacc etc
meta set sr_occf11_adjv_eff sr_occf11_adjv_se, studylabel(study_name) eslabel("Factory v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==99 & time_tranche==`i' 
replace se=`se`i'' if effect_id==99 & time_tranche==`i' 
replace q=`q`i'' if effect_id==99 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==99 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==99 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==99 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==99 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_occf11_eff lr_occf11_se, studylabel(study_name) eslabel("Factory v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==100 & time_tranche==`i' 
replace se=`se`i'' if effect_id==100 & time_tranche==`i' 
replace q=`q`i'' if effect_id==100 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==100 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==100 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==100 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==100 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_occf11_adj_eff lr_occf11_adj_se, studylabel(study_name) eslabel("Factory v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==101 & time_tranche==`i' 
replace se=`se`i'' if effect_id==101 & time_tranche==`i' 
replace q=`q`i'' if effect_id==101 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==101 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==101 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==101 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==101 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_occf11_adjv_eff lr_occf11_adjv_se, studylabel(study_name) eslabel("Factory v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==102 & time_tranche==`i' 
replace se=`se`i'' if effect_id==102 & time_tranche==`i' 
replace q=`q`i'' if effect_id==102 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==102 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==102 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==102 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==102 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


*occf12 Customer Serv v Other
**Self-Reported Infection
**- unadjusted
meta set sr_occf12_eff sr_occf12_se, studylabel(study_name) eslabel("Customer Serv v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==103 & time_tranche==`i' 
replace se=`se`i'' if effect_id==103 & time_tranche==`i' 
replace q=`q`i'' if effect_id==103 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==103 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==103 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==103 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==103 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_occf12_adj_eff sr_occf12_adj_se, studylabel(study_name) eslabel("Customer Serv v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==104 & time_tranche==`i' 
replace se=`se`i'' if effect_id==104 & time_tranche==`i' 
replace q=`q`i'' if effect_id==104 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==104 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==104 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==104 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==104 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e + vacc etc
meta set sr_occf12_adjv_eff sr_occf12_adjv_se, studylabel(study_name) eslabel("Customer Serv v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==105 & time_tranche==`i' 
replace se=`se`i'' if effect_id==105 & time_tranche==`i' 
replace q=`q`i'' if effect_id==105 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==105 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==105 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==105 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==105 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_occf12_eff lr_occf12_se, studylabel(study_name) eslabel("Customer Serv v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==106 & time_tranche==`i' 
replace se=`se`i'' if effect_id==106 & time_tranche==`i' 
replace q=`q`i'' if effect_id==106 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==106 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==106 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==106 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==106 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_occf12_adj_eff lr_occf12_adj_se, studylabel(study_name) eslabel("Customer Serv v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==107 & time_tranche==`i' 
replace se=`se`i'' if effect_id==107 & time_tranche==`i' 
replace q=`q`i'' if effect_id==107 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==107 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==107 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==107 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==107 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_occf12_adjv_eff lr_occf12_adjv_se, studylabel(study_name) eslabel("Customer Serv v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==108 & time_tranche==`i' 
replace se=`se`i'' if effect_id==108 & time_tranche==`i' 
replace q=`q`i'' if effect_id==108 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==108 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==108 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==108 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==108 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


*occf13 Hospitality v Other
**Self-Reported Infection
**- unadjusted
meta set sr_occf13_eff sr_occf13_se, studylabel(study_name) eslabel("Hospitality v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==109 & time_tranche==`i' 
replace se=`se`i'' if effect_id==109 & time_tranche==`i' 
replace q=`q`i'' if effect_id==109 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==109 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==109 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==109 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==109 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_occf13_adj_eff sr_occf13_adj_se, studylabel(study_name) eslabel("Hospitality v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==110 & time_tranche==`i' 
replace se=`se`i'' if effect_id==110 & time_tranche==`i' 
replace q=`q`i'' if effect_id==110 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==110 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==110 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==110 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==110 & time_tranche==`i'

}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e + vacc etc
meta set sr_occf13_adjv_eff sr_occf13_adjv_se, studylabel(study_name) eslabel("Hospitality v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==111 & time_tranche==`i' 
replace se=`se`i'' if effect_id==111 & time_tranche==`i' 
replace q=`q`i'' if effect_id==111 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==111 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==111 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==111 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==111 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_occf13_eff lr_occf13_se, studylabel(study_name) eslabel("Hospitality v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==112 & time_tranche==`i' 
replace se=`se`i'' if effect_id==112 & time_tranche==`i' 
replace q=`q`i'' if effect_id==112 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==112 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==112 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==112 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==112 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_occf13_adj_eff lr_occf13_adj_se, studylabel(study_name) eslabel("Hospitality v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==113 & time_tranche==`i' 
replace se=`se`i'' if effect_id==113 & time_tranche==`i' 
replace q=`q`i'' if effect_id==113 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==113 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==113 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==113 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==113 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_occf13_adjv_eff lr_occf13_adjv_se, studylabel(study_name) eslabel("Hospitality v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==114 & time_tranche==`i' 
replace se=`se`i'' if effect_id==114 & time_tranche==`i' 
replace q=`q`i'' if effect_id==114 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==114 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==114 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==114 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==114 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

*occf20 Miss/NIW v Other
**Self-Reported Infection
**- unadjusted
meta set sr_occf20_eff sr_occf20_se, studylabel(study_name) eslabel("Miss/NIW v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==115 & time_tranche==`i' 
replace se=`se`i'' if effect_id==115 & time_tranche==`i' 
replace q=`q`i'' if effect_id==115 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==115 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==115 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==115 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==115 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_occf20_adj_eff sr_occf20_adj_se, studylabel(study_name) eslabel("Miss/NIW v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==116 & time_tranche==`i' 
replace se=`se`i'' if effect_id==116 & time_tranche==`i' 
replace q=`q`i'' if effect_id==116 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==116 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==116 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==116 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==116 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e + vacc etc
meta set sr_occf20_adjv_eff sr_occf20_adjv_se, studylabel(study_name) eslabel("Miss/NIW v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==117 & time_tranche==`i' 
replace se=`se`i'' if effect_id==117 & time_tranche==`i' 
replace q=`q`i'' if effect_id==117 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==117 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==117 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==117 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==117 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_occf20_eff lr_occf20_se, studylabel(study_name) eslabel("Miss/NIW v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==118 & time_tranche==`i' 
replace se=`se`i'' if effect_id==118 & time_tranche==`i' 
replace q=`q`i'' if effect_id==118 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==118 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==118 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==118 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==118 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_occf20_adj_eff lr_occf20_adj_se, studylabel(study_name) eslabel("Miss/NIW v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==119 & time_tranche==`i' 
replace se=`se`i'' if effect_id==119 & time_tranche==`i' 
replace q=`q`i'' if effect_id==119 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==119 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==119 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==119 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==119 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_occf20_adjv_eff lr_occf20_adjv_se, studylabel(study_name) eslabel("Miss/NIW v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==120 & time_tranche==`i' 
replace se=`se`i'' if effect_id==120 & time_tranche==`i' 
replace q=`q`i'' if effect_id==120 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==120 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==120 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==120 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==120 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


****************************************
**Occupation Reduced version 


*occr2 Health Care v Other
**Self-Reported Infection
**- unadjusted
meta set sr_occr2_eff sr_occr2_se, studylabel(study_name) eslabel("Health Care v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==127 & time_tranche==`i' 
replace se=`se`i'' if effect_id==127 & time_tranche==`i' 
replace q=`q`i'' if effect_id==127 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==127 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==127 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==127 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==127 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_occr2_adj_eff sr_occr2_adj_se, studylabel(study_name) eslabel("Health Care v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==128 & time_tranche==`i' 
replace se=`se`i'' if effect_id==128 & time_tranche==`i' 
replace q=`q`i'' if effect_id==128 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==128 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==128 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==128 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==128 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e + vacc etc
meta set sr_occr2_adjv_eff sr_occr2_adjv_se, studylabel(study_name) eslabel("Health Care v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==129 & time_tranche==`i' 
replace se=`se`i'' if effect_id==129 & time_tranche==`i' 
replace q=`q`i'' if effect_id==129 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==129 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==129 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==129 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==129 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_occr2_eff lr_occr2_se, studylabel(study_name) eslabel("Health Care v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==130 & time_tranche==`i' 
replace se=`se`i'' if effect_id==130 & time_tranche==`i' 
replace q=`q`i'' if effect_id==130 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==130 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==130 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==130 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==130 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_occr2_adj_eff lr_occr2_adj_se, studylabel(study_name) eslabel("Health Care v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==131 & time_tranche==`i' 
replace se=`se`i'' if effect_id==131 & time_tranche==`i' 
replace q=`q`i'' if effect_id==131 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==131 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==131 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==131 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==131 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_occr2_adjv_eff lr_occr2_adjv_se, studylabel(study_name) eslabel("Health Care v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==132 & time_tranche==`i' 
replace se=`se`i'' if effect_id==132 & time_tranche==`i' 
replace q=`q`i'' if effect_id==132 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==132 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==132 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==132 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==132 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


*occr3 Social & Edu v Other
**Self-Reported Infection
**- unadjusted
meta set sr_occr3_eff sr_occr3_se, studylabel(study_name) eslabel("Social & Edu v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==133 & time_tranche==`i' 
replace se=`se`i'' if effect_id==133 & time_tranche==`i' 
replace q=`q`i'' if effect_id==133 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==133 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==133 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==133 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==133 & time_tranche==`i'

}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_occr3_adj_eff sr_occr3_adj_se, studylabel(study_name) eslabel("Social & Edu v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==134 & time_tranche==`i' 
replace se=`se`i'' if effect_id==134 & time_tranche==`i' 
replace q=`q`i'' if effect_id==134 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==134 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==134 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==134 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==134 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e + vacc etc
meta set sr_occr3_adjv_eff sr_occr3_adjv_se, studylabel(study_name) eslabel("Social & Edu v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==135 & time_tranche==`i' 
replace se=`se`i'' if effect_id==135 & time_tranche==`i' 
replace q=`q`i'' if effect_id==135 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==135 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==135 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==135 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==135 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_occr3_eff lr_occr3_se, studylabel(study_name) eslabel("Social & Edu v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==136 & time_tranche==`i' 
replace se=`se`i'' if effect_id==136 & time_tranche==`i' 
replace q=`q`i'' if effect_id==136 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==136 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==136 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==136 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==136 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_occr3_adj_eff lr_occr3_adj_se, studylabel(study_name) eslabel("Social & Edu v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==137 & time_tranche==`i' 
replace se=`se`i'' if effect_id==137 & time_tranche==`i' 
replace q=`q`i'' if effect_id==137 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==137 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==137 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==137 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==137 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_occr3_adjv_eff lr_occr3_adjv_se, studylabel(study_name) eslabel("Social & Edu v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==138 & time_tranche==`i' 
replace se=`se`i'' if effect_id==138 & time_tranche==`i' 
replace q=`q`i'' if effect_id==138 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==138 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==138 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==138 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==138 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


*occr4 Police & Protect v Other
**Self-Reported Infection
**- unadjusted
meta set sr_occr4_eff sr_occr4_se, studylabel(study_name) eslabel("Police & Protect v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==139 & time_tranche==`i' 
replace se=`se`i'' if effect_id==139 & time_tranche==`i' 
replace q=`q`i'' if effect_id==139 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==139 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==139 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==139 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==139 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_occr4_adj_eff sr_occr4_adj_se, studylabel(study_name) eslabel("Police & Protect v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==140 & time_tranche==`i' 
replace se=`se`i'' if effect_id==140 & time_tranche==`i' 
replace q=`q`i'' if effect_id==140 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==140 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==140 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==140 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==140 & time_tranche==`i'

}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e + vacc etc
meta set sr_occr4_adjv_eff sr_occr4_adjv_se, studylabel(study_name) eslabel("Police & Protect v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==141 & time_tranche==`i' 
replace se=`se`i'' if effect_id==141 & time_tranche==`i' 
replace q=`q`i'' if effect_id==141 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==141 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==141 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==141 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==141 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_occr4_eff lr_occr4_se, studylabel(study_name) eslabel("Police & Protect v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==142 & time_tranche==`i' 
replace se=`se`i'' if effect_id==142 & time_tranche==`i' 
replace q=`q`i'' if effect_id==142 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==142 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==142 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==142 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==142 & time_tranche==`i'

}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_occr4_adj_eff lr_occr4_adj_se, studylabel(study_name) eslabel("Police & Protect v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==143 & time_tranche==`i' 
replace se=`se`i'' if effect_id==143 & time_tranche==`i' 
replace q=`q`i'' if effect_id==143 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==143 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==143 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==143 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==143 & time_tranche==`i'

}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_occr4_adjv_eff lr_occr4_adjv_se, studylabel(study_name) eslabel("Police & Protect v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==144 & time_tranche==`i' 
replace se=`se`i'' if effect_id==144 & time_tranche==`i' 
replace q=`q`i'' if effect_id==144 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==144 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==144 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==144 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==144 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


*occr5 Oth Essential v Other
**Self-Reported Infection
**- unadjusted
meta set sr_occr5_eff sr_occr5_se, studylabel(study_name) eslabel("Oth Essential v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==145 & time_tranche==`i' 
replace se=`se`i'' if effect_id==145 & time_tranche==`i' 
replace q=`q`i'' if effect_id==145 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==145 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==145 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==145 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==145 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_occr5_adj_eff sr_occr5_adj_se, studylabel(study_name) eslabel("Oth Essential v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==146 & time_tranche==`i' 
replace se=`se`i'' if effect_id==146 & time_tranche==`i' 
replace q=`q`i'' if effect_id==146 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==146 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==146 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==146 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==146 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e + vacc etc
meta set sr_occr5_adjv_eff sr_occr5_adjv_se, studylabel(study_name) eslabel("Oth Essential v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==147 & time_tranche==`i' 
replace se=`se`i'' if effect_id==147 & time_tranche==`i' 
replace q=`q`i'' if effect_id==147 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==147 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==147 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==147 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==147 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_occr5_eff lr_occr5_se, studylabel(study_name) eslabel("Oth Essential v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==148 & time_tranche==`i' 
replace se=`se`i'' if effect_id==148 & time_tranche==`i' 
replace q=`q`i'' if effect_id==148 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==148 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==148 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==148 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==148 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_occr5_adj_eff lr_occr5_adj_se, studylabel(study_name) eslabel("Oth Essential v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==149 & time_tranche==`i' 
replace se=`se`i'' if effect_id==149 & time_tranche==`i' 
replace q=`q`i'' if effect_id==149 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==149 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==149 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==149 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==149 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_occr5_adjv_eff lr_occr5_adjv_se, studylabel(study_name) eslabel("Oth Essential v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==150 & time_tranche==`i' 
replace se=`se`i'' if effect_id==150 & time_tranche==`i' 
replace q=`q`i'' if effect_id==150 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==150 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==150 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==150 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==150 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


*occr6 Miss/NIW v Other
**Self-Reported Infection
**- unadjusted
meta set sr_occr6_eff sr_occr6_se, studylabel(study_name) eslabel("Miss/NIW v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==151 & time_tranche==`i' 
replace se=`se`i'' if effect_id==151 & time_tranche==`i' 
replace q=`q`i'' if effect_id==151 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==151 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==151 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==151 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==151 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e
meta set sr_occr6_adj_eff sr_occr6_adj_se, studylabel(study_name) eslabel("Miss/NIW v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==152 & time_tranche==`i' 
replace se=`se`i'' if effect_id==152 & time_tranche==`i' 
replace q=`q`i'' if effect_id==152 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==152 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==152 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==152 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==152 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

**- adjusted a/s/e + vacc etc
meta set sr_occr6_adjv_eff sr_occr6_adjv_se, studylabel(study_name) eslabel("Miss/NIW v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==153 & time_tranche==`i' 
replace se=`se`i'' if effect_id==153 & time_tranche==`i' 
replace q=`q`i'' if effect_id==153 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==153 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==153 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==153 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==153 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


**Linked Positive Test
** - unadjusted
meta set lr_occr6_eff lr_occr6_se, studylabel(study_name) eslabel("Miss/NIW v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)

*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==154 & time_tranche==`i' 
replace se=`se`i'' if effect_id==154 & time_tranche==`i' 
replace q=`q`i'' if effect_id==154 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==154 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==154 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==154 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==154 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e
meta set lr_occr6_adj_eff lr_occr6_adj_se, studylabel(study_name) eslabel("Miss/NIW v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==155 & time_tranche==`i' 
replace se=`se`i'' if effect_id==155 & time_tranche==`i' 
replace q=`q`i'' if effect_id==155 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==155 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==155 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==155 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==155 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore

** - adjusted a/s/e + vacc etc
meta set lr_occr6_adjv_eff lr_occr6_adjv_se, studylabel(study_name) eslabel("Miss/NIW v Other")
meta forestplot if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15 , esrefline nullrefline eform nooverall noohetstats  noohomtest  subgroup(time_tranche)   sort(study_name)
*meta funnelplot
meta summarize if inlist(time_tranche,1,5,6) & study_id!=4 & study_id!=15, subgroup(time_tranche) nostudies nometashow

matrix list r(esgroup)
matrix b = r(esgroup)
di b[1,1]
local effect1 = b[1,1]
local effect2 = b[2,1]
local effect3 = b[3,1]

local se1 = b[1,2]
local se2 = b[2,2]
local se3 = b[3,2]

matrix list r(hetgroup)
matrix h = r(hetgroup)

local q1 = h[1,2]
local q2 = h[2,2]
local q3 = h[3,2]

local pq1 = h[1,3]
local pq2 = h[2,3]
local pq3 = h[3,3]

local tau21 = h[1,4]
local tau22 = h[2,4]
local tau23 = h[3,4]

local i21 = h[1,5]
local i22 = h[2,5]
local i23 = h[3,5]

local h21 = h[1,6]
local h22 = h[2,6]
local h23 = h[3,6]

preserve 

use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

foreach i in 1 2 3 {
replace effect=`effect`i'' if effect_id==156 & time_tranche==`i' 
replace se=`se`i'' if effect_id==156 & time_tranche==`i' 
replace q=`q`i'' if effect_id==156 & time_tranche==`i'
replace pq=`pq`i'' if effect_id==156 & time_tranche==`i'
replace tau2=`tau2`i'' if effect_id==156 & time_tranche==`i'
replace i2=`i2`i'' if effect_id==156 & time_tranche==`i'
replace h2=`h2`i'' if effect_id==156 & time_tranche==`i'
	
}

list 

save "S:\LLC_0007\data\metaresults_datafile time-tranche combined", replace
restore


********************************************************************************
***PLOTTING OVERALL EFFECS
********************************************************************************

*generate RR and 95% C.I.
use "S:\LLC_0007\data\metaresults_datafile time-tranche combined", clear

gen lcon=exp(effect-(1.96*se))
gen ucon=exp(effect+(1.96*se))
gen leffect=exp(effect)

decode effect_id, gen(seffect_id)
split seffect_id, parse("_") gen(idstub)
gen idstub23=idstub2+"_"+idstub3
encode idstub1, gen(comparison)
encode idstub23, gen(model)
drop idstub*

numlabel model, add
tab model,
*label define model 1 "Unadj-linked postest" 2 "Adj-linked postest" 3 "Unadj-Selfrep infection" 4 "Adj-Selfrep infection" , replace
label define model 1 "Adj Mod1-linked postest" 2 "Unadj-linked postest" 3 "Adj Mod2-linked postest" 4 "Adj Mod1-Selfrep infection" 5 "Unadj-Selfrep infection" 6 "Adj Mod2-Selfrep infection" , replace

tab model 
decode model, gen(models)
numlabel comparison, add
tab comparison
recode comparison (1=1) (2=2) (3=10) (4=8) (5=11) (6=17) (7=18) (8=19) (9=20) (10=12) (11=13) (12=14) (13=15) (14=16) (15=21) (16=22) (17=23) (18=24) (19=25) (20=26) (21=5) (22=6) (23=4) (24=9) (25=3) (26=7), 
label define comparison 1 "Furlough" 2 "Keyworker" 3 "Unemployed v Emp" 4 "Retired v Emp" 5 "Part-time v FT" 6 "Retired v FT" 7 "Unemployed v FT" 8 "Empl but not working v FT"  9  "Some hm wrk vs all" 10 "Non hm wrk v all" 11 "Health Care v Other" 12 "Social Care v Other" 13 "Education v Other" 14 " Pol & Prot v Other" 15  "Food v Other" 16 "Transport v Other" 17 "Factory v Other" 18 "Customer Ser v Other" 19 "Hospitality v Other" 20 "Miss/NIW v Other" 21 "NA-Non Ess" 22 "Health Care v Non Ess" 23 "Social & Edu v Non Ess" 24 "Pol & Prot v Non Ess" 25 "Other Ess v Non Ess" 26 "Miss/NIW v Non Ess", replace
tab comparison
decode comparison, gen(comparisons)
numlabel comparison, add

recode model (1=5) (2=4) (3=6) (4=2) (5=1) (6=3), gen(modelled)

**key worker
meta set effect se, studylabel(models) eslabel("Keyworker v not")
meta forestplot _id _plot _esci if comparison==2, eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

**Unemployed v Employed
meta set effect se, studylabel(models) eslabel("Unemployed v Employed")
meta forestplot _id _plot _esci if comparison==3,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

**Retired v Employed
meta set effect se, studylabel(models) eslabel("Retired v Employed")
meta forestplot _id _plot _esci if comparison==4,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled) random(mle)


**Part-time vs full time
meta set effect se, studylabel(models) eslabel("Part-time v Full-time")
meta forestplot _id _plot _esci if comparison==5,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)


**Employed but not working vs FT
meta set effect se, studylabel(models) eslabel("Employed but not wk v Full-time")
meta forestplot _id _plot _esci if comparison==8,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

**Unemployed v FT
meta set effect se, studylabel(models) eslabel("Unemployed v Full-time")
meta forestplot _id _plot _esci if comparison==7,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

**Retired vs FT
meta set effect se, studylabel(models) eslabel("Retired v Full-time")
meta forestplot _id _plot _esci if comparison==6,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)   nonotes sort(modelled)

**Some hm working vs all
meta set effect se, studylabel(models) eslabel("Some Hm Wk v All")
meta forestplot _id _plot _esci if comparison==9,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

**No home working vs all
meta set effect se, studylabel(models) eslabel("No Home Wk v All")
meta forestplot _id _plot _esci if comparison==10,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)   nonotes sort(modelled)

**furlough
meta set effect se, studylabel(models) eslabel("Furlough v not")
meta forestplot _id _plot _esci if comparison==1,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)


**Occupation full-time

*Health care v Other
meta set effect se, studylabel(models) eslabel("Health Care v Other")
meta forestplot _id _plot _esci if comparison==11,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

*Social Care v Other
meta set effect se, studylabel(models) eslabel("Social Care v Other")
meta forestplot _id _plot _esci if comparison==12,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

*Education v Other
meta set effect se, studylabel(models) eslabel("Education v Other")
meta forestplot _id _plot _esci if comparison==13,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

*Police and Protective  v Other
meta set effect se, studylabel(models) eslabel("Police & Prot v Other")
meta forestplot _id _plot _esci if comparison==14,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

*Food Workers v Other
meta set effect se, studylabel(models) eslabel("Food Wks v Other")
meta forestplot _id _plot _esci if comparison==15,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

*Transport  v Other
meta set effect se, studylabel(models) eslabel("Transport Wks v Other")
meta forestplot _id _plot _esci if comparison==16,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

*Factory  v Other
meta set effect se, studylabel(models) eslabel("Factory Wks v Other")
meta forestplot _id _plot _esci if comparison==17,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

*Customer Services v Other
meta set effect se, studylabel(models) eslabel("Customer Serv v Other")
meta forestplot _id _plot _esci if comparison==18,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

*Hosptiality v Other
meta set effect se, studylabel(models) eslabel("Hospitality v Other")
meta forestplot _id _plot _esci if comparison==19,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

*Miss/NIW v Other
meta set effect se, studylabel(models) eslabel("Miss/MIW v Other")
meta forestplot _id _plot _esci if comparison==20,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

**Occupation Reduced

*Health Care  v Non Essential
meta set effect se, studylabel(models) eslabel("Health Care v Non Ess")
meta forestplot _id _plot _esci if comparison==22,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

*Social & Education v Non Essential
meta set effect se, studylabel(models) eslabel("Social & Edu v Non Ess")
meta forestplot _id _plot _esci if comparison==23,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

*Police & Protective v Non Essential
meta set effect se, studylabel(models) eslabel("Pol & Protect v Non Ess")
meta forestplot _id _plot _esci if comparison==24,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

*Other Essential v Non Essential
meta set effect se, studylabel(models) eslabel("Other Ess v Non Ess")
meta forestplot _id _plot _esci if comparison==25,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

*Miss/NIW v Non Essential
meta set effect se, studylabel(models) eslabel("Miss/NIW v Non Ess")
meta forestplot _id _plot _esci if comparison==26,  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)



tab models

****COME BACK AND TRY TO FIT THE ACROSS OCCUPATIONAL PLOT

**Occupation full version

**Unadjusted Self-reported
meta set effect se, studylabel(comparisons) eslabel("Unadj Self-reported")
meta forestplot _id _plot _esci if modelled==1 & inrange(comparison,11,20),  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

**Adjusted Model 1 Self-reported
meta set effect se, studylabel(comparisons) eslabel("Adj Mod1 Self-reported")
meta forestplot _id _plot _esci if modelled==2 & inrange(comparison,11,20),  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

**Adjusted Model 2 Self-reported
meta set effect se, studylabel(comparisons) eslabel("Adj Mod2 Self-reported")
meta forestplot _id _plot _esci if modelled==3 & inrange(comparison,11,20),  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)


**Unadjusted Linked Positive
meta set effect se, studylabel(comparisons) eslabel("Unadj Linked Pos")
meta forestplot _id _plot _esci if modelled==4 & inrange(comparison,11,20),  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

**Adjusted Model 1 Linked Positive
meta set effect se, studylabel(comparisons) eslabel("Adj Mod1 Linked Pos")
meta forestplot _id _plot _esci if modelled==5 & inrange(comparison,11,20),  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

**Adjusted Model 2 Linked Positive
meta set effect se, studylabel(comparisons) eslabel("Adj Mod2 Linked Pos")
meta forestplot _id _plot _esci if modelled==6 & inrange(comparison,11,20),  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)



**Occupation reduced version

**Unadjusted Self-reported
meta set effect se, studylabel(comparisons) eslabel("Unadj Self-reported")
meta forestplot _id _plot _esci if modelled==1 & inrange(comparison,21,26),  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

**Adjusted Model 1 Self-reported
meta set effect se, studylabel(comparisons) eslabel("Adj Mod1 Self-reported")
meta forestplot _id _plot _esci if modelled==2 & inrange(comparison,21,26),  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

**Adjusted Model 2 Self-reported
meta set effect se, studylabel(comparisons) eslabel("Adj Mod2 Self-reported")
meta forestplot _id _plot _esci if modelled==3 & inrange(comparison,21,26),  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)


**Unadjusted Linked Positive
meta set effect se, studylabel(comparisons) eslabel("Unadj Linked Pos")
meta forestplot _id _plot _esci if modelled==4 & inrange(comparison,21,26),  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

**Adjusted Model 1 Linked Positive
meta set effect se, studylabel(comparisons) eslabel("Adj Mod1 Linked Pos")
meta forestplot _id _plot _esci if modelled==5 & inrange(comparison,21,26),  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)

**Adjusted Model 2 Linked Positive
meta set effect se, studylabel(comparisons) eslabel("Adj Mod2 Linked Pos")
meta forestplot _id _plot _esci if modelled==6 & inrange(comparison,21,26),  eform nooverall nogmarkers noohetstats nowmarkers noomarker nogbhomtests nogwhomtests noghetstats noohomtest nometashow  subgroup(time_tranche)  nonotes sort(modelled)


