# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:percent
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.13.7
#   kernelspec:
#     display_name: Python 3 (ipykernel)
#     language: python
#     name: python3
# ---

# %% jupyter={"outputs_hidden": true} pycharm={"name": "#%%\n"}
from HARK.ConsumptionSaving.ConsPortfolioModel import PortfolioConsumerType
from HARK.utilities import plot_funcs
from time import time
from ConsWealthPortfolioModel import WealthPortfolioConsumerType


# %% [markdown] pycharm={"name": "#%% md\n"}
# ## Wealth in the Utility and Portfolio Choice

# %% [markdown] pycharm={"name": "#%% md\n"}
# ### Infinite Horizon Model

# %% jupyter={"outputs_hidden": false} pycharm={"name": "#%%\n"}
agent = WealthPortfolioConsumerType()
agent.cycles = 0

# %% jupyter={"outputs_hidden": false} pycharm={"name": "#%%\n"}
t0 = time()
agent.solve()
t1 = time()
print(
    "Solving an infinite horizon portfolio choice problem with wealth in the utility took "
    + str(t1 - t0)
    + " seconds."
)

# %% jupyter={"outputs_hidden": false} pycharm={"name": "#%%\n"}
plot_funcs(agent.solution[0].shareFunc, 0.0, 100)

# %% jupyter={"outputs_hidden": false} pycharm={"name": "#%%\n"}
plot_funcs(agent.solution[0].cFunc, 0.0, 20)

# %% [markdown] pycharm={"name": "#%% md\n"}
# ### Comparison to Portfolio Consumer Type

# %% jupyter={"outputs_hidden": false} pycharm={"name": "#%%\n"}

portfolio_agent = PortfolioConsumerType(CRRA=8)
portfolio_agent.cycles = 0

# %% pycharm={"name": "#%%\n"} jupyter={"outputs_hidden": false}
t0 = time()
portfolio_agent.solve()
t1 = time()
print(
    "Solving an infinite horizon portfolio choice problem took "
    + str(t1 - t0)
    + " seconds."
)

# %% [markdown] pycharm={"name": "#%% md\n"}
# ### Consumption Function

# %% pycharm={"name": "#%%\n"} jupyter={"outputs_hidden": false}
plot_funcs([agent.solution[0].cFunc, portfolio_agent.solution[0].cFuncAdj], 0, 20,
           legend_kwds={"labels": ["Wealth in Utility", "Portfolio Type"]})

# %% [markdown] pycharm={"name": "#%% md\n"}
# ### Share Function

# %% pycharm={"name": "#%%\n"} jupyter={"outputs_hidden": false}
plot_funcs([agent.solution[0].shareFunc, portfolio_agent.solution[0].ShareFuncAdj], 0, 100,
           legend_kwds={"labels": ["Wealth in Utility", "Portfolio Type"]})

# %% [markdown] pycharm={"name": "#%% md\n"}
# ### Lifecycle Model with Mortality

# %% pycharm={"name": "#%%\n"} jupyter={"outputs_hidden": false}
import numpy as np

# %% pycharm={"name": "#%%\n"} jupyter={"outputs_hidden": false}
mort_data = np.loadtxt("mortality.txt")

# %% pycharm={"name": "#%%\n"} jupyter={"outputs_hidden": false}
LivPrb = list(mort_data[:, -1])

# %% pycharm={"name": "#%%\n"} jupyter={"outputs_hidden": false}
T_cycle = len(LivPrb)
params = {"LivPrb": LivPrb, "T_cycle": T_cycle, "TranShkStd": [0.01] * T_cycle,
          "PermShkStd": [0.0] * T_cycle, "PermGroFac" : [1.0] * T_cycle}

# %% pycharm={"name": "#%%\n"} jupyter={"outputs_hidden": false}
agent = WealthPortfolioConsumerType(**params)

# %% pycharm={"name": "#%%\n"} jupyter={"outputs_hidden": false}
t0 = time()
agent.solve()
t1 = time()
print(
    "Solving a lifecycle portfolio choice problem with wealth in the utility took "
    + str(t1 - t0)
    + " seconds."
)

# %% pycharm={"name": "#%%\n"} jupyter={"outputs_hidden": false}
agent.cFunc = [agent.solution[i].cFunc for i in range(T_cycle)]
agent.shareFunc = [agent.solution[i].shareFunc for i in range(T_cycle)]

# %% pycharm={"name": "#%%\n"} jupyter={"outputs_hidden": false}
plot_funcs(agent.cFunc, 0, 20)

# %% pycharm={"name": "#%%\n"} jupyter={"outputs_hidden": false}
plot_funcs(agent.shareFunc, 0, 100)

# %% pycharm={"name": "#%%\n"} jupyter={"outputs_hidden": false}
