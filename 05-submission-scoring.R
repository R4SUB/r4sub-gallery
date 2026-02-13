# ============================================================================
# 05-submission-scoring.R — Compute SCI, Pillar Scores, and Decision Bands
# ============================================================================
#
# Shows the full scoring pipeline: indicator scores, pillar aggregation,
# the Submission Confidence Index (SCI), decision band classification,
# and the explainability breakdown.
#
# Packages: r4subscore, r4subdata
# ============================================================================

library(r4subscore)
library(r4subdata)

# Step 1: Start with evidence ----
cat("Evidence:", nrow(evidence_pharma), "rows across",
    length(unique(evidence_pharma$indicator_domain)), "domains\n\n")

# Step 2: Compute indicator scores ----
# Each indicator gets a weighted score based on severity and result.
ind_scores <- compute_indicator_scores(evidence_pharma)
cat("Indicator scores (", nrow(ind_scores), "indicators):\n\n")
print(ind_scores)

# Step 3: Compute pillar scores ----
# Indicators are aggregated into domain-level "pillars".
pillar_scores <- compute_pillar_scores(evidence_pharma)
cat("\n\nPillar scores:\n\n")
print(pillar_scores)

# Step 4: Compute the Submission Confidence Index ----
sci <- compute_sci(pillar_scores)
print(sci)

cat(sprintf("\n  SCI Score: %.1f / 100\n", sci$SCI))
cat(sprintf("  Decision Band: %s\n", sci$band))

# Step 5: Interpret the decision band ----
band_meanings <- c(
  ready      = "Ready for submission - all major criteria met",
  minor_gaps = "Minor gaps remain - address before filing",
  conditional = "Conditional - significant work needed",
  high_risk  = "High risk - not ready for submission"
)
cat(sprintf("\n  Interpretation: %s\n", band_meanings[sci$band]))

# Step 6: Explain the score ----
# Detailed breakdown showing each pillar's contribution.
cat("\n\nSCI Explainability:\n\n")
explanation <- sci_explain(evidence_pharma)
print(explanation)

# Step 7: Try different configurations ----
# What if we put more weight on quality?
custom_config <- sci_config_default(
  pillar_weights = c(quality = 0.50, trace = 0.20, risk = 0.20, usability = 0.10)
)
pillar_custom <- compute_pillar_scores(evidence_pharma, config = custom_config)
sci_custom <- compute_sci(pillar_custom, config = custom_config)

cat("\n\nDefault weights -> SCI:", sprintf("%.1f", sci$SCI),
    "(", sci$band, ")\n")
cat("Quality-heavy  -> SCI:", sprintf("%.1f", sci_custom$SCI),
    "(", sci_custom$band, ")\n")
