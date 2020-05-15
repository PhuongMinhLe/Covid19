
/*
________________________________________________________________________________

  The aim of this do-file is to merge the nat09_ISIC4.dta with the essential 
italian industries for, in fine, merging it with our sample.

________________________________________________________________________________

Explanations on how I achived   merge m:1 isic using ISIC_Italy_essential_w_d.dta

/*

use nat09_ISIC4.dta
merge 1:m isic using ISIC_Italy_essential.dta 

drop if isic==.
*(15 observations deleted)
* we will add them later.

* After dropping the isic==. we have the new dataset ISIC_Italy_essential_w.dta

  merge m:1 isic using ISIC_Italy_essential_w.dta

*We will create an id_code to check for duplicates.

  egen id = concat (isic essential_2digit)
  duplicates report id
  

--------------------------------------
   copies | observations       surplus
----------+---------------------------
        1 |          303             0
        2 |          140            70
        3 |           39            26
        4 |           44            33
        5 |           25            20
        6 |           24            20
        9 |           18            16
--------------------------------------



  duplicates drop id, force
    
*save as ISIC_Italy_essential_w_d.dta 
*So now we only have isic industries with two value for essential_new.

  duplicates list isic



  +----------------------+
  | group:   obs:   isic |
  |----------------------|
  |      1     64   1399 |=1
  |      1     65   1399 |
  |      2     66   1410 |
  |      2     67   1410 |
  |      3     98   2310 |
  |----------------------|
  |      3     99   2310 |
  |      4    112   2512 |
  |      4    113   2512 |
  |      5    119   2599 |
  |      5    120   2599 |
  |----------------------|
  |      6    146   2819 |
  |      6    147   2819 |
  |      7    154   2829 |
  |      7    155   2829 |
  |      8    174   3290 |
  |----------------------|
  |      8    175   3290 |
  |      9    210   4649 |
  |      9    211   4649 |
  |     10    215   4659 |
  |     10    216   4659 |
  |----------------------|
  |     11    267   5510 |
  |     11    268   5510 |
  +----------------------+
  


For thoses cases, there are defined as essential and not essentiaL. For instance,
if isic 1410, it's coded such as "Manufacture of wearing apparel, except fur apparel"
but in nace it's refers to 14.11 and 14.12.

14.11 : Manufacture of leather clothes
14.12 : Manufacture of workwear

The first one is not essential but the second one is essential. Hence, we assume
that 1410 in ISIC is essential

duplicates report isic

--------------------------------------
   copies | observations       surplus
----------+---------------------------
        1 |          394             0
        2 |            6             3
--------------------------------------
-> 1399, 2819 and 5510

*/

destring id, replace

  drop if id==14100
  drop if id==23100
  drop if id==25120
  drop if id==25990
  drop if id==28290
  drop if id==32900
  drop if id==46490
  drop if id==46590
  drop if id==51100

*After I checked for duplicates in isic, there are theses remaining still.

  drop if id==13990
  drop if id==28190
  drop if id==55100

*/ 

  merge m:1 isic using ISIC_Italy_essential_w_d.dta
  
/* 

    Result                           # of obs.
    -----------------------------------------
    not matched                            24
        from master                        24  (_merge==1)
        from using                          0  (_merge==2)

    matched                               638  (_merge==3)
    -----------------------------------------

*/

