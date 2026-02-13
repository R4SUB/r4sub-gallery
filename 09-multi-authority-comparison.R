# ============================================================================
# 09-multi-authority-comparison.R — Same Study Scored Against 6 Agencies
# ============================================================================
#
# Scores the same evidence dataset against all 6 supported regulatory
# authorities to show how submission readiness varies by jurisdiction.
#
# Packages: r4subprofile, r4subscore, r4subdata, r4subcore
# ============================================================================

library(r4subcore)
library(r4subscore)
library(r4subprofile)
library(r4subdata)

cat("=" , rep("=", 60), "\n", sep = "")
cat("  Multi-Authority Submission Readiness Comparison\n")
cat("  Study: CDISCPILOT01 | Evidence rows:", nrow(evidence_pharma), "\n")
cat("=", rep("=", 60), "\n\n", sep = "")

# Define authority/submission type pairs to compare ----
comparisons <- list(
  list(authority = "FDA",           type = "NDA"),
  list(authority = "EMA",           type = "MAA"),
  list(authority = "PMDA",          type = "NDA_JP"),
  list(authority = "Health_Canada", type = "NDS"),
  list(authority = "TGA",           type = "registration"),
  list(authority = "MHRA",          type = "MAA_UK")
)

# Score against each authority ----
results <- data.frame(
  Authority      = character(),
  Type           = character(),
  SCI            = numeric(),
  Band           = character(),
  Compliant      = logical(),
  Coverage       = numeric(),
  Min_Coverage   = numeric(),
  stringsAsFactors = FALSE
)

for (comp in comparisons) {
  profile    <- submission_profile(comp$authority, comp$type)
  sci_cfg    <- profile_sci_config(profile)
  ps         <- compute_pillar_scores(evidence_pharma, config = sci_cfg)
  sci        <- compute_sci(ps, config = sci_cfg)
  validation <- validate_against_profile(evidence_pharma, profile)

  results <- rbind(results, data.frame(
    Authority    = comp$authority,
    Type         = comp$type,
    SCI          = round(sci$SCI, 1),
    Band         = sci$band,
    Compliant    = validation$is_compliant,
    Coverage     = round(validation$coverage * 100, 0),
    Min_Coverage = round(profile$minimum_coverage * 100, 0),
    stringsAsFactors = FALSE
  ))
}

# Display results ----
cat("Results:\n\n")
print(results, row.names = FALSE)

# Find strictest and most lenient ----
strictest <- results$Authority[which.min(results$SCI)]
most_lenient <- results$Authority[which.max(results$SCI)]

cat(sprintf("\nStrictest authority:    %s (SCI: %.1f)\n",
            strictest, min(results$SCI)))
cat(sprintf("Most lenient authority: %s (SCI: %.1f)\n",
            most_lenient, max(results$SCI)))
cat(sprintf("SCI range:             %.1f points\n",
            max(results$SCI) - min(results$SCI)))

# Pillar weight comparison ----
cat("\n\nPillar Weight Comparison Across Authorities:\n\n")
cat(sprintf("  %-15s  %8s  %8s  %8s  %10s\n",
            "Authority", "Quality", "Trace", "Risk", "Usability"))
cat(sprintf("  %-15s  %8s  %8s  %8s  %10s\n",
            "----------", "-------", "-----", "----", "---------"))

for (comp in comparisons) {
  profile <- submission_profile(comp$authority, comp$type)
  w <- profile$pillar_weights
  cat(sprintf("  %-15s  %7.0f%%  %7.0f%%  %7.0f%%  %9.0f%%\n",
              comp$authority,
              w["quality"] * 100, w["trace"] * 100,
              w["risk"] * 100, w["usability"] * 100))
}
