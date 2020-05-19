***********************Who can work from home ?*********************************

	cls
	clear all
	set more off
	capture log close
	estimates clear

********************************************************************************

*Phuong, I hope this command will work for you:

    global path_emilie Dropbox/COVID-firmes/Emilie
    global isco88_rli.dta $path_emilie/isco88_rli.dta
    use $path_emilie/sim_combined.dta, clear
    merge m:1 isco88 using $isco88_rli.dta
 
 *Otherwise:
 
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

*Set the globals

  *Explanatory variables
  global X1 "i.edu"
  global X2 "i.edu i.b2.age_gr3 i.b1.region "
  global X3 "i.edu i.b2.age_gr3 i.b1.region i.b52.isco88_2"
  global X4 "sex educ earn urban contract formal public offshor skill youth non_youth marital position status industry" 
  
  *Fixed effect by indutry and governorate
  global fixed_effect "i.industry i.gouv "
 
* Generating variables 

  gen age_40=.
    replace age_40=0 if age<40
    replace age_40=1 if age>40
  
  gen low_rli=.
    replace low_rli=1 if rli<0.6
    replace low_rli=0 if rli>0.6
  
  gen non_youth=.
    replace non_youth=1 if youth==2
    replace non_youth=0 if youth==1
  
  gen rural=.
    replace rural=1 if urban==2
    replace rural=0 if urban==1
	
/*

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

foreach y in formal sex age_40 educ r_cog r_man nr_man_phys nr_man_pers offshor rti rti_man {
       regress `y' low_rli [pweight = wgt], robust 
	   matrix coef_1_=e(b)'
	   regress `y' low_rli [pweight = wgt] if low_rli==1 , robust 
} 
_______________________________________________________________________________


* Descriptive analysis on low_rli and high_rli

  sum $X1 [aw=wgt] if low_rli==1
  sum $X2 [aw=wgt] if low_rli==1
  sum $X3 [aw=wgt] if low_rli==1
  sum $X2 i.industry [aw=wgt] if low_rli==1
 
  foreach var of varlist $X4{
   
  asdoc ttest `var', by(low_rli) rowappend
	 
}

  sum rli [aw=wgt] if educ==1
  sum rli [aw=wgt] if educ==2
  sum rli [aw=wgt] if educ==3
  sum rli [aw=wgt] if educ==4
  
  sum rli [aw=wgt] if sex==1
  sum rli [aw=wgt] if sex==2
  
  table public    [aw=wgt], c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table youth     [aw=wgt], c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table urban     [aw=wgt], c(mean rli mean teleworkable mean earn) format(%4.2f) row

* Probit model to assess the significant characteristics of people with low_rli

  probit low_rli $X1 $fixed_effect [pweight = wgt], vce(cluster isco88)
  coefplot, drop(_cons) xline(0)
  probit low_rli $X2 $fixed_effect [pweight = wgt], vce(cluster isco88)
  coefplot, drop(_cons) xline(0)
  probit low_rli $X3 $fixed_effect [pweight = wgt], vce(cluster isco88)
  coefplot, drop(_cons) xline(0)
  
  probit low_rli i.industry [pweight = wgt], vce(cluster isco88)
  coefplot, drop(_cons) xline(0)
  probit low_rli i.isic3_2 [pweight = wgt], vce(cluster isco88)
  coefplot, drop(_cons) xline(0)
  
  
/*

********************************************************************************
  
/*
  
sum rli [aw=wgt] if educ==1
 
    Variable |     Obs      Weight        Mean   Std. Dev.       Min        Max
-------------+-----------------------------------------------------------------
         rli |  12,921  486061.372    .1956754   .1211795          0   .9090909

sum rli [aw=wgt] if educ==2
		 
    Variable |     Obs      Weight        Mean   Std. Dev.       Min        Max
-------------+-----------------------------------------------------------------
         rli |  52,982  1982089.19    .1910554    .125383          0   .9090909
		 
	 sum rli [aw=wgt] if educ==3
		 
    Variable |     Obs      Weight        Mean   Std. Dev.       Min        Max
-------------+-----------------------------------------------------------------
         rli |  58,056  2177231.94     .251764   .1856038          0   .9090909
		 
sum rli [aw=wgt] if educ==4

    Variable |     Obs      Weight        Mean   Std. Dev.       Min        Max
-------------+-----------------------------------------------------------------
         rli |  19,692  740270.943    .4897033   .1883278          0   .9090909
		 
sum rli [aw=wgt] if sex==1	 
		 

    Variable |     Obs      Weight        Mean   Std. Dev.       Min        Max
-------------+-----------------------------------------------------------------
         rli | 106,729  4004996.09    .2396311    .175729          0   .9090909
		 

sum rli [aw=wgt] if sex==2


    Variable |     Obs      Weight        Mean   Std. Dev.       Min        Max
-------------+-----------------------------------------------------------------
         rli |  36,922  1380657.35    .3076356   .2114376          0   .9090909



********************************************************************************

 sum $X2 [aw=wgt] if low_rli==1

 - Table 1 - Descriptive analysis of workers with low remote labor index (under 60)

    Variable |     Obs      Weight        Mean   Std. Dev.       Min        Max
-------------+-----------------------------------------------------------------
        educ |
          2  | 132,232  4960566.94    .3930691   .4884338          0          1
          3  | 132,232  4960566.94     .399176   .4897309          0          1
          4  | 132,232  4960566.94    .1102662   .3132225          0          1
             |
     age_gr3 |
      15-24  | 132,232  4960566.94    .2003922   .4002954          0          1
      45-64  | 132,232  4960566.94     .396755   .4892262          0          1
             |
      region |
 North-West  | 132,232  4960566.94    .1662616   .3723167          0          1
Centre-East  | 132,232  4960566.94    .1655844   .3717085          0          1
-------------+-----------------------------------------------------------------
Centre-West  | 132,232  4960566.94    .1667945   .3727937          0          1
 South-East  | 132,232  4960566.94    .1675998   .3735119          0          1
 South-West  | 132,232  4960566.94     .166799   .3727978          0          1

********************************************************************************

Two-sample t test with equal variances 

  	                    obs1 obs2  Mean1 	Mean2 	  dif 	St_Err 	t_value p_value
						
 sex by low rli: 0 1	40480	132232	1.31	1.243	  .068	.003	  27.2	0
 educ by low rli: 0 1	40480	132232	3.092	2.522	  .571	.004	 123.55	0
 earn by low rli: 0 1	40480	132232	123.34	84.057	39.282	.262	 149.8	0
 urban by low rli: ~1	40480	132232	1.504	1.5	  .004	.003	   1.4	 .155
 contract by low rl~1	40480	132232	1.996	1.998	 -.002	.004	   -.35	 .737
 formal by low rli:~1	40480	132232	1.502	1.501	  .002	.003	    .55	 .566
 public by low rli:~1	40480	132232	1.5	1.5	  .002	.003	    .45	 .64
 offshor by low rli~1	40480	132232	.32	 .059	  .261	.005	  54.25	0
 skill by low rli: ~1	40480	132232	1.583	2.301	 -.719	.004	-193.95	0
 youth by low rli: ~1	40480	132232	1.702	1.7	  .003	.003	    .85	 .387
 marital by low rli~1	40480	132232	2.503	2.501	  .003	.006	    .4	 .686
 position by low rl~1	40480	132232	3	3	      0     	0	    .	 .
 status by low rli:~1	40480	132232	1	1	      0	        0	    .	 .
 sector by low rli:~1	40480	132232	3.013	3.002	  .01   .008       1.25	 .209

********************************************************************************

----------------------------------------------------------
Public    |
sector    |      mean(rli)  mean(telewo~e)      mean(earn)
----------+-----------------------------------------------
   Public |           0.26            0.25           93.57
  Private |           0.26            0.24           93.06
          | 
    Total |           0.26            0.24           93.31
----------------------------------------------------------

----------------------------------------------------------
    Youth |      mean(rli)  mean(telewo~e)      mean(earn)
----------+-----------------------------------------------
    Youth |           0.26            0.25           93.28
Non-youth |           0.26            0.24           93.33
          | 
    Total |           0.26            0.24           93.31
----------------------------------------------------------

----------------------------------------------------------
Residence |
area      |      mean(rli)  mean(telewo~e)      mean(earn)
----------+-----------------------------------------------
    Urban |           0.26            0.24           93.01
    Rural |           0.26            0.25           93.61
          | 
    Total |           0.26            0.24           93.31
----------------------------------------------------------

*/

  

