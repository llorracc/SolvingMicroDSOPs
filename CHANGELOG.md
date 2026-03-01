# Changelog

## 2.0.0 — 2026-03-01

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
