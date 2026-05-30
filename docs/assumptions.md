# Project Assumptions and Decisions

This document records every decision made during the project: cleaning rules, thresholds, granularity choices, benchmark selection, hypotheses, and findings.

## Benchmark and Pricing Reference

**Benchmark used:** Platts 65% Fe Fines CFR China (IOPRM00) — all origins, current 2026 methodology.

**Reason for choice:** Matches the high-grade output range observed in the dataset (iron range 62–68%, mostly 64–67%). All-origins rather than country-specific, which matches the level of detail available about the plant's location.

**Spec sheet anchor:**
- Iron base: 65%
- Silica base: 2.0%
- Alumina base: 1.4%
- Phosphorus base: 0.065%
- Moisture base: 8.5%

The full pricing methodology and the formula for revenue calculation are documented separately in `pricing_methodology.md`.

---

## Quality Tier Classification

**Tiered on silica only**, not on iron. Iron content is mentioned as context but is not part of the tier rule.

**Reason for choice:**
- Iron and silica are strongly inversely correlated in this dataset (r ≈ −0.80). Silica tiers therefore implicitly capture most of the iron variation.
- Industry pricing treats silica as the penalty variable and iron as the premium variable. For a "quality tier" classification, the penalty axis is the more interpretable framing.
- A single-axis classification produces a cleaner methodological story.

**Tier thresholds:**

| Tier | Silica % range | Reasoning |
|---|---|---|
| **Premium** | Silica < 2.0% | At or below the Platts 65% Fe benchmark — no commercial penalty applies |
| **Standard** | 2.0% ≤ Silica < 3.5% | Within the first Platts silica penalty band (3.0–4.5%) |
| **Low** | Silica ≥ 3.5% | Significant penalty territory; worst observed hours reach 5.5% silica |

**Convention:** min-inclusive, max-exclusive on all tier boundaries.

---

## Time Granularity

**Primary working level:** hourly aggregates (one row per hour).

**Secondary roll-up:** daily aggregates (one row per day).

**Time dimension table** built from distinct hours in the data. Includes:
- Date, year, month, month name
- Day of the week (with Monday=0, Sunday=6 numeric code for sorting)
- Hour of the day (0–23)
- Time-of-day bucket (see below)
- Weekend flag

**Time-of-day buckets (six-hour windows):**
- Night: 00:00–05:59
- Morning: 06:00–11:59
- Afternoon: 12:00–17:59
- Evening: 18:00–23:59


---

## Data Cleaning Decisions

- **pH outlier handling:** Values above pH 14 (chemically impossible) were treated as data-entry errors and excluded. pH bounded to its valid range (0–14).
- **Aggregation method for 20-second readings:** Mean for typical values (e.g. `avg_ph`). Standard deviation (sample, N−1 formula) for within-hour variability (e.g. `std_ph`). Matches pandas default behaviour for consistency between SQL and Python results.
- **Missing values:** Hours with single readings (where standard deviation can't be calculated because it needs at least two readings) return NULL for variability columns. These represent 4 hours (~0.1% of data) and were handled by dropping them in tests rather than imputing.
- **Lab values (iron output % and silica output %):** Assumption was that lab values are constant within an hour. Verification on the silica output column found:
  - 3,881 hours (94.7%) — perfectly constant ✓
  - 197 hours — small variation (<0.5pp)
  - 15 hours — meaningful variation (>0.5pp, worst case 2.87pp spread on 2017-04-03 03:00)
  
  Decision: keep all hours, add standard-deviation columns for the four lab values so the data captures any within-hour variation if needed.
---

## Sampling Rates

- **Process measurements (20-second intervals):** pH, starch flow, amina flow, ore pulp flow, ore pulp density, all seven air-flow columns, all seven level columns. These are the fast-changing operating conditions.
- **Lab values (hourly):** Iron content in the output, silica content in the output, iron content in the input, silica content in the input. These are slower measurements from laboratory analysis.

---

## Stability — Operational Definition

Several hypotheses refer to "stability." This term is defined for the project as follows:

**Stability** = how much the operating conditions wobble within a single hour, measured by the standard deviation of process measurements within that hour. Lower standard deviation = more stable.

**What this captures:** short-term jitter or wobble in operating conditions over the course of one hour.

**What this does NOT capture:**
- Longer-term drift across hours or days
- Process robustness under disturbances
- Whether the plant is hitting its target setpoints (only how steady it stays around whatever value it's at)

This narrow definition was chosen because the data supports it directly (20-second readings within each hour) and because broader definitions of stability would require more context than this dataset provides.

---

## Project Goals

The project set out to answer five questions. Each is addressed by one or more hypotheses or descriptive analyses; this section serves as a crosswalk between the project's questions and where the work was done.

### Goal 1 — Identify when premium output is most likely (time-based patterns)

### Goal 2 — Understand overall output quality distribution

### Goal 3 — Test whether premium output is associated with steadier operating conditions

### Goal 4 — Investigate time-based patterns and clustering in output quality

### Goal 5 — Estimate commercial impact via Platts pricing

---

## Hypotheses

The project tests three hypotheses, each tied to a project goal.

### Hypothesis 1 — Stability and output quality

> Premium output is associated with steadier operating conditions during that hour.

- **H₀ :** Operating stability during premium hours equals operating stability during non-premium hours.
- **H₁ :** Operating stability during premium hours differs from operating stability during non-premium hours.

Test approach: compare within-hour standard deviations of process variables between premium and non-premium hours, using a non-parametric test (Mann-Whitney) since the variability data is right-skewed.

### Hypothesis 2 — Time-of-day pattern in output quality

> Output quality varies systematically with the time of day, and the variation can be partially explained by differences in operating conditions across time.

**Part 1 — Formal test:** Is there an association between time-of-day and quality tier?
- **H₀:** Quality tier and time-of-day are independent (no association).
- **H₁:** Quality tier and time-of-day are related.

Test approach: chi-squared test of independence on a contingency table of tier × time-of-day-bucket.

**Part 2 — Mechanism investigation (exploratory, NOT a formal hypothesis test):**
- Examine how operating conditions vary across time-of-day buckets
- Identify candidate explanations for the time-of-day pattern (no causal claims)

### Hypothesis 3 — Persistence in output quality

> When the plant produces premium output, it tends to stay in that state for several hours in a row rather than flipping between quality levels each hour.

- **H₀ :** Premium output does NOT persist longer than other quality tiers — when premium occurs, it lasts about the same amount of time as standard or low quality periods.
- **H₁ :** Premium output persists LONGER than other quality tiers — when premium occurs, it tends to last for several hours in a row, longer than standard or low quality periods.

Test approach: Mann-Whitney U test (one-sided, alternative='greater') comparing the distribution of premium streak lengths against non-premium streak lengths (standard and low combined). This is a non-parametric test, appropriate because streak length data is right-skewed. A complementary descriptive analysis of "dip recovery periods" (continuous non-premium hours between premium streaks) was also conducted to characterize how long the plant takes to bounce back from a quality drop.


---

## Out-of-Scope Items

The following are explicitly out of scope, due to data availability:

- Throughput or tonnage analysis (no volume data in the dataset)
- Operator or shift performance (no roster data)
- Maintenance impact (no maintenance logs)
- Equipment-level analysis (no machine-level identifiers)
- Causal claims — the analysis produces associations only, since there are no controlled experiments
- Anything requiring external context not present in the dataset (ambient temperature, ore stockpile rotation, etc.)

---

## Notes on Limits of the Analysis

A few honest limitations worth recording:

- The dataset offers about 4,097 hours of observations from a single plant. Findings from this dataset may not generalize to other plants or conditions.
- "Premium hours" is defined by output silica content, which is itself a lab measurement subject to sampling and timing limitations.
- No causal inference is possible. All findings describe associations between variables.
- Effect sizes were reported alongside p-values to avoid the common trap of treating "statistically significant" as the same as "meaningful."