# Plan: Apply \(^{\partial}\) (first derivative) notation consistently in the notebook

## Context

- **LaTeX convention** (see `Notation.md` and `Equations/*.tex`): First derivative of a single-argument function is denoted by superscript \(\partial\), e.g. \(\mathrm{u}^{\partial}(\mathrm{c})\), \(\mathrm{v}^{\partial}_{\succ}(a)\). The main document uses `\uFunc^{\partial}`, `\vEndPrd^{\partial}` (see `Equations/Envelope.tex`, `Equations/cEuler.tex`, `Equations/upEqbetaOp.tex`).
- **Current notebook state**: The notebook (markdown and plot labels) still uses **prime** notation for first derivatives: \(\mathrm{u}'(\mathrm{c})\), \(\mathrm{v}'_{\succ}\), \(\mathrm{v}'(m)\), etc. So the notational change from `'` to `^{\partial}` has not been applied there.

## Goal

Replace every use of **prime for first derivative** of a single-argument function with **superscript \(\partial\)** in:

1. All notebook **markdown** (inline and display math).
2. All **plot labels/titles/axes** in `Code/Python/notebook_plots.py` that show derivative notation.
3. **Comments and docstrings** in the same code that refer to derivative notation (optional but recommended for consistency).

Do **not** change:

- Second (or higher) derivatives, e.g. \(\mathrm{u}''\), \(\mathrm{v}''\), if any appear.
- Uses of prime that are not “first derivative of a function of one argument” (e.g. time derivative or other meaning, if any).
- LaTeX or Python outside the notebook and `notebook_plots.py` (e.g. private/legacy scripts can be updated separately if desired).

---

## 1. Replacement rules (math only)

Apply these in **math mode** (inside `$...$`, `$$...$$`, or `\begin{equation}...\end{equation}`), in a single pass (order below avoids double-replacement).

| Find (literal in math) | Replace with |
|------------------------|--------------|
| `\mathrm{u}'` | `\mathrm{u}^{\partial}` |
| `\mathrm{v}'` | `\mathrm{v}^{\partial}` |
| `\grave{\mathrm{v}}'` | `\grave{\mathrm{v}}^{\partial}` |
| `\grave{\mathrm{v}}^{\partial}'` (if any) | `\grave{\mathrm{v}}^{\partial}` (idempotent) |

So:

- \(\mathrm{u}'(\mathrm{c})\) → \(\mathrm{u}^{\partial}(\mathrm{c})\)
- \(\mathrm{v}'_{\succ}\), \(\mathrm{v}'_{\succ,T-1}\), \(\mathrm{v}'(m)\) → \(\mathrm{v}^{\partial}_{\succ}\), \(\mathrm{v}^{\partial}_{\succ,T-1}\), \(\mathrm{v}^{\partial}(m)\)
- \(\grave{\mathrm{v}}'_{\succ}\) → \(\grave{\mathrm{v}}^{\partial}_{\succ}\)

Leave \(\mathrm{v}^{\partial}_{\succ}\) and \(\mathrm{u}^{\partial}\) unchanged where they already use \(\partial\).

---

## 2. Where to apply

### 2.1 Notebook markdown

- **Automated pass**: Over all **markdown** cells, in each cell’s source lines:
  - Replace `\mathrm{u}'` → `\mathrm{u}^{\partial}`.
  - Replace `\mathrm{v}'` → `\mathrm{v}^{\partial}`.
  - Replace `\grave{\mathrm{v}}'` → `\grave{\mathrm{v}}^{\partial}`.
- **Known locations** (from grep):
  - Cell with “first-order condition \(\mathrm{u}'(\mathrm{c}) = \mathrm{v}^{\partial}_{\succ}(a)\)” → \(\mathrm{u}^{\partial}(\mathrm{c})\).
  - Cell with “\(\mathrm{u}'(\mathrm{c}_{t})\)” and “\(\mathrm{v}^{\partial}_{\succ}\)” in display equations → \(\mathrm{u}^{\partial}(\mathrm{c}_{t})\).
  - Cell with “Interpolate … \(\mathrm{v}'(m) = \mathrm{u}'(\mathrm{c}^*(m))\)” → \(\mathrm{v}^{\partial}(m) = \mathrm{u}^{\partial}(\mathrm{c}^*(m))\).
- **Verification**: After the pass, grep for `\mathrm{u}'`, `\mathrm{v}'`, `\grave{\mathrm{v}}'` in the notebook and fix any remaining by hand.

### 2.2 `Code/Python/notebook_plots.py`

- In **strings used for labels, titles, xlabel, ylabel** (e.g. `label=r"$...$"`, `plt.title(...)`):
  - Replace `\mathrm{u}'` → `\mathrm{u}^{\partial}`.
  - Replace `\mathrm{v}'` → `\mathrm{v}^{\partial}`.
  - Replace `\grave{\mathrm{v}}'` → `\grave{\mathrm{v}}^{\partial}`.
- **Known locations**:
  - `plot_uPrime_vs_vPrime`: all labels and the title that currently use \(\mathrm{u}'\), \(\mathrm{v}'_{\succ}\), \(\grave{\mathrm{v}}'_{\succ}\) and the y-axis text.
- **Comments/docstrings** in that function (e.g. “u'(c) versus …”) can be updated to “\(\mathrm{u}^{\partial}(\mathrm{c})\) versus …” or “marginal utility vs marginal value” for clarity.

### 2.3 Other code (optional)

- **Comments in notebook code cells**: If any cell has a comment like “# u'(c) vs v' …”, update to “# u^{\partial}(c) vs v^{\partial} …” or plain-English “marginal u vs marginal v”.
- **Private/legacy** (`Code-private/...`, `SolvingMicroDSOP_private_withBrentQToo.py`): Same substitution can be applied there for consistency if those files are still in use; otherwise leave out of scope.

---

## 3. Implementation steps

1. **Backup / branch**: Ensure notebook and `notebook_plots.py` are under version control (e.g. commit or branch before edits).
2. **`notebook_plots.py`**:
   - In `plot_uPrime_vs_vPrime`, replace every `\'` used for first derivative with `^{\partial}` in the label/title/axis strings (and optionally in the section comment and docstring).
   - Grep the file for `'` in math strings and fix any other plot that uses prime for first derivative.
3. **Notebook**:
   - Run a script (or manual find/replace) over all markdown cells: in each line, replace `\mathrm{u}'` → `\mathrm{u}^{\partial}`, `\mathrm{v}'` → `\mathrm{v}^{\partial}`, `\grave{\mathrm{v}}'` → `\grave{\mathrm{v}}^{\partial}`.
   - Re-run the notebook (or at least the moderation and FOC figure cells) to confirm plots and text render correctly.
4. **Verification**:
   - Grep the repo for `\mathrm{u}'`, `\mathrm{v}'`, `\grave{\mathrm{v}}'` in `.ipynb` and `notebook_plots.py`; result should be empty (or only in comments that you chose to leave as-is).
   - Spot-check a few markdown cells and the “u'(c) vs marginal continuation values” figure to ensure notation matches the LaTeX document.

---

## 4. Edge cases and caveats

- **Second derivatives**: If any \(\mathrm{u}''\) or \(\mathrm{v}''\) appear, keep the double prime; the plan only targets first derivative.
- **Rendering**: \(\mathrm{u}^{\partial}(\mathrm{c})\) and \(\mathrm{v}^{\partial}_{\succ}\) render in MathJax/KaTeX; no change to notebook kernel or environment is required.
- **Consistency with LaTeX**: After this, the notebook will use the same first-derivative convention as `Equations/*.tex` and `Notation.md` (\(\partial\) for first derivative of a single-argument function).
