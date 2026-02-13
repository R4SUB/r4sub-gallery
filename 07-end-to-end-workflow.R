# ============================================================================
# 07-end-to-end-workflow.R — Full Pipeline: Raw Data to Submission Decision
# ============================================================================
#
# The complete R4SUB workflow in one script: from loading metadata to a
# final go/no-go submission decision. This is the reference integration
# pattern showing how all packages work together.
#
# Packages: r4subcore, r4subtrace, r4subrisk, r4subscore, r4subprofile,
#           r4subdata
# ============================================================================

library(r4subcore)
library(r4subtrace)
library(r4subrisk)
library(r4subscore)
library(r4subprofile)
library(r4subdata)

cat("=" , rep("=", 60), "\n", sep = "")
cat("  R4SUB End-to-End Submission Readiness Assessment\n")
cat("=", rep("=", 60), "\n\n", sep = "")

# 1. Establish run context ----
ctx <- r4sub_run_context("CDISCPILOT01", "PROD", user = "lead_programmer")
cat("Study:", ctx$study_id, "| Environment:", ctx$environment, "\n\n")

# 2. Build traceability model ----
cat("--- Traceability Analysis ---\n")
tm <- build_trace_model(adam_metadata, sdtm_metadata, trace_mapping)
levels <- compute_trace_levels(tm)
cat(sprintf("  Variables: %d | L3 coverage: %.0f%%\n",
            nrow(levels),
            100 * mean(levels$trace_level >= 3)))
ev_trace <- trace_model_to_evidence(tm, ctx)

# 3. Build risk register ----
cat("\n--- Risk Assessment ---\n")
rr <- create_risk_register(risk_register_pharma)
scores_risk <- compute_risk_scores(rr)
cat(sprintf("  Risks: %d | Mean RPN: %.1f | Overall risk: %.3f\n",
            scores_risk$n_risks, scores_risk$mean_rpn,
            scores_risk$overall_risk_score))

# 4. Combine all evidence ----
cat("\n--- Evidence Consolidation ---\n")
ev_all <- bind_evidence(evidence_pharma, ev_trace)
cat(sprintf("  Total evidence rows: %d\n", nrow(ev_all)))
cat(sprintf("  Domains: %s\n",
            paste(unique(ev_all$indicator_domain), collapse = ", ")))

# 5. Select regulatory profile ----
cat("\n--- Regulatory Profile: FDA NDA ---\n")
profile <- submission_profile("FDA", "NDA")
sci_cfg  <- profile_sci_config(profile)
cat(sprintf("  Weights: quality=%.2f, trace=%.2f, risk=%.2f, usability=%.2f\n",
            sci_cfg$pillar_weights["quality"],
            sci_cfg$pillar_weights["trace"],
            sci_cfg$pillar_weights["risk"],
            sci_cfg$pillar_weights["usability"]))

# 6. Compute SCI with authority-specific config ----
cat("\n--- Submission Confidence Index ---\n")
pillar_scores <- compute_pillar_scores(ev_all, config = sci_cfg)
sci <- compute_sci(pillar_scores, config = sci_cfg)
cat(sprintf("  SCI: %.1f / 100\n", sci$SCI))
cat(sprintf("  Band: %s\n", sci$band))

cat("\n  Pillar breakdown:\n")
for (i in seq_len(nrow(pillar_scores))) {
  cat(sprintf("    %-10s  %.1f%%  (weight: %.0f%%)\n",
              pillar_scores$pillar[i],
              pillar_scores$pillar_score[i] * 100,
              pillar_scores$weight[i] * 100))
}

# 7. Validate against profile requirements ----
cat("\n--- Profile Compliance ---\n")
validation <- validate_against_profile(ev_all, profile)
cat(sprintf("  Compliant: %s\n", validation$is_compliant))
cat(sprintf("  Indicator coverage: %.0f%% (required: %.0f%%)\n",
            validation$coverage * 100,
            profile$minimum_coverage * 100))

# 8. Final decision ----
cat("\n", rep("=", 62), "\n", sep = "")
if (sci$band == "ready" && validation$is_compliant) {
  cat("  DECISION: READY FOR SUBMISSION\n")
} else if (sci$band %in% c("ready", "minor_gaps")) {
  cat("  DECISION: MINOR GAPS - Address before filing\n")
} else {
  cat("  DECISION: NOT READY - Significant work required\n")
}
cat(rep("=", 62), "\n", sep = "")
