# requirements setup and mamba for faster install for env
source /opt/conda/etc/profile.d/conda.sh
mamba env create -qq -f environment.yml
conda activate solvingmicrodsops

# execute script to reproduce figures
cd Code/
python StructEstimation.py
