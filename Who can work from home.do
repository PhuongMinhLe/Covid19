***********************Who can work from home ?*********************************

	cls
	clear all
	set more off
	capture log close
	estimates clear

use sim_combined.dta
merge m:1 isco88 using isco88_rli.dta

/*

    Result                           # of obs.
    -----------------------------------------
    not matched                        29,360
        from master                    29,061  (_merge==1)
        from using                        299  (_merge==2)

    matched                           143,651  (_merge==3)
    -----------------------------------------

*/ 

gen age_40=.
  replace age_40=0 if age<40
  replace age_40=1 if age>40
  
gen low_rli=.
  replace low_rli=1 if rli<0.6
  replace low_rli=0 if rli>0.6
  
gen HPP=.
  replace HPP=1 if physic_prox>=60
  replace HPP=0 if physic_prox<60

/*Characteristics we want to examine : formal sex age_40 educ r_cog r_man //
nr_man_phys nr_man_pers offshor rti rti_man
________________________________________________________________________________
1 - Saltiel (2020) - "Who can work from Home in Developing Countries ?"

NWFM ij = B0 + B1 Xi + vij

-NWFM ij is a binary variable which equals 1 if workers i in occupation j
cannot work from home
- Xi includes binary variables 
________________________________________________________________________________
*/

global X formal sex age_40 physic_prox infect_expo skill youth public lnearn

  reg low_rli $X [pweight = wgt], robust
  reg low_rli $X [pweight = wgt], vce(cluster isco88)
  coefplot, drop(_cons) xline(0)
  
/*With Fixed-effect 

  xtset isco88
  xtreg low_rli $X , fe
  coefplot, drop(_cons) xline(0) 

________________________________________________________________________________
2 - Mongey & Pilossoph (2020) - "Which Workers Bear the Burden of Social 
Distancing Policies ?"

- LWFH or high-physical proxmity
- Within occupation differences : in other words, the authors examined the
differences of characteristics within an occupation. (I used the cluster, is
it the right way?) 

They provides more detailed information about individuals having low WFH jobs
and high physical proximity jobs
________________________________________________________________________________
*/
*Low Remote Labor Index

  reg low_rli $X [pweight = wgt], robust
  reg low_rli $X [pweight = wgt], vce(cluster isco88)
  coefplot, drop(_cons) xline(0)

*High Physical Proximity
  reg HPP $X [pweight = wgt], robust
  reg HPP $X [pweight = wgt], vce(cluster isco88)
  coefplot, drop(_cons) xline(0)
  
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

reg foreach list of var 

foreach y in formal sex age_40 educ r_cog r_man nr_man_phys nr_man_pers offshor rti rti_man {
       regress `y' low_rli [pweight = wgt], robust  
}

di beta

foreach y in formal sex age_40 educ r_cog r_man nr_man_phys nr_man_pers offshor rti rti_man {
       regress `y' HPP [pweight = wgt], robust  
}

* I want to save the values of B taken in each group to show the differences
*of the characteristics between them.
