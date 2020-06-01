***********************Who can work from home ?*********************************

	cls
	set more off
	capture log close
	estimates clear
	
	global dofilename "5_WFH_Tunisia.do" 
		
// create local for date and version tracking

	local c_date = c(current_date)
	local date_string = subinstr("`c_date'", ":", "_", .)
	local date_string = subinstr("`date_string'", " ", "_", .)
	global track_date = c(current_date)
	global track_time = c(current_time)

// globals to manage users
		
	global user 2 /* put 1 for Yemen, 2 for Phuong and 3 for Emilie */

	if $user == 1 {
	global INS "D:/02_EnqEmp_new/Projet IRD decembre 2019"
	global person "Yemen"
	}

	if $user == 2 {
	global desktop "C:/Users/Dell/Dropbox"
	global person "Phuong"
	}
	
	if $user == 3 {
	global desktop "/Users/emiliewojcieszynski294gasyv/Dropbox"
	global person "Emilie"
	}
	
// globals for trial or real mode

	global trial 1 /* 
		* 0 if we are not in trial mode
		* 1 if we are in trial mode using individual data */

	if $trial ==1 {
		global data_task_measures $desktop/COVID-firmes/Working_files/Data
		global data_survey $desktop/COVID-firmes/Working_files/Data
		global data_trade $desktop/COVID-firmes/Working_files/Data
		global results $desktop/COVID-firmes/Working_files/Results
		global log $desktop/COVID-firmes/Working_files/Logs
		version 13
		}
	
	if $trial ==0 {
		cd
		cd "$INS"
		cap mkdir Results_WFH
		global data_survey $INS/Data/Survey_Data
		global data_task_measures $INS/Data/Task_Measures 
		global data_trade $INS/Data/WITS_TradeValue
		global results $INS/Results_WFH
		global log $INS/Log
		}

//run log for commands
	cd
	cd "$log"
	cap log using 5_WFH_Tunisia_`date_string', text replace

********************************************************************************
display "This file started on `c(current_date)' at `c(current_time)' " 
********************************************************************************

use "$data_survey/ENPE_survey.dta", clear
keep if year==2017 
keep if age>=15 & age<=64 & work==1

* Merge RLI and Teleworkability
merge m:1 isco08 using "$data_task_measures/isco08_rli.dta", keep(3) nogen
gen isco08_1 = int(isco08/1000)
gen isco08_2 = int(isco08/100)

lab def isco08_1  0 "0 Armed Forces Occupations"                              ///
                  1 "1 Managers"                                              ///
                  2 "2 Professionals"                                         ///
                  3 "3 Technicians and Associate Professionals"               ///
                  4 "4 Clerical Support Workers"                              ///
				  5 "5 Services and Sales Workers"                            /// 
                  6 "6 Skilled Agricultural, Forestry and Fishery Workers"    ///
                  7 "7 Craft and Related Trades Workers"                      /// 
                  8 "8 Plant and Machine Operators and Assemblers"            ///
                  9 "9 Elementary Occupations"
                  lab val isco08_1 isco08_1
		
lab def isco08_2 11 "Chief Executives, Senior Officials and Legislators"      ///
                 12 "Administrative and Commercial Managers"                  ///
                 13 "Production and Specialized Services Managers"            ///
                 14 "Hospitality, Retail and Other Services Managers"         ///
                 21 "Science and Engineering Professionals"                   ///
                 22 "Health Professionals"                                    ///
                 23 "Teaching Professionals"                                  ///
                 24 "Business and Administration Professionals"               ///
                 25 "Information and Communications Technology Professionals" ///
                 26 "Legal, Social and Cultural Professionals"                ///
                 31 "Science and Engineering Associate Professionals"         ///
                 32 "Health Associate Professionals"                          ///
                 33 "Business and Administration Associate Professionals"     ///
                 34 "Legal, Social, Cultural and Related Associate Professionals" ///
                 35 "Information and Communications Technicians"              ///
                 41 "General and Keyboard Clerks"                             ///
                 42 "Customer Services Clerks"                                ///
                 43 "Numerical and Material Recording Clerks"                 ///
                 44 "Other Clerical Support Workers"                          ///
                 51 "Personal Services Workers"                               ///
                 52 "Sales Workers"                                           ///
                 53 "Personal Care Workers"                                   ///
                 54 "Protective Services Workers"                             ///
                 61 "Market-oriented Skilled Agricultural Workers"            ///
                 62 "Market-oriented Skilled Forestry, Fishery and Hunting Workers" ///
                 63 "Subsistence Farmers, Fishers, Hunters and Gatherers"     ///
                 71 "Building and Related Trades Workers (excluding Electricians)" ///
                 72 "Metal, Machinery and Related Trades Workers"             ///
                 73 "Handicraft and Printing Workers"                         ///
                 74 "Electrical and Electronic Trades Workers"                ///
                 75 "Food Processing, Woodworking, Garment and Other Craft and Related Trades Workers" ///
                 81 "Stationary Plant and Machine Operators"                  ///
                 82 "Assemblers"                                              ///
                 83 "Drivers and Mobile Plant Operators"                      ///
                 91 "Cleaners and Helpers"                                    ///
                 92 "Agricultural, Forestry and Fishery Labourers"            ///
                 93 "Labourers in Mining, Construction, Manufacturing and Transport" ///
                 94 "Food Preparation Assistants"                             ///
                 95 "Street and Related Sales and Services Workers"           ///
                 96 "Refuse Workers and Other Elementary Workers"             ///
                  1 "Commissioned Armed Forces Officers"                      ///
                  2 "Non-commissioned Armed Forces Officers"                  ///
                  3 "Armed Forces Occupations, Other Ranks"
				 lab val isco08_2 isco08_2
 
* Merge essential score 
 *** Cleaning concordance table NAT 2009 - ISIC rev. 4
merge m:1 nat09 using "$data_trade/nat09_isic4.dta", keep(1 3) nogen 

gen isic4_2d = int(isic4/100)
recode isic4_2d ///
			(1/3 = 1 "A Agriculture, forestry & fishing") ///
			(5/9 = 2 "B Mining & quarrying") ///
			(10/33 = 3 "C Manufacturing") ///
			(35 = 4 "D Electricity & gas supply") ///
			(36/39 = 5 "E Water supply & waste management") ///
			(41/43 = 6 "F Construction") ///
			(45/47 = 7 "G Wholesale & retail") ///
			(49/53 = 8 "H Transportation & Storage") ///
			(55/56 = 9 "I Accomodation & food services") ///
			(58/63 = 10 "J Information & communication") ///
			(64/66 = 11 "K Financial & insurance") ///
			(68 = 12 "L Real estate") ///
			(69/75 = 13 "M Science & technology") ///
			(77/82 = 14 "N Administrative & support service") ///
			(84 = 15 "O Public administration & defence") ///
			(85 = 16 "P Education") ///
			(86/88 = 17 "Q Health & social work") ///
			(90/93 = 18 "R Arts, entertainment & recreation") ///
			(94/96 = 19 "S Other services") ////
			(97/98 = 20 "T Household self-production") ///
			(99 = 21 "U Extraterritorial organizations") , gen(isic4_reduced)
			decode isic4_reduced, gen(isic4_reduced_title)
 
*** Cleaning Tunisian classification of essential industries
preserve
use "$data_task_measures/essential_tunisia_final.dta", clear
collapse (mean) essential_tun, by(nat09)
tempfile tun_essential
save `tun_essential', replace
restore

merge m:1 nat09 using `tun_essential', keep(1 3) nogen
replace essential_tun = 1 if nat09==5040
replace essential_tun = 0 if nat09==9810
ren essential_tun essential_score

* Generating variables 
	gen low_rli=.
    replace low_rli=1 if rli<0.24
    replace low_rli=0 if rli>0.24
	
	gen low_teleworkable=.
    replace low_teleworkable=1 if teleworkable <0.33
    replace low_teleworkable=0 if teleworkable >0.33
	
	ren edu_lvl edu
	gen youth = cond(inrange(age, 15,29), 1, 0)
	gen skill = .
	replace skill = 1 if isco08_1 >= 1 & isco08_1 <= 3
	replace skill = 2 if (isco08_1 >= 4 & isco08_1 <= 5)|(isco08_1 >= 7 & isco08_1 <= 8)
	replace skill = 3 if isco08_1 == 6 | isco08_1 == 9
	lab def skill 1 "High" 2 "Medium" 3 "Low"
	lab val skill skill
	
	recode edu (1/3=1) (4=0), gen(no_coll)
	recode age (15/39=1) (40/64=0), gen(age40)
	recode age (15/49=1) (50/64=0), gen(age50)
	recode marital (1=0) (3/4=0) (2=1), gen(couple)
	recode sex (1=1) (2=0), gen(male)
	recode contract (1=0) (3=0) (2=1), gen (permanent) 
	recode formal (1=1) (2=0)
	recode public (1=1) (2=0)
	recode urban (1=1) (2=0)
	gen hhwkr = cond(position==5, 1, 0)
	gen selfemp = cond(position==2, 1, 0)
	gen wagewkr = cond(position==3, 1, 0)
	gen essind = cond(essential_score==1, 1, 0)
	foreach v in hhwkr selfemp wagewkr {
		replace `v' = . if position == . | position == 0
		}
	replace essind = . if essential_score == .
	xtile qnt_earn = earn, n(5)
	
* Label variables
	lab var no_coll "No college degree"
	lab var age40 "Age below 40"
	lab var age50 "Age below 50"
	lab var couple "Living with partner"
	lab var male "Male"
	lab var permanent "Permanent contract"
	lab var public "Public"
	lab var formal "Have contract"
	lab var urban "Urban"
	lab var hhwkr "Household business workers"
	lab var selfemp "Self-employed"
	lab var wagewkr "Wage worker"
	lab var essind "Essential industry"
	lab var qnt_earn "Earnings quintile"
	lab define QTN_EARN 1 "1st quintile" 2 "2nd quintile" 3 "3rd quintile" 4 "4th quintile" 5 "5th quintile"
	lab val qnt_earn QTN_EARN
	
save "$data_survey/ENPE_combined_WFH.dta", replace

* Set the globals
  global X1 "no_coll male youth age40 age50 couple permanent formal public urban hhwkr selfemp wagewkr essind" 
  global X30 "no_coll male youth couple urban essind" 
  global X40 "no_coll male age40 couple urban essind" 
  global X50 "no_coll male age50 couple urban essind" 
  global X30_wagewkr "no_coll male youth couple permanent public urban essind i.qnt_earn"
  global X30_wagewkr_inf "no_coll male youth couple formal urban essind i.qnt_earn"
  global X40_wagewkr "no_coll male age40 couple permanent public urban essind i.qnt_earn"
  global X40_wagewkr_inf "no_coll male age40 couple formal urban essind i.qnt_earn"
  global X50_wagewkr "no_coll male age50 couple permanent public urban essind i.qnt_earn"
  global X50_wagewkr_inf "no_coll male age50 couple formal urban essind i.qnt_earn" 

* Descriptive analysis on low_rli and high_rli

  sum $X1 earn [aw=wgt] if low_rli==1
  sum $X1 earn [aw=wgt] if low_rli==0
  sum $X1 earn [aw=wgt] if low_teleworkable==1
  sum $X1 earn [aw=wgt] if low_teleworkable==0
  
  table sex       [aw=wgt], c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table edu	  	  [aw=wgt], c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table contract  [aw=wgt], c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table skill 	  [aw=wgt], c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table public    [aw=wgt], c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table youth     [aw=wgt], c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table urban     [aw=wgt], c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table position  [aw=wgt], c(mean rli mean teleworkable) format(%4.2f) row
  
  table sex essind       [aw=wgt], c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table edu essind	  	 [aw=wgt], c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table contract essind  [aw=wgt], c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table skill essind 	 [aw=wgt], c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table public essind    [aw=wgt], c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table youth essind     [aw=wgt], c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table urban essind     [aw=wgt], c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table position essind  [aw=wgt], c(mean rli mean teleworkable) format(%4.2f) row
  
  table edu essind	  	 [aw=wgt] if sex==1, c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table contract essind  [aw=wgt] if sex==1, c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table skill essind 	 [aw=wgt] if sex==1, c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table public essind    [aw=wgt] if sex==1, c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table youth essind     [aw=wgt] if sex==1, c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table urban essind     [aw=wgt] if sex==1, c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table position essind  [aw=wgt] if sex==1, c(mean rli mean teleworkable) format(%4.2f) row

cd "$results" 
cap erase ttest_rli.doc
cap erase ttest_tlw.doc
 
  foreach var of varlist $X1 earn {
	asdoc ttest `var', by(low_rli) rowappend save(ttest_rli.doc) 
	}

  foreach var of varlist $X1 earn {
	asdoc ttest `var', by(low_teleworkable) rowappend save(ttest_tlw.doc)
	 }	
/*
______________________________________________________________________________
***3 - Mongey & Weinberg - Characteristics of Workers in LWFM and HPP occupation.

  yij = αy  + ßy  LWFHj  +   εij

  *They compute the difference of the mean between two groups (LWFM and HWFM)

  -> the authors compute the difference of the mean of each characteristics by 
  group and plot the difference on a graph.

  “Workers in occupations for which LW F Hj = 1 are relatively more different from 
workers in occupations for which LW F Hj = 0 along dimension y than along 
dimension y0”.

  https://bfi.uchicago.edu/wp-content/uploads/BFI_WP_202051.pdf
________________________________________________________________________________
*/

foreach X in X30 X40 X50 {
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if selfemp == 1, robust
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if selfemp == 1, vce(cluster isco08)
  reg low_teleworkable $`X' i.gouv i.isic4_reduced [pw = wgt] if selfemp == 1, robust
  reg low_teleworkable $`X' i.gouv i.isic4_reduced [pw = wgt]  if selfemp == 1, vce(cluster isco08)
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if hhwkr == 1, robust
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if hhwkr == 1, vce(cluster isco08)
  reg low_teleworkable $`X' i.gouv i.isic4_reduced [pw = wgt] if hhwkr == 1, robust
  reg low_teleworkable $`X' i.gouv i.isic4_reduced [pw = wgt] if hhwkr == 1, vce(cluster isco08)
  }

 foreach X in X30_wagewkr X30_wagewkr_inf X40_wagewkr X40_wagewkr_inf X50_wagewkr X50_wagewkr_inf{
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if wagewkr == 1, robust
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if wagewkr == 1, vce(cluster isco08)
  reg low_teleworkable $`X' i.gouv i.isic4_reduced [pw = wgt] if wagewkr == 1, robust
  reg low_teleworkable $`X' i.gouv i.isic4_reduced [pw = wgt] if wagewkr == 1, vce(cluster isco08)
  }
  
preserve
	keep if public==0 & essind==0
	reg low_rli no_coll male youth couple permanent urban i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08)
	reg low_rli no_coll male age40 couple permanent urban i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08)
	reg low_rli no_coll male age50 couple permanent urban i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08)
	reg low_rli no_coll male youth couple formal urban i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08)
	reg low_rli no_coll male age40 couple formal urban i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08)
	reg low_rli no_coll male age50 couple formal urban i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08) 
	reg teleworkable no_coll male youth couple permanent urban i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08)
	reg teleworkable no_coll male age40 couple permanent urban i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08)
	reg teleworkable no_coll male age50 couple permanent urban i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08)
	reg teleworkable no_coll male youth couple formal urban i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08)
	reg teleworkable no_coll male age40 couple formal urban i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08)
	reg teleworkable no_coll male age50 couple formal urban i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08) 

	keep if earn>0 & earn!=.
	reg low_rli no_coll male youth couple permanent urban i.qnt_earn i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08)
	reg low_rli no_coll male age40 couple permanent urban i.qnt_earn i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08)
	reg low_rli no_coll male age50 couple permanent urban i.qnt_earn i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08)
	reg low_rli no_coll male youth couple formal urban i.qnt_earn i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08)
	reg low_rli no_coll male age40 couple formal urban i.qnt_earn i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08)
	reg low_rli no_coll male age50 couple formal urban i.qnt_earn i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08) 
	reg teleworkable no_coll male youth couple permanent urban i.qnt_earn i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08)
	reg teleworkable no_coll male age40 couple permanent urban i.qnt_earn i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08)
	reg teleworkable no_coll male age50 couple permanent urban i.qnt_earn i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08)
	reg teleworkable no_coll male youth couple formal urban i.qnt_earn i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08)
	reg teleworkable no_coll male age40 couple formal urban i.qnt_earn i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08)
	reg teleworkable no_coll male age50 couple formal urban i.qnt_earn i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08) 
restore


*** Aggregation 

gen obs = 1

version 13

preserve 
keep if position==3 & status==1 
drop if isco08==. | public==. | nat09==.
gen earn_p50 = earn
gen earn_sum = earn
collapse (mean) rli infect_expo physic_prox teleworkable earn (median) earn_p50 ///
		 (sum) earn_sum (rawsum) wgt obs [pw=wgt], by(isco08 nat09 public)
	export delimited using "$results/meanwage_3d.csv", replace
restore

preserve 
drop if position==. | public==. | isco08==. | nat09==.
collapse (mean) rli infect_expo physic_prox teleworkable (rawsum) wgt obs [pw=wgt], by(isco08 nat09 public position)
	export delimited using "$results/wfh_4d.csv", replace
restore

preserve 
drop if gouv==. | position==. | public==.
collapse (mean) rli infect_expo physic_prox teleworkable (rawsum) wgt obs [pw=wgt], by(gouv public position nat09)
	export delimited using "$results/wfh_gouv.csv", replace
restore

*************************Outreg*************************************************

*1 - For each variable + selected regressions : we will have myreg_X30.docx, myreg_X40.docx and  myreg_X50.docx.
    *The two last reg for public sector and earnings are attached to myreg_X30.docx.
*2 - For each loop


********************************************************************************

foreach X in X30  {
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if selfemp == 1, robust // X
  outreg2 using myreg_X30.docx, drop(i.gouv i.isic4_reduced) replace  ctitle ($`X'_Self employed) 
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if hhwkr == 1, robust // X
  outreg2 using myreg_X30.docx, drop(i.gouv i.isic4_reduced) append  ctitle ($`X'_Household worker) 
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if hhwkr == 1, vce(cluster isco08)  // X
  outreg2 using myreg_X30.docx, drop(i.gouv i.isic4_reduced) append ctitle ($`X'_Household worker) 
 }
 
foreach X in X40 {
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if selfemp == 1, robust  // X
  outreg2 using myreg_X40.docx, drop(i.gouv i.isic4_reduced) append  ctitle ($`X'_Self employed) 
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if selfemp == 1, vce(cluster isco08) //X
  outreg2 using myreg_X40.docx, drop(i.gouv i.isic4_reduced) append  ctitle ($`X'_Self employed) 
 }
 
 foreach X in X50 {
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if selfemp == 1, robust // X
  outreg2 using myreg_X50.docx, drop(i.gouv i.isic4_reduced) append  ctitle ($`X'_Self employed) 
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if selfemp == 1, vce(cluster isco08) //X
  outreg2 using myreg_X50.docx, drop(i.gouv i.isic4_reduced) append  ctitle ($`X'_Self employed) 
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if hhwkr == 1, robust // X
  outreg2 using myreg_X50.docx, drop(i.gouv i.isic4_reduced) append  ctitle ($`X'_Household worker) 
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if hhwkr == 1, vce(cluster isco08) // X
  outreg2 using myreg_X50.docx, drop(i.gouv i.isic4_reduced) append ctitle ($`X'_Household worker) 
 }
 
 foreach X in X30_wagewkr {
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if wagewkr == 1, robust // X
    outreg2 using myreg_X30.docx, drop(i.gouv i.isic4_reduced) replace  ctitle ($`X'_wagewkr) 
  }
 
 foreach X in X30_wagewkr_inf {
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if wagewkr == 1, robust // X
    outreg2 using myreg_X30.docx, replace  ctitle ($`X'_wagewkr_inf) 
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if wagewkr == 1, vce(cluster isco08) //X
   outreg2 using myreg_X30.docx, drop(i.gouv i.isic4_reduced) append  ctitle ($`X'_wagewkr_inf) 
  }
  
 foreach X in  X40_wagewkr {
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if wagewkr == 1, robust // X
  outreg2 using myreg_X40.docx, drop(i.gouv i.isic4_reduced) append  ctitle ($`X'_wagewkr) 
  reg low_teleworkable $`X' i.gouv i.isic4_reduced [pw = wgt] if wagewkr == 1, robust // X
   outreg2 using myreg_X40.docx, drop(i.gouv i.isic4_reduced) append  ctitle ($`X'_wagewkr)
  }
  
 foreach X in  X40_wagewkr_inf {
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if wagewkr == 1, robust // X
  outreg2 using myreg_X40.docx, drop(i.gouv i.isic4_reduced) append  ctitle ($`X'_wagewkr_inf)
  }
  
 foreach X in  X50_wagewkr {
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if wagewkr == 1, robust // X
  outreg2 using myreg_X50.docx, drop(i.gouv i.isic4_reduced) append  ctitle ($`X'_wagewkr)
  reg low_teleworkable $`X' i.gouv i.isic4_reduced [pw = wgt] if wagewkr == 1, robust // X
   outreg2 using myreg_X50.docx, drop(i.gouv i.isic4_reduced) append  ctitle ($`X'_wagewkr)
  }
  
 foreach X in  X50_wagewkr_inf{
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if wagewkr == 1, robust // X
  outreg2 using myreg_X50.docx, drop(i.gouv i.isic4_reduced) append  ctitle ($`X'_wagewkr_inf)
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if wagewkr == 1, vce(cluster isco08) //X
  outreg2 using myreg_X50.docx, drop(i.gouv i.isic4_reduced) append  ctitle ($`X'_wagewkr_inf)
  reg low_teleworkable $`X' i.gouv i.isic4_reduced [pw = wgt] if wagewkr == 1, robust // X
   outreg2 using myreg_X50.docx, drop(i.gouv i.isic4_reduced) append  ctitle ($`X'_wagewkr_inf)
  }
   
preserve
	keep if public==0 & essind==0
	reg teleworkable no_coll male youth couple permanent urban i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08) // X
	outreg2 using myreg_X30.docx, drop(i.gouv i.isic4_reduced) ctitle (Private & non-essential industries)
	
	keep if earn>0 & earn!=.
	reg teleworkable no_coll male youth couple permanent urban i.qnt_earn i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08) // X
	outreg2 using myreg_X30.docx, drop(i.gouv i.isic4_reduced) append  ctitle (earnings)
restore

********************************************************************************

/*
  cap erase mydox1.docx
  foreach X in X30 X40 X50 {
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if selfemp == 1, robust // X
  outreg2 using mydox1.docx, drop(i.gouv i.isic4_reduced)  ctitle ($`X'_Self employed) 
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if selfemp == 1, vce(cluster isco08) //X
  outreg2 using mydox1.docx, drop(i.gouv i.isic4_reduced)  ctitle ($`X'_Self employed) 
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if hhwkr == 1, robust // X
  outreg2 using mydox1.docx, drop(i.gouv i.isic4_reduced)  ctitle ($`X'_Household worker) 
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if hhwkr == 1, vce(cluster isco08) // X
  outreg2 using mydox1.docx, drop(i.gouv i.isic4_reduced) ctitle ($`X'_Household worker) 
 }
 
  cap erase mydox2.docx
 foreach X in X30_wagewkr X30_wagewkr_inf X40_wagewkr X40_wagewkr_inf X50_wagewkr X50_wagewkr_inf{
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if wagewkr == 1, robust
    outreg2 using mydox2.docx, drop(i.gouv i.isic4_reduced)  ctitle ($`X'_Self employed_robust) 
  reg low_rli $`X' i.gouv i.isic4_reduced [pw = wgt] if wagewkr == 1, vce(cluster isco08)
    outreg2 using mydox2.docx, drop(i.gouv i.isic4_reduced)  ctitle ($`X'_Self employed_cluster) 
  reg low_teleworkable $`X' i.gouv i.isic4_reduced [pw = wgt] if wagewkr == 1, robust
    outreg2 using mydox2.docx, drop(i.gouv i.isic4_reduced)  ctitle ($`X'_Self employed_robust) 
  reg low_teleworkable $`X' i.gouv i.isic4_reduced [pw = wgt] if wagewkr == 1, vce(cluster isco08)
    outreg2 using mydox2.docx, drop(i.gouv i.isic4_reduced)  ctitle ($`X'Self employed_cluster) 
  }
  
  preserve
	keep if public==0 & essind==0
	reg teleworkable no_coll male youth couple permanent urban i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08) // X
	 outreg2 using mydox2.docx, drop(i.gouv i.isic4_reduced) ctitle (Private & non-essential industries)
	
	keep if earn>0 & earn!=.
	reg teleworkable no_coll male youth couple permanent urban i.qnt_earn i.gouv i.isic4_reduced [pw = wgt], vce(cluster isco08) // X
	 outreg2 using mydox2.docx, drop(i.gouv i.isic4_reduced) ctitle (earnings)
  restore
 
 */
 
 ********************************************************************************
