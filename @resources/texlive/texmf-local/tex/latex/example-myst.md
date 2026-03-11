---
# MyST frontmatter with Econ-ARK macros
# Include the math section from .econ-ark/generated/jupyter-book-config.yaml
math:
  '\PermGroFac': '\mathcal{G}'
  '\permGroFacInd': '\mathit{G}'
  '\PermGroFacAgg': '\mathscr{G}'
  '\PermGroRte': 'g'
  '\DiscFac': '\beta'
  '\DiscRte': '\nu'
  '\permShkInd': '\psi'
  '\tranShkInd': '\xi'
  '\tranShkEmp': '\theta'
  '\PermShkAgg': '\Psi'
  '\TranShkAgg': '\Theta'
  '\TranShkEmp': '\Theta'
  '\aLvl': '\boldsymbol{\mathit{a}}'
  '\cLvl': '\boldsymbol{\mathit{c}}'
  '\yLvl': '\boldsymbol{\mathit{y}}'
  '\aNrm': 'a'
  '\cNrm': 'c'
  '\yNrm': 'y'
  '\cFunc': '\mathrm{c}'
  '\vFunc': '\mathrm{v}'
  '\aFunc': '\mathrm{a}'
  '\Rfree': '\mathsf{R}'
  '\rfree': '\mathsf{r}'
  '\Risky': '\mathbf{R}'
  '\risky': '\mathbf{r}'
  '\CRRA': '\rho'
  '\CARA': '\alpha'
  '\MPC': '\kappa'
  '\mNrm': 'm'
  '\mLvl': '\boldsymbol{\mathit{m}}'
  '\PermLvl': '\boldsymbol{\mathit{P}}'
  '\util': 'u'
  '\Ex': '\mathbb{E}'
---

# Econ-ARK Mathematical Notation Example (MyST)

This document demonstrates the use of Econ-ARK's standardized mathematical notation in MyST markdown format. All macros are generated from a single source file and are **identical** to those used in LaTeX documents.

## Growth and Discount Factors

The permanent growth factor is denoted $\PermGroFac$, with individual growth factor $\permGroFacInd$ and aggregate growth factor $\PermGroFacAgg$. The corresponding growth rate is $\PermGroRte$.

The discount factor is $\DiscFac$ with rate $\DiscRte$.

## Shocks

### Individual Shocks
- Permanent shock: $\permShkInd$
- Transitory shock: $\tranShkInd$ 
- Employment shock: $\tranShkEmp$

### Aggregate Shocks
- Permanent shock: $\PermShkAgg$
- Transitory shock: $\TranShkAgg$
- Employment shock: $\TranShkEmp$

## Variables by Type

### Level Variables (Boldface Italic)
Individual asset level: $\aLvl$, consumption level: $\cLvl$, income level: $\yLvl$.

### Normalized Variables (Plain)
Asset ratio: $\aNrm$, consumption ratio: $\cNrm$, income ratio: $\yNrm$.

### Function Variables (Upright Roman)
Consumption function: $\cFunc$, value function: $\vFunc$, policy function: $\aFunc$.

## Interest Rates and Returns

The risk-free return factor is $\Rfree$ with rate $\rfree$. The risky return factor is $\Risky$ with rate $\risky$.

## Utility and Preferences

Coefficient of relative risk aversion: $\CRRA$. Coefficient of absolute risk aversion: $\CARA$. Marginal propensity to consume: $\MPC$.

## Mathematical Expression Example

The Bellman equation for the normalized consumption-saving problem:

```{math}
:label: bellman

\vFunc(\mNrm) &= \max_{\cNrm} \left\{ \util(\cNrm) + \DiscFac \Ex[\vFunc(\mNrm')] \right\} \\
\text{subject to:} \quad \mNrm' &= \Rfree/\PermGroFac \cdot (\mNrm - \cNrm) + \yNrm'
```

where $\mNrm' = \mLvl'/\PermLvl'$ is next period's market resources ratio.

:::{note}
**Single Source Consistency**: Notice that this MyST document uses **exactly the same macro names** as the LaTeX example (`example-latex.tex`). This ensures perfect consistency across document formats.
:::

## Cross-references

You can reference equations using MyST syntax. For example, see {eq}`bellman` above.

## Code Integration

MyST also allows inline code and executable content:

```python
# Python code can use the same variable names for clarity
def consumption_function(m_nrm, risk_aversion):
    """
    Consumption function where:
    - m_nrm corresponds to $\mNrm$ in the math
    - risk_aversion corresponds to $\CRRA$ 
    """
    return m_nrm ** (1/risk_aversion)

# Example usage
c_nrm = consumption_function(2.0, 2.0)
print(f"Consumption ratio: {c_nrm:.3f}")
```

## Conclusion

This example shows how the single-source macro system provides **identical notation** across LaTeX and MyST formats. Changes to `.econ-ark/macros.yaml` automatically update both formats.

### Benefits of This Approach

1. **Consistency**: Same macros work in LaTeX and MyST
2. **Maintainability**: Single source of truth
3. **Automation**: Generated files stay in sync
4. **Documentation**: Auto-generated macro lists
5. **Validation**: Catch errors early

### Next Steps

To use this system in your project:

1. Copy the `.econ-ark/` directory to your repository root
2. Run `make macros` to generate files
3. Include generated configs in your documents
4. Edit `.econ-ark/macros.yaml` to add new notation 