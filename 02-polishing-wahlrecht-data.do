* --------------------------------------------------------
* Forecasting the 2013 German Bundestag Election 
* Using Many Polls and Historical Election Results
*
* Peter Selb and Simon Munzert
* --------------------------------------------------------

clear
use "data\data_wahlrecht.dta", clear


* DATA MANAGEMENT
* Missings
rename actual_votes actual
recode actual (999=.)
drop if actual==.&election!=2013
drop if forecast==.
drop if date==.

* Correct codings
replace sample_size = 1500 if sample_size == 15

* Percent to proportions
gen vote=actual/100
gen poll=forecast/100

* Recode parties
recode party (3=1) (12=2) (5=3) (6=4) (4=5) (nonm=6), gen(party2)
lab def party2 1"CDU/CSU" 2"SPD" 3"B'90/Die Grünen" 4"Die Linke" 5"FDP" 6"Others"
lab val party2 party2

* Drop duplicates
duplicates tag institute date party poll, gen(dupl)
tab dupl
duplicates drop institute date party poll, force
drop dupl

* Format date
format date %td 

* Collapse data to sum votes for parties classified as 'Other'
collapse (sum) vote poll (mean) sample_size, by(election party2 institute date) 

sum vote
sum poll
recode vote (0=.)

* Labels
* rename party2 party
rename party2 party
lab var party Party
rename sample_size N
lab var N "Sample size"
lab var vote "Actual vote share"
lab var poll "Vote share in poll"
lab var date Date
lab var election Election
lab var institute "Polling firm"
lab drop institute
lab define institute 1"IfD Allensbach" 2"TNS Emnid" 3"Forsa" 4"F'gruppe Wahlen" 5"GMS" 6"Infratest Dimap"
lab val institute institute

* Election date
gen str11 edate2=""
replace edate2="27 Sep 1998" if election==1998
replace edate2="22 Sep 2002" if election==2002
replace edate2="18 Sep 2005" if election==2005
replace edate2="27 Sep 2009" if election==2009
replace edate2="22 Sep 2013" if election==2013
gen edate=date(edate2,"DMY")
lab var edate "Election date"
drop edate2

gen daystoelec = edate - date
sort date
save "data/wahlrecht_prep.dta", replace
