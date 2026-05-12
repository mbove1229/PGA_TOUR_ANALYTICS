# PGA Tour Analytics Pipeline (2010–2025)

A two-language data pipeline that collects, cleans, and analyzes 15 years of PGA Tour player statistics to examine whether **strokes gained metrics** outperform **traditional performance metrics** in predicting scoring average.

**Python** handles data collection via a custom GraphQL API scraper. **R** handles statistical analysis including OLS regression, 10-fold cross-validation, and stepwise regression.

---

## Research Question

Do strokes gained metrics explain variation in PGA Tour scoring averages more effectively than traditional performance metrics?

---

## Repository Structure

```
- PGA Tour Scraper.ipynb      # Python scraper. Collects 2019-2025 data from PGA Tour API
- 01_combine_data.R           # Load, clean, and combine both datasets
- 02_regression.R             # OLS regression models
- 03_visualizations.R         # All five visualizations
- 04_cross_validation.R       # 10-fold cross validation
- 05_stepwise.R               # Stepwise regression
- golf.csv                    # Original dataset (2010-2018) sourced from Kaggle
- pga_tour_2019_2025.csv      # Scraped dataset (2019-2025) collected via PGA Tour GraphQL API
- README.md
```
## Portfolio Essay

[Read the full portfolio essay here] https://docs.google.com/document/d/1I_rpi3P9MbUzLGlb3ApTc85KlYFbJcyk5KInTP1HKMQ/edit?usp=sharing
---

## Data Collection (Python)

The scraper interacts directly with the PGA Tour's GraphQL API at `orchestrator.pgatour.com/graphql`. The API endpoint and client-side API key were identified by inspecting browser network traffic.

**Stats collected:**
- Scoring Average
- Driving Distance
- Fairway Hit Percentage
- Greens in Regulation
- Putts Per Round
- Scrambling Percentage
- Strokes Gained: Off the Tee
- Strokes Gained: Approach
- Strokes Gained: Around the Green
- Strokes Gained: Putting

**Years covered:** 2019–2025  
**Final dataset:** 1,327 player-season observations across 12 columns

### How to Run the Scraper

1. Install dependencies:
```bash
pip install requests pandas
```

2. Open `PGA Tour Scraper.ipynb` in Jupyter Notebook
3. Run all cells. The final cell saves `pga_tour_2019_2025.csv` to your working directory

---

## Statistical Analysis (R)

The R script loads both datasets, combines them into a 3,639 row dataset spanning 2010–2025, and runs the following analyses:

**Models:**
- OLS regression using traditional metrics (R² = 0.712)
- OLS regression using strokes gained metrics (R² = 0.926)

**Validation:**
- 10-fold cross-validation confirms both models generalize well to unseen data (CV R² = 0.711 and 0.925 respectively)
- Stepwise regression retains all variables in both models, confirming each predictor contributes independently

**Visualizations:**
- GIR vs. Scoring Average
- SG Approach vs. Scoring Average
- Predicted vs. Actual (side by side model comparison)
- Tour Average Scoring by Year (2010–2025)
- Distribution of Strokes Gained Metrics

### How to Run the Analysis

1. Install R packages:
```r
   install.packages(c("dplyr", "tidyverse", "tidymodels"))
```

2. Download the full repository as a folder and open the scripts from that folder. No file paths need to be changed.
3. Run the scripts in order: 01 first, then 02, 03, 04, and 05

---

## Key Findings

- Strokes gained metrics explain **92.6% of variance** in scoring average vs. **71.2%** for traditional metrics
- Cross-validation confirms the gap is not due to overfitting. Both models generalize well to unseen data
- Stepwise regression retains all variables in both models, with SG metrics showing more balanced variable importance across categories
- Tour-wide scoring averages have remained remarkably stable (70.85–71.1) across 15 seasons despite equipment and course changes

---

## Tools & Technologies

| Tool | Purpose |
|------|---------|
| Python | Data collection, API interaction |
| requests | HTTP requests to GraphQL API |
| pandas | Data manipulation and export |
| Jupyter Notebook | Interactive development environment |
| R | Statistical analysis |
| tidyverse | Data wrangling and visualization |
| tidymodels | Cross-validation framework |
| ggplot2 | Data visualization |

---

## Data Sources

- **2010–2018:** [PGA Tour Data 2010-2018](https://www.kaggle.com/datasets/jmpark746/pga-tour-data-2010-2018) via Kaggle
- **2019–2025:** Scraped directly from the PGA Tour GraphQL API

---

## Author

**Michael Bove**  
Graduate Student, Data Analysis & Visualization — Pratt Institute  
[LinkedIn](https://linkedin.com/in/michael-bove-476b62264) | [GitHub](https://github.com/mbove1229)
