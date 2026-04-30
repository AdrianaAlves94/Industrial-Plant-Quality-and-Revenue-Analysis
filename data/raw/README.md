# Raw data

**Immutable.** Never edit files in this folder. Treat as read-only.

## Expected contents

- `2026_BatteryPassReady_DataAttributeLongList_v1_3.xlsx` — the longlist (primary dataset)
- `manufacturer_reports/` — sustainability/ESG PDFs for the 10 Act 4 manufacturers (gitignored, not committed)
- `rag_extractions/` — raw outputs from the RAG pipeline before validation (gitignored)

## Why this folder is mostly empty in the repo

PDFs and large raw files are not committed to git (see `.gitignore`). The longlist Excel file IS committed because it's small and licensing allows redistribution.

If you're cloning this repo and want to reproduce Act 4, you'll need to re-download the manufacturer reports yourself. The list is documented in `references/manufacturers.md`.
