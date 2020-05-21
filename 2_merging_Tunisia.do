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
use $data_index/nat_essential.dta, clear
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
lab def isco08_2d 11 "Chief Executives, Senior Officials and Legislators"      ///
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
				 lab val isco08_2d isco08_2d
				 decode isco08_2d, gen(isco08_2d_title)
				 
gen isco08_2d_reduced = int(isco08/100)
lab def isco08_2d_reduced 11 "Chief Executives"                               ///
                 12 "Managers"                                                ///
                 13 "Services Managers"                                       ///
                 14 "Other Services Managers"                                 ///
                 21 "Science and Engineering Pro."                   ///
                 22 "Health Pro."                                    ///
                 23 "Teaching Pro."                                  ///
                 24 "B&A Pro."               ///
                 25 "ICT Pro." ///
                 26 "Legal, Social and Cultural Pro."                ///
                 31 "Science and Engineering Associate Pro."         ///
                 32 "Health Associate Pro."                          ///
                 33 "Business and Admin. Associate Pro."     ///
                 34 "Legal, Social, Cultural and Related Associate Pro." ///
                 35 "I&C Technicians"              ///
                 41 "General and Keyboard Clerks"                             ///
                 42 "Customer Services Clerks"                                ///
                 43 "Numerical & Material Recording Clerks"                 ///
                 44 "Other Clerical Support Workers"                          ///
                 51 "Personal Services Workers"                               ///
                 52 "Sales Workers"                                           ///
                 53 "Personal Care Workers"                                   ///
                 54 "Protective Services Workers"                             ///
                 61 "Agricultural Workers"            ///
                 62 "Forestry, Fishery & Hunting Workers" ///
                 63 "Subsistence Farmers, Fishers, Hunters and Gatherers"     ///
                 71 "Building and Related Trades Workers (excluding Electricians)" ///
                 72 "Metal, Machinery and Related Trades Workers"             ///
                 73 "Handicraft & Printing Workers"                         ///
                 74 "Electrical & Electronic Trades Workers"                ///
                 75 "Food Processing, Woodworking, Garment & Other Craft and Related Trades Workers" ///
                 81 "Stationary Plant & Machine Operators"                  ///
                 82 "Assemblers"                                              ///
                 83 "Drivers & Mobile Plant Operators"                      ///
                 91 "Cleaners & Helpers"                                    ///
                 92 "Agricultural, Forestry & Fishery Labourers"            ///
                 93 "Labourers in Mining, Construction, Manufacturing & Transport" ///
                 94 "Food Preparation Assistants"                             ///
                 95 "Street and Related Sales & Services Workers"           ///
                 96 "Refuse Workers and Other Elementary Workers"             ///
                  1 "Commissioned Armed Forces Officers"                      ///
                  2 "Non-commissioned Armed Forces Officers"                  ///
                  3 "Armed Forces Occupations, Other Ranks"
				 lab val isco08_2d_reduced isco08_2d_reduced
				 decode isco08_2d_reduced, gen(isco08_2d_reduced_title)


gen isic4_2d = int(isic4/100)
recode isic4_2d ///
			(1 = 1 "Agriculture") ///
			(2 = 2 "Forestry") ///
			(3 = 3 "Aquaculture") ///
			(5 = 5 "Mining of coal and lignite") ///
			(6 = 6 "Extraction of crude petroleum and natural gas") ///
			(7 = 7 "Mining of metal ores") ///
			(8 = 8 "Other mining and quarrying") ///
			(9 = 9 "Mining support service activities") ///
			(10 = 10 "Manufacture of food products") ///
			(11 = 11 "Manufacture of beverages") ///
			(12 = 12 "Manufacture of tobacco products") ///
			(13 = 13 "Manufacture of textiles") ///
			(14 = 14 "Manufacture of wearing apparel") ///
			(15 = 15 "Manufacture of leather and related products") ///
			(16 = 16 "Manufacture of wood and of related products") ///
			(17 = 17 "Manufacture of paper and paper products") ///
			(18 = 18 "Printing and reproduction of recorded media") ///
			(19 = 19 "Manufacture of coke and refined petroleum products") ///
			(20 = 20 "Manufacture of chemicals and chemical products") ///
			(21 = 21 "Manufacture of pharmaceuticals and related products") ///
			(22 = 22 "Manufacture of rubber and plastics products") ///
			(23 = 23 "Manufacture of other non-metallic mineral products") ///
			(24/25 = 24 "Manufacture of metal products") ///
			(26 = 25 "Manufacture of computer, electronic and optical products") ///
			(27/30 = 26 "Manufacture of  machinery and equipment") ///
			(31 = 27 "Manufacture of furniture") ///
			(32 = 28 "Other manufacturing") ///
			(33 = 29 "Repair and installation of machinery and equipment") ///
			(35 = 30 "Electricity, gas, steam and air conditioning supply") ///
			(36/39 = 31 "Water supply; sewerage, waste management and remediation activities") ///
			(41/43 = 32 "Construction") ///
			(45/47 = 33 "Wholesale and retail trade") ///
			(49 = 34 "Land transport and transport via pipelines") ///
			(50 = 35 "Water transport") ///
			(51 = 36 "Air transport") ///
			(52 = 37 "Warehousing and support activities for transportation") ///
			(53 = 38 "Postal and courier activities") ///
			(55 = 39 "Accommodation") ///
			(56 = 40 "Food and beverage service activities") ///
			(58/63 = 41 "Information and communication") ///
			(64/68 = 42 "Financial, insurance and real estate activities") ///
			(69/75 = 43 "Professional, scientific and technical activities") ///
			(77/82 = 44 "Administrative and support service activities") ///
			(84 = 45 "Public administration and defence; compulsory social security") ///
			(85 = 46 "Education") ///
			(86/87 = 47 "Human health and social work activities") ///
			(90/93 = 48 "Arts, entertainment and recreation") ///
			(94/96 = 50 "Activities of membership organizations") ///
			(97/98 = 51 "Activities of households as employers; production for own use") ///
			(99 = 52 "Activities of extraterritorial organizations and bodies"), gen(isic4_reduced)
			decode isic4_reduced, gen(isic4_reduced_title)


save $data_survey/combined_data.dta, replace
export delimited using "C:/Users/Dell/Downloads/Covid19/data/combined_data.csv", nolabel replace
