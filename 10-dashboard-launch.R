# ============================================================================
# 10-dashboard-launch.R — Launch the Interactive Shiny Dashboard
# ============================================================================
#
# Shows how to launch the R4SUB dashboard with different data sources:
# pre-loaded evidence, demo data, or custom evidence.
#
# Packages: r4subui, r4subdata
# ============================================================================

library(r4subdata)

# Check if r4subui is available
if (!requireNamespace("r4subui", quietly = TRUE)) {
  cat("r4subui is not installed. Install it with:\n")
  cat('  pak::pak("R4SUB/r4subui")\n')
  quit(save = "no")
}

library(r4subui)

# Option 1: Launch with demo data from r4subdata ----
cat("Launching R4SUB dashboard with evidence_pharma dataset...\n")
cat("(Close the browser window or press Ctrl+C to stop)\n\n")

r4sub_app(evidence = evidence_pharma)

# Option 2: Launch with auto-generated demo data ----
# Uncomment below to try:
#
# demo_ev <- generate_demo_evidence(n_rows = 200, study_id = "DEMO-001")
# r4sub_app(evidence = demo_ev)

# Option 3: Launch empty (upload data in the UI) ----
# Uncomment below to try:
#
# r4sub_app()
