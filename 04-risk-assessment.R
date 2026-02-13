# ============================================================================
# 04-risk-assessment.R — FMEA Risk Register, Scoring, and Mitigation
# ============================================================================
#
# Demonstrates the risk quantification workflow: creating a risk register,
# computing Risk Priority Numbers (RPN), classifying risk levels,
# auto-generating risks from evidence, and tracking mitigations.
#
# Packages: r4subrisk, r4subdata, r4subcore
# ============================================================================

library(r4subcore)
library(r4subrisk)
library(r4subdata)

# Step 1: Load the demo risk register ----
cat("Demo risk register:", nrow(risk_register_pharma), "risks\n\n")
print(risk_register_pharma[1:5, c("risk_id", "description", "probability",
                                    "impact", "detectability")])

# Step 2: Create a formal risk register ----
rr <- create_risk_register(risk_register_pharma)
print(rr)

# Step 3: Compute risk scores ----
scores <- compute_risk_scores(rr)
print(scores)

cat("\nRisk distribution:\n")
print(scores$risk_distribution)

cat("\nCategory summary:\n")
print(scores$category_summary)

# Step 4: Classify individual RPNs ----
rpn_values <- c(5, 20, 50, 100)
cat("\nRPN classification examples:\n")
for (rpn in rpn_values) {
  cat(sprintf("  RPN %3d -> %s\n", rpn, classify_rpn(rpn)))
}

# Step 5: Auto-generate risks from evidence ----
# Evidence severity maps to probability/impact automatically.
cat("\n\nAuto-generating risks from evidence_pharma...\n")
auto_risks <- evidence_to_risks(evidence_pharma)
cat("Generated", nrow(auto_risks), "risks from", nrow(evidence_pharma), "evidence rows\n")
rr_auto <- create_risk_register(auto_risks)
auto_scores <- compute_risk_scores(rr_auto)
print(auto_scores)

# Step 6: Apply mitigations ----
# Simulate mitigating the top risks.
top_risks <- rr$risk_id[order(rr$rpn, decreasing = TRUE)][1:3]
cat("\nMitigating top 3 risks:", paste(top_risks, collapse = ", "), "\n")

updates <- data.frame(
  risk_id       = top_risks,
  probability   = c(2, 1, 2),
  status        = c("mitigated", "mitigated", "mitigated"),
  mitigation    = c("Added automated checks",
                     "Implemented review process",
                     "Enhanced validation rules"),
  stringsAsFactors = FALSE
)

rr_after <- apply_mitigations(rr, updates)

# Step 7: Compare before and after ----
comparison <- compare_risk_registers(rr, rr_after)
cat("\nBefore vs After mitigation:\n")
cat(sprintf("  Mean RPN: %.1f -> %.1f\n",
            comparison$before$mean_rpn, comparison$after$mean_rpn))
cat(sprintf("  Max RPN:  %d -> %d\n",
            comparison$before$max_rpn, comparison$after$max_rpn))
cat(sprintf("  Overall risk score: %.3f -> %.3f\n",
            comparison$before$overall_risk_score,
            comparison$after$overall_risk_score))

# Step 8: Indicator-level summary ----
cat("\nRisk summary by indicator:\n")
print(risk_indicator_summary(rr))
