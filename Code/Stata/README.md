# Stata Code: SCF Data Processing

This directory contains Stata scripts that process raw Survey of Consumer Finances (SCF) microdata into the empirical moments used by the structural estimation in `Code/Python/StructEstimation.py`.

## Pipeline overview

```
Raw SCF data (external, not in repo)
        │
        ▼
SelectVarsUsingSCF{YEAR}.do   ← extract variables from each wave
        │
        ▼
AppendDataUsingSCF1992_2007.do ← combine all waves, filter ages 26–65
        │
        ▼
WIRatioPopulation.do           ← compute wealth-to-income ratios by age group
        │
        ▼
Data/Constructed/SCFdata.txt   ← final output for estimation
```

Run the full pipeline via `doAll.do`.

## Scripts

| Script | Purpose |
|--------|---------|
| `doAll.do` | Master script — sets paths, runs the pipeline |
| `SelectVarsUsingSCF1992.do` | Extract income, assets, net worth from 1992 SCF |
| `SelectVarsUsingSCF1995.do` | Same for 1995 |
| `SelectVarsUsingSCF1998.do` | Same for 1998 |
| `SelectVarsUsingSCF2001.do` | Same for 2001 |
| `SelectVarsUsingSCF2004.do` | Same for 2004 |
| `SelectVarsUsingSCF2007.do` | Same for 2007 |
| `AppendDataUsingSCF1992_2007.do` | Append year-specific files, filter to ages 26–65 |
| `WIRatioPopulation.do` | Compute weighted median/mean W/I ratios by 5-year age bins |

## Data requirements

**Input**: raw SCF `.dta` files, expected at `../../../Downloads/SCF/{YEAR}/scf{YY}.dta` relative to this directory. These are not included in the repository.

Sources:
- Federal Reserve: https://www.federalreserve.gov/econres/scfindex.htm
- The year-specific `SelectVars` scripts document exact variable mappings.

**Output** (written to `Data/Constructed/`):
- `SCF{YEAR}_population.dta` — processed data for each wave
- `SCF1992_2007_population.dta` — appended multi-wave dataset
- `WIRATIO_Population.dta` — wealth-to-income ratios by age group
- `SCFdata.txt` — text export consumed by `StructEstimation.py`

## Notes

- All dollar amounts are CPI-adjusted to 1992 dollars.
- Income is adjusted from before-tax to after-tax using ratios from Cagetti (2003).
- The 1992 wave requires special handling (filtering for "normal" income levels).
- Coverage is 1992–2007. Adding newer waves would require new `SelectVars` scripts following the same pattern.
