# SolvingMicroDSOPs

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/econ-ark/SolvingMicroDSOPs/HEAD)

## Installation

See the instructions at https://econ-ark.org/materials/SolvingMicroDSOPs

## Structure

- [Jupyter notebook](./Code/Python/SolvingMicroDSOP-Python.ipynb) corresponding to the SolvingMicroDSOPs lecture notes
- [Python Code](/Code/python/StructEstimation.py) that does the structual estimation

## Replication

To reproduces all the results in the repository first clone this repository locally:

```
# Clone this repository
$ git clone https://github.com/econ-ark/SolvingMicroDSOPs

# Change working directory to SolvingMicroDSOPs
$ cd SolvingMicroDSOPs
```

Then you can either use a local virtual env(conda) or [nbreproduce](https://github.com/econ-ark/nbreproduce) to reproduce to the results.

#### A local conda environment and execute the do_all.py file.

```
$ conda env create -f environment.yml
$ conda activate solvingmicrodsops
# execute the script, select the appropriate option and use it to reproduce the data and figures.
$ python do_all.py
```

#### Local conda environment to execute the notebooks

```
$ conda env create -f environment.yml
$ conda activate solvingmicrodsops
# open jupyter lab, browse through the notebooks and execute them.
$ jupyter lab
```

#### [nbreproduce](https://github.com/econ-ark/nbreproduce) (requires Docker to be installed on the machine).

```
# Install nbreproduce
$ pip install nbreproduce

# Reproduce all results using nbreproduce
$ nbreproduce
```

## References
