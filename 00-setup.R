# ============================================================================
# 00-setup.R — Install and Verify the R4SUB Ecosystem
# ============================================================================
#
# This script installs all R4SUB packages from GitHub and verifies
# the installation. Run this once before running the other demos.
#
# ============================================================================

# Install pak if not available ----
if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak")
}

# Install the r4sub meta-package (pulls all dependencies) ----
pak::pak("R4SUB/r4sub")

# Optionally install the Shiny dashboard ----
pak::pak("R4SUB/r4subui")

# Verify installation ----
library(r4sub)
cat("\nInstalled R4SUB packages:\n")
print(r4sub_packages())

cat("\nSetup complete. You can now run any demo script.\n")
