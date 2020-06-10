********************************************************************************
**********************Do-file for making a map of Tunisia***********************
********************************************************************************

* https://www.stata.com/support/faqs/graphics/spmap-and-maps/
* http://www.maplibrary.org/library/stacks/Africa/Tunisia/index.htm
* https://www.data4tunisia.org/fr/datasets/decoupage-de-la-tunisie-geojson-et-shapefile/


********************************************************************************
  
clear all
	set more off
	cap
	estimates clear

// globals to manage users
		
	global user 2 /* put 1 for Phuong and 2 for Emilie */

	if $user == 1 {
	global dropbox "C:/Users/Dell/Dropbox"
	global person "Phuong"
	}

	if $user == 2 {
	global dropbox "/Users/emiliewojcieszynski294gasyv/Dropbox"
	global person = "Emilie"
	}

// define data repository

	global data_index "$dropbox/COVID-firmes/Working_files/Data/Files_map_Tunisia"
	global dofiles "$dropbox/COVID-firmes/Working_files/Scripts"	

*********************Simulation of a dataset************************************

cd
cd "$data_index"
  
*** Package to install

 * ssc install sppack
 * ssc install shp2dta
 * ssc install spmap

  shp2dta using TUN.shp ,database(TUNdb) coordinates(TUNcoord) genid(id) // this command will create TUNdb.dta and TUNcoord.dta
  use TUNdb,clear

*I recoded the variable id in TUN.db so it can match with the coding in the ENPE survey.
/*
   recode id (4=11 "TUNIS") (1=12 "ARIANA") (2=13 "BEN_AROUS") (3=14 "MANOUBA") ///
			(6=15 "NABEUL") (7=16 "ZAGHOUAN") (5=17 "BIZERTE") (8=21 "BEJA") ///
			(9=22 "JENDOUBA") (11=23 "LE_KEF") (10=24 "SILIANA") (18=31 "SOUSSE") ///
			(16=32 "MONASTIR") (15=33 "MAHDIA") (17=34 "SFAX") (12=41 "KAIROUAN") ///
			(13=42 "KASSERINE") (14=43 "SIDI_BOUZIDE") (24=51 "GABES") (25=52 "MEDNINE") ///
			(27=53 "TATAOUINE") (21=61 "GAFSA") (23=62 "TOZEUR") (22=63 "KEBILI"), ///
			gen(id_place1) label(governorate)

*/
  * drop if id_place1==19
  * drop if id_place1==20
  * drop if id_place1==26
   
   
  * drop if ID==20
  * drop if ID==17
  * drop if ID==25
   
   *drop if id==20
   *drop if id==17

   
   
 *  rename id_place1 gouv
   merge 1:1 id using "qgis_id.dta"
  * merge 1:1 id using "qgis_id_Sfax_Mednine.dta"
  * merge 1:m id using "qgis_id_Sfax_Mednine.dta"
			
 *In the package, Sfax and Mendine are coded with two number, respectively 17 18 and 25 26. Sfax is counted 3 times ?
 *by id_place, sort: egen mean_rli=mean(rli)
 
  gen ID_1=_n
  sort ID_1 
  quietly by ID_1 : gen dup = cond(_N==1,0,_n)
  drop if dup>1
  
 * bysort gouv : egen rli_gouv=mean(rli)
 * bysort gouv : egen essential_score_gouv=mean(essential_score)

*** here are different methods for plotting the map, the most used one is clmethod(quantile)

 
  destring Nonteleworkable, replace
  destring Nonteleworkableofprivatesect, replace
  
  replace Nonteleworkable= Nonteleworkable*100
  replace Nonteleworkableofprivatesect= Nonteleworkableofprivatesect*100

  spmap Nonteleworkable using TUNcoord.dta, id(ID_1) fcolor(Blues) clmethod(quantile)
  spmap Nonteleworkableofprivatesect using TUNcoord.dta, id(ID_1) fcolor(Blues) clmethod(quantile)

  
  *spmap Nonteleworkable using TUNcoord.dta, id(ID_1) fcolor(Oranges) clmethod(custom) clbreaks(0 0.644 0.720 0.761 0.789 0.857)
  *spmap Nonteleworkable using TUNcoord.dta, id(ID_1) fcolor(Oranges) clmethod(custom) clbreaks(0 0.60 0.65 0.70 0.75 0.80 0.85 0.90)
  *spmap Nonteleworkableofprivatesect using TUNcoord.dta, id(ID_1) fcolor(Oranges) clmethod(custom)  clbreaks(0 0.25 0.338 0.370 0.426 0.589)
  
  *spmap Nonteleworkable using TUNcoord.dta, id(ID_1) fcolor(Oranges) clmethod(custom) clbreaks(0 60 65 70 75 80 85 90)
  *spmap Nonteleworkableofprivatesect using TUNcoord.dta, id(ID_1) fcolor(Oranges) clmethod(custom)  clbreaks(0 20 30 40 50)

  
   graph save Graph "Map of the mean of RLI by region.gph", replace
   graph export "Map of the mean of RLI by region.png", as(png) replace
