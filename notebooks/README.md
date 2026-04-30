# Notebooks

Numbered, single-purpose Jupyter notebooks. Run in order.

## Naming convention (Cookiecutter Data Science)

```
<step>-<initials>-<short-description>.ipynb
```

Example: `01-cs-data-cleaning.ipynb`

## Expected sequence

| # | Notebook | Purpose |
|---|---|---|
| 01 | data-profiling.ipynb | Initial profiling of the raw longlist |
| 02 | data-cleaning.ipynb | Cleaning + producing processed CSVs |
| 03 | feature-engineering.ipynb | Complexity score definition + computation |
| 04 | eda.ipynb | Exploratory analysis across the schema |
| 05 | act1-reach.ipynb | Act 1 final analysis + visuals |
| 06 | act2-complexity.ipynb | Act 2 final analysis + visuals |
| 07 | act3-transparency.ipynb | Act 3 + chi-square test |
| 08 | act4-rag-extraction.ipynb | RAG pipeline run |
| 09 | act4-validation.ipynb | Manual validation + scoring |
| 10 | final-synthesis.ipynb | Cross-act synthesis + figures for report |

## Rules of thumb

- **One purpose per notebook.** If you find yourself doing two unrelated things, split it.
- **Notebooks consume from `src/`, they don't define logic.** Reusable functions go in `src/`, notebooks call them.
- **Re-runnable end to end.** Restart kernel + Run All should work from a clean clone.
- **Outputs cleared before commit.** Heavy outputs bloat the repo and obscure diffs. Use `nbstripout` or clear manually.
