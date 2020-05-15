************************Do-file for the first graph*****************************
	
	cls
	clear all
	set more off
	capture log close
	estimates clear

***Setting the data***

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
   drop _merge
   merge m:1 isic3_2 using essential_isic2.dta
  
/*

    Result                           # of obs.
    -----------------------------------------
    not matched                           299
        from master                       299  (_merge==1)
        from using                          0  (_merge==2)

    matched                           172,712  (_merge==3)
    -----------------------------------------
	
*/

***Computing the weight

  preserve
  
  keep if year==2017

*** Firstly, we compute the share of workers in essential industries***

    keep if essential_new1 ==1
    gen total=_N
    by isco88_2, sort: generate freq = _N
    by isco88_2: generate share = freq / total

***Secondly, we compute the weight of industry and occupations**

*** MPL: since we work at 4-digit occupation level, collapse with pweight should be used here
		// collapse (mean) with rli, wage and other index - pweight
		// collapse (rawsum) with wgt observations - sum no weight
    
	egen occupation_wgt= total(wgt), by (isco88)
    *egen industry_wgt= total(wgt), by(isic3_2)
    *egen essential_wgt = total(wgt), by(essential)
	
***Thridly, we will generate a categorical variable for assessing earnins

     gen lnearn1=.
	 replace lnearn1=1 if 0<=lnearn & lnearn <1
	 replace lnearn1=2 if 1<=lnearn & lnearn <2
	 replace lnearn1=3 if 2<=lnearn & lnearn <3
	 replace lnearn1=4 if 3<=lnearn & lnearn <4
	 replace lnearn1=5 if 4<=lnearn & lnearn <5
	 replace lnearn1=6 if 5<=lnearn & lnearn <6
	 
	 gen lnearn2=.
	 replace lnearn2=0 if 0<=lnearn & lnearn <4
	 replace lnearn2=1 if 4<=lnearn & lnearn <6
	
***Lastly, we plot the graph***

    twoway (scatter share rli [aweight = occupation_wgt], mcolor(navy8) msymbol(smcircle_hollow) ///
    ytitle(Share of workers in essential sectors) xtitle(Remote Labor Index))  //

* With 2 colors 
* Comment : it's strange because I put in the code that I want to mark earning 
*by category but all the colors I coded doesn't show up.. *** MPL : Because earn/lnearn is a simulated variable
																	// they does vary across occupation

    twoway (scatter share rli [aweight = occupation_wgt] if lnearn2==0, mcolor(red) ///
	msymbol(smcircle_hollow)) (scatter share rli [aweight = occupation_wgt] if ///
	lnearn2==1, mcolor(ebblue) msymbol(smcircle_hollow)) //
  
    *Essai 1 
    twoway (scatter share rli [aweight = occupation_wgt] if lnearn2==0, mcolor(red) ///
	msymbol(smcircle_hollow))  //
	ytitle(Share of workers in essential sectors) xtitle(Remote Labor Index))//
	(scatter share rli [aweight = occupation_wgt] if lnearn2==1, mcolor(blue) //
	msymbol(smcircle_hollow)) ,scheme(s1color) //
	
    *Essai 2
	twoway (scatter share rli if lnearn2==0 [w = occupation_wgt], mcolor(red) ///
	msymbol(smcircle_hollow)) //
	(scatter share rli if lnearn2==1, [w = occupation_wgt] mcolor(blue) //
	msymbol(smcircle_hollow)), scheme(s1color) //
    ytitle(Share of workers in essential sectors) xtitle(Remote Labor Index))//
	
* With five colors

    twoway (scatter share rli [aweight = occupation_wgt] if lnearn1==1, mcolor(ebg) ///
	msymbol(smcircle_hollow)) (scatter share rli [aweight = occupation_wgt] if ///
	lnearn1==2, mcolor(ebblue) msymbol(smcircle_hollow)) //
	(scatter share rli [aweight = occupation_wgt] if lnearn1==3, mcolor(edkblue) ///
	msymbol(smcircle_hollow))(scatter share rli [aweight = occupation_wgt] if ///
	lnearn1==4, mcolor(eltblue) msymbol(smcircle_hollow))
	(scatter share rli [aweight = occupation_wgt] if lnearn1==5, mcolor(eltgreen) ///
	msymbol(smcircle_hollow))(scatter share rli [aweight = occupation_wgt] if ///
	lnearn1==6, mcolor(emidblue) msymbol(smcircle_hollow)), scheme(s1color) //
	ytitle(Share of workers in essential sectors) xtitle(Remote Labor Index))  //
	
	
*** Command for adding gradient colors for markers to assess wages by occupation :
*(but it doesn't take in consideration the weights of the subsample of observations.

    colorscatter share rli earn
    colorscatter share rli earn, scatter_options(pweights = occupation_wgt)
	
  restore
	
	 

	
