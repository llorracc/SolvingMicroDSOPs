This folder contains the Mathematica code producing the figures and results of the "Structural Estimation" section. 

1. StructEstimation.nb produces the parameter estimates with standard errors. The file calls:

- setup_ConsFn.m loading parameters and routines to solve for the age varying consumption functions

- setup_Sim.m loading parameters and routines to compute simulated medians

- setup_Estimation.m loading the "MedianStructEstimation" function

- SCFdata.m loading SCF data

- setup_Bootsrap.m loading bootstrap parameters and "Bootstrap" routine


2. PlotMeanMedianSCF.nb plots the means and medians of the wealth to income ratios from SCF data for college graduates

3. PlotTimeVaryingParameters.nb plots the discount factor correction, the income growth factor and the survival probability (from Cagetti (2003))

4. FindMinimum.nb compares the performance of the FindMinimum routine under different "Method" specifications


The folder also contains the following subfolders:

- Cagetti2003Data: includes ln income, the discount factor correction and the survival probability across the life time taken from Cagetti (2003). Ln income and the discount factor correction varies across educational groups (college, high school and non high school grads)

- SCFDataPopulation: includes the Stata and Matlab code to create the SCFdata.txt from SCF data.