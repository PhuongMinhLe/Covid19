************************Do-file for the first graph*****************************
********* The impact of supply side and demand side on occupations**************
********************************************************************************

	cls
	clear all
	set more off
	capture log close
	estimates clear

***Setting the data***

   use sim_combined.dta
   merge m:1 isco88 using isco88_rli.dta
   drop _merge
   merge m:1 isic3_2 using essential_isic2.dta
   drop _merge
   merge m:1 isic3_2 using isic_demand_shock_d.dta
  
*** Computing the weight of the occupations

  egen occupation_wgt= total(wgt), by (isco88)
		
/*

    Result                           # of obs.
    -----------------------------------------
    not matched                        20,597
        from master                    20,566  (_merge==1)
        from using                         31  (_merge==2)

    matched                           152,146  (_merge==3)
    -----------------------------------------


On the basis of the working file of Del-Rio, we will compute the supply shock and
the demand shock on occupation as follow : 

*/

* 1 - Aggregate information by occupation


  gen occ_employment_essential= occupation_wgt if essential==1
  
  gen occ_employment_tot= occupation_wgt

  gen occ_essential = occ_employment_essential/occ_employment_tot
  
*  2 - Computing the shock by supply side and demand side.

  gen occ_supply_shock = (1 - occ_employment_essential/occ_employment_tot) *  (1 - rli)
	
  gen occ_demandshock = (1 - severe_demand_shock/occ_employment_tot)


*Language Python que je n'ai pas pu traduire.

  * occ_overall_shock = np.maximum(np.maximum(occ_demandshock, 0), occ_supply_shock)

  * occ_overall_shock_incpos = np.maximum(occ_demandshock, occ_supply_shock) + np.minimum(occ_demandshock, 0)

 twoway (scatter occ_supply_shock occ_demandshock [aweight = occupation_wgt], mcolor(navy8) msymbol(smcircle_hollow) ///
    ytitle(Supply shock) xtitle(Demand shock))  //


 
