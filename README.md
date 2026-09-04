# R4SUB Gallery

Practical demos and use-case gallery for the [R4SUB](https://github.com/R4SUB) clinical submission readiness ecosystem.

## The R4SUB Ecosystem

| Package | Purpose |
|---|---|
| [r4subcore](https://github.com/R4SUB/r4subcore) | Core evidence schema, parsers, and scoring primitives |
| [r4subtrace](https://github.com/R4SUB/r4subtrace) | ADaM-to-SDTM traceability analysis |
| [r4subscore](https://github.com/R4SUB/r4subscore) | Submission Confidence Index (SCI) scoring engine |
| [r4subrisk](https://github.com/R4SUB/r4subrisk) | FMEA-based risk quantification |
| [r4subdata](https://github.com/R4SUB/r4subdata) | Demo datasets for the ecosystem |
| [r4subprofile](https://github.com/R4SUB/r4subprofile) | Regulatory submission profiles (FDA, EMA, PMDA, ...) |
| [r4subui](https://github.com/R4SUB/r4subui) | Interactive Shiny dashboard |
| [r4sub](https://github.com/R4SUB/r4sub) | Meta-package to install and load everything |

## Prerequisites

- R >= 4.2
- Run `00-setup.R` to install all packages

## Demo Index

| Script | Description | Key Packages |
|---|---|---|
| `00-setup.R` | Install and verify the R4SUB ecosystem | r4sub |
| `01-getting-started.R` | Load packages, explore datasets and schema | r4sub, r4subdata |
| `02-evidence-pipeline.R` | Build and validate evidence from multiple sources | r4subcore |
| `03-traceability-analysis.R` | ADaM-to-SDTM traceability model and coverage | r4subtrace, r4subdata |
| `04-risk-assessment.R` | FMEA risk register, scoring, and mitigation | r4subrisk, r4subdata |
| `05-submission-scoring.R` | Compute SCI, pillar scores, and decision bands | r4subscore, r4subdata |
| `06-regulatory-profiles.R` | Compare requirements across regulatory authorities | r4subprofile |
| `07-end-to-end-workflow.R` | Full pipeline from raw data to submission decision | all |
| `08-sensitivity-analysis.R` | What-if analysis on weights and thresholds | r4subscore, r4subdata |
| `09-multi-authority-comparison.R` | Same study scored against 6 agencies | r4subprofile, r4subscore |
| `10-dashboard-launch.R` | Launch the interactive Shiny dashboard | r4subui |

## Running the Demos

Each script is self-contained. Run any demo directly:

```r
source("01-getting-started.R")
```

Or from the command line:

```bash
Rscript 01-getting-started.R
```

## Maintained by

R4SUB is part of the open-source work of [TechWorksLab](https://techworkslab.com) - clinical programming and regulatory submissions. Maintainer: Pawan Rama Mali.

## License

MIT
