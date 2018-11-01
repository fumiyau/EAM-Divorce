cd "/Users/fumiyau/Desktop/"
use "SecondaryData/0400/0400.dta",clear

/**********************************************************************/
/*  SECTION 1:Data construction NFRJ  			
    Notes: */
/**********************************************************************/

/*----------------------------------------------------*/
   /* [>   1.  Winnowing   <] */ 
/*----------------------------------------------------*/
drop NO
gen id=_n
gen survey = 2002
 
/*----------------------------------------------------*/
   /* [>   2.  Marital status and spouses educational attainment   <] */ 
/*----------------------------------------------------*/
gen marriage = Q01
drop if Q37==9
/*再婚の区別（1:初婚, 2:再婚, 8:非該当）*/
gen remarriage = Q18
gen sex = 2
gen age = Q32A
/*1番目の結婚：結婚時年齢・学歴（離死別は問2?問16では、死別、離別なさった夫との結婚について答える。（再婚経験のある場合は最後の夫について））*/
gen marage1 = Q02A 
replace marage1 = Q18_1A if remarriage ==1 

gen marspage1 = Q08A
replace marspage1 = .  if remarriage ==1 

gen spedu1 = Q16
replace spedu1 = Q19_3 if remarriage ==1 
recode spedu1 9=.

/*2番目の相手の情報*/
gen spedu2 = Q16 if remarriage ==1
gen marage2 = Q02A if remarriage ==1
gen marspage2 = Q08A if remarriage ==1

/*離別年齢*/
gen divage = Q17_1A if Q17==1 | Q17==2
gen widage = Q17_2A if Q17==3 | Q17==2

/*----------------------------------------------------*/
   /* [>   2.  Respondents information   <] */ 
/*----------------------------------------------------*/
gen redu = Q37

/*出生年/出生コーホート*/
gen birth = 2002-Q32A2
gen cohort = birth
recode cohort 1921/1929=0 1930/1939 = 1 1940/1949=2 1950/1959=3 1960/1969=4 1970/1979=5 1980/1989=6 1990/1995=7
/*結婚年*/
gen maryear = marage1 + birth if marage1 ~=.

/*----------------------------------------------------*/
   /* [>   3.  Recoding variables   <] */ 
/*----------------------------------------------------*/
recode maryear (1937/1949=0)(1950/1959=1)(1960/1969=2)(1970/1979=3)(1980/1989=4)(1990/1999=5)(2000/2010=6)(2011/2015=7),gen(marco)
recode marco 0/3=1 4/6=2, gen(marco2)
recode marco 0/2=1 3/4=2 5/6=3, gen(marco3)
/*Educational assortative mating*/
gen redu4=redu
gen spedu4=spedu1
recode redu spedu1 spedu2 (3/4=3) (9=5)
/*1"低学歴同類婚"2"高学歴同類婚"3"妻上昇婚"4"妻下降婚"*/

gen hom44=.
replace hom44 = 1 if redu4 == 1 & spedu4 == 1
replace hom44 = 1 if redu4 == 2 & spedu4 == 2
replace hom44 = 2 if redu4 == 3 & spedu4 == 3
replace hom44 = 2 if redu4 == 4 & spedu4 == 4
replace hom44 = 3 if redu4 < spedu4 & redu4 ~=. & spedu4 ~=. & spedu4 ~=5
replace hom44 = 4 if redu4 > spedu4 & redu4 ~=. & spedu4 ~=.

 
/*----------------------------------------------------*/
   /* [>   4.  Expand dataset   <] */ 
/*----------------------------------------------------*/
gen tf = age - marage1 + 1
expand tf
sort id 
by id: gen length = marage1 + _n - 1 
gen lyear = length - marage1 + 1

drop if divage < length & divage~=.
recode spedu1 *=. if widage < length & widage~=.

 
/*----------------------------------------------------*/
   /* [>   5.  Recoding in long dataset   <] */ 
/*----------------------------------------------------*/
gen div=0
recode div 0=1 if divage==length
gen year=maryear+lyear-1
/*子ども数*/
gen cnum=1 if year>Q24_1A2S & Q24_1A2S~=.
replace cnum=0 if cnum==. & Q24_1A2S~=0
replace cnum=2 if year>Q24_1B2S & Q24_1B2S~=. & cnum==1
replace cnum=3 if year>Q24_1C2S & Q24_1C2S~=. & cnum==2
replace cnum=4 if year>Q24_1D2S & Q24_1D2S~=. & cnum==3
replace cnum=5 if year>Q24_1E2S & Q24_1E2S~=. & cnum==4
*父学歴（中学、高校、短大高専、大卒、わからない）
gen fedu =Q38 if Q38~=9

 
/*----------------------------------------------------*/
   /* [>   6.  Keeping variables for merge   <] */ 
/*----------------------------------------------------*/
keep div maryear lyear cnum fedu marage1 spedu1 redu redu4 spedu4 marco marco2 marco3 hom44 sex survey id
rename spedu1 spedu
rename marage1 marage


save "SecondaryData/Edited/JSS-EAM-Divorce/NFR-S01.dta",replace

/*------------------------------------ End of SECTION 1 -------------------------------*/

