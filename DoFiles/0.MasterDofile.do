log using `"/Users/fumiyau/Documents/GitHub/EAM-Divorce/Log/`path'JSS_EAMDivorce`=subinstr("`c(current_date)'"," ","",.)'.smcl"', replace
set more off
do "/Users/fumiyau/Documents/GitHub/EAM-Divorce/DoFiles/1.NFR-S01.do"
do "/Users/fumiyau/Documents/GitHub/EAM-Divorce/DoFiles/2.SSM2015.do"
do "/Users/fumiyau/Documents/GitHub/EAM-Divorce/DoFiles/3.Analysis.do"
do "/Users/fumiyau/Documents/GitHub/EAM-Divorce/DoFiles/4.Prediction.do"
log close
