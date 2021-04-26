* Read in dataset and describe
use "crime4.dta", clear
describe

gen lpolpc1=lpolpc- clpolpc

*It is clear from the problem that variables we are interested in are:
*crimes committed per person,  lcrmrte
*'probability' of arrest lprbarr
* 'probability' of conviction lprbconv
* 'probability' of prison sentenc lprbpris
* avg. sentence, days lavgsen

*I would probably also include police per capita as a measure of anti-stimulus for crime commitment lpolpc
*Everything would be measured inb logarithms for more convenient interpretation.

*#1 Descriptive statistics

* Summary of dataset
summarize

*Create a correlation matrix of variables of interest
pwcorr lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc, star(.05)

*scatter lcrmrte lpolpc 
*scatter of crimes and people per square mile
*scatter lcrmrte ldensity
*scatter of crimes and percent young male
*scatter lcrmrte lpctymle
*scatter of crimes and county id
*scatter lcrmrte county
*scatter of crimes and prbarr
*scatter lcrmrte lprbarr
*scatter of crimes and avgsen
*scatter lcrmrte lavgsen

**************************************************

*#2 Pooled regressions
reg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc

* Pooled OLS with cluster-robust standard errors
*regress lwage exp exp2 wks ed, vce(cluster id)

**************************************************

*#3 Pooled regressions for each cross-section
reg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc if year==81
reg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc if year==82
reg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc if year==83
reg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc if year==84
reg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc if year==85
reg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc if year==86
reg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc if year==87

*regress with each year-dummy
reg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc d82 d83 d84 d85 d86 d87


**************************************************

*#4 * Declare individual identifier and time identifier
xtset county year
* Panel description of dataset
*xtdescribe 
* Panel summary statistics: within and between variation
*xtsum county year lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc

*Construct the means over time
foreach v of var lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc {
bysort county : egen sum`v' = sum(`v')
}
foreach v of var lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc {
bysort county : gen mean`v' = sum`v'/7
}
*regress with means
reg meanlcrmrte meanlprbarr meanlprbconv meanlprbpris meanlavgsen meanlpolpc

*OR use directly betweem estimator (results are the same)

* Between estimator 
xtreg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc, be
*Between estimator with cluster-robust standard errors
*xtreg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc, be vce(cluster id)

**************************************************

*#5 * Estimate FE
xtreg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc, fe

**************************************************

*#7 * estimated county specific effects 
xtreg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc, fe
*predict county specific effect from FE regression
predict uu, u
*regress estimated specific fixed effect on variables + means
reg uu west central urban pctmin80 meanlprbarr meanlprbconv meanlprbpris meanlavgsen meanlpolpc

**************************************************

*#8 * FE with year dummies
xtreg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc d82 d83 d84 d85 d86 d87, fe
*test for joint significance of dummies
test d82 d83 d84 d85 d86 d87

**************************************************

*#9 * FE with other variables
*First round of elimination
xtreg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc d8* ldensity ltaxpc lwcon lwtuc lwtrd lwfir lwser lwmfg lwfed lwsta lwloc lmix lpctymle lpctmin,fe

**************************************************

*#10 * FE with other variables
*regression
xtreg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc, re

*store results
quietly xtreg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc, re 
estimates store RE
quietly xtreg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc, fe 
estimates store FE
quietly reg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc
estimates store OLS

*test: pooled OLS vs RE
quietly xtreg lcrmrte lprbarr lprbconv lprbpris lavgsen lpolpc, re 
xttest0 

*test: FE vs RE
hausman FE RE, sigmamore


