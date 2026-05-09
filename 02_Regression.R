# 02_REGRESSION.R
# OLS regression models comparing traditional metrics vs
# strokes gained metrics in predicting PGA Tour scoring average
# Run 01_combine_data.R first to generate the required datasets
# ________________________________________________________________________
 
library(dplyr)
library(tidyverse)
 
# load cleaned datasets produced by 01_combine_data.R
data_trad <- read.csv("data_trad.csv")
data_sg <- read.csv("data_sg.csv")
 
# traditional metrics model
# predicts scoring average using driving distance, fairway %,
# greens in regulation, putts per round, scrambling, and year
model_trad <- lm(Average.Score ~ Avg.Distance +
                   Fairway.Percentage +
                   gir +
                   Average.Putts +
                   Average.Scrambling +
                   Year,
                 data = data_trad)
 
summary(model_trad)
 
# strokes gained model
# predicts scoring average using all four strokes gained categories
# and year as a control variable
model_sg <- lm(Average.Score ~ SG.OTT +
                 SG.APR +
                 SG.ARG +
                 Average.SG.Putts +
                 Year,
               data = data_sg)
 
summary(model_sg)
 
# save models for use in following scripts
saveRDS(model_trad, "model_trad.rds")
saveRDS(model_sg, "model_sg.rds")
