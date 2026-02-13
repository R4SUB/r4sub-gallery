# ============================================================================
# 02-evidence-pipeline.R — Build and Validate Evidence from Multiple Sources
# ============================================================================
#
# Demonstrates the core evidence pipeline: creating run contexts, building
# evidence rows from scratch, canonicalizing severity/results, validating
# schema compliance, and combining multiple evidence sources.
#
# Packages: r4subcore
# ============================================================================

library(r4subcore)

# Step 1: Create a run context ----
# A run context captures metadata about who/when/where evidence was collected.
ctx <- r4sub_run_context(
  study_id    = "CDISCPILOT01",
  environment = "PROD",
  user        = "demo_user"
)
print(ctx)

# Step 2: Build evidence from scratch ----
# Evidence rows represent individual quality/compliance findings.
quality_findings <- data.frame(
  indicator_id     = c("QUAL_P21_ERROR", "QUAL_P21_ERROR", "QUAL_P21_WARN"),
  indicator_name   = c("P21 Errors", "P21 Errors", "P21 Warnings"),
  indicator_domain = c("quality", "quality", "quality"),
  asset_type       = c("validation", "validation", "validation"),
  asset_id         = c("ADSL", "ADAE", "ADLB"),
  source_name      = c("pinnacle21", "pinnacle21", "pinnacle21"),
  result           = c("fail", "pass", "warn"),
  severity         = c("high", "info", "medium"),
  detail           = c("3 critical errors found", "No errors", "2 warnings"),
  source_version   = c("4.0", "4.0", "4.0"),
  stringsAsFactors = FALSE
)

ev_quality <- as_evidence(quality_findings, ctx = ctx)
cat("Quality evidence (", nrow(ev_quality), "rows):\n")
print(ev_quality[, c("indicator_id", "asset_id", "result", "severity")])

# Step 3: Canonicalize raw labels ----
# Real data often has inconsistent severity/result labels.
raw_severities <- c("HIGH", "Low", "MEDIUM", "Info", "CRITICAL", "low")
cat("\nRaw severities:", paste(raw_severities, collapse = ", "), "\n")
cat("Canonical:     ", paste(canon_severity(raw_severities), collapse = ", "), "\n")

raw_results <- c("PASS", "Fail", "WARNING", "pass", "N/A")
cat("\nRaw results:", paste(raw_results, collapse = ", "), "\n")
cat("Canonical:  ", paste(canon_result(raw_results), collapse = ", "), "\n")

# Step 4: Validate evidence ----
# Ensures all required columns exist and values are in controlled vocabularies.
# validate_evidence() returns TRUE if valid, or throws an error if not.
valid <- tryCatch(
  { validate_evidence(ev_quality); TRUE },
  error = function(e) { cat("Validation error:", e$message, "\n"); FALSE }
)
cat("\nValidation result:", valid, "\n")

# Step 5: Build more evidence and combine ----
trace_findings <- data.frame(
  indicator_id     = c("TRACE_COVERAGE", "TRACE_COVERAGE"),
  indicator_name   = c("Trace Coverage", "Trace Coverage"),
  indicator_domain = c("trace", "trace"),
  asset_type       = c("dataset", "dataset"),
  asset_id         = c("ADSL", "ADAE"),
  result           = c("pass", "warn"),
  severity         = c("info", "low"),
  detail           = c("100% mapped", "85% mapped"),
  source_name      = c("r4subtrace", "r4subtrace"),
  source_version   = c("0.1.0", "0.1.0"),
  stringsAsFactors = FALSE
)
ev_trace <- as_evidence(trace_findings, ctx = ctx)

# Combine all evidence sources into one table
ev_all <- bind_evidence(ev_quality, ev_trace)
cat("\nCombined evidence (", nrow(ev_all), "rows):\n")
print(ev_all[, c("indicator_domain", "indicator_id", "asset_id", "result")])

# Step 6: Summarize ----
cat("\nEvidence summary:\n")
print(evidence_summary(ev_all))
