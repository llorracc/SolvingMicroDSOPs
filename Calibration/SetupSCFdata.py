"""
Sets up the SCF data for use in the SolvingMicroDSOPs estimation.
"""
from __future__ import division  # Use new division function
from __future__ import print_function
from __future__ import absolute_import
from builtins import zip
from builtins import str
from builtins import range

import os, sys

# Find pathname to this file:
my_file_path = os.path.dirname(os.path.abspath(__file__))

# Pathnames to the other files:
calibration_dir = os.path.join(
    my_file_path, "../Calibration/"
)  # Relative directory for primitive parameter files
tables_dir = os.path.join(
    my_file_path, "../Tables/"
)  # Relative directory for primitive parameter files
figures_dir = os.path.join(
    my_file_path, "../Figures/"
)  # Relative directory for primitive parameter files
code_dir = os.path.join(
    my_file_path, "../Code/"
)  # Relative directory for primitive parameter files


# Need to rely on the manual insertion of pathnames to all files in do_all.py
# NOTE sys.path.insert(0, os.path.abspath(tables_dir)), etc. may need to be
# copied from do_all.py to here

# Import files first:
from EstimationParameters import initial_age, empirical_cohort_age_groups


# The following libraries are part of the standard python distribution
import numpy as np  # Numerical Python
import csv  # Comma-separated variable reader
import pandas as pd

# Set the path to the empirical data:
scf_data_path = data_location = os.path.dirname(
    os.path.abspath(__file__)
)  # os.path.abspath('./')   #'./'


data = pd.read_csv(scf_data_path + "/SCFdata.csv")

# Keep only observations with normal incomes > 0,
# otherwise wealth/income is not well defined
data = data[data.norminc > 0.0]

# Initialize empty lists for the data
w_to_y_data = []  # Ratio of wealth to permanent income
empirical_weights = []  # Weighting for this observation
empirical_groups = []  # Which age group this observation belongs to (1-7)

# Only extract the data required from the SCF dataset
search_ages = [ages[-1] for ages in empirical_cohort_age_groups]
for idx, age in enumerate(search_ages):
    age_data = data[data.age_group.str.contains(f"{age}]")]
    w_to_y_data.append(age_data.wealth_income_ratio.values)
    empirical_weights.append(age_data.weight.values)
    # create a group id 1-7 for every observation
    empirical_groups.append([idx + 1] * len(age_data))

# Convert SCF data to numpy's array format for easier math
w_to_y_data = np.concatenate(w_to_y_data)
empirical_weights = np.concatenate(empirical_weights)
empirical_groups = np.concatenate(empirical_groups)

# Generate a single array of SCF data, useful for resampling for bootstrap
scf_data_array = np.array([w_to_y_data, empirical_groups, empirical_weights]).T


# Generate a mapping between the real ages in the groups and the indices of simulated data
simulation_map_cohorts_to_age_indices = []
for ages in empirical_cohort_age_groups:
    simulation_map_cohorts_to_age_indices.append(np.array(ages) - initial_age)


if __name__ == "__main__":
    print("Sorry, SetupSCFdata doesn't actually do anything on its own.")
    print("This module is imported by StructEstimation, providing data for")
    print("the example estimation.  Please see that module if you want more")
    print("interesting output.")
