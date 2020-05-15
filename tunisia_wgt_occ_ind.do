
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
	
	global dofiles $covid/Script
	global dofilename "tunisia_wgt_occ_ind.do"
		
// create local for date and version tracking

	local c_date = c(current_date)
	local date_string = subinstr("`c_date'", ":", "_", .)
	local date_string = subinstr("`date_string'", " ", "_", .)
	global track_date = c(current_date)
	global track_time = c(current_time)

		// define data repository
		global desktop C:/Users/Dell/Dropbox
		global rti $desktop/Tunisie_ENPE
		global data_rti_survey $rti/data/enquete_des_individus/echantillon_2000_10_17
		global data_rti_combined $rti/data/Combined_Data
		global data_INS $rti/INS/out/Out_11.05.20/Results/PartA_Descriptive/Tables
		global covid $desktop/COVID-firmes/Working_files
		global data_covid $covid/Data
	
		// make folders to organise work  
		cd
		
		cd $covid
		foreach folder in Log Results {
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
keep if year==2010

* Occupations
merge m:1 isco88 using "$data_covid/isco88_rli.dta", keep(3) nogen
gen isco88_1 = int(isco88/1000)
gen isco88_2 = int(isco88/100)

lab def isco88_1  0 "0 Armed Forces Occupations"                              ///
                  1 "1 Managers"                                              ///
                  2 "2 Professionals"                                         ///
                  3 "3 Technicians and Associate Professionals"               ///
                  4 "4 Clerical Support Workers"                              ///
				  5 "5 Services and Sales Workers"                            /// 
                  6 "6 Skilled Agricultural, Forestry and Fishery Workers"    ///
                  7 "7 Craft and Related Trades Workers"                      /// 
                  8 "8 Plant and Machine Operators and Assemblers"            ///
                  9 "9 Elementary Occupations"
                  lab val isco88_1 isco88_1
		
lab def isco88_2 11 "11 Legislators and senior officials"                     ///
                 12 "12 Corporate managers"                                   ///
				 13 "13 Managers of small enterprises"                        ///				 
				 21 "21 Physical, mathematical and engineering science professionals" ///
				 22 "22 Life science and health professionals"                ///
				 23 "23 Teaching professionals"                               ///
				 24 "24 Other professionals"                                  ///				 
				 31 "31 Physical and engineering science associate professionals" ///
				 32 "32 Life science and health associate professionals"      ///
				 33 "33 Teaching associate professionals"                     ///
				 34 "34 Other associate professionals "                       ///				 
				 41 "41 Office clerks"                                        ///
				 42 "42 Customer services clerk"                              ///				 
				 51 "51 Personal and protective services worker"              ///
				 52 "52 Models, salespersons and demonstrators"               ///				 
				 61 "61 Skilled agricultural and fishery workers"             ///
				 62 "62 Subsistence agricultural and fishery workers"         ///				 
				 71 "71 Extraction and building trades workers"               ///
				 72 "72 Metal, machinery and related trades workers"          ///
				 73 "73 Precision, handicraft, craft printing and related trades workers" ///
				 74 "74 Other craft and related trades workers"                ///				 
				 81 "81 Stationary plant and related operators"               ///
				 82 "82 Machine operators and assemblers "                    ///
				 83 "83 Drivers and mobile plant operators"                   ///				 
				 91 "91 Sales and services elementary occupations"            ///
				 92 "92 Agricultural, fishery and related labourers "         ///
				 93 "93 Labourers in mining, construction, manufacturing and transport" ///
				  1 "01 Armed forces"
				lab val isco88_2 isco88_2
				
gen skill = .
replace skill = 1 if isco88_1 >= 1 & isco88_1 <= 3
replace skill = 2 if (isco88_1 >= 4 & isco88_1 <= 5)|(isco88_1 >= 7 & isco88_1 <= 8)
replace skill = 3 if isco88_1 == 6 | isco88_1 == 9
lab def skill 1 "High" 2 "Medium" 3 "Low"
lab val skill skill

gen isic3_1 = int(isic3/1000)
gen agri = cond(isic3_1==1, 1, 0)

table skill [pw=wgt], c(mean teleworkable)
table agri [pw=wgt], c(mean rli)

tab agri [aw=wgt], freq
table sector [pw=wgt], c(mean teleworkable)

sum teleworkable [aw=wgt]


/*
----------------------
    skill |  mean(rli)
----------+-----------
     High |   .5983344
   Medium |   .2617748
      Low |   .2129537
----------------------
*/


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

preserve 
gen obs = 1
collapse (mean) rli infect_expo physic_prox teleworkable earn (median) earn (rawsum) wgt obs [pw=wgt], by(isco08)
	export excel isco08 rli infect_expo physic_prox teleworkable p50 earn wgt obs /// 
	using "$Tables/occupation_mean", sheet("occ") sheetreplace firstrow(variables)
restore

* Industries
* Map ISIC rev. 4 to ISIC rev. 3
use "$data_rti_survey/ENPE_survey.dta", clear
keep if year==2010

	gen obs=1
	collapse (sum) obs wgt, by(isic3)
	drop if isic3 == .
	replace wgt=round(wgt)
	tempfile isic_rev3
	save `isic_rev3', replace
	
	merge m:1 isic3 using `isic_rev3', keep(2 3) nogen
	drop if essential==.
	
	bys isic3: gen freq=_N
	bys isic3: egen sumess = total(essential)
	bys isic3: egen meaness = mean(essential)
	browse if meaness!=int(meaness)
	
gen isic3_1 = int(isic3/1000)
gen isic3_2 = int(isic3/100)



