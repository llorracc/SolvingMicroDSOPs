# Improvement Plan: SolvingMicroDSOPs-Latest

This plan addresses gaps identified in the researcher review (see `SolvingMicroDSOPs-make/conversations/you-are/a-researcher_is-anything-missing-from-Latest_answers.md`), with emphasis on **missing material** and **clarifying what the existing scripts do**.

**Script layout (implemented):** `./reproduce.sh` = full reproduction (notebook → PDF → estimation). `./reproduce_min.sh` = notebook only. `./reproduce_doc.sh` = PDF only (latexmk).

---

## 1. README: What each script does (done)

README and repository structure document all three scripts. Partial runs: `./reproduce_min.sh` (notebook), `./reproduce_doc.sh` (PDF), `uv run python Code/Python/StructEstimation.py` (estimation only).


---

## 2. README: Clone URL and Binder (skipped by design)

**Goal:** Avoid confusion when the canonical development repo is `llorracc/SolvingMicroDSOPs-Latest` while README points at `econ-ark/SolvingMicroDSOPs`.

**Decision:** No change. This repo (SolvingMicroDSOPs-Latest) is the draft/source; the destination and canonical clone URL is **econ-ark/SolvingMicroDSOPs**. README correctly points to that repo.

**Actions:**

- If this repo is published as **SolvingMicroDSOPs-Latest** (llorracc): add a line such as “Development repo: `git clone https://github.com/llorracc/SolvingMicroDSOPs-Latest`” and note that the Binder badge may point at the stable `econ-ark/SolvingMicroDSOPs` build.
- If the README is shared with the public repo: keep a single clone URL but add a sentence: “For the latest development version, clone `llorracc/SolvingMicroDSOPs-Latest`.”

**Deliverable:** One or two sentences in README that state which clone to use (and why, if there are two).

---

## 3. Data path and SCF: one-place explanation

**Goal:** Clarify that estimation uses `Calibration/SCFdata.csv` and how that relates to the Stata pipeline.

**Actions:**

- Add a short **“Data”** subsection to the README (or a single paragraph):  
  “Estimation uses **Calibration/SCFdata.csv** (included in the repo). To rebuild this from raw SCF data, use the Stata pipeline in **Code/Stata/** (see Code/Stata/README.md); that pipeline writes to **Data/Constructed/**; the Python code uses the pre-processed CSV in **Calibration/**.”
- Optionally add one sentence in **Calibration/README.md** (create if missing): “SCFdata.csv is the processed SCF data used by StructEstimation.py. Built by the Stata pipeline (Code/Stata/); see Code/Stata/README.md.”

**Deliverable:** Single place (README or Calibration) where “which data” and “where it comes from” are stated.

---

## 4. Reference outputs (optional but high value)

**Goal:** Let researchers check that their run matches a known-good result.

**Actions:**

- Keep **Tables/estimate_results.csv** (and optionally a small subset or digest) as the reference. In README or in a short **Tables/README.md**, add one sentence: “After running `./reproduce.sh`, Tables/estimate_results.csv should match the committed version (or the digest in …) within numerical tolerance.”
- If we prefer not to commit large or machine-dependent outputs: commit a **small reference digest** (e.g. key parameters and a few moments) and document “reproduction should match this digest.”

**Deliverable:** Clear statement of “expected output” and where to compare (file or digest).

---

## 5. HARK / econ-ark version

**Goal:** Reduce breakage when HARK’s API changes.

**Actions:**

- In README or in **Code/Python/README.md** (or pyproject.toml comment): state “Tested with econ-ark >= 0.17.1; for exact reproduction use `uv sync` (uses uv.lock).”
- Ensure **uv.lock** is committed and that README mentions “uv sync” for reproducible installs.

**Deliverable:** One sentence on HARK version and use of lockfile.

---

## 6. Companion document (cctwMoM / Method of Moderation)

**Goal:** Explain the relationship between the main document and the MoM material.

**Actions:**

- Add one sentence to README or CONTRIBUTION.md: “The repository also contains the **Method of Moderation** (cctwMoM) companion document; it is not included in the main PDF by default. See cctwMoM.tex and _sectn-method-of-moderation.tex.”

**Deliverable:** Single sentence so researchers are not confused by cctwMoM* and _sectn-method-of-moderation.tex.

---

## 7. Optional: Root QUICKSTART.md

**Goal:** One-page “clone → install → run estimation → run notebook → build PDF” for users who want the shortest path.

**Actions:**

- Add **QUICKSTART.md** at repo root with: clone, `uv sync`, `./reproduce.sh`, `uv run jupyter lab` + open notebook, `./build-pdf.sh`, and pointers to README/AGENTS.md for details.
- README can link to it: “For a one-page quick start, see [QUICKSTART.md](QUICKSTART.md).”

**Deliverable:** Optional QUICKSTART.md and link from README.

---

## 8. ~~Optional: Single “do everything” script~~ ✅ Done

`./reproduce.sh` now runs notebook → PDF → estimation. No separate “do everything” script needed.

---

## Priority summary

| Priority | Item | Effort |
|----------|------|--------|
| **P0** | README: “What to run” with one-liners for estimation vs notebook vs PDF (and clarify reproduce.sh does not run notebook/PDF) | Low |
| **P1** | README: Clone URL / Binder note | Low |
| **P1** | Data path / SCF: one-place explanation (README or Calibration) | Low |
| **P2** | Reference outputs: document expected Tables/ and optionally add digest | Low |
| **P2** | HARK version + lockfile sentence | Low |
| **P2** | One sentence on cctwMoM / MoM companion | Low |
| **P3** | QUICKSTART.md + link | Low |

---

## Checklist for implementation

- [x] Scripts: reproduce.sh = full (notebook + PDF + estimation); reproduce_min.sh = notebook only; reproduce_doc.sh = PDF only.
- [x] README: Document all three scripts and one-liners for partial runs.
- [x] **Skipped by design:** Clone URL / Binder — destination is econ-ark/SolvingMicroDSOPs; this repo is draft/source.
- [x] README + Calibration/README.md: Data path and SCF.
- [x] README + Tables/README.md: Reference outputs / digest and “match within tolerance.”
- [x] README: HARK version and uv.lock.
- [x] README + CONTRIBUTION.md: One sentence on cctwMoM / MoM.
- [x] QUICKSTART.md and link from README.
