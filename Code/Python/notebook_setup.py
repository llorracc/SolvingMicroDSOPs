"""Consolidated imports and setup for SolvingMicroDSOPs.ipynb.

Importing ``from Code.Python.notebook_setup import *`` replaces the
scattered import cells at the top of the notebook.
"""

import os
from copy import copy
from time import time


def _env_flag_is_true(name: str, default: str = "0") -> bool:
    """Interpret common truthy shell values for notebook runtime flags."""
    return os.getenv(name, default).strip().lower() in {"1", "true", "yes", "on"}


SAVE_FIGURES = _env_flag_is_true("SAVE_FIGURES", "0")

import numpy as np
import pylab as plt
import scipy.stats as stats
from numpy import log, exp
from scipy.interpolate import InterpolatedUnivariateSpline
from scipy.optimize import brentq, minimize

from Code.Python.resources import (
    Utility,
    DiscreteApproximation,
    DiscreteApproximationToMeanOneLogNormal,
    DiscreteApproximationTwoIndependentDistribs,
)
from Code.Python.notebook_plots import *

from HARK.ConsumptionSaving.ConsIndShockModel import init_lifecycle
from HARK.ConsumptionSaving.ConsPortfolioModel import PortfolioConsumerType

import warnings
warnings.filterwarnings("ignore", category=UserWarning)
warnings.filterwarnings("ignore", category=RuntimeWarning)
