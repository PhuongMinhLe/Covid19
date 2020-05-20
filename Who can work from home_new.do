***********************Who can work from home ?*********************************

clear all
estimates clear

cd $data_index
 
    use sim_combined.dta
    merge m:1 isco88 using isco88_rli.dta
    
*Set the globals

  *Explanatory variables
  global X1 "i.edu"
  global X2 "i.edu i.b2.age_gr3 i.b1.region "
  global X3 "i.edu i.b2.age_gr3 i.b1.region i.b52.isco88_2"
  global X4 "i.sex i.educ earn i.urban i.contract i.formal i.public offshor i.skill i.youth i.marital i.industry" 
  
  *Fixed effect by indutry and governorate
  global fixed_effect "i.industry i.gouv "
 
* Generating variables 

  gen low_rli=.
    replace low_rli=1 if rli<0.24
    replace low_rli=0 if rli>0.24
  
  gen low_teleworkable=.
    replace low_teleworkable=1 if teleworkable <0.33
	replace low_teleworkable=0 if teleworkable >0.33
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
  
  sum $X1 [aw=wgt] if low_teleworkable==1
  sum $X2 [aw=wgt] if low_teleworkable==1
  sum $X3 [aw=wgt] if low_teleworkable==1
  sum $X4 [aw=wgt] if low_teleworkable==1
  sum $X2 i.industry [aw=wgt] if low_teleworkable==1
 
  foreach var of varlist $X4{
   
  asdoc ttest `var', by(low_rli) rowappend
	 
}

  foreach var of varlist $X4{
   
  asdoc ttest `var', by(low_teleworkable) rowappend
	 
}

  bys educ: sum rli [aw=wgt]
  bys sex: sum rli [aw=wgt]
  
  bys educ: sum teleworkable [aw=wgt]
  bys sex: sum teleworkable [aw=wgt]
  
  table public    [aw=wgt], c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table youth     [aw=wgt], c(mean rli mean teleworkable mean earn) format(%4.2f) row
  table urban     [aw=wgt], c(mean rli mean teleworkable mean earn) format(%4.2f) row

* Probit model to assess the significant characteristics of people with low_rli

  probit low_rli $X1 $fixed_effect [pweight = wgt], vce(cluster isco88)
  coefplot, drop(_cons) xline(0)
  graph export $data_index
  
  probit low_rli $X2 $fixed_effect [pweight = wgt], vce(cluster isco88)
  coefplot, drop(_cons) xline(0)
  graph export $data_index
  
  probit low_rli $X3 $fixed_effect [pweight = wgt], vce(cluster isco88)
  coefplot, drop(_cons) xline(0)
  graph export $data_index
  
  probit low_rli i.industry [pweight = wgt], vce(cluster isco88)
  coefplot, drop(_cons) xline(0)
  graph export $data_index
  
  probit low_rli i.isic3_2 [pweight = wgt], vce(cluster isco88)
  coefplot, drop(_cons) xline(0)
  graph export $data_index
  
*Probit model to assess the significant characteristics of people with low_teleworkable index
  
  probit low_teleworkable $X1 $fixed_effect [pweight = wgt], vce(cluster isco88)
  coefplot, drop(_cons) xline(0)
  graph export $data_index
  
  probit low_teleworkable $X2 $fixed_effect [pweight = wgt], vce(cluster isco88)
  coefplot, drop(_cons) xline(0)
  graph export $data_index
  
  probit low_teleworkable $X3 $fixed_effect [pweight = wgt], vce(cluster isco88)
  coefplot, drop(_cons) xline(0)
  graph export $data_index
  
  probit low_teleworkable i.industry [pweight = wgt], vce(cluster isco88)
  coefplot, drop(_cons) xline(0)
  graph export $data_index
  
  probit low_teleworkable i.isic3_2 [pweight = wgt], vce(cluster isco88)
  coefplot, drop(_cons) xline(0)
  graph export $data_index
  
  
