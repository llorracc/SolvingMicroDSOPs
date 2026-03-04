# Plan: Script to Replace "Prime" (First Derivative) with Delta (δ) Terminology

## 1. Goal

Replace all uses of the **word/identifier "Prime"** that denote the **first derivative** of a function of a single argument with **delta (δ)**-based naming, in line with existing usage in the repo:

- **LaTeX**: First derivative is already denoted by superscript `\partial` (e.g. `\vFunc^{\partial}`); see `Notation.md` and `_sectn-the-usual-theory.tex`. Some labels and refs still use "Prime" in their names.
- **Python**: Already uses δ in names: `vCntnδ` (marginal value w.r.t. a at continuation), `δ` (marginal utility in `Utility.δ`), and in CodeInfo/docstrings (`\vEndPrd^{\da}`).
- **Notebook**: Figure titles, function names, and data keys still use "uPrime", "vPrime", "PlotuPrimeVSOPrime", etc.

Do **not** change uses of "prime" that mean **next period** (e.g. `c_prime` as a parameter for next-period consumption, or `m'` in prose).

---

## 2. Scope and Exclusions

### 2.1 Replace (derivative meaning)

- **LaTeX**
  - Label/ref/hypertarget names: `eq:vEndPrimeTm1`, `fig:PlotuPrimeVSOPrime`, `eq:KoppaPrime`, `eq:koppaPrime`.
  - Comments and CodeInfo that refer to these labels (e.g. `eq:vEndPrimeTm1`).
  - Prose that says "Prime" for derivative (e.g. "u Prime" as marginal utility) → rephrase to "marginal" or use symbol.
- **Notebook**
  - Markdown: "PlotuPrimeVSOPrime (marginal utility vs …)" → use δ-based figure name and keep description.
  - Code: `compute_uPrime_vs_vPrime_data`, `plot_uPrime_vs_vPrime`, `uPrime_vs_vPrime_data`, dict key `'uPrime'`, and similar.
- **Python**
  - `notebook_solvers.py`: function `compute_uPrime_vs_vPrime_data`, return keys `'uPrime'`, comments "PlotuPrimeVSOPrime", "eq:vEndPrimeTm1".
  - `notebook_plots.py`: function `plot_uPrime_vs_vPrime`, parameter `uPrime_vs_vPrime_data`, docstring/comment references to "uPrime", "vPrime", "PlotuPrimeVSOPrime".
  - `endOfPrd.py`, `endOfPrdMC.py`, `endOfPrd.ipynb`: docstrings that reference `eq:vEndPrimeTm1`.
  - `stages/cons_with_shocks.py`, `solution.py`: comments referencing `eq:vEndPrimeTm1`.
  - `FIGURES.md`: table row for `plot_uPrime_vs_vPrime` and description "u'(c) vs …".

### 2.2 Do **not** replace (next-period or other meaning)

- **Parameter/variable names**: `c_prime` (next-period consumption function), `v_prime` when it denotes "next-period value function" (e.g. in gothic_class), `m'`, `a'` in text.
- **External API**: `scipy.optimize.approx_fprime` (leave as-is).
- **Prose**: Phrases like "next period's" or "prime" in "time-prime" context.
- **LaTeX math**: The *symbol* `^{\prime}` in formulae is handled by the existing plan in `plan-derivative-notation-notebook.md` (replace with `^{\partial}` in math). This script focuses on **identifiers and the word "Prime"**, not the LaTeX prime symbol itself.

### 2.3 Optional / separate pass

- **Figure filename**: `Figures/PlotuPrimeVSOPrime.pdf` (or similar) — renaming requires updating all `\includegraphics` and possibly build scripts; can be a second step or left as legacy filename with updated caption/label only.
- **Private/legacy**: `SolvingMicroDSOP_private_withBrentQToo.ipynb`, `gothic_class.ipynb` — include only if they are in active use.

---

## 3. Naming Convention

- **Python / notebook (Unicode allowed)**  
  Use **δ** where the codebase already does:
  - `uPrime` → `uδ` (or `u_delta` if ASCII-only policy).
  - `vPrime` → `vδ` (or `v_delta`).
  - `compute_uPrime_vs_vPrime_data` → `compute_uδ_vs_vδ_data`.
  - `plot_uPrime_vs_vPrime` → `plot_uδ_vs_vδ`.
  - `uPrime_vs_vPrime_data` → `uδ_vs_vδ_data`.
  - Dict key `'uPrime'` → `'uδ'`.
  - Docstring refs: `eq:vEndPrimeTm1` → `eq:vEndδTm1` or `eq:vEndPartialTm1` (see below).

- **LaTeX labels and refs (ASCII)**  
  Labels must be ASCII-safe; use **Delta** or **Partial**:
  - `eq:vEndPrimeTm1` → `eq:vEndPartialTm1` (matches `\partial`) or `eq:vEndDeltaTm1`.
  - `fig:PlotuPrimeVSOPrime` → `fig:PlotuPartialVsOPartial` or `fig:PlotuDeltaVsODelta` (O = continuation value).
  - `eq:KoppaPrime`, `eq:koppaPrime` → `eq:KoppaDelta` / `eq:koppaDelta` or `eq:KoppaPartial` (choose one and use consistently).
  - All `\ref`, `\label`, `\hypertarget` that use these labels must be updated in the same pass.

- **Figure display names in notebook**  
  Can use "uδ vs vδ" or "marginal u vs marginal v" in markdown; script can replace "PlotuPrimeVSOPrime" with "PlotuδVsVδ" or leave a human-readable title.

---

## 4. Inventory (for script logic)

### 4.1 LaTeX

| Current | Proposed | Files (from grep) |
|--------|----------|-------------------|
| `\label{eq:vEndPrimeTm1}` | `\label{eq:vEndPartialTm1}` | `_sectn-solving-the-next.tex` |
| `\ref{eq:vEndPrimeTm1}` | `\ref{eq:vEndPartialTm1}` | `_sectn-solving-the-next.tex`, `_sectn-method-of-moderation.tex` |
| `\hypertarget{PlotuPrimeVSOPrime}` | `\hypertarget{PlotuPartialVsOPartial}` | `_sectn-solving-the-next.tex` |
| `\label{fig:PlotuPrimeVSOPrime}` | `\label{fig:PlotuPartialVsOPartial}` | `_sectn-solving-the-next.tex` |
| `\ref{fig:PlotuPrimeVSOPrime}` | `\ref{fig:PlotuPartialVsOPartial}` | `_sectn-solving-the-next.tex` |
| `\label{eq:KoppaPrime}` | `\label{eq:KoppaPartial}` | `_sectn-method-of-moderation.tex`, `cctwMoM/value-Rest.tex` |
| `eq:koppaPrime` (in text) | `eq:KoppaPartial` | `_sectn-method-of-moderation.tex` |
| CodeInfo / comments containing `vEndPrimeTm1`, `PlotuPrimeVSOPrime` | Same substitution | Various `.tex` |

### 4.2 Notebook (SolvingMicroDSOPs.ipynb)

- Markdown: string "PlotuPrimeVSOPrime" in figure header; any "uPrime" / "vPrime" in prose.
- Code cells: `compute_uPrime_vs_vPrime_data`, `plot_uPrime_vs_vPrime(…)`, `uPrime_vs_vPrime_data`; dict key `'uPrime'` inside solver/plot logic.

### 4.3 Python

- `notebook_solvers.py`: `compute_uPrime_vs_vPrime_data`, docstring and comments "PlotuPrimeVSOPrime", "eq:vEndPrimeTm1"; return dict key `'uPrime'`.
- `notebook_plots.py`: `plot_uPrime_vs_vPrime`, parameter name, docstring, comments "PlotuPrimeVSOPrime", "u'(c) vs …".
- `endOfPrd.py`: docstrings "eq:vEndPrimeTm1".
- `endOfPrdMC.py`: docstring "eq:vEndPrimeTm1".
- `endOfPrd.ipynb`: same docstring refs.
- `stages/cons_with_shocks.py`: comment "eq:vEndPrimeTm1".
- `solution.py`: comment "eq:vEndPrimeTm1".
- `FIGURES.md`: `plot_uPrime_vs_vPrime` and description text.

---

## 5. Script Design

### 5.1 Inputs and mode

- **Input**: Repository root (or configurable paths for LaTeX, notebook, Python).
- **Modes**: `--dry-run` (report only), `--apply` (write changes). Optionally `--scope=latex|notebook|python|all`.

### 5.2 Replacement table (script data)

Define a single table of (pattern, replacement) pairs, with context to avoid touching "next period" uses:

1. **Identifier / label renames** (whole-word or bounded):
   - `vEndPrimeTm1` → `vEndPartialTm1` (or `vEndDeltaTm1`).
   - `PlotuPrimeVSOPrime` → `PlotuPartialVsOPartial` (and hypertarget/label/ref).
   - `KoppaPrime` → `KoppaPartial`; `koppaPrime` → `koppaPartial`.
   - `uPrime_vs_vPrime` → `uδ_vs_vδ` (Python/notebook).
   - `compute_uPrime_vs_vPrime_data` → `compute_uδ_vs_vδ_data`.
   - `plot_uPrime_vs_vPrime` → `plot_uδ_vs_vδ`.
   - Dict key `'uPrime'` → `'uδ'`.

2. **Exclusions** (don’t replace):
   - `c_prime` (parameter name).
   - `approx_fprime`.
   - Substrings inside words where "prime" means something else (e.g. "primary" — exclude by requiring word boundaries or known context).

### 5.3 Order of operations

1. **Catalog**: Scan all in-scope files and list every occurrence (file, line, current text, proposed replacement). Output a report (e.g. CSV or structured log).
2. **LaTeX pass**: Over `.tex` files, replace label/ref/hypertarget names and comments from the table; use whole-string or regex that respects `\label{...}`, `\ref{...}`, `\hypertarget{...}` and comment lines.
3. **Notebook pass**: Over `SolvingMicroDSOPs.ipynb`, only in markdown and code source lines: apply the same identifier/key renames; do not change output or metadata that might contain cached strings.
4. **Python pass**: Over `Code/Python/*.py` (and optionally `FIGURES.md`), apply renames and key renames; skip excluded names (e.g. `c_prime`, `approx_fprime`).
5. **Verification**: Re-scan for remaining "Prime" in derivative contexts (e.g. grep for `Prime` and manual review of hits), and run tests (e.g. `pytest Code/Python/tests/`) to ensure renames didn’t break call sites.

### 5.4 Safety

- **Backup**: Script should not modify files unless `--apply`; with `--apply`, recommend running from a clean git state so changes can be reverted.
- **Idempotency**: Replacements should be written so that running the script twice does not double-substitute (e.g. replace "Prime" only with the chosen delta/partial name, not "Prime" → "Delta" → "DeltaDelta").
- **Tests**: After applying, run `pytest Code/Python/tests/` and any notebook smoke test; fix broken references (e.g. in tests that reference `compute_uPrime_vs_vPrime_data` or `plot_uPrime_vs_vPrime`).

---

## 6. Implementation Checklist

- [ ] Create script (e.g. `scripts/prime-to-delta.py` or under `Code/Python/tools/`).
- [ ] Implement catalog mode (scan and report).
- [ ] Implement LaTeX replacements (labels, refs, hypertargets, comments).
- [ ] Implement notebook replacements (markdown + code cells; preserve structure).
- [ ] Implement Python replacements (functions, params, keys, docstrings, comments); enforce exclusions.
- [ ] Update `FIGURES.md` and any CI that references figure/function names.
- [ ] Add tests that expect new names (or update existing tests that reference old names).
- [ ] Document in README or CONTRIBUTION how to run the script (e.g. `python scripts/prime-to-delta.py --dry-run` then `--apply`).

---

## 7. Relation to Other Plans

- **`plan-derivative-notation-notebook.md`**: Handles the **math symbol** in the notebook and plot strings (`^{\prime}` → `^{\partial}`). This plan handles **identifiers and the word "Prime"** (→ δ/Delta/Partial). Both can be applied; the script here does not change LaTeX math markup, only label names and code/markdown identifiers.
