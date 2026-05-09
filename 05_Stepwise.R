# 05_STEPWISE.R
# Stepwise regression to identify which variables contribute
# independently to each model
# Run 01_combine_data.R and 02_regression.R first
# _________________________________________________________________________

library(dplyr)
library(tidyverse)
library(tidymodels)

# load models produced by 02_regression.R
model_trad <- readRDS("model_trad.rds")
model_sg <- readRDS("model_sg.rds")

# stepwise regression with traditional metrics
# uses stats:: prefix to avoid conflict with tidymodels
# direction = "both" means variables can be added or removed at each step
stepwise_trad <- stats::step(model_trad, direction = "both")
summary(stepwise_trad)

# stepwise regression with strokes gained metrics
stepwise_sg <- stats::step(model_sg, direction = "both")
summary(stepwise_sg)
