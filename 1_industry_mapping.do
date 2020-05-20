clear all
estimates clear

cd $data_index

/*  Map essential NACE rev.2 4 digit to ISIC rev.4 4 digit
	Input:
	1. isic_nace.dta - Concordance table
	2. italy_essential.dta - Italy essential industries 
	Output:
	1. isic_essential.dta - Corresponding essential ISIC 4 digit */

* Divide essential NACE into subsets of different digit levels
use italy_essential.dta, clear
replace nace=substr(nace,1,5) if strlen(nace)>5
replace nace="0" + nace if strlen(nace)==1 | nace=="9.1"
gen essential=1

preserve 
	keep if strlen(nace)==5
	keep nace essential
	ren essential ess4
	duplicates drop
	tempfile nace4
	save `nace4', replace
restore

preserve 
	keep if strlen(nace)==4
	keep nace essential
	ren (nace essential) (nace3 ess3)
	tempfile nace3
	save `nace3', replace
restore

preserve 
	keep if strlen(nace)==2
	keep nace essential
	ren (nace essential) (nace2 ess2)
	tempfile nace2
	save `nace2', replace
restore

* Merge essential NACE with ISIC
use isic_nace.dta, clear
gen nace2 = substr(nace,1,2)
gen nace3 = substr(nace,1,4)
merge m:1 nace  using `nace4', keep(1 3) nogen
merge m:1 nace3 using `nace3', keep(1 3) nogen
merge m:1 nace2 using `nace2', keep(1 3) nogen

gen essential=ess4
replace essential=ess3 if essential==. & ess3!=.
replace essential=ess2 if essential==. & ess2!=.
replace essential=0 if essential==.

drop nace2 nace3 ess2 ess3 ess4

collapse (mean) essential, by(isic)

replace essential = 1 if isic == 1399 | isic == 1410 | isic == 4649
replace essential = 0 if isic == 2310 | isic == 2512 | isic == 2599 | ///
								  isic == 2819 | isic == 2829 | isic == 3290 | ///
								  isic == 4659 | isic == 5510
ren isic isic4
								  
save isic_essential.dta, replace

/*  Map NAICS 2017 6 digit demand shocks to ISIC rev.4 4 digit
	Input:
	1. isic_naics.dta - Concordance table
	2. us_demand_shock.dta - US demand shock by industry
	Output:
	1. isic_demand_shock.dta - Corresponding demand shock at ISIC 4 digit level
	2. isic_demand_shock_exceptional.dta - Exceptional NAICS - ISIC (duplicate) to map manually 

* Merge NAICS demand shocks with ISIC
use isic_naics.dta, clear

drop if strlen(naics)<6
destring naics, replace
ren naics naics6
gen naics = int(naics6/100)

merge m:1 naics using us_demand_shock.dta, keep(3) nogen

* Unique ISIC to map automatically
preserve
collapse (mean) severe_demand_shock mild_demand_shock, by(isic)
keep if severe_demand_shock==int(severe_demand_shock) & ///
		mild_demand_shock==int(mild_demand_shock)
save isic_demand_shock.dta, replace
restore

* Duplicate ISIC to map manually
preserve
collapse (mean) severe_demand_shock mild_demand_shock, by(isic)
keep if severe_demand_shock!=int(severe_demand_shock) | ///
		mild_demand_shock!=int(mild_demand_shock)
gen exceptional_demand_shock=1
tempfile exceptional
save `exceptional', replace
restore

merge m:1 isic using `exceptional', keep(3) nogen
save isic_demand_shock_exceptional.dta, replace
