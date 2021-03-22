# 2020-PET-predict-EF-after-Revasc_TVL
This project contains the analysis for the paper on the predictive values of cardiac PET parameters on the improvement in left ventricular ejection fraction after coronary revascularization procedure by Luong TV et al.

## Research question
We aim to investigate whether PET-scans with <sup>82</sup>Rb and dynamic FDG prior to coronary revascularization procedure can predict improvement of left ventricular EF in patients with ischemic heart failure (:HF). Secondarily, we aim to investigate if the predictive values of the PET parameters differ in these patients depending on diabetes status.

Patients were recruited as a part of a study on cardiac insulin resistance and survival in patients with ischemic HF (n=131). Of those, the 44 patients who underwent a successful revascularization procedure were recruited in this study.

## About this repository
The purpose of this repository is to provide transparency about the analysis and allow other researchers to replicate the analysis. Due to privacy concerns, the original data is NOT available in the repository. Upon request, the corresponding author will detail restrictions to data availability and under which conditions access to some of the data may be provided.

## Abbreviations
| Abbreviation | Meaning                                             |
|--------------|-----------------------------------------------------|
| CABG         | Coronary artery bypass grafting                     |
| CFR          | Coronary flow reserve                               |
| CTO          | Chronic total occlusion                             |
| EF           | Left ventricular ejection fraction                  |
| FDG-PET      | 18F-Fluorodeoxyglucose positron emission tomography |
| GIR          | Glucose infusion rate                               |
| HEC          | Hyperinsulinemic euglycemic clamp                   |
| HF           | Heart failure                                       |
| MGU          | Myocardial glucose uptake                           |
| M-value      | Whole-body insulin sensitivity                      |
| PCI          | Percutaneous coronary intervention                  |
| <sup>82</sup>Rb-PET       | Rubidium-82 positron emission tomography            |
| SAP          | Statistical analysis plan                           |
| NPV          | Negative predictive value                           |
| PPV          | Positive predictive value                           |
| ROC          | Receiver operator curve                             |

# Statistical analysis plan
This section describes the SAP in terms of:
1. Definitions of exposure variables
2. Definitions of outcomes
3. Statistics
4. Layout of planned tables
5. Layout of planned figures
6. Change log

## 1) Exposure variables
Stationary PET variables to be examined:
- Scar tissue: Total cardiac scar tissue in % (based on FDG-PET)
- Hibernating tissue: Hibernating cardiac tissue in %, defined as an area in LAD/LCX/RCA with reduced uptake on (based on rest <sup>82</sup>Rb-PET scan) that is metabolically active (based on FDG-PET)
- Total coronary flow reserve: Total cardiac coronary blood flow during adenosine-stress test minus resting blood flow (based on <sup>82</sup>Rb-PET)
- CFR LAD/LCX/RCA: Coronary flow reserve by anatomical area (as defined above)

Dynamic PET variables to be examined:
- Global MGU: a proxy for overall heart insulin resistance (based on dynamic FDG-PET)
- MGU LAD/LCX/RCA: Myocardial glucose uptake by anatomical area (as defined above)

Other exposure variables to be examined:
- Mean glucose infusion rate: infusion rate of glucose during the last 30 min of a 120 min HEC, which is a measure of whole-body insulin resistance.

Diabetes status: Including both Type 1 and Type 2 diabetes mellitus (based on medical records).

## 2) Outcome variables
Primary outcome:
- Improved EF: defined as EF after cardiac intervention minus EF before intervention >= 5% (measured by echocardiogram)

Secondary outcome:
- EF improved >=10%

## 3) Statistics
Diagnostic value of exposure variables on primary and secondary outcomes will be visualized using receiver operator curves (:ROC).

Area under the curve (:AUC) will be reported for each exposure-outcome combination.

In addition, optimal cutoffs will be presented in a table for each exposure-outcome combination along with summary statistics:
- Sensitivity
- Specificity
- Positive predictive value (:PPV)
- Negative predictive value (:NPV)

All analyses, tables and graphs will be reported for total patient cohort and stratified by diabetes status.

Patients with missing data on one an exposure variable will be excluded from the relevant analysis.

Analyses will be performed in Stata Statistical Software v 16.1 (College Station, Texas 77845 USA) using the *diagt* package ([link](https://ideas.repec.org/c/boc/bocode/s423401.html)).

## 4) Table shells
**Table 1** - Patient Characteristics, PET measurements, and Cardiac Status by Diabetes Status

|                                                                           | Total | Diabetics | Non-diabetics |
|---------------------------------------------------------------------------|-------|-----------|---------------|
| **Patient characteristics**                                               |       |           |               |
| Patients, n                                                               |       |           |               |
| Age in years, mean (SD)                                                   |       |           |               |
| Sex                                                                       |       |           |               |
| - Men                                                                     |       |           |               |
| - Women                                                                   |       |           |               |
| BMI in kg/m2, mean (SD)                                                   |       |           |               |
| P-glucose during HEC in mM, mean (SD)                                     |       |           |               |
| Glucose infusion rate during HEC in mg/kg/min, mean (SD)                  |       |           |               |
| **Cardiac status**                                                        |       |           |               |
| Ejection-fraction on echocardiogram in %, mean (SD)                       |       |           |               |
| - Before intervention                                                     |       |           |               |
| - After intervention                                                      |       |           |               |
| Types of intervention, n (%)                                              |       |           |               |
| - PCI without CTO                                                         |       |           |               |
| - PCI with CTO                                                            |       |           |               |
| - CABG                                                                    |       |           |               |
| - PCI and CABG combined                                                   |       |           |               |
| Area of intervention, n (%)                                               |       |           |               |
| - LAD                                                                     |       |           |               |
| - LCX                                                                     |       |           |               |
| - RCA                                                                     |       |           |               |
| - Multiple areas                                                          |       |           |               |
| **PET measurements**                                                      |       |           |               |
| Scar tissue in %, mean (SD)                                               |       |           |               |
| Hibernating tissue in %, mean (SD)                                        |       |           |               |
| - Overall                                                                 |       |           |               |
| - Area of intervention in counts  *                                       |       |           |               |
| Coronary flow reserve, mean (SD)                                          |       |           |               |
| - Overall                                                                 |       |           |               |
| - Area of intervention *                                                  |       |           |               |
| Myocardial glucose uptake during HEC in µmol/min/100g tissue, mean (SD) # |       |           |               |
| - Overall                                                                 |       |           |               |
| - Remote area                                                             |       |           |               |
| - Hibernating area                                                        |       |           |               |

Notes: Mean (SD) will be changed to median (IQR) if data are non-parametrically distributed.

'* For patients with interventions in more than one area, average will be reported.

'# Overall MGU is defined as average of global cardiac MGU. Remote area is defined as area with highest FDG-uptake and lowest amount of scar tissue. Hibernating area is defined as the area with the highest count of hibernating spots; in case two or three areas have same number of spots, then the average will be reported.



**Supplementary table** - Same as table 1 but by Improvement after Revascularization Procedure

|                        | Total | EF improved | Not improved |
|------------------------|-------|-------------|--------------|
| (same rows as table 1) |       |             |              |

Notes: EF improvement by 5% or more.


**Table 2** - Predictive value of PET measurements on 5% and 10% EF improvement

|                                      | AUC | Sensitivity at optimal cutoff | Specificity at optimal cutoff |
|--------------------------------------|-----|-------------------------------|-------------------------------|
| **EF improvement >=5%**              |     |                               |                               |
| Hibernating tissue                   |     |                               |                               |
| -   (by table 1 subgroups)           | 0.123 (0.012-0.234) |  12.3%        |          23.4%                |
| Scar tissue                          |     |                               |                               |
| Coronary flow reserve                |     |                               |                               |
| -   (by table 1 subgroups)           |     |                               |                               |
| Myocardial glucose uptake during HEC |     |                               |                               |
| -   (by table 1 subgroups)           |     |                               |                               |
| **EF improvement >=10%**             |     |                               |                               |
| (Same as above)                      |     |                               |                               |


**Table 3** - AUC of PET Measurements by Patient Characteristics

|                                    | Hibernation, overall | Hibernation, AoI | Scar tissue | CFR, overall | CFR, AoI | MGU |
|------------------------------------|----------------------|------------------|-------------|--------------|----------|-----|
| **Patient characteristics**        |                      |                  |             |              |          |     |
| Age                                |                      |                  |             |              |          |     |
| -   Below median                   | 0.123 (0.012-0.234)  |                  |             |              |          |     |
| -   Above median                   |                      |                  |             |              |          |     |
| Sex                                |                      |                  |             |              |          |     |
| -   Men                            |                      |                  |             |              |          |     |
| -   Women                          |                      |                  |             |              |          |     |
| Diabetes                           |                      |                  |             |              |          |     |
| -   Yes                            |                      |                  |             |              |          |     |
| -   No                             |                      |                  |             |              |          |     |
| **Cardiac status**                 |                      |                  |             |              |          |     |
| Pre-intervention ejection-fraction |                      |                  |             |              |          |     |
| -   Below median                   |                      |                  |             |              |          |     |
| -   Above median                   |                      |                  |             |              |          |     |
| Area of intervention               |                      |                  |             |              |          |     |
| -   LAD                            |                      |                  |             |              |          |     |
| -   LCX                            |                      |                  |             |              |          |     |
| -   RCA                            |                      |                  |             |              |          |     |
| -   Multiple areas                 |                      |                  |             |              |          |     |

Notes: AUC calculated on 5% EF improvement.




## 5) Figure layout
Figure 1 - ROC Graphs for each Exposure on Improved Ejection Fraction >=5%

Figure 2 - ROC Graphs for each Exposure on >=10%


## 6) Change log
This section describes the development of the prespecified SAP (before inspection of data), as well as any later changes to the SAP after inspection of data, reviewer comments, after acceptance, etc.
The development of the Stata code is documented in GitHub's "commits" section, and will not be described below, unless changes to the code:
1. are related to changes in the SAP,
2. affect results or interpretation of results substantially,
3. or are integrated after submission/acceptance/publication/etc.

### Changes before analysis (prespecified)
- 1.0 Initial draft by TVL and ALE.
- 1.1 SAP completed after discussion with LG

### Changes after initial analysis (post hoc analyses)
...

### Changes after submission
...
