/*******************************************************************************
This dofile produces figures and tables for analysis.
*******************************************************************************/

clear all
estimates clear

cd $tables 

*** Aggregating by 1 digit occupation
use $data_survey/combined_data.dta, clear
sum teleworkable [aw=wgt] if teleworkable>0.35, d
gen isco08_1d = int(isco08/1000)

*** Labelling and saving
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
				  
table isco08_1d [aw=wgt], c(mean rli mean teleworkable mean earn_mean) format(%4.2f) row

*** Aggregating by broad industry
use $data_survey/combined_data.dta, clear
recode isic4_2d (1/3 = 1 "Agriculture") ///
				(5/9 = 2 "Mining and quarrying; Electricity, gas and water supply") ///
				(35/39 = 2 "Mining and quarrying; Electricity, gas and water supply") ///
				(10/33 = 3 "Manufacturing") ///
				(41/43 = 4 "Construction") ///
				(45/82 = 5 "Market services") ///
				(84/99 = 6 "Non-Market services"), gen(isic4_broad)

sum rli teleworkable [aw=wgt] // Entire economy
sum rli teleworkable [aw=wgt] if isic4_broad == 1 // Agriculture
sum rli teleworkable [aw=wgt] if isic4_broad != 1 & isic4_broad != . // Non-agriculture
sum rli teleworkable [aw=wgt] if essential_tun == 0 // Italian non-essential industry
sum rli teleworkable [aw=wgt] if essential_ita == 0 // Tunisian non-essential industry
				
table isic4_broad [aw=wgt], c(mean rli mean teleworkable mean earn_mean) format(%4.2f) row

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


