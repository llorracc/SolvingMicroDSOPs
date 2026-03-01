# AGENTS.md — Orientation for AI-Assisted Work

This repository contains **SolvingMicroDSOPs**: LaTeX lecture notes plus replication code (Python, Stata) for numerical methods in consumption/saving problems under uncertainty. The main artifact is the book PDF built from root-level `.tex` files.

The document teaches how to solve consumption-saving problems efficiently, progressing from brute-force value function iteration through the transformation trick (inverse marginal value), the Endogenous Grid Method (EGM), and a modular stage architecture for composing complex periods. It concludes with structural estimation matching model predictions to Survey of Consumer Finances data.

## Quick orientation

| Path | Purpose |
|------|---------|
| `SolvingMicroDSOPs.tex` | Main document entry |
| `_sectn-*.tex` | Section subfiles |
| `Equations/` | Equation fragments (included by main doc) |
| `Tables/`, `Figures/` | Tables and figures |
| `Code/Python/`, `Code/Stata/` | Replication code |
| `Code/Python/tests/` | Test suite (pytest) |
| `SolvingMicroDSOPs.ipynb` | Jupyter notebook implementing the methods |
| `prompts/` | Canonical prompts for AI-assisted work |
| `@resources/`, `@local/` | LaTeX search path and macros (needed for build) |
| `CONTRIBUTION.md` | What this document contributes, audience, HARK comparison |
| `ROADMAP.md` | How to read this — suggested reading paths |
| `Notation.md` | Glossary of all mathematical notation and macros |
| `FIGURES.md` | Figure regeneration manifest (Python vs. legacy) |
| `.github/workflows/ci.yml` | CI pipeline (tests, notebook, lint) |

## What this document contributes

See **`CONTRIBUTION.md`** for a concise statement of what the document covers, who it is for, and how it relates to HARK and standard textbooks.

## Critical rules

- **`docs/`** is a **reference copy**. Do **not** edit it. All edits use **root-level** files only.
- **Build**: `latexmk` on root `.tex` (uses LuaLaTeX via `.latexmkrc`)
- **Code mirrors math**: Python identifiers parallel LaTeX macros (e.g. `DiscFac` ↔ `\DiscFac`, `vEndPrd` ↔ `\vEndPrd`)
- **`verbatimwrite` pattern**: Many equation files in `Equations/` are **generated at compile time** by `\begin{verbatimwrite}` blocks inside `_sectn-*.tex` files. Always edit the equation in the section file, not the generated `.tex` fragment in `Equations/`.

## Detailed documentation: `.agents/`

For deeper context—LaTeX structure, build system, macro conventions, code layout, and the `%% CodeInfo:` annotation scheme—see the **`.agents/`** directory:

| File | Use when you need |
|------|-------------------|
| `.agents/orientation-latex-math.md` | Document structure, subfiles, equations, build, boolean flags, custom macros |
| `.agents/orientation-code.md` | Code layout, module roles, figure–code integration, naming conventions |
| `.agents/codeinfo-spec.md` | `%% CodeInfo:` tag vocabulary, placement rules, status values |

Read these before making substantial changes to LaTeX or code.
