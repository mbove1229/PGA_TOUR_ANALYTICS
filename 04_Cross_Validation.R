# 04_CROSS_VALIDATION.R
# 10-fold cross validation to test whether both models
# generalize well to unseen data
# Run 01_combine_data.R first to generate the required datasets
# _____________________________________________________________________

library(dplyr)
library(tidyverse)
library(tidymodels)

# load cleaned datasets produced by 01_combine_data.R
data_trad <- read.csv("data_trad.csv")
data_sg <- read.csv("data_sg.csv")

# freeze randomness so results are reproducible
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

# bundle recipe and model spec into workflows
workflow_trad <- workflow() %>%
  add_recipe(recipe_trad) %>%
  add_model(lm_spec)

workflow_sg <- workflow() %>%
  add_recipe(recipe_sg) %>%
  add_model(lm_spec)

# run cross validation across all 10 folds
cv_results_trad <- fit_resamples(workflow_trad,
                                 resamples = cv_folds_trad,
                                 metrics = metric_set(rmse, rsq))

cv_results_sg <- fit_resamples(workflow_sg,
                               resamples = cv_folds_sg,
                               metrics = metric_set(rmse, rsq))

# view averaged R-squared and RMSE across all 10 folds
# if CV R-squared is close to OLS R-squared the model is not overfitting
collect_metrics(cv_results_trad)
collect_metrics(cv_results_sg)
