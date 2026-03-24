# Econ-ARK standard mathematical notation Documentation

**Version:** 2.0  
**Generated:** 2025-07-15 15:40:43  
**Maintainer:** econ-ark.org

This document lists all available mathematical notation macros for Econ-ARK projects.

## Usage

### In LaTeX files:
```latex
\usepackage{econark-shortcuts}  % Add to preamble
The growth factor is $\PermGroFac$.
```

### In MyST files:

#### Option 1: Jupyter Book
Copy the `math:` section from `jupyter-book-config.yaml` into your `_config.yml`.

#### Option 2: Individual file frontmatter  
Copy the frontmatter from `myst-frontmatter.yaml` into your `.md` files.

#### Option 3: Sphinx
Add the configuration from `sphinx-config.py` to your `conf.py`.

## Available Macros

Total macros: 193


### Behavior (1 macros)

| Command | Output | Description |
|---------|--------|-------------|
| `\MPC` | `\kappa` | Marginal propensity to consume |

### Functions (52 macros)

| Command | Output | Description |
|---------|--------|-------------|
| `\AFunc` | `\mathrm{A}` | Function variable for letter A *(generated)* |
| `\BFunc` | `\mathrm{B}` | Function variable for letter B *(generated)* |
| `\CFunc` | `\mathrm{C}` | Function variable for letter C *(generated)* |
| `\DFunc` | `\mathrm{D}` | Function variable for letter D *(generated)* |
| `\EFunc` | `\mathrm{E}` | Function variable for letter E *(generated)* |
| `\FFunc` | `\mathrm{F}` | Function variable for letter F *(generated)* |
| `\GFunc` | `\mathrm{G}` | Function variable for letter G *(generated)* |
| `\HFunc` | `\mathrm{H}` | Function variable for letter H *(generated)* |
| `\IFunc` | `\mathrm{I}` | Function variable for letter I *(generated)* |
| `\JFunc` | `\mathrm{J}` | Function variable for letter J *(generated)* |
| `\KFunc` | `\mathrm{K}` | Function variable for letter K *(generated)* |
| `\LFunc` | `\mathrm{L}` | Function variable for letter L *(generated)* |
| `\MFunc` | `\mathrm{M}` | Function variable for letter M *(generated)* |
| `\NFunc` | `\mathrm{N}` | Function variable for letter N *(generated)* |
| `\OFunc` | `\mathrm{O}` | Function variable for letter O *(generated)* |
| `\PFunc` | `\mathrm{P}` | Function variable for letter P *(generated)* |
| `\QFunc` | `\mathrm{Q}` | Function variable for letter Q *(generated)* |
| `\RFunc` | `\mathrm{R}` | Function variable for letter R *(generated)* |
| `\SFunc` | `\mathrm{S}` | Function variable for letter S *(generated)* |
| `\TFunc` | `\mathrm{T}` | Function variable for letter T *(generated)* |
| `\UFunc` | `\mathrm{U}` | Function variable for letter U *(generated)* |
| `\VFunc` | `\mathrm{V}` | Function variable for letter V *(generated)* |
| `\WFunc` | `\mathrm{W}` | Function variable for letter W *(generated)* |
| `\XFunc` | `\mathrm{X}` | Function variable for letter X *(generated)* |
| `\YFunc` | `\mathrm{Y}` | Function variable for letter Y *(generated)* |
| `\ZFunc` | `\mathrm{Z}` | Function variable for letter Z *(generated)* |
| `\aFunc` | `\mathrm{a}` | Function variable for letter a *(generated)* |
| `\bFunc` | `\mathrm{b}` | Function variable for letter b *(generated)* |
| `\cFunc` | `\mathrm{c}` | Function variable for letter c *(generated)* |
| `\dFunc` | `\mathrm{d}` | Function variable for letter d *(generated)* |
| `\eFunc` | `\mathrm{e}` | Function variable for letter e *(generated)* |
| `\fFunc` | `\mathrm{f}` | Function variable for letter f *(generated)* |
| `\gFunc` | `\mathrm{g}` | Function variable for letter g *(generated)* |
| `\hFunc` | `\mathrm{h}` | Function variable for letter h *(generated)* |
| `\iFunc` | `\mathrm{i}` | Function variable for letter i *(generated)* |
| `\jFunc` | `\mathrm{j}` | Function variable for letter j *(generated)* |
| `\kFunc` | `\mathrm{k}` | Function variable for letter k *(generated)* |
| `\lFunc` | `\mathrm{l}` | Function variable for letter l *(generated)* |
| `\mFunc` | `\mathrm{m}` | Function variable for letter m *(generated)* |
| `\nFunc` | `\mathrm{n}` | Function variable for letter n *(generated)* |
| `\oFunc` | `\mathrm{o}` | Function variable for letter o *(generated)* |
| `\pFunc` | `\mathrm{p}` | Function variable for letter p *(generated)* |
| `\qFunc` | `\mathrm{q}` | Function variable for letter q *(generated)* |
| `\rFunc` | `\mathrm{r}` | Function variable for letter r *(generated)* |
| `\sFunc` | `\mathrm{s}` | Function variable for letter s *(generated)* |
| `\tFunc` | `\mathrm{t}` | Function variable for letter t *(generated)* |
| `\uFunc` | `\mathrm{u}` | Function variable for letter u *(generated)* |
| `\vFunc` | `\mathrm{v}` | Function variable for letter v *(generated)* |
| `\wFunc` | `\mathrm{w}` | Function variable for letter w *(generated)* |
| `\xFunc` | `\mathrm{x}` | Function variable for letter x *(generated)* |
| `\yFunc` | `\mathrm{y}` | Function variable for letter y *(generated)* |
| `\zFunc` | `\mathrm{z}` | Function variable for letter z *(generated)* |

### Growth (4 macros)

| Command | Output | Description |
|---------|--------|-------------|
| `\PermGroFac` | `\mathcal{G}` | Permanent growth factor |
| `\PermGroFacAgg` | `\mathscr{G}` | Aggregate permanent growth factor |
| `\PermGroRte` | `g` | Permanent growth rate |
| `\permGroFacInd` | `\mathit{G}` | Individual permanent growth factor |

### Modifiers (17 macros)

| Command | Output | Description |
|---------|--------|-------------|
| `\MPCMax` | `\overline{\MPC}` | Maximum value of MPC *(generated)* |
| `\MPCMin` | `\underline{\MPC}` | Minimum value of MPC *(generated)* |
| `\PermGroFacMin` | `\underline{\PermGroFac}` | Minimum value of PermGroFac *(generated)* |
| `\PermShkAllStd` | `\std_{\PermShkAll}` | Standard deviation of PermShkAll *(generated)* |
| `\PermShkAllVar` | `\std^{2}_{\PermShkAll}` | Variance of PermShkAll *(generated)* |
| `\TranShkAggStd` | `\std_{\TranShkAgg}` | Standard deviation of TranShkAgg *(generated)* |
| `\TranShkAggVar` | `\std^{2}_{\TranShkAgg}` | Variance of TranShkAgg *(generated)* |
| `\permShkIndMax` | `\overline{\permShkInd}` | Maximum value of permShkInd *(generated)* |
| `\permShkIndMin` | `\underline{\permShkInd}` | Minimum value of permShkInd *(generated)* |
| `\prstShkIndMax` | `\overline{\prstShkInd}` | Maximum value of prstShkInd *(generated)* |
| `\prstShkIndMin` | `\underline{\prstShkInd}` | Minimum value of prstShkInd *(generated)* |
| `\tranShkAllStd` | `\std_{\tranShkAll}` | Standard deviation of tranShkAll *(generated)* |
| `\tranShkAllVar` | `\std^{2}_{\tranShkAll}` | Variance of tranShkAll *(generated)* |
| `\tranShkEmpMax` | `\overline{\tranShkEmp}` | Maximum value of tranShkEmp *(generated)* |
| `\tranShkEmpMin` | `\underline{\tranShkEmp}` | Minimum value of tranShkEmp *(generated)* |
| `\tranShkIndStd` | `\std_{\tranShkInd}` | Standard deviation of tranShkInd *(generated)* |
| `\tranShkIndVar` | `\std^{2}_{\tranShkInd}` | Variance of tranShkInd *(generated)* |

### Operators (1 macros)

| Command | Output | Description |
|---------|--------|-------------|
| `\std` | `\sigma` | Standard deviation operator |

### Preferences (4 macros)

| Command | Output | Description |
|---------|--------|-------------|
| `\CARA` | `\alpha` | Coefficient of absolute risk aversion |
| `\CRRA` | `\rho` | Coefficient of relative risk aversion |
| `\DiscFac` | `\beta` | Discount factor |
| `\DiscRte` | `\nu` | Discount rate |

### Returns (4 macros)

| Command | Output | Description |
|---------|--------|-------------|
| `\Rfree` | `\mathsf{R}` | Risk-free return factor |
| `\Risky` | `\mathbf{R}` | Risky return factor |
| `\rfree` | `\mathsf{r}` | Risk-free return rate |
| `\risky` | `\mathbf{r}` | Risky return rate |

### Shocks (6 macros)

| Command | Output | Description |
|---------|--------|-------------|
| `\PermShkAgg` | `\Psi` | Aggregate permanent shock |
| `\TranShkAgg` | `\Theta` | Aggregate transitory shock |
| `\TranShkEmp` | `\Theta` | Aggregate transitory shock for employed |
| `\permShkInd` | `\psi` | Individual permanent shock |
| `\tranShkEmp` | `\theta` | Transitory shock for employed |
| `\tranShkInd` | `\xi` | Individual transitory shock |

### Variables (104 macros)

| Command | Output | Description |
|---------|--------|-------------|
| `\ALvl` | `\boldsymbol{\mathit{A}}` | Level variable for letter A *(generated)* |
| `\ANrm` | `A` | Normalized variable for letter A *(generated)* |
| `\BLvl` | `\boldsymbol{\mathit{B}}` | Level variable for letter B *(generated)* |
| `\BNrm` | `B` | Normalized variable for letter B *(generated)* |
| `\CLvl` | `\boldsymbol{\mathit{C}}` | Level variable for letter C *(generated)* |
| `\CNrm` | `C` | Normalized variable for letter C *(generated)* |
| `\DLvl` | `\boldsymbol{\mathit{D}}` | Level variable for letter D *(generated)* |
| `\DNrm` | `D` | Normalized variable for letter D *(generated)* |
| `\ELvl` | `\boldsymbol{\mathit{E}}` | Level variable for letter E *(generated)* |
| `\ENrm` | `E` | Normalized variable for letter E *(generated)* |
| `\FLvl` | `\boldsymbol{\mathit{F}}` | Level variable for letter F *(generated)* |
| `\FNrm` | `F` | Normalized variable for letter F *(generated)* |
| `\GLvl` | `\boldsymbol{\mathit{G}}` | Level variable for letter G *(generated)* |
| `\GNrm` | `G` | Normalized variable for letter G *(generated)* |
| `\HLvl` | `\boldsymbol{\mathit{H}}` | Level variable for letter H *(generated)* |
| `\HNrm` | `H` | Normalized variable for letter H *(generated)* |
| `\ILvl` | `\boldsymbol{\mathit{I}}` | Level variable for letter I *(generated)* |
| `\INrm` | `I` | Normalized variable for letter I *(generated)* |
| `\JLvl` | `\boldsymbol{\mathit{J}}` | Level variable for letter J *(generated)* |
| `\JNrm` | `J` | Normalized variable for letter J *(generated)* |
| `\KLvl` | `\boldsymbol{\mathit{K}}` | Level variable for letter K *(generated)* |
| `\KNrm` | `K` | Normalized variable for letter K *(generated)* |
| `\LLvl` | `\boldsymbol{\mathit{L}}` | Level variable for letter L *(generated)* |
| `\LNrm` | `L` | Normalized variable for letter L *(generated)* |
| `\MLvl` | `\boldsymbol{\mathit{M}}` | Level variable for letter M *(generated)* |
| `\MNrm` | `M` | Normalized variable for letter M *(generated)* |
| `\NLvl` | `\boldsymbol{\mathit{N}}` | Level variable for letter N *(generated)* |
| `\NNrm` | `N` | Normalized variable for letter N *(generated)* |
| `\OLvl` | `\boldsymbol{\mathit{O}}` | Level variable for letter O *(generated)* |
| `\ONrm` | `O` | Normalized variable for letter O *(generated)* |
| `\PLvl` | `\boldsymbol{\mathit{P}}` | Level variable for letter P *(generated)* |
| `\PNrm` | `P` | Normalized variable for letter P *(generated)* |
| `\QLvl` | `\boldsymbol{\mathit{Q}}` | Level variable for letter Q *(generated)* |
| `\QNrm` | `Q` | Normalized variable for letter Q *(generated)* |
| `\RLvl` | `\boldsymbol{\mathit{R}}` | Level variable for letter R *(generated)* |
| `\RNrm` | `R` | Normalized variable for letter R *(generated)* |
| `\SLvl` | `\boldsymbol{\mathit{S}}` | Level variable for letter S *(generated)* |
| `\SNrm` | `S` | Normalized variable for letter S *(generated)* |
| `\TLvl` | `\boldsymbol{\mathit{T}}` | Level variable for letter T *(generated)* |
| `\TNrm` | `T` | Normalized variable for letter T *(generated)* |
| `\ULvl` | `\boldsymbol{\mathit{U}}` | Level variable for letter U *(generated)* |
| `\UNrm` | `U` | Normalized variable for letter U *(generated)* |
| `\VLvl` | `\boldsymbol{\mathit{V}}` | Level variable for letter V *(generated)* |
| `\VNrm` | `V` | Normalized variable for letter V *(generated)* |
| `\WLvl` | `\boldsymbol{\mathit{W}}` | Level variable for letter W *(generated)* |
| `\WNrm` | `W` | Normalized variable for letter W *(generated)* |
| `\XLvl` | `\boldsymbol{\mathit{X}}` | Level variable for letter X *(generated)* |
| `\XNrm` | `X` | Normalized variable for letter X *(generated)* |
| `\YLvl` | `\boldsymbol{\mathit{Y}}` | Level variable for letter Y *(generated)* |
| `\YNrm` | `Y` | Normalized variable for letter Y *(generated)* |
| `\ZLvl` | `\boldsymbol{\mathit{Z}}` | Level variable for letter Z *(generated)* |
| `\ZNrm` | `Z` | Normalized variable for letter Z *(generated)* |
| `\aLvl` | `\boldsymbol{\mathit{a}}` | Level variable for letter a *(generated)* |
| `\aNrm` | `a` | Normalized variable for letter a *(generated)* |
| `\bLvl` | `\boldsymbol{\mathit{b}}` | Level variable for letter b *(generated)* |
| `\bNrm` | `b` | Normalized variable for letter b *(generated)* |
| `\cLvl` | `\boldsymbol{\mathit{c}}` | Level variable for letter c *(generated)* |
| `\cNrm` | `c` | Normalized variable for letter c *(generated)* |
| `\dLvl` | `\boldsymbol{\mathit{d}}` | Level variable for letter d *(generated)* |
| `\dNrm` | `d` | Normalized variable for letter d *(generated)* |
| `\eLvl` | `\boldsymbol{\mathit{e}}` | Level variable for letter e *(generated)* |
| `\eNrm` | `e` | Normalized variable for letter e *(generated)* |
| `\fLvl` | `\boldsymbol{\mathit{f}}` | Level variable for letter f *(generated)* |
| `\fNrm` | `f` | Normalized variable for letter f *(generated)* |
| `\gLvl` | `\boldsymbol{\mathit{g}}` | Level variable for letter g *(generated)* |
| `\gNrm` | `g` | Normalized variable for letter g *(generated)* |
| `\hLvl` | `\boldsymbol{\mathit{h}}` | Level variable for letter h *(generated)* |
| `\hNrm` | `h` | Normalized variable for letter h *(generated)* |
| `\iLvl` | `\boldsymbol{\mathit{i}}` | Level variable for letter i *(generated)* |
| `\iNrm` | `i` | Normalized variable for letter i *(generated)* |
| `\jLvl` | `\boldsymbol{\mathit{j}}` | Level variable for letter j *(generated)* |
| `\jNrm` | `j` | Normalized variable for letter j *(generated)* |
| `\kLvl` | `\boldsymbol{\mathit{k}}` | Level variable for letter k *(generated)* |
| `\kNrm` | `k` | Normalized variable for letter k *(generated)* |
| `\lLvl` | `\boldsymbol{\mathit{l}}` | Level variable for letter l *(generated)* |
| `\lNrm` | `l` | Normalized variable for letter l *(generated)* |
| `\mLvl` | `\boldsymbol{\mathit{m}}` | Level variable for letter m *(generated)* |
| `\mNrm` | `m` | Normalized variable for letter m *(generated)* |
| `\nLvl` | `\boldsymbol{\mathit{n}}` | Level variable for letter n *(generated)* |
| `\nNrm` | `n` | Normalized variable for letter n *(generated)* |
| `\oLvl` | `\boldsymbol{\mathit{o}}` | Level variable for letter o *(generated)* |
| `\oNrm` | `o` | Normalized variable for letter o *(generated)* |
| `\pLvl` | `\boldsymbol{\mathit{p}}` | Level variable for letter p *(generated)* |
| `\pNrm` | `p` | Normalized variable for letter p *(generated)* |
| `\qLvl` | `\boldsymbol{\mathit{q}}` | Level variable for letter q *(generated)* |
| `\qNrm` | `q` | Normalized variable for letter q *(generated)* |
| `\rLvl` | `\boldsymbol{\mathit{r}}` | Level variable for letter r *(generated)* |
| `\rNrm` | `r` | Normalized variable for letter r *(generated)* |
| `\sLvl` | `\boldsymbol{\mathit{s}}` | Level variable for letter s *(generated)* |
| `\sNrm` | `s` | Normalized variable for letter s *(generated)* |
| `\tLvl` | `\boldsymbol{\mathit{t}}` | Level variable for letter t *(generated)* |
| `\tNrm` | `t` | Normalized variable for letter t *(generated)* |
| `\uLvl` | `\boldsymbol{\mathit{u}}` | Level variable for letter u *(generated)* |
| `\uNrm` | `u` | Normalized variable for letter u *(generated)* |
| `\vLvl` | `\boldsymbol{\mathit{v}}` | Level variable for letter v *(generated)* |
| `\vNrm` | `v` | Normalized variable for letter v *(generated)* |
| `\wLvl` | `\boldsymbol{\mathit{w}}` | Level variable for letter w *(generated)* |
| `\wNrm` | `w` | Normalized variable for letter w *(generated)* |
| `\xLvl` | `\boldsymbol{\mathit{x}}` | Level variable for letter x *(generated)* |
| `\xNrm` | `x` | Normalized variable for letter x *(generated)* |
| `\yLvl` | `\boldsymbol{\mathit{y}}` | Level variable for letter y *(generated)* |
| `\yNrm` | `y` | Normalized variable for letter y *(generated)* |
| `\zLvl` | `\boldsymbol{\mathit{z}}` | Level variable for letter z *(generated)* |
| `\zNrm` | `z` | Normalized variable for letter z *(generated)* |
