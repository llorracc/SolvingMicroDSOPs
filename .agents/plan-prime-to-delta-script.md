# Plan: Script to Replace "Prime" (First Derivative) with Delta (δ) Terminology

> **Lessons from prior attempt (2026-02-28)**: An earlier version of `scripts/prime_to_delta.py` was applied at commit `3771b951`. That version contained only two replacement tables (`CODE_REPLACEMENTS` and `TEX_REPLACEMENTS`) covering label/ref/identifier renames in Python, notebooks, and `.tex` files. It did **not** contain the `LATEX_P_REPLACEMENTS` table and did **not** process `.sty` files. The short-form `\vP*` macro renames (`\vPCntn` → `\vδCntn`, etc.) were added to the script in a later commit but the updated script was **never re-run with `--apply`**. As a result, all `\vP*` macro names persist in both `@local/local-macros.sty` (definitions) and the `.tex` files that use them.
>
> **The regenerated script must**:
> 1. Include the `LATEX_P_REPLACEMENTS` table from the start.
> 2. Process `.sty` files (especially `@local/local-macros.sty` and `@resources/texlive/texmf-local/tex/latex/econark-shortcuts.sty`) in the **same pass** as `.tex` files, so macro definitions and usages are renamed atomically.
> 3. Be idempotent: already-renamed identifiers from the prior run must not be double-substituted.

## 1. Goal

Replace all uses of the **word/identifier "Prime"** that denote the **first derivative** of a function of a single argument with **delta (δ)**-based naming, in line with existing usage in the repo. Also apply two related renames:

- **LaTeX**: First derivative is already denoted by superscript `\partial` (e.g. `\vFunc^{\partial}`); see `Notation.md` and `_sectn-the-usual-theory.tex`. Some labels and refs still use "Prime" in their names.
- **Python**: Already uses δ in names: `vCntnδ` (marginal value w.r.t. a at continuation), `δ` (marginal utility in `Utility.δ`), and in CodeInfo/docstrings (`\vEndPrd^{\da}`).
- **Notebook**: Figure titles, function names, and data keys still use "uPrime", "vPrime", "PlotuPrimeVSOPrime", etc. These **will** be renamed by the script (same replacements as Python code).

**Next-period "prime" → "Nxt"**: Change uses of "prime" that mean **next period** (e.g. `c_prime` as a parameter for next-period consumption, or `m'` in prose) to use **"Nxt"** in place of prime (e.g. `c_Nxt`, or prose that refers to "next period" explicitly).

**"O" (Other/continuation value) → "vCntn"**: Where **"O"** signified "Other" or the continuation version of the value function, replace with **"vCntn"** (e.g. OPrime → vCntnδ, figure names like PlotuPrimeVSOPrime → Plot_ud_VS_vCntnd).

**Short-form "P" abbreviations for "prime" → δ**: Where `P` is short for "prime" (derivative), replace with δ. This includes shorthand like `uPPP` (third derivative), `uPP` (second derivative), `uP` (first derivative), and the same for `v` and `c`. Replace triple first, then double, then single to avoid partial matches. These appear in:
- **LaTeX macros**: `\uPPP` → `\uδδδ`, `\uPP` → `\uδδ`, `\uP` → `\uδ` (defined in `econark-shortcuts.sty`; redefined in `econark_demacro_demacro.sty`).
- **LaTeX local macros** (CRITICAL — must be renamed atomically with `.tex` usages): `\vPCntn` → `\vδCntn`, `\vPDcsn` → `\vδDcsn`, `\vPArvl` → `\vδArvl`, etc. (defined in `@local/local-macros.sty`; used in `.tex` files like `Equations/vBegtpdefn.tex`, `cuts/sec_notation.tex`).
- **Python code**: `uP` as a variable (e.g. `uP=self.uFunc.δ` in `endOfPrd.py`); `vP` as parameter name in `solution.py`.
- **Mathematica readme**: `\uP`, `\uPP` used in `Code-private/Mathematica-Code_ReadMe.tex`.

**Filenames and "vs"**: Whenever "vs" is part of a filename (or a function/figure name that corresponds to a filename), use **"VS"** (upper case), e.g. `compute_uδ_VS_vCntnδ_data` not `compute_uδ_vs_vCntnδ_data`.

**Name alignment**: In every instance where there are corresponding LaTeX macros and Python code objects or filenames, the names should be **identical** except that underscores are allowed in Python and in filenames for readability (e.g. LaTeX `fig:Plot_ud_VS_vCntnd`, Python `compute_uδ_VS_vCntnδ_data`).

---

## 2. Scope and Exclusions

### 2.1 Replace (derivative meaning)

- **LaTeX**
  - Label/ref/hypertarget names: `eq:vEndPrimeTm1`, `fig:PlotuPrimeVSOPrime`, `eq:KoppaPrime`, `eq:koppaPrime`. Use **δ** in labels (same as Python); use **vCntn** where "O" meant continuation value.
  - Comments and CodeInfo that refer to these labels (e.g. `eq:vEndPrimeTm1`).
  - Prose that says "Prime" for derivative (e.g. "u Prime" as marginal utility) → rephrase to "marginal" or use symbol.
  - **`.sty` macro definitions AND all `.tex` usages — atomically**: The macro **names** `\vPCntn`, `\vPDcsn`, `\vPArvl`, `\vPArvlNxt`, `\vPBegPrdNxt`, `\vPCntnNxt`, `\vPDcsnNxt` are defined in `@local/local-macros.sty` and used in `.tex` files. The `\uP`, `\uPP`, `\uPPP` macros are defined in `@resources/texlive/texmf-local/tex/latex/econark-shortcuts.sty` and `econark_demacro_demacro.sty`. Renaming these macro names requires changing **both** the `\newcommand{\vPCntn}` definition and every `\vPCntn` usage in `.tex` files **in the same script pass**. If one is changed without the other, the LaTeX build breaks.
- **Notebook**
  - Markdown: "PlotuPrimeVSOPrime (marginal utility vs …)" → use δ-based figure name (with **VS** uppercase) and keep description.
  - Code: `compute_uPrime_vs_vPrime_data` → `compute_uδ_VS_vCntnδ_data`, `plot_uPrime_vs_vPrime` → `plot_uδ_VS_vCntnδ`, `uPrime_vs_vPrime_data` → `uδ_VS_vCntnδ_data`, dict key `'uPrime'` → `'uδ'`, and similar; **VS** uppercase in names that mirror filenames.
- **Python**
  - `notebook_solvers.py`: function `compute_uPrime_vs_vPrime_data`, return keys `'uPrime'`, comments "PlotuPrimeVSOPrime", "eq:vEndPrimeTm1".
  - `notebook_plots.py`: function `plot_uPrime_vs_vPrime`, parameter `uPrime_vs_vPrime_data`, docstring/comment references to "uPrime", "vPrime", "PlotuPrimeVSOPrime".
  - `endOfPrd.py`, `endOfPrdMC.py`, `endOfPrd.ipynb`: docstrings that reference `eq:vEndPrimeTm1`.
  - `stages/cons_with_shocks.py`, `solution.py`: comments referencing `eq:vEndPrimeTm1`.
  - `FIGURES.md`: table row for `plot_uPrime_vs_vPrime` and description "u'(c) vs …".

### 2.2 Replace (next-period meaning): "prime" → "Nxt"

- **Parameter/variable names**: `c_prime` (next-period consumption) → `c_Nxt`; `v_prime` when it denotes "next-period value function" → `v_Nxt` (e.g. in gothic_class).
- **Prose**: Where `m'`, `a'` or "prime" in text means next period, rephrase to use "Nxt" or "next period" (e.g. variable names `m_Nxt`, `a_Nxt` where appropriate).

### 2.3 Do **not** replace

- **External API**: `scipy.optimize.approx_fprime` (leave as-is).
- **Prose**: Phrases like "next period's" where no identifier is being renamed.
- **LaTeX math**: The *symbol* `^{\prime}` in formulae is handled by the existing plan in `plan-derivative-notation-notebook.md` (replace with `^{\partial}` in math). This script focuses on **identifiers and the word "Prime"**, not the LaTeX prime symbol itself.
- **Substrings**: "primary", or "prime" inside words with another meaning — exclude by context.

### 2.4 Optional / separate pass

- **Figure filename**: `Figures/PlotuPrimeVSOPrime.pdf` (or similar) — renaming requires updating all `\includegraphics` and possibly build scripts; use same stem as labels (e.g. `Plot_ud_VS_vCntnd` with **VS** uppercase).
- **Private/legacy**: `SolvingMicroDSOP_private_withBrentQToo.ipynb`, `gothic_class.ipynb` — include only if they are in active use.

---

## 3. Naming Convention

- **Identical names across LaTeX, Python, and filenames**  
  Where there are corresponding LaTeX macros/labels and Python code objects or filenames, use the **same name** in all contexts. Underscores are allowed in Python and in filenames for readability (e.g. `compute_uδ_VS_vCntnδ_data`); LaTeX may use the same token sequence with or without underscores (e.g. `fig:Plot_ud_VS_vCntnd`).

- **Derivative "Prime" → δ (Python, notebook, LaTeX)**  
  Use **δ** consistently (Unicode U+03B4); LaTeX labels and refs may use δ the same as code:
  - `uPrime` → `uδ` (marginal utility); `vPrime` / **O** (Other/continuation) → `vCntnδ`.
  - `compute_uPrime_vs_vPrime_data` → `compute_uδ_VS_vCntnδ_data` (**VS** uppercase in filenames/function names).
  - `plot_uPrime_vs_vPrime` → `plot_uδ_VS_vCntnδ`.
  - `uPrime_vs_vPrime_data` → `uδ_VS_vCntnδ_data`.
  - Dict key `'uPrime'` → `'uδ'`.
  - Figure/label: `PlotuPrimeVSOPrime` → `Plot_ud_VS_vCntnd` (O → vCntn, **VS** uppercase).
  - `eq:vEndPrimeTm1` → `eq:vEndδTm1`; `eq:KoppaPrime` / `eq:koppaPrime` → `eq:Koppaδ` / `eq:koppaδ` (or keep Koppa as-is if it is unrelated to "O").
  - All `\ref`, `\label`, `\hypertarget` updated in the same pass.

- **Next-period "prime" → Nxt**  
  - `c_prime` → `c_Nxt`; `v_prime` (next-period value) → `v_Nxt`; in prose, use "Nxt" or "next period" where an identifier is meant.

- **"vs" in filenames / figure names → VS (uppercase)**  
  Any identifier that corresponds to a filename or figure must use **VS** not "vs", e.g. `compute_uδ_VS_vCntnδ_data`, `Plot_ud_VS_vCntnd`.

- **Short-form P abbreviations → δ (LaTeX macros, Python variables)**  
  Replace in order: triple, double, single (to avoid partial matches):
  - `\uPPP` → `\uδδδ`; `\uPP` → `\uδδ`; `\uP` → `\uδ` (LaTeX macro definitions and usages).
  - `\vPCntn` → `\vδCntn`; `\vPDcsn` → `\vδDcsn`; `\vPArvl` → `\vδArvl`; `\vPArvlNxt` → `\vδArvlNxt`; `\vPBegPrdNxt` → `\vδBegPrdNxt`; `\vPCntnNxt` → `\vδCntnNxt`; `\vPDcsnNxt` → `\vδDcsnNxt` (LaTeX macro definitions and usages).
  - Python: `uP` (variable) → `uδ`; `vP` (variable/parameter) → `vδ` where P means derivative. Be careful: `vP` in `solution.py` (`vinv_to_v(vP, rho)`) uses P to mean "processed/transformed value", not derivative — verify context before replacing.

- **Figure display names in notebook**  
  Can use "uδ vs vδ" or "marginal u vs marginal v" in markdown; figure identifier in code should be `Plot_ud_VS_vCntnd` (VS uppercase).

---

## 4. Inventory (for script logic)

### 4.1 LaTeX

| Current | Proposed | Files (from grep) |
|--------|----------|-------------------|
| `\label{eq:vEndPrimeTm1}` | `\label{eq:vEndδTm1}` | `_sectn-solving-the-next.tex` |
| `\ref{eq:vEndPrimeTm1}` | `\ref{eq:vEndδTm1}` | `_sectn-solving-the-next.tex`, `_sectn-method-of-moderation.tex` |
| `\hypertarget{PlotuPrimeVSOPrime}` | `\hypertarget{Plot_ud_VS_vCntnd}` | `_sectn-solving-the-next.tex` |
| `\label{fig:PlotuPrimeVSOPrime}` | `\label{fig:Plot_ud_VS_vCntnd}` | `_sectn-solving-the-next.tex` |
| `\ref{fig:PlotuPrimeVSOPrime}` | `\ref{fig:Plot_ud_VS_vCntnd}` | `_sectn-solving-the-next.tex` |
| `\label{eq:KoppaPrime}` | `\label{eq:Koppaδ}` | `_sectn-method-of-moderation.tex`, `cctwMoM/value-Rest.tex` |
| `eq:koppaPrime` (in text) | `eq:koppaδ` | `_sectn-method-of-moderation.tex` |
| CodeInfo / comments containing `vEndPrimeTm1`, `PlotuPrimeVSOPrime` | Same substitution (δ, vCntn, VS) | Various `.tex` |

### 4.1b `.sty` macro name renames (CRITICAL — missed in prior run)

These macros are **defined** in `.sty` and **used** in `.tex`. Both must be renamed in the same pass.

| Current definition | Proposed | Defined in | Used in |
|-------------------|----------|-----------|---------|
| `\newcommand{\vPCntn}{\vFunc^{\da}_{\Cntn}}` | `\newcommand{\vδCntn}{…}` | `@local/local-macros.sty:105` | (only via compound expansion) |
| `\newcommand{\vPCntnNxt}{\vFunc^{\da}_{\ArvlNxt}}` | `\newcommand{\vδCntnNxt}{…}` | `@local/local-macros.sty:106` | (only via compound expansion) |
| `\newcommand{\vPDcsn}{\vFunc^{m}_{\Dcsn}}` | `\newcommand{\vδDcsn}{…}` | `@local/local-macros.sty:107` | (only via compound expansion) |
| `\newcommand{\vPDcsnNxt}{\vFunc^{m}_{\DcsnNxt}}` | `\newcommand{\vδDcsnNxt}{…}` | `@local/local-macros.sty:108` | (only via compound expansion) |
| `\newcommand{\vPArvl}{\vFunc^{k}_{\Arvl}}` | `\newcommand{\vδArvl}{…}` | `@local/local-macros.sty:109` | (only via compound expansion) |
| `\newcommand{\vPArvlNxt}{\vFunc^{k}_{\ArvlNxt}}` | `\newcommand{\vδArvlNxt}{…}` | `@local/local-macros.sty:110` | `cuts/sec_notation.tex` |
| `\newcommand{\vPBegPrdNxt}{\vFunc^{k}_{\BegPrdNxt}}` | `\newcommand{\vδBegPrdNxt}{…}` | `@local/local-macros.sty:111` | `Equations/vBegtpdefn.tex` |
| `\providecommand{\uPPP}{…}` | `\providecommand{\uδδδ}{…}` | `econark-shortcuts.sty:228` | various `.tex` |
| `\providecommand{\uPP}{…}` | `\providecommand{\uδδ}{…}` | `econark-shortcuts.sty:229` | various `.tex` |
| `\providecommand{\uP}{…}` | `\providecommand{\uδ}{…}` | `econark-shortcuts.sty:230` | various `.tex` |

**Note**: The `econark_demacro_demacro.sty` file contains matching `\renewcommand` definitions that must also be renamed.

### 4.2 Notebook (SolvingMicroDSOPs.ipynb)

- Markdown: string "PlotuPrimeVSOPrime" in figure header → `Plot_ud_VS_vCntnd`; any "uPrime" / "vPrime" in prose.
- Code cells: `compute_uPrime_vs_vPrime_data` → `compute_uδ_VS_vCntnδ_data`, `plot_uPrime_vs_vPrime` → `plot_uδ_VS_vCntnδ`, `uPrime_vs_vPrime_data` → `uδ_VS_vCntnδ_data`; dict key `'uPrime'` → `'uδ'`; **VS** uppercase.

### 4.3 Python

- `notebook_solvers.py`: `compute_uPrime_vs_vPrime_data`, docstring and comments "PlotuPrimeVSOPrime", "eq:vEndPrimeTm1"; return dict key `'uPrime'`.
- `notebook_plots.py`: `plot_uPrime_vs_vPrime`, parameter name, docstring, comments "PlotuPrimeVSOPrime", "u'(c) vs …".
- `endOfPrd.py`: docstrings "eq:vEndPrimeTm1".
- `endOfPrdMC.py`: docstring "eq:vEndPrimeTm1".
- `endOfPrd.ipynb`: same docstring refs.
- `stages/cons_with_shocks.py`: comment "eq:vEndPrimeTm1".
- `solution.py`: comment "eq:vEndPrimeTm1".
- `FIGURES.md`: `plot_uPrime_vs_vPrime` and description text.
- Next-period renames: `c_prime` → `c_Nxt`, `v_prime` (next-period) → `v_Nxt` where applicable.

---

## 5. Script Design

### 5.1 Inputs and mode

- **Input**: Repository root (or configurable paths for LaTeX, notebook, Python).
- **Modes**: `--dry-run` (report only), `--apply` (write changes). Optionally `--scope=latex|notebook|python|all`.

### 5.2 Replacement table (script data)

The script must define **four** replacement tables, all present from the initial version:

1. **`SHARED_REPLACEMENTS`** — Derivative "Prime" and "O" (continuation) → δ / vCntn (longest first). Applied to `.py`, `.md`, `.ipynb`, `.tex`, `.sty`:
   - `PlotuPrimeVSOPrime` → `Plot_ud_VS_vCntnd` (O → vCntn, **VS** uppercase; same name in LaTeX, Python, filenames).
   - `compute_uPrime_vs_vPrime_data` → `compute_uδ_VS_vCntnδ_data`.
   - `plot_uPrime_vs_vPrime` → `plot_uδ_VS_vCntnδ`.
   - `uPrime_vs_vPrime_data` → `uδ_VS_vCntnδ_data`.
   - `vEndPrimeTm1` → `vEndδTm1`.
   - `eq:vEndPrimeTm1` → `eq:vEndδTm1`.
   - `KoppaPrime` → `Koppaδ`; `koppaPrime` → `koppaδ`.
   - `uPrime` (derivative) → `uδ`; dict key `'uPrime'` → `'uδ'`.
   - `vPrime` / O (continuation) → `vCntnδ` where it denotes the continuation value derivative.

2. **`LATEX_P_REPLACEMENTS`** — Short-form P abbreviation **macro names** → δ. Applied to `.tex` AND `.sty` files (longest first):
   - `\\uPPP` → `\\uδδδ`; `\\uPP` → `\\uδδ`; `\\uP` → `\\uδ`.
   - `\\vPCntnNxt` → `\\vδCntnNxt`; `\\vPCntn` → `\\vδCntn`.
   - `\\vPDcsnNxt` → `\\vδDcsnNxt`; `\\vPDcsn` → `\\vδDcsn`.
   - `\\vPArvlNxt` → `\\vδArvlNxt`; `\\vPArvl` → `\\vδArvl`.
   - `\\vPBegPrdNxt` → `\\vδBegPrdNxt`.

   **CRITICAL**: These renames change LaTeX **command names**. The `\newcommand{\vPCntn}{…}` definition in `@local/local-macros.sty` and every `\vPCntn` usage in `.tex` files must be renamed in the **same pass**. The script must process `.sty` and `.tex` with the same `LATEX_P_REPLACEMENTS` table. If definitions are renamed without usages (or vice versa), the LaTeX build breaks immediately.

3. **`NEXT_PERIOD_REPLACEMENTS`** — Next-period "prime" → Nxt. Applied to `.py` and `.ipynb` only:
   - `c_prime` → `c_Nxt`; `v_prime` (when next-period value) → `v_Nxt`; similar parameter names.

4. **Exclusions** (don't replace):
   - `approx_fprime`.
   - Substrings inside words (e.g. "primary") — exclude by context.

### 5.3 Order of operations

1. **Catalog**: Scan all in-scope files and list every occurrence (file, line, current text, proposed replacement). Output a report (e.g. CSV or structured log).
2. **LaTeX + STY pass (atomic)**: Over **all** `.tex` and `.sty` files (including `@local/local-macros.sty`, `@resources/texlive/texmf-local/tex/latex/econark-shortcuts.sty`, `@resources/texlive/texmf-local/tex/latex/econark_demacro_demacro.sty`), apply **both** `SHARED_REPLACEMENTS` and `LATEX_P_REPLACEMENTS`. This ensures that macro definitions (`\newcommand{\vPCntn}`) and macro usages (`\vPCntn` in `.tex`) are renamed together. Use whole-string matching; respect `\label{...}`, `\ref{...}`, `\hypertarget{...}` and comment lines.
3. **Notebook pass**: Over `SolvingMicroDSOPs.ipynb`, only in markdown and code source lines: apply `SHARED_REPLACEMENTS` and `NEXT_PERIOD_REPLACEMENTS`; do not change output or metadata that might contain cached strings.
4. **Python pass**: Over `Code/Python/*.py` (and optionally `FIGURES.md`), apply `SHARED_REPLACEMENTS`, `NEXT_PERIOD_REPLACEMENTS`, and Python-specific P replacements (`uP` → `uδ` etc.); skip excluded names (e.g. `approx_fprime`).
5. **Figure/filename pass**: Rename figure files to match stems (e.g. `Plot_ud_VS_vCntnd`); update `.xbb`, `.dep`, and any paths that reference figure names.
6. **Verification**: Re-scan for remaining "Prime" or unrenamed `\vP` in derivative contexts and run tests (e.g. `pytest Code/Python/tests/`) and a LaTeX build to ensure renames didn't break call sites or references.

### 5.4 Safety

- **Backup**: Script should not modify files unless `--apply`; with `--apply`, recommend running from a clean git state so changes can be reverted.
- **Idempotency**: Replacements should be written so that running the script twice does not double-substitute (e.g. replace "Prime" only with the chosen delta/partial name, not "Prime" → "Delta" → "DeltaDelta").
- **Tests**: After applying, run `pytest Code/Python/tests/` and any notebook smoke test; fix broken references (e.g. in tests that reference `compute_uPrime_vs_vPrime_data` or `plot_uPrime_vs_vPrime`).

---

## 6. Implementation Checklist

- [ ] Create script at `scripts/prime_to_delta.py` (replace existing version).
- [ ] Include **all four** replacement tables (`SHARED_REPLACEMENTS`, `LATEX_P_REPLACEMENTS`, `NEXT_PERIOD_REPLACEMENTS`, exclusions) from the start — not as a later addition.
- [ ] Implement catalog/dry-run mode (scan and report).
- [ ] Implement **atomic** LaTeX + STY pass: process `.tex` and `.sty` files with the same replacement tables in the same pass. Explicitly include `@local/local-macros.sty` and `@resources/texlive/texmf-local/tex/latex/econark-shortcuts.sty` and `econark_demacro_demacro.sty`.
- [ ] Implement notebook replacements (markdown + code cells; preserve structure).
- [ ] Implement Python replacements (functions, params, keys, docstrings, comments); enforce exclusions.
- [ ] Update `FIGURES.md` and any CI that references figure/function names.
- [ ] Add tests that expect new names (or update existing tests that reference old names).
- [ ] **Verify atomicity**: After `--apply`, confirm that every renamed macro (e.g. `\vδCntn`) has both a `\newcommand` in `.sty` and matching usage(s) in `.tex`. Report any orphaned definitions or usages.
- [ ] Document in README or CONTRIBUTION how to run the script (e.g. `python scripts/prime_to_delta.py` then `--apply`).

---

## 7. Relation to Other Plans

- **`plan-derivative-notation-notebook.md`**: Handles the **math symbol** in the notebook and plot strings (`^{\prime}` → `^{\partial}`). This plan handles **identifiers and the word "Prime"** (→ δ / vCntn / Nxt). Both can be applied; the script here does not change LaTeX math markup, only label names and code/markdown identifiers.

---

## 8. Evaluation: Compilation and Implementation Risks

**Likely to work without failures if applied carefully:**

- **LaTeX (LuaLaTeX)**: Labels and refs using δ (e.g. `fig:Plot_ud_VS_vCntnd`, `eq:vEndδTm1`) are valid; LuaLaTeX and hyperref accept Unicode in label names. Cross-references and `\ref`/`\label` will resolve. The only residual risk is rare viewer quirks with non-ASCII PDF destination names; document compilation itself should succeed.
- **Python / notebook**: Renames are identifier and string substitutions. As long as every call site and import is updated in the same pass (same script or same batch), `pytest` and notebook execution should pass. The plan explicitly includes tests and FIGURES.md in scope.
- **Filenames**: Renaming figures to `Plot_ud_VS_vCntnd.*` and updating all `\includegraphics`, `.xbb`, `.dep`, and Python `save_as` in one go keeps references consistent. Build scripts that assume old figure names must be updated too (or run after the script).

**Risks that could cause failures or bugs:**

1. **Macro definition/usage mismatch (the prior failure mode)**: If the script renames `\vPCntn` → `\vδCntn` in `.sty` definitions but not in `.tex` usages (or vice versa), the LaTeX build breaks with "Undefined control sequence". The script MUST process `.sty` and `.tex` files with the **same** `LATEX_P_REPLACEMENTS` table in the **same** pass. The prior version of this script failed precisely because it was deployed without the `LATEX_P_REPLACEMENTS` table, and when the table was added later the script was not re-run.
2. **Next-period vs derivative confusion**: If the script replaces `v_prime` with `v_Nxt` in a place where it actually meant "derivative of v" (or the reverse), logic or docstrings become wrong. Mitigation: use a table of (pattern, replacement) with **context**: e.g. only replace `c_prime` when it is a parameter name in a function signature or a variable holding next-period consumption; do not replace inside comments that say "derivative". Optionally run derivative renames first, then next-period renames, and exclude identifiers that were already changed.
3. **"O" not meaning continuation**: The plan says O → vCntn where O signified "Other/continuation value". If "O" or "OPrime" appears in a different meaning (e.g. in Koppa or another symbol), replacing it would be wrong. The inventory lists KoppaPrime → Koppaδ; if Koppa is unrelated to continuation value, that rename is safe. Any other "O" that means something else must be excluded.
4. **Order of application**: If replacements are applied in the wrong order, partial tokens can be re-replaced (e.g. a string containing both "uPrime" and "vPrime" might get one wrong). The plan specifies "longest first" for the replacement table, which avoids most of this. Running the script twice (idempotency) should not double-substitute if targets contain no "Prime" or "prime".
5. **External and generated files**: `approx_fprime` is excluded. Generated files (e.g. `.aux`, `.bbl`, `*.pyc`) should not be edited by the script; they are regenerated by the build. If any script or config outside the repo (CI, external docs) hardcodes old names, those will break until updated manually.
6. **Case sensitivity**: "VS" vs "vs" is explicit in the plan; the script must use "VS" in all figure-related identifiers and filenames so that `\includegraphics{./Figures/Plot_ud_VS_vCntnd}` matches the file `Plot_ud_VS_vCntnd.pdf`.

**Conclusion**: The plan is **likely to be safe for compilation and tests** provided (i) the replacement table is applied in a single pass with longest-first ordering, (ii) next-period renames are limited to clear parameter/variable names (e.g. `c_prime`, `v_prime` in next-period contexts) and excluded from derivative contexts, and (iii) all references (LaTeX, Python, notebook, figure paths, .xbb, .dep) are updated together. Doing a dry-run, then applying, then running `pytest` and `latexmk` (or equivalent) is recommended to catch any missed reference before commit.
