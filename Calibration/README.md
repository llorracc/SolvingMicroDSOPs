# Calibration

**SCFdata.csv** is the processed SCF data used by `Code/Python/StructEstimation.py`. It is included in the repo so estimation can be run without raw SCF files.

To rebuild this file from raw Survey of Consumer Finances data, use the Stata pipeline in **Code/Stata/**; see [Code/Stata/README.md](../Code/Stata/README.md). That pipeline writes to **Data/Constructed/**; the Python estimation code reads the pre-processed CSV from this directory (**Calibration/**).

**EstimationParameters.py** and **SetupSCFdata.py** define model parameters and load the SCF data for estimation.
