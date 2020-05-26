/*******************************************************************************
This dofiles merge industry shocks to Tunisian survey database of occupation.
*******************************************************************************/

clear all
estimates clear
	
*********************** 1. Preparing survey data to merge **********************

*** Cleaning concordance table NAT 2009 - ISIC rev. 4
import excel "$data_index/Table Corresp_NAT09_ISIC Rev4.xlsx", ///
	sheet("NAT09_ISICRev4") firstrow clear
ren (CodeNAT09 IntitulésNAT09 CodeISICRev4 IntitulésISICRev4) ///
	(nat09 nat09_title isic4 isic4_title)
replace nat09 = subinstr(nat09, ".", "", 1)
destring nat09 isic4, replace
tempfile nat09_isic4
save `nat09_isic4', replace

*** Cleaning Tunisian classification of essential industries
use $data_index/essential_tunisia_final.dta, clear
ren essential_New essential_tun
collapse (mean) essential_tun, by(nat09)
tempfile tun_essential
save `tun_essential', replace

*** Merging occupational indices with mean and median earnings
clear
import delimited $data_survey/occupation_mean.csv
ren earn_p50 earn_med
ren earn earn_mean
keep isco08 earn_med earn_mean
tempfile mearn
save `mearn', replace

clear
import delimited $data_survey/occupation_industry.csv
merge m:1 isco08 using `mearn', keep(3) nogen

*** Mapping from NAT 2009 to ISIC rev. 4
merge m:1 nat09 using `nat09_isic4', keep(3) nogen
/*  Result                           # of obs.
    -----------------------------------------
    not matched                            94
        from master                        41  (_merge==1)
        from using                         53  (_merge==2)
    matched                             9,682  (_merge==3)
    -----------------------------------------
// This is a survey, so some 4-digit industries are absent from the master data (_merge==2).
// What about industries absent from the using data (_merge==1)? We checked this by hand.
   These activities were incorrectly recorded and don't exist in the Tunisian Nomenclature */

   
********************** 2. Essential/Non essential industry *********************

*** Tunisian source
merge m:1 nat09 using `tun_essential', keep(1 3) nogen
// Correct some activities *** MPL: Emile could you please check if these activities are essential?
replace essential_tun = 1 if nat09==5040
replace essential_tun = 0 if nat09==9810

*** Italian source
merge m:1 isic4 using $data_index/isic_essential.dta, keep(1 3) nogen
ren essential essential_ita
replace essential_ita = essential_tun if essential_ita==. 
// Some industries are absent from the Italian essential industry list.


************************ 3. Demand shocks (in progress) ************************

gen isco08_2d = int(isco08/100)
lab def isco08_2d  11 "Chief Executives"                                ///
                 12 "Admin. & Commercial Managers"                      ///
                 13 "Production & Services Managers"                    ///
                 14 "Other Specialized Managers"                        ///
                 21 "Science & Engineering Pro."                           ///
                 22 "Health Pro."                                          ///
                 23 "Teaching Pro."                                        ///
                 24 "Business & Admin. Pro."                               ///
                 25 "ICT Pro."                                             ///
                 26 "Social Pro."                         ///
                 31 "Science & Engineering Associate Pro."                  ///
                 32 "Health Associate Pro."                                 ///
                 33 "Business & Admin. Associate Pro."                      ///
                 34 "Social Associate Pro."      ///
                 35 "ICT Technicians"              ///
                 41 "Keyboard Clerks"                             ///
                 42 "Customer Services Clerks"                                ///
                 43 "Numerical & Material Recording Clerks"                   ///
                 44 "Other Clerks"                          ///
                 51 "Personal Services Workers"                               ///
                 52 "Sales Workers"                                           ///
                 53 "Personal Care Workers"                                   ///
                 54 "Protective Services Workers"                             ///
                 61 "Agricultural Workers"            ///
                 62 "Forestry, Fishery & Hunting Workers" ///
                 63 "Subsistence Farmers"     ///
                 71 "Construction Workers" ///
                 72 "Machinery Workers"             ///
                 73 "Handicraft & Printing Workers"                         ///
                 74 "Electrical & Electronic Workers"                ///
                 75 "Food, Garment & Craft Workers" ///
                 81 "Stationary Plant & Machine Operators"                    ///
                 82 "Assemblers"                                              ///
                 83 "Drivers & Mobile Plant Operators"                        ///
                 91 "Cleaners & Helpers"                                      ///
                 92 "Agricultural, Forestry & Fishery Labourers"              ///
                 93 "Non-agricultural Labourers" ///
                 94 "Food Preparation Assistants"                             ///
                 95 "Street, Related Sales & Services Workers"             ///
                 96 "Refuse & Other Elementary Workers"             ///
                  1 "Commissioned Armed Forces Officers"                      ///
                  2 "Non-commissioned Armed Forces Officers"                  ///
                  3 "Armed Forces Occupations, Other Ranks"
				 lab val isco08_2d isco08_2d
				 decode isco08_2d, gen(isco08_2d_title)

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
			(99 = 21 "U Extraterritorial organizations"), gen(isic4_reduced)
			decode isic4_reduced, gen(isic4_reduced_title)

save $data_survey/combined_data.dta, replace
export delimited using "C:/Users/Dell/Downloads/Covid19/data/combined_data.csv", nolabel replace
