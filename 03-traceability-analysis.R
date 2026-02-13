# ============================================================================
# 03-traceability-analysis.R — ADaM-to-SDTM Traceability Model and Coverage
# ============================================================================
#
# Shows how to build a traceability model linking ADaM datasets back to
# their SDTM sources, compute trace levels (L0-L3), identify orphan
# variables, and generate evidence rows for downstream scoring.
#
# Packages: r4subtrace, r4subdata, r4subcore
# ============================================================================

library(r4subcore)
library(r4subtrace)
library(r4subdata)

# Step 1: Load demo metadata ----
cat("ADaM metadata:", nrow(adam_metadata), "variables\n")
cat("SDTM metadata:", nrow(sdtm_metadata), "variables\n")
cat("Mappings:     ", nrow(trace_mapping), "links\n\n")

# Step 2: Validate metadata before building the model ----
# validate_metadata() and validate_mapping() return cleaned tibbles if valid,
# or throw an error if required columns are missing.
adam_clean <- validate_metadata(adam_metadata, kind = "adam")
sdtm_clean <- validate_metadata(sdtm_metadata, kind = "sdtm")
map_clean  <- validate_mapping(trace_mapping)
cat("ADaM metadata:", nrow(adam_clean), "variables (validated)\n")
cat("SDTM metadata:", nrow(sdtm_clean), "variables (validated)\n")
cat("Mapping:      ", nrow(map_clean), "links (validated)\n\n")

# Step 3: Build the traceability model ----
tm <- build_trace_model(
  adam_meta = adam_metadata,
  sdtm_meta = sdtm_metadata,
  mapping   = trace_mapping
)
print(tm)

# Step 4: Examine diagnostics ----
# diagnostics is a list of three tibbles: orphans, ambiguities, conflicts
cat("\nOrphan variables (ADaM vars with no SDTM link):\n")
orphans <- tm$diagnostics$orphans
if (nrow(orphans) > 0) {
  print(orphans)
} else {
  cat("  None found.\n")
}

cat("\nAmbiguous mappings (ADaM vars with multiple SDTM sources):\n")
ambig <- tm$diagnostics$ambiguities
if (nrow(ambig) > 0) {
  print(ambig)
} else {
  cat("  None found.\n")
}

# Step 5: Compute trace levels ----
# L0 = no mapping, no derivation
# L1 = derivation text only
# L2 = mapping exists
# L3 = mapping + high confidence or derivation text
levels <- compute_trace_levels(tm)
cat("\nTrace level distribution:\n")
print(table(levels$trace_level))

cat("\nDetailed trace levels:\n")
print(levels[, c("adam_dataset", "adam_var", "trace_level", "has_mapping", "max_confidence")])

# Step 6: Convert to evidence ----
ctx <- r4sub_run_context("CDISCPILOT01", "PROD")
ev_trace <- trace_model_to_evidence(tm, ctx)
cat("\nGenerated", nrow(ev_trace), "evidence rows from traceability model:\n")
print(ev_trace[, c("indicator_id", "asset_id", "result", "severity")])

# Step 7: Compute trace-specific indicator scores ----
scores <- trace_indicator_scores(ev_trace)
cat("\nTrace indicator scores:\n")
print(scores)
