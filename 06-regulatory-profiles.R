# ============================================================================
# 06-regulatory-profiles.R — Compare Requirements Across Regulatory Authorities
# ============================================================================
#
# Demonstrates regulatory submission profiles: listing authorities and
# submission types, creating profiles, comparing pillar weights,
# extracting SCI/risk configs, and validating evidence compliance.
#
# Packages: r4subprofile, r4subcore, r4subdata
# ============================================================================

library(r4subcore)
library(r4subprofile)
library(r4subdata)

# Step 1: List all supported authorities ----
cat("Supported regulatory authorities:\n\n")
print(list_authorities())

# Step 2: Explore submission types ----
cat("\n\nFDA submission types:", paste(list_submission_types("FDA"), collapse = ", "), "\n")
cat("EMA submission types:", paste(list_submission_types("EMA"), collapse = ", "), "\n")
cat("PMDA submission types:", paste(list_submission_types("PMDA"), collapse = ", "), "\n")

# Step 3: Create profiles ----
fda_nda  <- submission_profile("FDA", "NDA")
ema_maa  <- submission_profile("EMA", "MAA")
pmda_nda <- submission_profile("PMDA", "NDA_JP")

cat("\n\nFDA NDA profile:\n")
print(fda_nda)

# Step 4: Compare pillar weights ----
cat("\n\nPillar weight comparison:\n\n")
authorities <- list(
  "FDA NDA"    = fda_nda,
  "EMA MAA"    = ema_maa,
  "PMDA NDA_JP" = pmda_nda
)

for (name in names(authorities)) {
  w <- authorities[[name]]$pillar_weights
  cat(sprintf("  %-12s  quality=%.2f  trace=%.2f  risk=%.2f  usability=%.2f\n",
              name, w["quality"], w["trace"], w["risk"], w["usability"]))
}

# Step 5: Compare minimum coverage requirements ----
cat("\nMinimum coverage requirements:\n")
for (name in names(authorities)) {
  cat(sprintf("  %-12s  %.0f%%\n", name,
              authorities[[name]]$minimum_coverage * 100))
}

# Step 6: Required indicators ----
cat("\n\nFDA NDA required indicators:\n")
cat(paste(" ", profile_required_indicators(fda_nda)), sep = "\n")

# Step 7: Extract configs compatible with r4subscore and r4subrisk ----
fda_sci_cfg  <- profile_sci_config(fda_nda)
fda_risk_cfg <- profile_risk_config(fda_nda)
cat("\n\nFDA NDA SCI config class:", class(fda_sci_cfg), "\n")
cat("FDA NDA risk config class:", class(fda_risk_cfg), "\n")

# Step 8: Validate evidence against a profile ----
cat("\n\nValidating evidence_pharma against FDA NDA:\n\n")
validation <- validate_against_profile(evidence_pharma, fda_nda)
print(validation)

cat("\nCompliant:       ", validation$is_compliant, "\n")
cat("Coverage:        ", sprintf("%.1f%%", validation$coverage * 100), "\n")
cat("Coverage met:    ", validation$coverage_met, "\n")
cat("Missing indicators:", length(validation$missing_indicators), "\n")
if (length(validation$missing_indicators) > 0) {
  cat(paste("  -", validation$missing_indicators), sep = "\n")
}
