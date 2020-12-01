# 2020-PET-predict-EF-after-Revasc_TVL
This project contains the analysis for the paper on FDG-PET and improvement in ejection fraction after revascularization by Luong TV et al.

## Research question
We aim to investigate if static and dynamic FDG-PET and Rb-PET measures can predict improved left ventricular ejection-fraction (:EF) after revascularization in patients with heart failure (:HF). Secondarily, we aim to investigate if the predictive values of these measures differ between patients with and without diabetes.

Patients were recruited as a part of a study on cardiac insulin resistance and survival in patients with ischemic HF (n=131). Of those, the X patients who underwent an intervention (PCI and/or CABG) were recruited in this study.

## About this repository
The purpose of this repository is to provide transparency about the analysis and allow other researchers to *replicate* the analysis. Due to privacy concerns, the original data is NOT available in the repository. Thus, it is not possible *reproduce* the analysis presented in the paper. Upon request, the corresponding author will detail restrictions to data availability and under which conditions access to some of the data may be provided.

## Abbreviations
| Abbreviation | Meaning                                             |
|--------------|-----------------------------------------------------|
| CFR          | Coronary flow reserve                               |
| EF           | Left ventricular ejection fraction                  |
| FDG-PET      | 18F-Fluorodeoxyglucose positron emission tomography |
| GIR          | Glucose infusion rate                               |
| HF           | Heart failure                                       |
| MGU          | Mean glucose uptake                                 |
| RB-PET       | Rubidium-82 positron emission tomography            |
| SAP          | Statistical analysis plan                           |


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
- Myocardial glucose uptake: a proxy for overall heart insulin resistance (based on FDG-PET)
- Scar tissue: Total cardiac scar tissue in % (based on FDG-PET)

Dynamic PET variables to be examined:
- Total coronary flow reserve: total cardiac blood flow during adenosine-stress test minus resting blood flow (based on Rb-PET)
- CFR LAD/LCX/RCA: Coronary flow reserve by anatomical area (as defined above)
- Hibernating tissue: Hibernating cardiac tissue in %, defined as area with abnormal CFR (based on Rb-PET) that is metabolically active (based on FDG-PET).

Other exposure variables to be examined:
- Mean glucose infusion rate: infusion rate of glucose during insulin-clamp, which is a measure of whole-body insulin resistance.

Diabetes status: Including both Type 1 and Type 2 diabetes mellitus (based on medical records).

## 2) Outcome variables
Primary outcome:
- Improved EF: defined as EF after cardiac intervention minus EF before intervention >= 5% (measured by echocardiogram)

Secondary outcomes:
- ... Any? ...


## 3) Statistics
Diagnostic value of exposure variables on primary and secondary outcomes will be visualized using receiver operator curves (:ROC).

Area under the curve (:AUC) will be reported for each exposure-outcome combination.

In addition, optimal cutoffs will be presented in a table for each exposure-outcome combination along with summary statistics:
- Sensitivity
- Specificity
- Positive predictive value (:PPV)
- Negative predictive value (:NPV)

All analyses, tables and graphs will be reported for total patient cohort and stratified by diabetes status.

Patients with missing data on one or more exposure variables will be excluded from the relevant analysis/analyses.

Analyses will be performed in Stata Statistical Software v 16.1 (College Station, Texas 77845 USA) using the *diagt* package (ref).

## 4) Table shells
Table 1 - Patient Characteristics, Ejection Fraction, and Cardiac Interventions

Table 2 - PET Measurements

Table 3 - Diagnostic Value of PET Measures on Improved EF after Intervention

## 5) Figure layout
Figure 1 - ROC Graphs for each Exposure on Improved Ejection Fraction

Figure 2 - ROC Graphs for each Exposure on *Secondary Outcomes (if any)*


## 6) Change log
This section describes the development of the prespecified SAP (before inspection of data), as well as any later changes to the SAP after inspection of data, reviewer comments, after acceptance, etc.
The development of the Stata code is documented in GitHub's "commits" section, and will not be described below, unless changes to the code:
1. are related to changes in the SAP,
2. affect results or interpretation of results substantially,
3. or are integrated after submission/acceptance/publication/etc.

### Changes before analysis (prespecified)
- 1.0 Initial draft by TVL and ALE.

### Changes after initial analysis (post hoc analyses)
...

### Changes after submission
...
