/*
*******************************
The indices quantifying the occupational features affected by the COVID-19 crisis are provided by:

1. del Rio-Chanona, R. M., Mealy, P., Pichler, A., Lafond, F., & Farmer, D. (2020). 
Supply and demand shocks in the COVID-19 pandemic: An industry and occupation perspective. arXiv preprint arXiv:2004.06759.
	- Remote labor index (RLI), constructed from ONET-2010 Work Activities
	- Infection exposure
	- Physical proximity
Data and scripts (Python and R) are available to download from: 
https://zenodo.org/record/3751068
 
2. Dingel, J. I., & Neiman, B. (2020). How many jobs can be done at home? 
(No. w26948). National Bureau of Economic Research.
	- Classification of the feasibility of working at home for occupations,
	  constructed from ONET-2010 Work Context
Data and dofiles (Stata) are available to download from:  
https://github.com/jdingel/DingelNeiman-workathome

*******************************
The code for occupation mapping was prepared by the Institute for Structural Research - IBS.
Adjusted version of orginal code retrieved from:
http://ibs.org.pl/en/resources/occupation-classifications-crosswalks-from-onet-soc-to-isco/

In case of using it please include the following citation:

Hardy, W., Keister, R. and Lewandowski, P. (2018). Educational upgrading, structural change and the task composition of jobs in Europe. Economics Of Transition 26.

For details, you can find the paper here: 
https://onlinelibrary.wiley.com/doi/full/10.1111/ecot.12145

*******************************
*/

clear all
estimates clear

cd $data_index

*** Del Rio Chanona et al.(2020)

import delimited "bipartite_industry_occupation_and_variables.csv", clear
ren occupation soc10_name
ren occ_code soc10
ren remote_labor_index rli
ren infection_exposure infect_expo
ren physical_proximity physic_prox

collapse (mean) rli infect_expo physic_prox, by(soc10_name soc10)
replace soc10 = subinstr(soc10, "-", "", 1)
destring soc10, replace
tempfile soc10_delrio
save `soc10_delrio', replace

*** Dingel and Neiman (2020)

import delimited "occupations_workathome.csv", clear
replace onetsoccode = subinstr(onetsoccode, "-", "", 1)
destring onetsoccode, gen(soc10)
replace soc10=int(soc10)
collapse (mean) teleworkable, by(soc10)

merge 1:1 soc10 using `soc10_delrio', nogen
tempfile soc10
save `soc10', replace

//from SOC-10 to SOC-00
use `soc10', clear
	ren soc10 soc2010
	joinby soc2010 using "soc00_soc10.dta"
	collapse (mean) rli infect_expo physic_prox teleworkable, by(soc2000)
	drop if soc2000==.
	ren soc2000 soc00
tempfile soc00
save `soc00', replace

// from SOC-00 to ISCO-88 
use `soc00', clear
	joinby soc00 using "isco88_soc00.dta"
	collapse (mean) rli infect_expo physic_prox teleworkable, by(isco88)
	destring isco88, replace
	drop if isco88==.
save "isco88_rli.dta", replace

// from SOC-10 to ISCO-08
use `soc10', clear
	joinby soc10 using "soc10_isco08.dta"
	collapse (mean) rli infect_expo physic_prox teleworkable, by(isco08)
	destring isco08, replace
	drop if isco08==.
save "isco08_rli.dta", replace

// Manually correct ISCO-88
use "ISCO_88_08.dta", clear
	ren (isco08_4 isco88_4) (isco08 isco88)
	collapse (mean) isco88, by(isco08)
	replace isco88 = int(isco88)
tempfile isco88_08
save `isco88_08'

use "isco08_rli.dta"
merge 1:1 isco08 using `isco88_08', keep(3) nogen
keep if isco88==2142 | isco88==2429 | isco88==3340 | isco88==3474 | ///
		isco88==4144 | isco88==7346 | isco88==8171 | isco88==8286 | ///
		isco88==8321 | isco88==9120 | isco88==9162 | isco88==9212 | ///
		isco88==9321 | isco88==9331 | isco88==9332
collapse (mean) rli infect_expo physic_prox teleworkable, by(isco88)
tempfile isco88
save `isco88', replace

use "isco88_rli.dta", clear
append using `isco88'
save, replace


