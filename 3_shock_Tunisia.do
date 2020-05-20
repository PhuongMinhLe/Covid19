/*******************************************************************************
This dofile calculates the labor supply shocks by occupation and industry.
*******************************************************************************/

clear all
estimates clear

cd $data_index

* 1 - Supply shock - Working from home (SS)

*** Aggregating by 4 digit occupation
use $data_survey/combined_data.dta, clear

	bys isco08: egen occ_emp_tot = total(wgt)
	bys isco08: egen occ_emp_ess_ita = total(wgt*essential_ita)
	bys isco08: egen occ_emp_ess_tun = total(wgt*essential_tun)
	bys isco08: egen occ_emp_noness_ita = total(wgt*(1-essential_ita))
	bys isco08: egen occ_emp_noness_tun = total(wgt*(1-essential_tun))
	
collapse (mean) occ_emp_tot occ_emp_ess_ita occ_emp_ess_tun occ_emp_noness_ita ///
				occ_emp_noness_tun rli teleworkable infect_expo physic_prox ///
				earn_med earn_mean, by(isco08)
				
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
export delimited using "supply_occ.cvs", nolabel replace

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

save $data_index/supply_ind.dta, replace
export delimited using "supply_ind.cvs", nolabel replace
  
* 2 - Supply shock - Global value chain (SS) (In progress)
   
* 3 - Demand shock (DS) (In progress)



 
