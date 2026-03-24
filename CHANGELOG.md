# Changelog

## 2.0.0 — 2026-03-01

### REMARK Tier 3 and HARK 0.17 compatibility (2026-03)

- **HARK 0.17 lifecycle parameters**: Estimation and solver code updated for HARK’s time-varying lifecycle handling. `Rfree` and `LivPrb` are now length-65 lists in `Calibration/EstimationParameters.py`; `parse_ssa_life_table` uses `age_max=final_age` so LivPrb has 65 entries. `StructEstimation.py` overrides `check_restrictions()` to support list-valued (and array) discount factor instead of assuming a scalar.
- **Structural estimation**: Sanity-check expected objective updated after parameter fixes; full reproduction (Nelder-Mead, sensitivity, contour) runs successfully in Docker and locally.
- **econark-multibib**: When `system.bib` is absent, the style now omits `system` from the `\bibliography{}` call so BibTeX does not fail in clean/Docker environments. No dummy `system.bib` required.
- **Build and reproducibility**: `.latexmkrc` uses portable `sed` (no `sed -i ""`) for Linux/Docker. `reproduce/required_latex_packages.txt` includes `luatex85` for the Docker TeX Live image. `reproduce.sh` sets `PYTHONPATH` for estimation and uses `uv sync --locked --all-groups` so the lockfile is strictly enforced per REMARK standard.
- **Dependencies**: `pyproject.toml` dependency ranges tightened (e.g. `econ-ark>=0.17.1,<0.18`). `uv.lock` regenerated with exact resolved versions for reproducible installs.
- **Metadata**: `CITATION.cff` now includes `license: Apache-2.0`. `REMARK.md` frontmatter set to `tier: 3`. README status and footer updated to Tier 3 (Published REMARK).

### Notation standardization

- Replaced `\Alive` with `\LivPrb` in all LaTeX source files (matches the Python identifier).
- Consolidated time macros: `\trmT` replaced by `\prdT`, `\prdLsT` inlined as `\prdT-1`.
- Shock variables in Python now use lowercase initial (`permShk`, `tranShk`, `tranShkEmp`), matching the LaTeX convention. HARK API dictionary keys retain uppercase.
- Renamed Perch attributes from `.cda`/`.vda` to `.cδ`/`.vδ` (Unicode delta), matching the mathematical notation.
- Removed unused entries from `Notation.md` (only symbols that appear in Python/ipynb code are listed).

### cctwMoM material removal

- Removed all files, directories, and conditional compilation related to the cctwMoM (Method of Moderation) companion document (~108 files deleted).
- Preserved the brief Method of Moderation section in the main document and its associated figures.

### Test suite consolidation

- Merged two parallel test suites (`Code/test_*.py` and `Code/Python/tests/`) into a single canonical location at `Code/Python/tests/`, which is the CI-run suite.

### Repository organization

- Created `reproduce/` directory; moved auxiliary reproduction scripts (`reproduce_doc.sh`, `reproduce_text_*.sh`, environment setup) out of the repo root.
- Moved `makeMath.sh` to `Code-private/Mathematica/` (alongside the Mathematica code it invokes).
- Added `.fdb_latexmk`, `.mk4`, `.synctex.gz`, `.upa`, `.upb` to the `latexmk -c` clean list.

### Metadata and documentation

- Updated Buffer Stock Theory citation to 2026 (published in Quantitative Economics).
- Added `codemeta.json` for machine-readable scholarly metadata.
- Added abbreviated directory tree to `README.md`.
- Added `Thanks` section to `README.md` crediting contributors.
- Updated `AGENTS.md` with conceptual overview, `verbatimwrite` rule, and corrected build instructions.
- Archived completed plan files in `.agents/`.
