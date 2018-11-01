

/**********************************************************************/
/*  SECTION 6: Prediction			
    Notes: */
/**********************************************************************/
import delimited "/Users/fumiyau/Documents/GitHub/EAM-Divorce/Results/Regression/Prediction.csv",clear
forvalues i=1/3{
qui reg score i.year  if type==`i'
estpost margins year if type==`i'
est sto model`i'
}

label define yearl 1"1950-1964年"	2"1965-1979年"	3"1980-1994年"	4"1995-2010年",replace
label values year yearl 

*marker option : https://www.stata.com/manuals13/g-3marker_options.pdf#g-3marker_options
*line option : https://www.stata.com/manuals13/g-4linepatternstyle.pdf#g-4linepatternstyle
*http://www.bruunisejs.dk/StataHacks/Coding%20Stata/coefplot/estimates_into_Stata_matrix_and_using_coefplot/
generate lbl=""
coefplot (model1, label(妻下降婚（vsその他）) lcolor(gs3) lpattern(solid) recast(connected) msymbol(T) mcolor(gs3)) ///
(model2, label(高学歴同類婚（vs異類婚）) lcolor(gs3) lpattern(solid) recast(connected) msymbol(O) mcolor(gs3)) ///
(model3, label(低学歴同類婚（vs異類婚）) lcolor(gs3) lpattern(solid) recast(connected) msymbol(Oh) mcolor(gs3))  ///
, generate mlabel(lbl) mlabpos(12) vert offset(0) noci scheme(s1mono) legend(row(2) size(small) rowgap(small))  ///
ylabel(-1.25(0.5)1.25, nogrid) xlabel(,nogrid) ytitle(係数) xtitle(結婚年コーホート) yline(0, lpattern(dash)lcolor(gray))  ///
note("出所：NFRJ-S01・SSM2015データより筆者推計" "注1：下降婚モデルと同類婚モデルにおける基準カテゴリーは異なる．""注2：低学歴同類婚の1995-2010年の係数は-.057") ///
saving(Fig/g1,replace)
replace lbl=string(__b)
replace lbl="." if lbl=="-.057"
`r(graph)'
graph export /Users/fumiyau/Documents/GitHub/EAM-Divorce/Results/Fig/Prediction.pdf,replace 





/*------------------------------------ End of SECTION 6 ------------------------------------*/
