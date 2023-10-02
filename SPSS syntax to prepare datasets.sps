* Encoding: UTF-8.
/*2012 - remove those not eligible for LBQ*/

DATASET ACTIVATE DataSet1.
FILTER OFF.
USE ALL.
SELECT IF (NLBELIG = 1).
EXECUTE.

/*2014 - remove those not eligible for LBQ*/

DATASET ACTIVATE DataSet2.
FILTER OFF.
USE ALL.
SELECT IF (OLBELIG = 1).
EXECUTE.

/*run the following for both 2012 and 2014 cohorts*/

COMPUTE COUNT=1.
EXECUTE.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=HHID
  /COUNT_sum=SUM(COUNT).

FILTER OFF.
USE ALL.
SELECT IF (COUNT_sum >= 2).
EXECUTE.


/* assign a value of 1 to everyone with xPN_SP*/
     
DATASET ACTIVATE DataSet1.
FILTER OFF.
USE ALL.
SELECT IF (VAR00001 = 1).
EXECUTE.
/*removed 4,006 participants, leaving 6,073 in the dataset*/

DATASET ACTIVATE DataSet1.
COMPUTE COUNT2=1.
EXECUTE.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=HHID
  /COUNT2_sum=SUM(COUNT2).

1 - 25
2 - 6,004
3 - 12
4 - 32

remove the 25 participants and double check the 12 participants for the value 3.

FILTER OFF.
USE ALL.
SELECT IF (COUNT2_sum  >= 2).
EXECUTE.

for households with 3 people, remove:
    014427/010
    208867/021
    501283/011
    535283/020
    
32 participants belong to 8 households. use xSUBHH.
  
/*removed 3853 participants, leaving 5,696 in the dataset*/
    
DATASET ACTIVATE DataSet2.
COMPUTE COUNT2=1.
EXECUTE.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=HHID
  /COUNT2_sum=SUM(COUNT2).

1 - 24
2 - 5,622
3 - 6
4 - 44

remove the 24 participants and double check the 6 participants for the value 3.

FILTER OFF.
USE ALL.
SELECT IF (COUNT2_sum  >= 2).
EXECUTE.

for households with 3 people, remove:
    050125/021
    140836/011
    
44 participants belong to 11 households. use xSUBHH.

/*did participant report on spa?*/
    /*2012*/
    
DATASET ACTIVATE DataSet1.
RECODE NNSPA NPSPA (MISSING=0) (ELSE=1) INTO NNSPA_count NPSPA_count.
VARIABLE LABELS  NNSPA_count 'NSPA data yes/no' /NPSPA_count 'PSPA data yes/no'.
EXECUTE.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=HHID
  /NNSPA_count_sum=SUM(NNSPA_count) 
  /NPSPA_count_sum=SUM(NPSPA_count).

NSPA: 
    0 - 902
    1 - 1,114
    2 - 4,002
    3 - 16
    4 - 12
    
PSPA:
    0 - 906
    1 - 1,108
    2 - 4,004
    3 - 16
    4 - 12

FILTER OFF.
USE ALL.
SELECT IF (NNSPA_count_sum >= 2).
EXECUTE.

FILTER OFF.
USE ALL.
SELECT IF (NPSPA_count_sum >= 2).
EXECUTE.

4016 participants/2010 couples with both PSPA and NSPA data in 2012.

/*2014*/

COMPUTE ONSPA=MEAN(OLB028B01,OLB028B3,OLB028B7,OLB028B8).
VARIABLE LABELS  ONSPA 'NEGATIVE SPA 2014'.
EXECUTE.
COMPUTE OPSPA=MEAN(OLB028B02,OLB028B4,OLB028B5,OLB028B6).
VARIABLE LABELS  OPSPA 'POSITIVE SPA 2014'.
EXECUTE.

DATASET ACTIVATE DataSet2.
RECODE ONSPA OPSPA (MISSING=0) (ELSE=1) INTO ONSPA_count OPSPA_count.
VARIABLE LABELS  ONSPA_count 'NSPA data yes/no' /OPSPA_count 'PSPA data yes/no'.
EXECUTE.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=HHID
  /ONSPA_count_sum=SUM(ONSPA_count) 
  /OPSPA_count_sum=SUM(OPSPA_count).

NSPA: 
    0 - 674
    1 - 776
    2 - 4,186
    4 - 32
    
PSPA:
    0 - 672
    1 - 780
    2 - 4,186
    4 - 32

FILTER OFF.
USE ALL.
SELECT IF (ONSPA_count_sum >= 2).
EXECUTE.

FILTER OFF.
USE ALL.
SELECT IF (OPSPA_count_sum >= 2).
EXECUTE.

/*ended up with 4,210 participants with both PSPA and NSPA data in 2014*/

/*combine 2012 and 2014 cohorts*/
    
GET FILE ='C:\Users\mmhuo\Box Sync\Research\Papers in progress\HRS\HRS_Profiles\H12LB_R_eligible_cleaned_SPA.sav'
 /KEEP = hhid pn NLBELIG NNSPA NPSPA NSUBHH. 
SORT CASES BY hhid (a).
SAVE OUTFILE ='C:\Users\mmhuo\Box Sync\Research\Papers in progress\HRS\HRS_Profiles\H12_tobecombined.sav'.

GET FILE ='C:\Users\mmhuo\Box Sync\Research\Papers in progress\HRS\HRS_Profiles\H14LB_R_eligible_cleaned_SPA.sav'
 /KEEP = hhid pn OLBELIG ONSPA OPSPA OSUBHH. 
SORT CASES BY hhid (a).
SAVE OUTFILE ='C:\Users\mmhuo\Box Sync\Research\Papers in progress\HRS\HRS_Profiles\H14_tobecombined.sav'.

In the 2012 dataset, create a new variable LB and assign a value 0.
In the 2014 dataset, rename OLBELIG as LB.  
in both datasets, remove x (N/O) in variable names.


/*extract age from tracker*/
    
GET FILE ='C:\Users\mmhuo\Box Sync\Research\Papers in progress\HRS\HRS data\trk2018tr_r.sav'
 /KEEP = hhid pn NAGE OAGE
 gender race hispanic schlyrs . 
SORT CASES BY hhid (a).
SAVE OUTFILE ='C:\Users\mmhuo\Box Sync\Research\Papers in progress\HRS\HRS_Profiles\trk_cov.sav'.

RECODE hhid pn (CONVERT) INTO hhid1 pn1.
 COMPUTE hhidpn = (hhid1*1000)+pn1.
 SORT CASES BY hhidpn (A).
FORMATS hhid1 pn1 hhidpn (f10.0).

/*Age*/

IF  (LB = 0) AGE_a=NAGE.
EXECUTE.
IF  (LB = 1) AGE_b=OAGE.
EXECUTE.

COMPUTE AGE=MAX(AGE_a, AGE_b).
FORMATS AGE (f6.0).
EXECUTE.

IF  (AGE >= 50) age50=1.
EXECUTE.

RECODE age50 (MISSING=0).
EXECUTE.

among the sample of 8,226 participants, 245 age under 50 (478 participants removed due to at least one partner < 50). 


AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=HHID_r
  /age50_sum=SUM(age50).

FILTER OFF.
USE ALL.
SELECT IF (age50_sum  = 2).
EXECUTE.

SORT CASES BY HHID_r .
CASESTOVARS
  /ID=HHID_r
  /GROUPBY=VARIABLE.


/*pre-restructure dataset*/

DATASET ACTIVATE DataSet2.
DATASET DECLARE aggr_gender.
AGGREGATE
  /OUTFILE='aggr_gender'
  /BREAK=HHID_r
  /GENDER_sum=SUM(GENDER).

2 - 9 gay couples
4 - 15 lesbian couples

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=HHID_r
  /GENDER_sum=SUM(GENDER).

FILTER OFF.
USE ALL.
SELECT IF (GENDER_sum = 3).
EXECUTE.

removed 24 same-sex couples. the final sample includes 7,700 participants, thus 3,850 couples.


/*recode gender*/

RECODE GENDER (2=0) (1=1) (MISSING=SYSMIS).
EXECUTE.

RECODE GENDER (ELSE=Copy) INTO hw.
VARIABLE LABELS  hw 'husband 1 wife 0'.
EXECUTE.


/*extract RQ variables*/

C
GET FILE ='C:\Users\mmhuo\Box Sync\Research\Papers in progress\HRS\HRS data\2014\H14LB_R.sav'
 /KEEP = hhid pn OLB004A
OLB004B
OLB004C
OLB004D
OLB004E
OLB004F
OLB004G. 
SORT CASES BY hhid (a).
SAVE OUTFILE ='C:\Users\mmhuo\Box Sync\Research\Papers in progress\HRS\HRS_Profiles\H14_marital quality.sav'.
  

/*marital quality in 2012 and 2014*/
    /*reverse code all items*/

RECODE NLB005A NLB005B NLB005C OLB004A OLB004B OLB004C (1=4) (2=3) (3=2) (4=1) 
    (MISSING=SYSMIS) INTO NLB005Ar NLB005Br NLB005Cr OLB004Ar OLB004Br OLB004Cr.
VARIABLE LABELS  NLB005Ar 'UNDERSTAND REVERSE' /NLB005Br 'RELY ON REVERSE' /NLB005Cr 
    'OPEN UP REVERSE' /OLB004Ar 'UNDERSTAND REVERSE' 
    /OLB004Br 'RELY ON REVERSE' /OLB004Cr 'OPEN UP REVERSE'.
EXECUTE.

RECODE NLB005D NLB005E NLB005F NLB005G OLB004D OLB004E OLB004F OLB004G (1=4) (2=3) (3=2) (4=1) 
    (MISSING=SYSMIS) INTO NLB005Dr NLB005Er NLB005Fr NLB005Gr OLB004Dr OLB004Er OLB004Fr OLB004Gr.
VARIABLE LABELS  NLB005Dr 'TOO MANY DEMANDS REVERSE' /NLB005Er 'CRITICIZE REVERSE' /NLB005Fr 
    'LET YOU DOWN REVERSE' /NLB005Gr 'GETS ON YOUR NERVES REVERSE' /OLB004Dr 'TOO MANY DEMANDS REVERSE' 
    /OLB004Er 'CRITICIZE REVERSE' /OLB004Fr 'LET YOU DOWN REVERSE' /OLB004Gr 'GETS ON YOUR NERVES '+
    'REVERSE'.
EXECUTE.


COMPUTE RQ12=MEAN(NLB005Ar,NLB005Br,NLB005Cr,NLB005D,NLB005E,NLB005F,NLB005G).
EXECUTE.

COMPUTE RQ14=MEAN(OLB004Ar, OLB004Br, OLB004Cr, OLB004D, OLB004E, OLB004F, OLB004G).
EXECUTE.


/*marital quality*/

IF  (LB = 0) RQ_a = RQ12.
EXECUTE.
IF  (LB = 1) RQ_b = RQ14.
EXECUTE.

COMPUTE RQ=MAX(RQ_a, RQ_b).
FORMATS RQ (f8.2).
EXECUTE.



/*covariates from rand*/
    
GET FILE ='C:\Users\mmhuo\Box Sync\Research\Papers in progress\HRS\HRS data\randhrs1992_2018v1.sav'
 /KEEP = hhidpn H11ITOT H12ITOT R11CONDE R12CONDE R11MCURLN R12MCURLN S11MCURLN S12MCURLN. 
SORT CASES BY hhid (a).
SAVE OUTFILE ='C:\Users\mmhuo\Box Sync\Research\Papers in progress\HRS\HRS_Profiles\rand_cov.sav'.

/*income*/

IF  (LB = 0) ITOT_a=H11ITOT.
VARIABLE LABELS  ITOT_a 'ITOT 12'.
EXECUTE.
IF  (LB = 1) ITOT_b=H12ITOT.
VARIABLE LABELS  ITOT_b 'ITOT 14'.
EXECUTE.

COMPUTE ITOT=MAX(ITOT_a,ITOT_b).
VARIABLE LABELS  ITOT 'ITOT'.
EXECUTE.

/*log transform income*/

COMPUTE Income=LN(ITOT+1).
EXECUTE.


/*chronic conditions*/

IF  (LB = 0) CONDE_a=R11CONDE.
VARIABLE LABELS  CONDE_a 'CONDE 12'.
EXECUTE.
IF  (LB = 1) CONDE_b=R12CONDE.
VARIABLE LABELS  CONDE_b 'CONDE 14'.
EXECUTE.

COMPUTE CONDE=MAX(CONDE_a,CONDE_b).
VARIABLE LABELS  CONDE 'CONDE'.
EXECUTE.

/*marital duration*/

IF  (LB = 0) MDUR_a=R11MCURLN.
VARIABLE LABELS  MDUR_a 'marital duration 12'.
EXECUTE.
IF  (LB = 1) MDUR_b=R12MCURLN.
VARIABLE LABELS  MDUR_b 'marital duration 14'.
EXECUTE.

COMPUTE MDUR=MAX(MDUR_a,MDUR_b).
VARIABLE LABELS  MDUR 'marital duartion'.
EXECUTE.


/*functional limitations*/

IF  (LB = 0) FL_a=NG013.
VARIABLE LABELS  FL_a 'FL 12'.
EXECUTE.
IF  (LB = 1) FL_b=OG013.
VARIABLE LABELS  FL_b 'FL 14'.
EXECUTE.

COMPUTE FL=MAX(FL_a,FL_b).
VARIABLE LABELS  FL 'FL'.
EXECUTE.


/*self-rated health*/

IF  (LB = 0) HEALTH_a=NC001.
VARIABLE LABELS  HEALTH_a 'HEALTH 12'.
EXECUTE.
IF  (LB = 1) HEALTH_b=OC001.
VARIABLE LABELS  HEALTH_b 'HEALTH 14'.
EXECUTE.

COMPUTE HEALTH=MAX(HEALTH_a,HEALTH_b).
VARIABLE LABELS  HEALTH 'HEALTH'.
EXECUTE.


RECODE HEALTH (8=SYSMIS) (MISSING=SYSMIS) (5=1) (4=2) (3=3) (2=4) (1=5) INTO Healthr.
EXECUTE.



/*recode minority status*/

IF  (HISPANIC = 5 and race = 1) Minority=0.
EXECUTE.

DO IF (HISPANIC = 1 OR HISPANIC = 2 OR HISPANIC = 3 OR RACE =2 OR RACE = 7).
RECODE Minority (MISSING=1).
END IF.
EXECUTE.

/*recode work status*/

IF  (LB = 0) work_a=NJ020.
VARIABLE LABELS  work_a 'work 12'.
EXECUTE.
IF  (LB = 1) work_b=OJ020.
VARIABLE LABELS  work_b 'work 14'.
EXECUTE.

COMPUTE work=MAX(work_a,work_b).
VARIABLE LABELS  work 'work'.
EXECUTE.

RECODE work (9=SYSMIS) (5=0) (ELSE=Copy) INTO workr.
EXECUTE.


/*generate depressive symptom variables*/

RECODE ND113 ND115 OD113 OD115 PD113 PD115 (1=0) (0=1) (MISSING=SYSMIS) INTO ND113r ND115r OD113r OD115r PD113r PD115r .
EXECUTE.


COMPUTE DEP12=SUM(ND110, ND111, ND112, ND113r, ND114, ND115r, ND116, ND117).
EXECUTE.
COMPUTE DEP14=SUM(OD110, OD111, OD112, OD113r, OD114, OD115r, OD116, OD117).
EXECUTE.
COMPUTE DEP16=SUM(PD110, PD111, PD112, PD113r, PD114, PD115r, PD116, PD117).
EXECUTE.



IF  (LB = 0) w1dep_a=dep12.
EXECUTE.
IF  (LB = 0) w2dep_a=dep14.
EXECUTE.



IF  (LB = 1) w1dep_b=dep14.
EXECUTE.
IF  (LB = 1) w2dep_b=dep16.
EXECUTE.



COMPUTE w1dep=max(w1dep_a, w1dep_b).
EXECUTE.
COMPUTE w2dep=max(w2dep_a, w2dep_b).
EXECUTE.



/*center continuous covariates*/

COMPUTE cage=AGE - 67.44.
EXECUTE.
COMPUTE cedu=SCHLYRS - 13.02.
EXECUTE.
COMPUTE cinc=income - 10.89.
EXECUTE.
COMPUTE chea=healthr - 3.22.
EXECUTE.
COMPUTE cfl=fl - 1.90.
EXECUTE.
COMPUTE ccon=conde - 2.12.
EXECUTE.
COMPUTE crq=rq - 3.26.
EXECUTE.
COMPUTE cmdu=mdur - 37.18.
EXECUTE.



/*reorder the 5 profiles*/

RECODE Profile_5 (1=1) (4=2) (5=3) (2=4) (3=5) INTO Profile5r.
VARIABLE LABELS  Profile5r 'reordered profiles 5 new model'.
EXECUTE.

IF  (Profile5r = 1) pro5_1=1.
VARIABLE LABELS  Pro5_1 'similarly positive'.
EXECUTE.

IF  (Profile5r = 2) pro5_2=1.
VARIABLE LABELS  Pro5_2 'similarly negative'.
EXECUTE.

IF  (Profile5r = 3) pro5_3=1.
VARIABLE LABELS  Pro5_3 'similarly average'.
EXECUTE.

IF  (Profile5r = 4) pro5_4=1.
VARIABLE LABELS  Pro5_4 'husband negative'.
EXECUTE.

IF  (Profile5r = 5) pro5_5=1.
VARIABLE LABELS  Pro5_5 'wife negative'.
EXECUTE.

RECODE pro5_1 pro5_2 pro5_3 pro5_4 pro5_5 (MISSING=0).
EXECUTE.

