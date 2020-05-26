/*******************************************************************************
This dofile calculates the labor supply shocks by occupation and industry.
*******************************************************************************/

clear all
estimates clear

cd $data_index

* 1 - Supply shock - Working from home (SS)

*** Aggregating by 4 digit occupation
use $data_survey/combined_data.dta, clear
gen isco08_1d = int(isco08/1000)

	bys isco08_2d: egen occ_emp_tot = total(wgt)
	bys isco08_2d: egen occ_emp_ess_ita = total(wgt*essential_ita)
	bys isco08_2d: egen occ_emp_ess_tun = total(wgt*essential_tun)
	bys isco08_2d: egen occ_emp_noness_ita = total(wgt*(1-essential_ita))
	bys isco08_2d: egen occ_emp_noness_tun = total(wgt*(1-essential_tun))
	
collapse (mean) occ_emp_tot occ_emp_ess_ita occ_emp_ess_tun occ_emp_noness_ita ///
				occ_emp_noness_tun rli teleworkable infect_expo physic_prox ///
				earn_med earn_mean (sum) wgt, by(isco08_2d)
				
*** Shocks in terms of share	
gen occ_ess_ita = occ_emp_ess_ita/occ_emp_tot
gen occ_ess_tun = occ_emp_ess_tun/occ_emp_tot		
gen occ_SS_ita_rli = (1 - occ_ess_ita)*(1 - rli)
gen occ_SS_tun_rli = (1 - occ_ess_tun)*(1 - rli)
gen occ_SS_ita_telework = (1 - occ_ess_ita)*(1 - teleworkable)
gen occ_SS_tun_telework = (1 - occ_ess_tun)*(1 - teleworkable)

*** Making the shocks negative
replace occ_SS_ita_rli = -occ_SS_ita_rli
replace occ_SS_tun_rli = -occ_SS_tun_rli
replace occ_SS_ita_telework = -occ_SS_ita_telework
replace occ_SS_tun_telework = -occ_SS_tun_telework

*** Labelling and saving

gen isco08_2d = int(isco08/100)
lab val isco08_2d isco08_2d
decode isco08_2d, gen(isco08_2d_title)

				 
save $data_index/supply_occ.dta, replace
export delimited using "C:\Users\Dell\Downloads\Covid19\data\supply_occ_2d.csv", nolabel replace

*** Aggregating by 4-digit industry
use $data_survey/combined_data.dta, clear

	bys isic4: egen ind_emp_tot = total(wgt)
	bys isic4: egen ind_emp_rli = total(wgt*rli)
	bys isic4: egen ind_emp_telework = total(wgt*teleworkable)
	bys isic4: egen ind_emp_ess_ita = total(wgt*essential_ita)
	bys isic4: egen ind_emp_ess_tun = total(wgt*essential_tun)
	bys isic4: egen ind_emp_noness_ita = total(wgt*(1-essential_ita))
	bys isic4: egen ind_emp_noness_tun = total(wgt*(1-essential_tun))

collapse (mean) ind_emp_tot ind_emp_rli ind_emp_telework ind_emp_ess_ita ///
				ind_emp_ess_tun ind_emp_noness_ita ind_emp_noness_tun ///
				essential_ita essential_tun, by(isic4)

*** Shocks in terms of share
gen ind_emp_SS_ita_rli = (1 - essential_ita)*(1 - ind_emp_rli/ind_emp_tot)
gen ind_emp_SS_tun_rli = (1 - essential_tun)*(1 - ind_emp_rli/ind_emp_tot)
gen ind_emp_SS_ita_telework = (1 - essential_ita)*(1 - ind_emp_telework/ind_emp_tot)
gen ind_emp_SS_tun_telework = (1 - essential_tun)*(1 - ind_emp_telework/ind_emp_tot)

*** Making the shocks negative
replace ind_emp_SS_ita_rli = - ind_emp_SS_ita_rli
replace ind_emp_SS_tun_rli = - ind_emp_SS_tun_rli
replace ind_emp_SS_ita_telework = - ind_emp_SS_ita_telework
replace ind_emp_SS_tun_telework = - ind_emp_SS_tun_telework

*** Labelling and saving
gen isic4_2d = int(isic4/1000)
recode isic4_2d ///
			(1/3 = 1 "A Agriculture, forestry & fishing" ///
			5/9 = 2 "B Mining and quarrying" ///
			10/33 = 3 "C Manufacturing" ///
			35 = 4 "D Electricity & gas supply" ///
			36/39 = 5 "E Water supply and waste management" ///
			41/43 = 6 "F Construction" ///
			45/47 = 7 "G Wholesale & retail trade" ///
			49/53 = 8 "H Transportation & storage" ///
			55/56 = 9 "I Accommodation &food services" ///
			58/63 = 10 "J Information & communication" ///
			64/66 = 11 "K Financial & insurance" ///
			68 = 12 "L Real estate" ///
			69/75 = 13 "M Science and technology" ///
			77/82 = 14 "N Administration & support services" ///
			84 = 15 "O Health and social work" ///
			85 = 16 "P Edducation" /// 
			86/88 = 17 "Q Public administration & defence" ///
			90/93 = 18 "R Arts, entertainment & recreation" ///
			94/96 = 19 "S Other services" ///
			97/98 = 20 "T Household self-production" ///
			99 = 21 "U Extraterritorial organizations", gen(isic4_broad)
			decode isic4_reduced, gen(isic4_broad_title)

save $data_index/supply_ind.dta, replace
export delimited using "supply_ind.cvs", nolabel replace
  
* 2 - Supply shock - Global value chain (SS) (In progress)
   
* 3 - Demand shock (DS) (In progress)



 
