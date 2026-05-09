# 03_VISUALIZATIONS.R
# Five visualizations exploring the relationship between
# traditional and strokes gained metrics and scoring average
# Run 01_combine_data.R and 02_regression.R first
# ___________________________________________________________________________
 
library(dplyr)
library(tidyverse)
 
# load cleaned datasets and models
data_trad <- read.csv("data_trad.csv")
data_sg <- read.csv("data_sg.csv")
data_combined <- read.csv("data_combined.csv")
model_trad <- readRDS("model_trad.rds")
model_sg <- readRDS("model_sg.rds")
 
# PLOT 1: GIR vs Average Score
# shows the relationship between greens in regulation and scoring average
# noticeable scatter around the trend line
ggplot(data_trad, aes(x = gir, y = Average.Score)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)
 
# PLOT 2: SG Approach vs Average Score
# compare to plot 1 
# much tighter fit around the trend line
# suggests SG metrics more directly capture scoring performance
ggplot(data_sg, aes(x = SG.APR, y = Average.Score)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)
 
# PLOT 3: Predicted vs Actual side by side
# points closer to the dashed line = better predictions
trad_preds <- data.frame(
  Actual = data_trad$Average.Score,
  Predicted = predict(model_trad),
  Model = "Traditional"
)
 
sg_preds <- data.frame(
  Actual = data_sg$Average.Score,
  Predicted = predict(model_sg),
  Model = "Strokes Gained"
)
 
all_preds <- rbind(trad_preds, sg_preds)
 
ggplot(all_preds, aes(x = Actual, y = Predicted, color = Model)) +
  geom_point(alpha = 0.3) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "black") +
  facet_wrap(~Model) +
  labs(title = "Predicted vs. Actual Scoring Average",
       subtitle = "Points closer to the dashed line = better predictions",
       x = "Actual Score",
       y = "Predicted Score") +
  theme_minimal() +
  theme(legend.position = "none")
 
# PLOT 4: Tour average scoring by year (2010-2025)
# shows how tour-wide scoring averages have changed over time
# year is included as a control variable in both models because of this trend
data_combined %>%
  group_by(Year) %>%
  summarise(avg_score = mean(Average.Score, na.rm = TRUE)) %>%
  ggplot(aes(x = Year, y = avg_score)) +
  geom_line() +
  geom_point() +
  labs(title = "PGA Tour Average Scoring by Year (2010-2025)",
       subtitle = "Tour-wide average scoring average per season",
       x = "Year",
       y = "Average Score") +
  theme_minimal()
 
# PLOT 5: Distribution of strokes gained metrics
# all four distributions centered around 0, the tour average
# dashed line represents the tour average
data_sg %>%
  select(SG.OTT, SG.APR, SG.ARG, Average.SG.Putts) %>%
  pivot_longer(cols = everything(),
               names_to = "metric",
               values_to = "value") %>%
  ggplot(aes(x = value, fill = metric)) +
  geom_density(alpha = 0.5) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  facet_wrap(~metric) +
  labs(title = "Distribution of Strokes Gained Metrics (2010-2025)",
       subtitle = "Dashed line represents tour average (0)",
       x = "Strokes Gained",
       y = "Density") +
  theme_minimal() +
  theme(legend.position = "none")
 
