library(dplyr)
library(tidyverse)
library(tidymodels)  # for cross-validation

setwd('/Users/michaelbove/Desktop/640 Labs')

#load data 
data_original <- read.csv("golf.csv")
data_scraped <- read.csv("pga_tour_2019_2025.csv")

#see full list of columns so I can get rid of the ones I won't be using
names(data_original)
names(data_scraped)

#keep only the columns I will be working with
data_original <- data_original %>%
  select(Player.Name, Average.Score, Avg.Distance,
         Fairway.Percentage, gir, Average.Putts,
         Average.Scrambling, SG.OTT, SG.APR,
         SG.ARG, Average.SG.Putts, Year)

# rename and clean scraped data to match original
data_scraped <- data_scraped %>%
  rename(
    Player.Name = player_name,
    Average.Score = scoring_avg,
    Avg.Distance = driving_dist,
    Fairway.Percentage = fairway_pct,
    Average.Putts = Putts_per_round,
    Average.Scrambling = Scrambling,
    SG.OTT = SG_off_the_tee,
    SG.APR = SG_approach,
    SG.ARG = SG_around_the_green,
    Average.SG.Putts = SG_putting,
    Year = year
  ) %>%
  mutate(
    Fairway.Percentage = as.numeric(str_remove(Fairway.Percentage, "%")),
    gir = as.numeric(str_remove(gir, "%")),
    Average.Scrambling = as.numeric(str_remove(Average.Scrambling, "%"))
  )

# combine into one dataset
data_combined <- bind_rows(data_original, data_scraped)

# seperating data into traditional metrics 
# and strokes gained metrics 

#traditional metrics
data_trad <- data_combined %>%
  select(Average.Score,
         Avg.Distance,
         Fairway.Percentage,
         gir,
         Average.Putts,
         Average.Scrambling,
         Year) %>%
  na.omit()

#strokes gained metrics
data_sg <- data_combined %>%
  select(Average.Score,
         SG.OTT, # strokes gained off the tee
         SG.APR, # strokes gained approach shots
         SG.ARG, #strokes gained around the green
         Average.SG.Putts, #strokes gained putts
         Year) %>%
  na.omit()
  
# REGRESSION MODEL

# traditional metrics model
model_trad <- lm(Average.Score ~ Avg.Distance +
                   Fairway.Percentage +
                   gir +
                   Average.Putts +
                   Average.Scrambling +
                   Year,
                 data = data_trad)

summary(model_trad)

# strokes gained model
model_sg <- lm(Average.Score ~ SG.OTT +
                 SG.APR +
                 SG.ARG +
                 Average.SG.Putts +
                 Year,
               data = data_sg)

summary(model_sg)

# VISUALIZATIONS OF DATA ____________________________________________________-


#visual evidence for GIR
ggplot(data_trad, aes(x = gir, y = Average.Score)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

# visual evidence for Strokes Gained on Approach shots
# which is the sg metric for GIR (green in regulation) 
#. so these are good to compare against each other 
ggplot(data_sg, aes(x = SG.APR, y = Average.Score)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)  

# predicted vs actual - both models side by side
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
  
# average score by year across the tour
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

# distribution of strokes gained metrics
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

# K-Fold Cross validation
# seeing how well the data predicts UNSEEN data

# freeze randomness (reporducibility) 
set.seed(123)

# split each dataset into 10 folds
cv_folds_trad <- vfold_cv(data_trad, v = 10)
cv_folds_sg   <- vfold_cv(data_sg, v = 10)

# tell R we are using linear regression
lm_spec <- linear_reg() %>%
  set_engine("lm")

# define formula and dataset for traditional metrics model
recipe_trad <- recipe(Average.Score ~ Avg.Distance +
                        Fairway.Percentage +
                        gir +
                        Average.Putts +
                        Average.Scrambling +
                        Year,
                      data = data_trad)

# define formula and dataset for strokes gained model
recipe_sg <- recipe(Average.Score ~ SG.OTT +
                      SG.APR +
                      SG.ARG +
                      Average.SG.Putts +
                      Year,
                    data = data_sg)

# workflows
workflow_trad <- workflow() %>%
  add_recipe(recipe_trad) %>%
  add_model(lm_spec)

workflow_sg <- workflow() %>%
  add_recipe(recipe_sg) %>%
  add_model(lm_spec)

# run cross validation
cv_results_trad <- fit_resamples(workflow_trad,
                                 resamples = cv_folds_trad,
                                 metrics = metric_set(rmse, rsq))

cv_results_sg <- fit_resamples(workflow_sg,
                               resamples = cv_folds_sg,
                               metrics = metric_set(rmse, rsq))

# view averaged results across all 10 folds
collect_metrics(cv_results_trad)
collect_metrics(cv_results_sg)

# STEPWISE ___________________________________________________________

#traditional metrics
stepwise_trad <- stats::step(model_trad, direction = "both")
summary(stepwise_trad)

# strokes gained metrics
stepwise_sg <- stats::step(model_sg, direction = "both")
summary(stepwise_sg)






