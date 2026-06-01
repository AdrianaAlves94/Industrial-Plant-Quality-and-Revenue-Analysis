# Industrial Iron Plant - Quality and Revenue Analysis

*How often does an iron ore processing plant produce its best-quality output and what would it be worth to do that more often?*

Capstone project for the Ironhack Data Analytics Bootcamp. Built on real plant data from a working iron ore flotation circuit, combined with industry-standard pricing benchmarks (Platts 65% Fe Fines CFR China).

---

## Headline findings

- **Roughly half** of all operating hours produce top-quality output. **Almost 1 in 5** hours sit in price-penalty territory.
- Top quality is a **persistent state**, that typically lasts about **3 hours**, the longest stretched to **61**.
- Most quality drops self-correct within **~2 hours**, but a long tail of recoveries drags on much further.
- Two intuitive assumptions **didn't hold**: a smoother-running plant doesn't reliably mean better quality, and the time-of-day effect is real but too small to act on.

---

## Dashboard


🔗 **[Open interactive dashboard on Tableau Public](https://public.tableau.com/views/IronProcessingPlantAnalysis_Tableau/IndustrialOperationsPerformanceCommandCenter?:language=en-GB&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**

The dashboard summarises the analysis in one view: how often quality is at its best, what each hour is worth, how long good runs last, and how fast the plant recovers from a drop.

---

## The question

The plant turns raw rock into iron ore concentrate. The cleaner the output, the less impurity left in and the more buyers pay for it. The analysis asks five related questions:

1. **Quality mix** — What share of operating hours produce top-quality output vs middle vs low?
2. **Time patterns** — Does quality vary by hour, day, or part of the day?
3. **Stability** — Does the plant run more steadily on its inputs (pH, airflow, reagent dosing) during high-quality periods?
4. **Persistence and recovery** — Once quality is good, how long does it last? When it drops, how long until it returns?
5. **Operating envelopes** — What ranges of process conditions appear during the best-quality hours vs the worst?

---

## The data

- **Source:** [Quality Prediction in a Mining Process (Kaggle)](https://www.kaggle.com/datasets/edumagalhaes/quality-prediction-in-a-mining-process) — real operational data from an iron ore flotation plant, March–September 2017.
- **Scale:** ~4,100 hours of observations, aggregated from second-by-second sensor readings plus hourly lab results.
- **What's in it:** pH, starch flow, amina flow, ore pulp flow and density, seven airflow columns, seven level columns, and hourly lab measurements of iron and silica content (in and out).
- **What's not in it:** production volumes (tonnes per hour), shift rosters, maintenance logs, equipment IDs.

The missing volume data is the reason the revenue analysis stops at "per tonne" — the pricing framework is fully built, but a final total-revenue figure waits on production rate.

---

## How quality is defined

Each hour is classified by its **silica content** (the impurity that real buyers penalise). Iron and silica are strongly inversely correlated in this dataset (r ≈ −0.80), so silica alone captures most of the quality story.

| Tier | Silica % | Reasoning |
|---|---|---|
| **Premium** | < 2.0% | At or below the Platts 65% Fe benchmark — no commercial penalty |
| **Standard** | 2.0% – 3.5% | Within the first Platts silica penalty band |
| **Low** | ≥ 3.5% | Significant penalty territory |

Full rationale and threshold sources in [`docs/assumptions.md`](docs/assumptions.md). Pricing methodology and the revenue formula in [`docs/pricing_methodology.md`](docs/pricing_methodology.md).

---

## Approach

**Phase 1 — Data cleaning and modelling.** Raw 20-second readings aggregated to hourly means and within-hour standard deviations. Validation checks on lab values and process inputs. Loaded into a MySQL database with a time dimension and tier-threshold reference tables.

**Phase 2 — Exploration and hypothesis testing.** Three hypotheses tested with appropriate non-parametric methods (Mann-Whitney U, chi-square), with effect sizes computed alongside p-values to distinguish real effects from trivial ones.

**Phase 3 — Revenue modelling.** Per-tonne revenue computed for every hour using the Platts pricing formula, anchored to a fixed reference date.

**Phase 4 — Visualisation.** Tableau dashboard consolidating the headline numbers, distributions, and time trends.

**Tech stack:** Python (pandas, scipy), MySQL, Tableau, Jupyter.

---

## Findings in detail

**1. Quality mix — about half premium, but ~18% in penalty territory.**
Of ~4,100 hours: 49.9% Premium, 32.4% Standard, 17.7% Low. The Low band is where revenue leaks under the Platts pricing framework — once production volume is known, this becomes a quantified dollar figure.

**2. Top quality persists — it's not hour-to-hour luck.**
Premium streaks lasted **3 hours typically (median), with a longest run of 61 hours**. The Mann-Whitney U test confirmed premium streaks are significantly longer than non-premium (p < 0.001, moderate effect). This was the strongest, cleanest result in the analysis. *Implication: the operational priority is maintaining premium once reached, not just reaching it more often.*

**3. Recoveries are mostly quick, but a long tail drags on.**
Of 387 drops out of premium, the typical recovery (median) took **~2 hours**. The mean was 5.3h, pulled up by a long right tail with the worst stretches lasting up to ~88h. Those long recoveries are where most lost time accumulates and are the right target for early intervention.

**4. Stability did not predict quality (a tested null).**
Only 2 of 5 process inputs (pH variability, airflow variability) showed any difference between premium and non-premium hours. The intuitive idea that "smoother running = better quality" was not supported by the data. Reported as an honest negative result — stability is not a reliable quality indicator in this dataset.

**5. Time of day is significant but trivial (a tested null in effect).**
Premium share is highest in the evening (53.7%) and night (51.2%), lowest in the afternoon (47.0%). The chi-square test was significant (p = 0.030) but the effect size (Cramér's V = 0.041) is below the threshold for "small." Statistically real, operationally negligible, not worth reorganising shifts over.

---

## Limitations

- **One plant.** Findings may not generalise to other facilities or other ore types.
- **Associations only.** The analysis identifies what occurs together with quality, not what *causes* it. Causal claims would require designed experiments or richer operational data.
- **No production volumes.** Revenue is computed per tonne; final revenue totals depend on production rate, which isn't in the dataset.
- **No operator or shift data.** Limits the ability to investigate human or maintenance factors.
- **Sample size makes small effects significant.** With ~4,100 hours, even trivial differences pass significance tests — this is why effect sizes are reported alongside p-values throughout.

---

## Repo structure

```
.
├── README.md                          # This file
├── data/
│   └── cleaned/                       # Hourly aggregates and derived tables
├── docs/
│   ├── assumptions.md                 # Every decision, with rationale
│   └── pricing_methodology.md         # Platts benchmark and revenue formula
├── notebooks/
│   ├── 01_data_quality.ipynb          # Validation, cleaning, hourly aggregation
│   ├── 02_exploratory_analysis.ipynb  # Tier distributions, time patterns, EDA
│   └── 03_hypothesis_testing.ipynb    # Three hypotheses with statistical tests
├── sql/
│   ├── data_schema.sql                # Database schema and reference tables
│   ├── goal_1&2.sql                   # Tier distribution by time
│   ├── goal_3.sql                     # Stability comparisons across tiers
│   ├── goal_4.sql                     # Streak lengths and dip recoveries
│   └── goal_5.sql                     # Per-tonne revenue calculation
├── report/                            # Final deliverables (deck PDF, figures)
├── requirements.txt
└── LICENSE
```

---

## How to reproduce

```bash
# Clone and install dependencies
git clone https://github.com/YOUR_USERNAME/Industrial-Operation-Performance-and-Revenue-Analysis.git
cd Industrial-Operation-Performance-and-Revenue-Analysis
pip install -r requirements.txt

# Set up the MySQL database (requires a running MySQL instance)
mysql -u USER -p < sql/data_schema.sql

# Then run the SQL goals in order
mysql -u USER -p industrial_plant < sql/goal_1\&2.sql
mysql -u USER -p industrial_plant < sql/goal_3.sql
mysql -u USER -p industrial_plant < sql/goal_4.sql
mysql -u USER -p industrial_plant < sql/goal_5.sql

# Or open the notebooks for the full analysis
jupyter notebook notebooks/
```

---

## Author

**Adriana Alves** — Data Analytics Bootcamp Capstone, Ironhack, 2026.

## License

MIT — see [LICENSE](LICENSE).
