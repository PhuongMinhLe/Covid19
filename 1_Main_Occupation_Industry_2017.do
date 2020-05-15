
********************************************************************************
********************************************************************************
***** COVID-19
***** 30 April 2020
********************************************************************************
********************************************************************************
	cls
	clear all
	set more off
	capture log close
	estimates clear
	
	global dofilename "1_Main_Occupation_industry_2017.do"
		
// create local for date and version tracking

	local c_date = c(current_date)
	local date_string = subinstr("`c_date'", ":", "_", .)
	local date_string = subinstr("`date_string'", " ", "_", .)
	global track_date = c(current_date)
	global track_time = c(current_time)

// define data repository
	global INS "D:/02_EnqEmp_new/Projet IRD decembre 2019"
	global rti $INS/Tunisie_ENPE
	global data_rti_survey $INS/Data/Survey_Data
	global data_rti_combined $INS/Data/Combined_Data
	
// make folders to organise work 
	cd
		
	cd "$INS"
	cap mkdir COVID-19
	global covid $INS/COVID-19
		
	cd "$covid"
	cap mkdir Data
	global data_covid $covid/Data
	foreach folder in Dofiles Log Results {
		cap mkdir "`folder'"
		global `folder' = "$covid/`folder'"
		}	
	cd "$Results"
	cap mkdir Graphs
	cap mkdir Tables

//run log for commands
	 cd "$Log"
	 cap log using Main_`date_string', text replace

********************************************************************************
display "This file started on `c(current_date)' at `c(current_time)' " 
********************************************************************************

use "$data_rti_survey/ENPE_survey.dta", clear
keep if year==2017

* Occupations
merge m:1 isco08 using "$data_covid/isco08_rli.dta", keep(3) nogen
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
				 
graph hbox rli [pweight = wgt], over(isco88_2) nooutsides medtype(marker) ///
		 medmarker(mcolor(cranberry) msize(medsmall) msymbol(diamond))  ///
		 alsize(40) marker(1, msize(small)) ytitle(Remote Labor Index) ///
		 ylabel(0(.2)1) scheme(s1color) scale(0.8) name(RTI_delrio, replace)
graph export "$Results\Graphs\rti_delrio.png", replace

graph hbox rli [pweight = wgt], over(isco88_2) nooutsides medtype(marker) ///
		 medmarker(mcolor(cranberry) msize(medsmall) msymbol(diamond))  ///
		 alsize(40) marker(1, msize(small)) ytitle(Teleworkability) ///
		 ylabel(0(.2)1) scheme(s1color) scale(0.8) name(RTI_dingel, replace)
graph export "$Results\Graphs\rti_dingel.png", replace

*** Aggregation 
preserve 
gen obs = 1
collapse (mean) rli infect_expo physic_prox teleworkable earn (median) earn (rawsum) wgt obs [pw=wgt], by(isco08)
	export excel isco08 rli infect_expo physic_prox teleworkable p50 earn wgt obs /// 
	using "$Tables/occupation_mean", sheet("occ") sheetreplace firstrow(variables)
restore

preserve
gen obs = 1
collapse (mean) essential (rawsum) wgt obs [pw=wgt], by(isco08 isic3)
	export excel isco08 isic3 essential wgt obs /// 
	using "$Tables/occupation_industry", sheet("occ_ind") sheetreplace firstrow(variables)
restore



