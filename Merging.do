
/*
________________________________________________________________________________
 1 - There are duplicates within nat09. In the aim to merge with our main sample, 
*we have to drop the duplicates

use essential_tunisia_final.dta 
duplicates report nat09
duplicates list nat09

We will generate and id variable to check the duplicates 

egen id = concat (nat09 essential_New)
duplicates report id

--------------------------------------
   copies | observations       surplus
----------+---------------------------
        1 |          589             0
        2 |          118            59
        3 |           15            10
        4 |            8             6
        5 |           10             8
        7 |            7             6
--------------------------------------

duplicates drop id, force

The file essential_tunisia_final_no_d.dta is now created.
________________________________________________________________________________

*/

* 2 - 

use Book1.dta
merge m:1 isco08 using occupation.dta

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           281
        from master                        89  (_merge==1)
        from using                        192  (_merge==2)

    matched                                88  (_merge==3)
    -----------------------------------------
*/
 
*Merging to have the essential industries depending on Tunisian and Italian cri-
*teria
 
drop _merge
drop if nat09==0
*(1 observation deleted (insignificant weight + was necessary to effectue the merge)

merge m:1 nat09 using essential_tunisia_final_no_d.dta

/*

   Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                               698  (_merge==3)
    -----------------------------------------
*/ 
	
gen isco08_2digit= int(isco08/100)
drop id

rename (isco08 rli infect_expo physic_prox mean_earn median_earn)(occupation remote_labor_index infection_exposure physical_proximity occ_specific_mean_wage occ_specific_median_wage)
drop _merge

order occupation remote_labor_index nat09 nat09_title wgt NAT_2_digit Nat_2_digit_name essential_New isco08_2digit infection_exposure physical_proximity occ_specific_mean_wage occ_specific_median_wage
drop nat09_3digit nat09_2digit

* 3 - We want to add the variable for the shock on the demand side.
