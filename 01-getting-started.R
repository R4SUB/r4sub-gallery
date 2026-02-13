# ============================================================================
# 01-getting-started.R — Load Packages, Explore Datasets and Schema
# ============================================================================
#
# A quick tour of the R4SUB ecosystem: load packages, discover available
# datasets, and understand the evidence table schema.
#
# Packages: r4sub, r4subdata, r4subcore
# ============================================================================

library(r4sub)

# Discover available datasets ----
cat("Available datasets in r4subdata:\n\n")
print(list_datasets())

# Explore the evidence table schema ----
cat("\n\nEvidence table schema (the core data contract):\n\n")
schema <- evidence_schema()
print(schema)

# Peek at each dataset ----
cat("\n\n--- evidence_pharma (", nrow(evidence_pharma), "rows ) ---\n")
print(head(evidence_pharma, 5))

cat("\n\n--- adam_metadata (", nrow(adam_metadata), "rows ) ---\n")
print(head(adam_metadata, 5))

cat("\n\n--- sdtm_metadata (", nrow(sdtm_metadata), "rows ) ---\n")
print(head(sdtm_metadata, 5))

cat("\n\n--- trace_mapping (", nrow(trace_mapping), "rows ) ---\n")
print(head(trace_mapping, 5))

cat("\n\n--- risk_register_pharma (", nrow(risk_register_pharma), "rows ) ---\n")
print(head(risk_register_pharma, 5))

cat("\n\n--- regulatory_indicators (", nrow(regulatory_indicators), "rows ) ---\n")
print(head(regulatory_indicators, 5))

# Look up a dataset dictionary ----
cat("\n\nColumn dictionary for evidence_pharma:\n\n")
print(dataset_dictionary("evidence_pharma"))
