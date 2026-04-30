# Decoding the EU Battery Passport

> Reach, Complexity, Transparency, and Industry Position
> Data Analytics Capstone Project

## Project overview

The EU Battery Regulation (2023/1542) requires every battery placed on the EU market to publish a digital "Battery Passport" by February 2027. This project analyses the **100 data attributes** that make up that passport, plus a sample of **10 battery manufacturer disclosures**, to answer four questions:

1. **Reach** — Which battery types carry the heaviest disclosure burden?
2. **Complexity** — Where does the real engineering complexity sit?
3. **Transparency** — What can each stakeholder actually see?
4. **Industry Position** — How ready is the industry today vs. what the regulation will demand?

## Methodology summary

- **Source data**: BatteryPass-Ready Data Attribute Longlist v1.3 (100 attributes × 20+ metadata columns)
- **Schema**: Normalized 8-table relational model (~600 rows total)
- **Stack**: Python (pandas) → DuckDB → dbt → RAG (LLM extraction) → scipy → Tableau
- **Industry sample**: 10 manufacturers × 8 high-signal attributes, RAG-extracted, **manually validated 100%**
- **Statistical testing**: Chi-square test of independence (access tier × category)

Full methodology: see [`reports/report.pdf`](reports/) and [`references/`](references/).

## Repository structure

```
.
├── data/
│   ├── raw/             # Original immutable inputs (longlist, manufacturer PDFs)
│   ├── external/        # Third-party reference data
│   ├── interim/         # Intermediate cleaning outputs
│   └── processed/       # Final, analysis-ready datasets
├── dbt/                 # dbt project: staging → intermediate → marts
├── docs/                # Project documentation (data dictionary, schema diagrams)
├── notebooks/           # Numbered, single-purpose Jupyter notebooks
├── references/          # Data sources, regulation excerpts, manuals
├── reports/             # Final report (PDF), presentation deck
│   └── figures/         # Generated charts and visuals
├── src/                 # Reusable Python source code
│   ├── data/            # Cleaning and ingestion scripts
│   ├── features/        # Complexity score and other derived features
│   ├── rag/             # RAG pipeline for Act 4
│   └── visualization/   # Plotting helpers
├── tests/               # Unit tests for src/
├── .env.example         # Template for environment variables (API keys)
├── .gitignore
├── LICENSE
├── README.md
├── requirements.txt
└── setup.py             # Makes src/ importable as a package
```

## Findings

> Filled in after the analysis is complete. Three-sentence conclusion paragraph goes here.

## Reproducing the analysis

### 1. Set up environment

```bash
git clone <repo-url>
cd <repo-name>
python -m venv .venv
source .venv/bin/activate     # or .venv\Scripts\activate on Windows
pip install -r requirements.txt
pip install -e .              # makes src/ importable
```

### 2. Set up environment variables

```bash
cp .env.example .env
# edit .env with your OpenAI API key (only needed to re-run the RAG pipeline)
```

### 3. Run the pipeline

```bash
# Step 1 — clean raw data
python src/data/clean_longlist.py

# Step 2 — run dbt models
cd dbt
dbt deps
dbt build           # runs all models + tests
cd ..

# Step 3 — (optional) re-run RAG extraction. Requires OPENAI_API_KEY
python src/rag/run_extraction.py

# Step 4 — open notebooks in numerical order
jupyter lab notebooks/
```

### 4. View the dashboard

Live dashboard: [Tableau Public link — add after publishing]

## Key deliverables

| Deliverable | Location |
|---|---|
| Final report (PDF) | `reports/report.pdf` |
| Presentation deck | `reports/presentation.pdf` |
| Cleaned datasets | `data/processed/` |
| dbt models + docs | `dbt/` |
| Tableau dashboard | [Tableau Public link] |
| Tableau Story | [Tableau Public link] |

## Limitations

Honestly stated upfront — full discussion in the report:

- **Small population**: 100 regulatory attributes is small in row count; the analytical depth comes from metadata dimensions, not volume.
- **Complexity score is rule-based and subjective**: weights are defended in the methodology section.
- **RAG extractions can hallucinate**: every one of the 80 extractions in Act 4 was manually validated against the source PDF. Error rate and confidence flags are reported.
- **Manufacturer sample is small** (n=10): findings are illustrative, not statistically representative of the industry.

## License

MIT — see [LICENSE](LICENSE).

## Author

[Your name] — Data Analytics Bootcamp Capstone
[Date]
