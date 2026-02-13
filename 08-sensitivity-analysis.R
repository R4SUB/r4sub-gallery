# ============================================================================
# 08-sensitivity-analysis.R — What-if Analysis on Weights and Thresholds
# ============================================================================
#
# Explores how the SCI changes under different configurations: adjusting
# pillar weights, changing decision band thresholds, and using the built-in
# sensitivity analysis function.
#
# Packages: r4subscore, r4subdata
# ============================================================================

library(r4subscore)
library(r4subdata)

# Baseline SCI ----
cat("--- Baseline SCI (default weights) ---\n\n")
ps_default <- compute_pillar_scores(evidence_pharma)
sci_default <- compute_sci(ps_default)
cat(sprintf("  SCI: %.1f | Band: %s\n\n", sci_default$SCI, sci_default$band))

# Experiment 1: Vary pillar weights ----
cat("--- Experiment 1: Impact of Pillar Weights ---\n\n")
weight_scenarios <- list(
  "Default (35/25/25/15)"   = c(quality = 0.35, trace = 0.25, risk = 0.25, usability = 0.15),
  "Quality-heavy (50/20/20/10)" = c(quality = 0.50, trace = 0.20, risk = 0.20, usability = 0.10),
  "Risk-heavy (20/20/50/10)"    = c(quality = 0.20, trace = 0.20, risk = 0.50, usability = 0.10),
  "Trace-heavy (20/40/20/20)"   = c(quality = 0.20, trace = 0.40, risk = 0.20, usability = 0.20),
  "Equal (25/25/25/25)"         = c(quality = 0.25, trace = 0.25, risk = 0.25, usability = 0.25)
)

cat(sprintf("  %-35s  %6s  %s\n", "Scenario", "SCI", "Band"))
cat(sprintf("  %-35s  %6s  %s\n", "--------", "---", "----"))

for (name in names(weight_scenarios)) {
  cfg <- sci_config_default(pillar_weights = weight_scenarios[[name]])
  ps  <- compute_pillar_scores(evidence_pharma, config = cfg)
  sci <- compute_sci(ps, config = cfg)
  cat(sprintf("  %-35s  %5.1f  %s\n", name, sci$SCI, sci$band))
}

# Experiment 2: Vary decision band thresholds ----
cat("\n\n--- Experiment 2: Impact of Decision Band Thresholds ---\n\n")
cat("Using default weights, varying the 'ready' threshold:\n\n")

for (threshold in c(75, 80, 85, 90, 95)) {
  bands <- list(
    ready       = c(threshold, 100),
    minor_gaps  = c(threshold - 15, threshold - 1),
    conditional = c(threshold - 35, threshold - 16),
    high_risk   = c(0, threshold - 36)
  )
  cfg <- sci_config_default(bands = bands)
  ps  <- compute_pillar_scores(evidence_pharma, config = cfg)
  sci <- compute_sci(ps, config = cfg)
  cat(sprintf("  Ready threshold >= %d  ->  SCI: %.1f  Band: %s\n",
              threshold, sci$SCI, sci$band))
}

# Experiment 3: Built-in sensitivity analysis ----
cat("\n\n--- Experiment 3: Automated Sensitivity Analysis ---\n\n")
cat("Varying the quality pillar weight from 0.15 to 0.55:\n\n")

# Build a weight grid where quality varies and the rest share equally
quality_weights <- seq(0.15, 0.55, by = 0.10)
weight_grid <- data.frame(
  quality   = quality_weights,
  trace     = (1 - quality_weights) / 3,
  risk      = (1 - quality_weights) / 3,
  usability = (1 - quality_weights) / 3
)

result <- sci_sensitivity_analysis(
  evidence    = evidence_pharma,
  weight_grid = weight_grid
)
print(result)
