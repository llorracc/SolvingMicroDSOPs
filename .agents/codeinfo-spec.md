# CodeInfo Annotation Specification

**Spec version: 1.0**

> **Quick start:**
> - Read this before adding or editing `%% CodeInfo:` annotations in `.tex` files.
> - Covers: tag vocabulary, key-value syntax, placement rules, status values.
> - See also: [orientation-latex-math.md](orientation-latex-math.md) for where equations live; [orientation-code.md](orientation-code.md) for the Python modules these annotations point to.

This document defines the `%% CodeInfo:` comment convention used throughout the LaTeX source to provide structured metadata that an AI (or human) can use to connect mathematical content to code.

---

## Prefix and syntax

Every annotation begins with `%% CodeInfo:` followed by a **tag** and semicolon-separated key-value pairs:

```latex
%% CodeInfo:tag key1=val1; key2=val2; key3=val3
```

- **Semicolons** separate key-value pairs.
- **Values** run from the `=` to the next `;` or end of line; no quoting needed.
- **Multi-line continuation**: use `%% CodeInfo+:` on subsequent lines.

```latex
%% CodeInfo:eq label=eq:cEuler; computes=Euler equation for consumption
%% CodeInfo+: inputs=cNrm_t, DiscFac, Rfree, PermGroFac, cNrm_tp1; outputs=cNrm_t
%% CodeInfo+: python_func=endOfPrd.vCntnδ; module=Code/Python/endOfPrd.py; status=implemented
```

These comments are invisible in the compiled PDF.

---

## Tag vocabulary

| Tag | Purpose | Common keys |
|-----|---------|-------------|
| `var` | Maps a LaTeX macro to its Python name | `latex`, `python`, `type`, `desc` |
| `func` | Maps a LaTeX function to a Python callable | `latex`, `python`, `signature`, `module`, `desc` |
| `param` | Maps a LaTeX parameter to its Python name and default | `latex`, `python`, `default`, `units`, `desc` |
| `eq` | Describes what an equation computes | `label`, `computes`, `inputs`, `outputs`, `python_func`, `python_equiv`, `module`, `status` |
| `stage` | Describes a modular stage | `name`, `control`, `arrival_state`, `continuation_state`, `python_class`, `module` |
| `figure` | Records figure provenance | `label`, `shows`, `generator`, `status`, `target_generator`, `output` |
| `algo` | Describes an algorithm or procedure | `name`, `inputs`, `outputs`, `python_func`, `module`, `desc` |
| `connector` | Documents a connector between stages/periods | `from`, `to`, `type_constraint`, `python_class` |
| `dataflow` | Traces how values flow between equations | `chain`, `desc` |

---

## Tag details

### `var` -- variable mapping

```latex
%% CodeInfo:var latex=\mNrm; python=mNrm; type=float; desc=normalized market resources (m-type)
```

| Key | Required | Description |
|-----|----------|-------------|
| `latex` | yes | The LaTeX macro (e.g. `\mNrm`) |
| `python` | yes | The Python variable name |
| `type` | no | Python type (`float`, `np.ndarray`, etc.) |
| `desc` | no | Brief description |

### `func` -- function mapping

```latex
%% CodeInfo:func latex=\uFunc; python=Utility; signature=Utility(c, CRRA); module=Code/Python/resources.py
```

| Key | Required | Description |
|-----|----------|-------------|
| `latex` | yes | The LaTeX function macro |
| `python` | yes | Python callable (class or function) |
| `signature` | no | Call signature |
| `module` | no | File path |
| `desc` | no | Brief description |

### `param` -- parameter mapping

```latex
%% CodeInfo:param latex=\DiscFac; python=DiscFac; default=0.96; desc=discount factor (beta)
```

| Key | Required | Description |
|-----|----------|-------------|
| `latex` | yes | The LaTeX parameter macro |
| `python` | yes | Python variable name |
| `default` | no | Default numerical value |
| `units` | no | Units or dimensionality |
| `desc` | no | Brief description |

### `eq` -- equation annotation

```latex
%% CodeInfo:eq label=eq:mLvl; computes=market resources; inputs=kLvl, Rfree, yLvl; outputs=mLvl
%% CodeInfo+: python_equiv=mLvl = kLvl * Rfree + pLvl * tranShkEmp; status=inline
```

| Key | Required | Description |
|-----|----------|-------------|
| `label` | yes | The `\label{...}` of the equation |
| `computes` | yes | What the equation computes (plain English) |
| `inputs` | no | Comma-separated input variables |
| `outputs` | no | Comma-separated output variables |
| `python_func` | no | Python function that implements it |
| `python_equiv` | no | Inline Python expression equivalent |
| `module` | no | File path of the implementing module |
| `status` | no | `implemented`, `inline`, `STATIC-LEGACY`, `TODO` |

### `stage` -- stage description

```latex
%% CodeInfo:stage name=cons-noshocks; control=cNrm; arrival_state=mNrm; continuation_state=aNrm
%% CodeInfo+: python_class=Stage; module=Code/Python/solution.py
```

### `figure` -- figure provenance

```latex
%% CodeInfo:figure label=fig:PlotcTm1Simple; shows=cFunc T-1 vs approximation
%% CodeInfo+: generator=Code/Python/SolvingMicroDSOP_private_withBrentQToo.py; status=STATIC-LEGACY
%% CodeInfo+: target_generator=Code/Python/figures/plot_cTm1_simple.py; output=Figures/PlotcTm1Simple.pdf
```

| Key | Required | Description |
|-----|----------|-------------|
| `label` | yes | The `\label{...}` of the figure |
| `shows` | yes | What the figure depicts |
| `generator` | no | Python file that currently generates it |
| `status` | no | `implemented` or `STATIC-LEGACY` |
| `target_generator` | no | Planned Python file (if not yet implemented) |
| `output` | no | Output file path |

### `algo` -- algorithm description

```latex
%% CodeInfo:algo name=EGM; inputs=vEndPrd_partial, aVec; outputs=mVec_egm, cVec_egm
%% CodeInfo+: python_func=endOfPrd.cCntn; module=Code/Python/endOfPrd.py; desc=Endogenous Grid Method
```

### `connector` -- connector documentation

```latex
%% CodeInfo:connector from=aNrm; to=kNrm; type_constraint=k-type; python_class=CnctrComp
```

### `dataflow` -- cross-equation tracing

```latex
%% CodeInfo:dataflow chain=eq:vEndPrimeTm1 -> eq:cGoth -> eq:consumedfn -> EGM
%% CodeInfo+: desc=transformation chain from marginal value to consumed function to endogenous grid
```

---

## Placement rules

| Annotation type | Placement |
|----------------|-----------|
| `var`, `param`, `func` | Immediately after the first rendered appearance |
| `eq` | Just after `\end{equation}` or inline after the `%%% Unified:` line |
| `figure` | Just before `\end{figure}` |
| `stage` | Just after the table that defines the stage's perches |
| `algo` | At the start of the subsection describing the algorithm |
| `connector` | Just after the connector definition or table |
| `dataflow` | Near the cross-equation derivation passage |

---

## Relationship to existing annotations

The `%%% Unified:` and `\UnifiedNote{...}` annotations map equations to the bellman-ddsl unified framework. `%% CodeInfo:` annotations are complementary: they map to **Python code** in this repository. Both can coexist on the same equation. The `%%% Unified:` line always comes first (inside the equation environment); `%% CodeInfo:` follows (outside or just after the environment).

---

## Status values

- `implemented` -- Python code exists and generates the correct output.
- `inline` -- The equation is a simple identity computed inline (no standalone function).
- `STATIC-LEGACY` -- The figure/table was generated by legacy code (MATLAB/Mathematica) and is a static file; Python replacement is desired.
- `TODO` -- No code exists yet; this is a target for future implementation.
