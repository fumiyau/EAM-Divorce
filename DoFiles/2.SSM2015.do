/**********************************************************************/
/*  SECTION 2:Data construction SSM  			
    Notes: */
/**********************************************************************/

/*----------------------------------------------------*/
   /* [>   1.  Winnowing   <] */ 
/*----------------------------------------------------*/
use "SSM/Rawdata/2015ssm_v050a0827.dta", clear
drop id 
gen id=_n+10000
gen survey = 2015

/*----------------------------------------------------*/
   /* [>   2.  Marital status and spouses educational attainment   <] */ 
/*----------------------------------------------------*/
gen sex = q1_1
gen age = q1_2_5
gen marriage = q25
/*現在の結婚：結婚時年齢・学歴*/
gen marage1 = q26 
gen spedu1 = q30
/*再婚の区別（1:初婚, 2:再婚, 8:非該当）*/
gen remarriage = q33

/*離死別者の初婚相手の情報*/
gen spedu2 = q38
gen marage2 = q34
recode spedu1 8/99=.
recode spedu2 8/99=.

/*再婚者の初婚相手の情報*/
gen spedu3 = sq5
gen marage3 = sq1
recode spedu3 8/99=.
gen spjob_re = sq4

/*離死別年齢*/
gen divage = q41 if q25==3
replace divage = sq2_1 if sq2 == 1
recode divage 99/999=.

gen widage = q41 if q25==3
replace widage = sq2_2 if sq2 == 2
recode widage 99/999=.

/*q26とq34を組み合わせた本人初婚年齢（厳密には再婚者を除く必要あり）変数の作成*/
/*q28とq36を組み合わせた配偶者初婚年齢（厳密には再婚者を除く必要あり）変数の作成*/
/*配偶者年齢の男女反転はやや慎重な対応を要する（相手が初婚かわからないので）*/
/*本人初婚年齢は6485ケースが回答*/
recode marage1 888/999=. 99=.
recode marage2 888/999=. 99=.
recode marage3 888/999=. 99=. 88=.

gen marage = marage1
replace marage = marage2 if marage ==.
replace marage = marage3 if remarriage == 2
recode marage 98=. 99=.

/*初婚相手の学歴*/
gen spedu = spedu1
replace spedu = spedu2 if spedu == .
replace spedu = spedu3 if remarriage == 2

/*----------------------------------------------------*/
   /* [>   2.  Respondents information   <] */ 
/*----------------------------------------------------*/
gen edssm = 0
replace edssm = 88 if q18_4 == 0
replace edssm = 4 if q18_4 == 1 & q18_5 == 0 & q18_9 == 0 & q18_8 == 0 & q18_10 == 0 & q18_11 == 0
replace edssm = 5 if q18_5 == 1 & q18_9 == 0 & q18_8 == 0 & q18_10 == 0 & q18_11 == 0
replace edssm = 9 if q18_9 == 1 & q18_8 == 0 & q18_10 == 0 & q18_11 == 0
replace edssm = 8 if q18_8 == 1 & q18_10 == 0 & q18_11 == 0
replace edssm = 10 if q18_10 == 1 & q18_11 == 0
replace edssm = 11 if q18_11 == 1
replace edssm = 99 if q18_99 == 1
replace edssm = 99 if q18_4 == 9  | q18_5 == 9 | q18_9 == 9 | q18_8 == 9 | q18_10 == 9 | q18_11 == 9

/*出生年/出生コーホート*/
gen birth = q1_2_1
replace birth = 1925 + q1_2_3 if birth == 9999 & q1_2_2 == 1
replace birth = 1989 + q1_2_3 if birth == 9999 & q1_2_2 == 2

*結婚年
gen maryear = marage + birth if marage ~=.

/*----------------------------------------------------*/
   /* [>   3.  Recoding variables   <] */ 
/*----------------------------------------------------*/
/*q25とq33を組み合わせた変数の作成*/
/*未婚1　初婚継続2 再婚3 離別4 死別5 7ケースが除外*/
/*6379/6498=98.2%の回答率*/
gen marsta = .
recode marsta . = 1 if marriage == 1 & remarriage == 8
recode marsta . = 2 if marriage == 2 & remarriage == 1
recode marsta . = 3 if marriage == 2 & remarriage == 2
recode marsta . = 4 if marriage == 3 & remarriage == 8
recode marsta . = 5 if marriage == 4 & remarriage == 8

/*marstaを使ってmarflagを立てる。flagが立っていないのは生存と捉えるので、本人の現在の年齢を代入*/
gen marflag = marsta > 1
gen surv = marage
replace surv = q1_2_5 if marflag == 0

/*結婚可能年齢を基準として期間を算出*/
gen period = surv - 18 if q1_1 == 1
replace period = surv - 16 if q1_1 == 2
recode period -1=.
*結婚年コーホート
recode maryear (1949=0)(1950/1959=1)(1960/1969=2)(1970/1979=3)(1980/1989=4)(1990/1999=5)(2000/2010=6)(2011/2015=7),gen(marco)
recode marco 0/3=1 4/7=2, gen(marco2)
recode marco 0/2=1 3/4=2 5/7=3, gen(marco3)
*spedu4: 1中学2高校3短大高専4大卒以上（専門は高卒）
recode spedu (4/5=4) (6=5) (7=6) (9/99=.)
recode spedu 3=2 4=3 5/6=4 .=5,gen(spedu4)
recode spedu 3=2 4/6=3 .=5

gen redu = edssm
recode redu 4=1 5=2 7/9=3 10/11=4 88/99=.,gen(redu4)
recode redu 4=1 5=2 7/9=3 10/11=3 88/99=.

drop if marriage == 1
drop if redu ==.
drop if marage ==. 


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

gen tf = age - marage + 1
expand tf
sort id 
by id: gen length = marage + _n - 1 
gen lyear = length - marage + 1

drop if divage < length & divage~=.

/*----------------------------------------------------*/
   /* [>   5.  Recoding in long dataset   <] */ 
/*----------------------------------------------------*/
gen div=0
recode div 0=1 if divage==length

recode spedu (*=.) if widage < length & widage~=.
gen year=maryear+lyear-1

*子ども数
forvalues i=1/4{
gen cbirth`i' = dq13_`i'_2b+1925 if dq13_`i'_2a == 1
replace cbirth`i' = dq13_`i'_2b+1989 if dq13_`i'_2a == 2
}
gen cnum=0 if dq12==0
replace cnum=1 if year>cbirth1 & cbirth1~=.
replace cnum=0 if cnum==. & cbirth1~=.
replace cnum=2 if year>cbirth2 & cbirth2~=. & cnum==1
replace cnum=3 if year>cbirth3 & cbirth3~=. & cnum==2
replace cnum=4 if year>cbirth4 & cbirth4~=. & cnum==3

/*父学歴*/
gen fedu = q22_a
recode fedu (1/2=1)(3=2)(4/5=3)(6/7=4)(8=1)(9=2)(10/11=3)(12/13=4)(14=.)(99/999=5)

keep maryear div lyear cnum fedu marage spedu redu redu4 spedu4 hom44 marco marco2 marco3 hom sex survey id
append using "SecondaryData/Edited/JSS-EAM-Divorce/NFR-S01.dta"
