---
# This file is located at: papers/macroeconomics/consumption/lifecycle-models/deep-paper.md
# It's 4 directories deep from the repo root!

title: "Life-Cycle Consumption with Uncertainty"
authors:
  - name: "Deep Directory Author"
  - name: "Nested Folder Researcher"
date: 2025-07-15
---

# Life-Cycle Consumption Model

This paper is located deep in the directory structure at:
`papers/macroeconomics/consumption/lifecycle-models/deep-paper.md`

## How Macros Work Here

Even though this file is **4 directories deep**, all the Econ-ARK macros work perfectly because they're defined in the **root `myst.yml`** file:

```
repo-root/
├── myst.yml                                    # ← extends defined here
├── .econ-ark/generated/econark-macros.yml      # ← source file  
└── papers/
    └── macroeconomics/
        └── consumption/
            └── lifecycle-models/
                └── deep-paper.md               # ← this file (4 levels deep!)
```

## The Model

The consumer maximizes lifetime utility:

$$\max \sum_{t=0}^{T} \DiscFac^t \uFunc(\cLvl_t)$$

Subject to the budget constraint:
$$\aLvl_{t+1} = \Rfree(\aLvl_t + \yLvl_t - \cLvl_t)$$

Where:
- $\DiscFac$ is the discount factor (imported from root config)
- $\cLvl_t$ is consumption at time $t$ (imported from root config)  
- $\aLvl_t$ is assets (imported from root config)
- $\yLvl_t$ is income (imported from root config)
- $\Rfree$ is the risk-free rate (imported from root config)

## Value Function

The Bellman equation becomes:
$$\vFunc_t(\aLvl_t) = \max_{\cLvl_t} \left\{ \uFunc(\cLvl_t) + \DiscFac \Ex_t[\vFunc_{t+1}(\aLvl_{t+1})] \right\}$$

## Pattern-Generated Macros Work Too

All the algorithmically generated notation works seamlessly:

- **Functions**: $\cFunc, \aFunc, \vFunc$ (function notation)
- **Levels**: $\cLvl, \aLvl, \vLvl$ (level variables)  
- **Normalized**: $\cNrm, \aNrm, \vNrm$ (normalized by permanent income)
- **Standard deviations**: $\cStd, \aStd, \vStd$ (volatility measures)

## Key Benefits

**🎯 No relative path hell**: This file doesn't need `../../../../.econ-ark/generated/econark-macros.yml`

**✅ Clean frontmatter**: Only 7 lines of frontmatter instead of 200+

**🔄 Automatic updates**: When `.econ-ark/macros.yaml` changes, this deep file automatically gets updates

**📂 Location independence**: This file could move to any directory depth and still work

## Perfect Single Source of Truth

This demonstrates the power of your single-source macro system:

1. **One definition**: All macros defined in `.econ-ark/macros.yaml`
2. **Global inheritance**: Root `myst.yml` imports for entire project  
3. **Location independence**: Files work regardless of directory depth
4. **Format consistency**: Same macros work in LaTeX and MyST
5. **Zero maintenance**: Deep files require no path management

**The macro system just works, everywhere! 🚀** 