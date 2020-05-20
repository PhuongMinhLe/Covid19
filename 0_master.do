/*******************************************************************************
This master file allows to run all dofiles in 1 click.
*******************************************************************************/

	cls
	clear all
	set more off
	capture log close
	estimates clear
		
// create local for date and version tracking

	local c_date = c(current_date)
	local date_string = subinstr("`c_date'", ":", "_", .)
	local date_string = subinstr("`date_string'", " ", "_", .)
	global track_date = c(current_date)
	global track_time = c(current_time)

// globals to manage users
		
	global user 1 /* put 1 for Phuong and 2 for Emilie */

	if $user == 1 {
	global dropbox "C:/Users/Dell/Dropbox"
	global person "Phuong"
	}

	if $user == 2 {
	global dropbox "/Utilisateurs/emiliewojcieszynski294gasyv/Dropbox"
	global person "Emilie"
	}

// define data repository

	global data_index $dropbox/COVID-firmes/Working_files/Data
	global log $dropbox/COVID-firmes/Working_files/Logs
	global dofiles $dropbox/COVID-firmes/Working_files/Scripts
	global tables $dropbox/COVID-firmes/Working_files/Results/Graphs
	global graphs $dropbox/COVID-firmes/Working_files/Results/Tables

// globals for trial or real mode

	global trial 0 /* 
		* 0 if we are not in trial mode
		* 1 if we are in trial mode */

	if $trial ==0 {
		global data_survey $dropbox/Tunisie_ENPE/INS/out/Out_12.05.20/Results/PartA_Descriptive/Tables
		}
	
	if $trial ==1 {
		global data_survey $dropbox/COVID-firmes/Emilie
		}

//run log for commands
	 cd "$log"
	 cap log using Master_`date_string', text replace

********************************************************************************
display "This file started on `c(current_date)' at `c(current_time)' " 
********************************************************************************

* 1. Mapping occupation and activity nomenclatures

do "$dofiles/1_occupation_mapping.do"

do "$dofiles/1_industry_mapping.do"

* 2. Merging the indices with Tunisian data

do "$dofiles/2_merging_Tunisia.do"

* 3. Calculating shock variables

do "$dofiles/3_shock_Tunisia.do"

* 4. Figures and tables

 do "$dofiles/4_figure_table_Tunisia.do"

** End of Dofile
	
display "This file was closed on `c(current_date)' at `c(current_time)' " 

cap log close 

