# Iron Ore Pricing Methodology

This document explains the industry-standard pricing framework used for the revenue analysis component of this project, including the chosen benchmark and how penalties and premiums work in practice.

---

## The Three Conceptual Layers

There are three different things in this domain that have percentages, and they're easy to confuse:

1. **Benchmark NAME** — refers to the iron content of the benchmark category (e.g. "Platts 65% Fe" or "IODEX 61% Fe"). Think of these like product models in a catalog.
2. **Benchmark SPEC SHEET** — each benchmark has its own full set of specifications (Fe, silica, alumina, phosphorus). These describe what "standard" looks like for that grade.
3. **TIER THRESHOLDS** — the project-specific classification of operating hours (Premium / Standard / Low), anchored to the benchmark's spec sheet.

The benchmark's NAME and the SILICA SPEC inside it are both percentages but they refer to different things. The "65%" in "Platts 65% Fe" is iron content; the "2%" silica spec inside that benchmark refers to silica content.

---

## Chosen Benchmark for This Project

**Platts 65% Fe Fines CFR China (IOPRM00)** — all-origins, high-grade iron ore fines benchmark.

| Spec | Value |
|---|---|
| Iron base | 65% |
| Silica base | 2.0% |
| Alumina base | 1.4% |
| Phosphorus base | 0.065% |
| Moisture | 8.5% |
| Granularity | up to 10 mm for up to 90% of cargo |
| Currency | USD per dry metric tonne |
| Pricing location | CFR Qingdao, China |

**Why this benchmark:** Matches the high-grade concentrate range observed in the dataset (Fe range 62–68%, mostly 64–67%). All-origins rather than country-specific, which matches the level of detail available about the plant.

---

## How Iron Ore Pricing Works (The Formula)

The final price of iron ore depends on its iron content (premium) and silica content (penalty), measured against the benchmark's spec sheet:

```
Final Price = P_base
            + [ (Fe_actual − Fe_base) × VIU_Fe ]
            − [ max(0, Si_actual − Si_base) × Penalty_Si ]
```

LaTeX version (for use in the report):

$$
\text{Final Price} = P_{\text{base}} + \left[(Fe_{\text{actual}} - Fe_{\text{base}}) \times VIU_{Fe}\right] - \left[\max(0, Si_{\text{actual}} - Si_{\text{base}}) \times Penalty_{Si}\right]
$$

### What each term means

| Symbol | Meaning |
|---|---|
| `P_base` | Current dollar value of the benchmark (here, Platts 65% Fe Fines) |
| `Fe_actual` | Iron percentage from the lab assay |
| `Si_actual` | Silica percentage from the lab assay |
| `Fe_base` | 65% (Platts 65% Fe baseline) |
| `Si_base` | 2.0% (Platts 65% Fe baseline) |
| `VIU_Fe` | Daily market premium per 1% of extra iron |
| `Penalty_Si` | Daily market penalty per 1% of excess silica |

---

## Important Nuance: Silica Penalties Are NOT Linear

In practice, Platts publishes silica penalty rates in **bands**, because the penalty rate per 1% of extra silica gets steeper as silica content increases:

- **3.0–4.5% silica** — first penalty band (one rate per 1% silica)
- **4.5–6.5% silica** — steeper penalty band
- **6.5–9.0% silica** — steepest penalty band

For high-grade product (≥65% Fe), Platts publishes a separate "HG-Si-VIU" covering the 0.5–8.5% silica range.

**Project-level simplification:** This analysis uses a single `Penalty_Si` rate to keep the formula manageable. Acknowledging the band structure in the report demonstrates awareness of real-world complexity without requiring it to be implemented.


---

## Important Caveats

> **The dataset does not include actual production volumes.** Revenue figures in this project use an *assumed* tonnes-per-hour rate and should be interpreted as **directional or illustrative**, not actual revenue.

> **Market rates change daily.** This project uses a fixed snapshot from a specific reference date. Real-world application would require live or time-matched pricing data.

> **Other impurity penalties (alumina, phosphorus, moisture) are excluded** from this analysis to keep scope manageable. Silica is treated as the dominant commercial penalty for the concentrate type studied.

---

## Sources

- Platts Global Iron Ore Specifications Guide (S&P Global Commodity Insights), January 2026 edition
- Fastmarkets MB Iron Ore Indices methodology, May 2026 edition
