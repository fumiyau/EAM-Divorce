
/**********************************************************************/
/*  SECTION 3: Recoding integrated dataset  			
    Notes: */
/**********************************************************************/

cd "/Users/fumiyau/Documents/GitHub/EAM-Divorce/Results"
*分析を女性に限定
drop if sex == 1
drop if spedu4==5
*SSM2015では子ども数が5人までのため丸める
recode cnum 5=4
*結婚年齢ダミーの作成
recode marage 16/22=1 23/25=2 26/28=3 29/31=4 32/61=5, gen(marcat)
*16歳以下は削除
drop if marage < 16
*ダミー変数作成
tabulate redu4,gen(redu4)
tabulate spedu4,gen(spedu4)
*学歴4分類で上昇婚基準
tabulate hom44,gen(hom44)
tabulate redu,gen(redu3)
tabulate spedu,gen(spedu3)
tabulate survey,gen(surveyd)
tabulate marcat,gen(marcat)
*父高専卒がいないため統合
recode fedu 4=3 2=1
tabulate fedu,gen(fedu)
recode maryear (1937/1949=.)(1950/1964=1)(1965/1979=2)(1980/1994=3)(1995/2010=4)(2011/2015=.),gen(marcox)
tabulate marcox,gen(marcox)
***Sample restriction***
drop if marco==7 | marco==0
keep if marage<49 & lyear < 25
keep if marcox~=.
/*------------------------------------ End of SECTION 3 ------------------------------------*/


/**********************************************************************/
/*  SECTION 4: Labeling 			
    Notes: */
/**********************************************************************/

lab var div"離別イベント"
lab var redu41"本人中学卒"
lab var redu42"本人高校卒"
lab var redu43"本人短大高専卒"
lab var redu44"本人四大卒以上"
lab var spedu41"配偶者中学卒"
lab var spedu42"配偶者高校卒"
lab var spedu43"配偶者短大高専卒"
lab var spedu44"配偶者四大卒以上"
lab var hom441"低学歴同類婚"
lab var hom442"高学歴同類婚"
lab var hom443"妻上昇婚"
lab var hom444"妻下降婚"
lab var marcat1"結婚年齢16-22歳"
lab var marcat2"結婚年齢23-25歳"
lab var marcat3"結婚年齢26-28歳"
lab var marcat4"結婚年齢29-31歳"
lab var marcat5"結婚年齢32歳以上"
lab var surveyd2"2015年調査ダミー"
lab var fedu1"父親高校卒以下"
lab var fedu2"父親高等教育卒"
lab var fedu3"父親最終学歴不明"
lab var lyear"初婚からの経過年数（時変）"
lab var marcox1"結婚年コーホート（1950-1964年）"
lab var marcox2"結婚年コーホート（1965-1979年）"
lab var marcox3"結婚年コーホート（1980-1994年）"
lab var marcox4"結婚年コーホート（1995-2010年）"

/*------------------------------------ End of SECTION 4 ------------------------------------*/

/**********************************************************************/
/*  SECTION 5: Results output 			
    Notes: */
/**********************************************************************/


 
/*----------------------------------------------------*/
   /* [>   1.  Table 1   <] */ 
/*----------------------------------------------------*/
keep id div redu4 spedu4 redu41 redu42 redu43 redu44 spedu41 spedu42 spedu43 spedu44 hom44 hom441 hom442 hom443 hom444 marcat1 marcat2 marcat3 marcat4 marcat5 surveyd2 fedu1 fedu2 fedu3 marage lyear marcox marcox1 marcox2 marcox3 marcox4 
mark nomiss
markout nomiss redu41 redu42 redu43 redu44 spedu41 spedu42 spedu43 spedu44 hom44 hom441 hom442 hom443 hom444 marcat1 marcat2 marcat3 marcat4 marcat5 surveyd2 fedu1 fedu2 fedu3 marage lyear marcox marcox1 marcox2 marcox3 marcox4
drop if nomiss == 0
quietly estpost tabstat div redu41 redu42 redu43 redu44 spedu41 spedu42 spedu43 spedu44 hom441 hom442 hom443 hom444 marcat1 marcat2 marcat3 marcat4 marcat5 surveyd2 fedu1 fedu2 fedu3 marcox1 marcox2 marcox3 marcox4 lyear, statistics(mean sd max min) columns(statistics)
quietly esttab . using "Descriptive/devsc.csv", replace cells("mean(fmt(3)) sd(fmt(3)) min max(fmt(3))") noobs nonote label

/*----------------------------------------------------*/
   /* [>   2.  Table 2   <] */ 
/*----------------------------------------------------*/
forvalues i=1/4{
tabout redu4 spedu4 if lyear ==1 & marcox==`i' using "Bivariate/crosstabx`i'.txt",replace
}

/*----------------------------------------------------*/
   /* [>   3.  Figure 1   <] */ 
/*----------------------------------------------------*/
ta hom44 marcox if lyear == 1,col

/*----------------------------------------------------*/
   /* [>   4.  Table 2   <] */ 
/*----------------------------------------------------*/
*記述的なグラフ
*イベントヒストリー・セット
stset lyear, failure(div==1) id(id)
rename hom44 assortative
sts graph if marage <49   & lyear <25, cumhaz by(marcox)ytitle("離婚経験率")title("結婚年コーホート")xtitle("初婚からの経過年数")legend(ring(0) position(10) cols(1) rows(4) order(1 2 3 4) label(1 "1950-1964年") label(2 "1965-1979年") label(3 "1980-1994年")  label(4 "1995-2010年")  ) saving(Fig/KMdivorceMarco.gph,replace) plot1opts(lcolor(gs5))plot4opts(lcolor(black)lpattern(dash_dot)) caption("出所：NFRJ-S01，SSM2015データより筆者推計",span)
sts test marcox
sts graph if marage <49   & lyear <25, cumhaz by(assortative)ytitle("　")title("学歴結合")xtitle("初婚からの経過年数")legend(ring(0) position(10) cols(1) rows(4) order(1 2 3 4) label(1 "高学歴同類婚") label(2 "低学歴同類婚") label(3 "妻上昇婚")  label(4 "妻下降婚")  ) saving(Fig/KMdivorceAssortative.gph,replace) plot1opts(lcolor(gs5))plot4opts(lcolor(black)lpattern(dash_dot)) caption("　",span)
sts test assortative
graph combine "Fig/KMdivorceMarco.gph" "Fig/KMdivorceAssortative.gph", saving("Fig/KM-sex.gph",replace)
graph export "Fig/KM-sex.pdf",replace

/*----------------------------------------------------*/
   /* [>   5.  Table 3   <] */ 
/*----------------------------------------------------*/

local vars1 "surveyd2 marcat2 marcat3 marcat4 marcat5 fedu2 fedu3 marcox1 marcox3 marcox4"
local vars2 "redu41 redu42 redu43 spedu41 spedu42 spedu43"


qui stcox hom444 `vars1'
est sto ModelA1
qui stcox hom444 `vars1' `vars2'
est sto ModelA2
qui stcox hom441 hom442 `vars1'
est sto ModelB1
qui stcox hom441 hom442 `vars1' `vars2'
est sto ModelB2
esttab ModelA1 ModelA2 ModelB1 ModelB2  using "Regression/Baseline.csv", se scalar(N chi2 df_m ll aic r2_p) star(# 0.1 * 0.05 ** 0.01 *** 0.001) b(3)  replace label  wide noomitted title(Determinants of second childbirth (left: adjusted right: observed))


/*----------------------------------------------------*/
   /* [>   6.  Figure 3   <] */ 
/*----------------------------------------------------*/
forvalues i=1/4{
forvalues j=1/4{
gen redu4`i'marco`j'=0
gen spedu4`i'marco`j'=0
replace redu4`i'marco`j'=1 if redu4==`i' & marcox==`j'
replace spedu4`i'marco`j'=1 if spedu4==`i' & marcox==`j'
}
}
order redu41marco1 redu41marco2 redu41marco3 redu41marco4 redu42marco1 redu42marco2 redu42marco3 redu42marco4 redu43marco1 redu43marco2 redu43marco3 redu43marco4 redu44marco1 redu44marco2 redu44marco3 redu44marco4
order spedu41marco1 spedu41marco2 spedu41marco3 spedu41marco4 spedu42marco1 spedu42marco2 spedu42marco3 spedu42marco4 spedu43marco1 spedu43marco2 spedu43marco3 spedu43marco4 spedu44marco1 spedu44marco2 spedu44marco3 spedu44marco4

***If reference is marco == 2
qui stcox c.hom444##c.marcox1 c.hom444##c.marcox3 c.hom444##c.marcox4 surveyd2 marcat2 marcat3 marcat4 fedu2 fedu3 redu41 redu42 redu43 spedu41 spedu42 spedu43 redu41marco3 redu41marco4 redu42marco3 redu42marco4 redu43marco3 redu43marco4 spedu41marco1 spedu41marco3 spedu41marco4 spedu42marco1 spedu42marco3 spedu42marco4 spedu43marco1 spedu43marco3 spedu43marco4
est sto Model1
qui stcox c.hom441##c.marcox1 c.hom441##c.marcox3 c.hom441##c.marcox4 c.hom442##c.marcox3 c.hom442##c.marcox4 surveyd2 marcat2 marcat3 marcat4 fedu2 fedu3 redu41 redu42 redu43 spedu41 spedu42 spedu43 redu41marco3 redu41marco4 redu42marco3 redu42marco4 redu43marco3 redu43marco4 spedu41marco1 spedu41marco3 spedu41marco4 spedu42marco1 spedu42marco3 spedu42marco4 spedu43marco1 spedu43marco3 spedu43marco4
est sto Model2
esttab Model1 Model2 using "Regression/Interaction.csv", se scalar(N chi2 df_m ll aic r2_p) star(# 0.1 * 0.05 ** 0.01 *** 0.001) b(3)  replace label  wide noomitted title(Determinants of second childbirth (left: adjusted right: observed))

/*------------------------------------ End of SECTION 5 ------------------------------------*/



