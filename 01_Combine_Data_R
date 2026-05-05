# To run this script: download the full repository as a folder and open
# this file from that folder.
 
# 01_COMBINE_DATA.R
# Load, clean, and combine the original Kaggle dataset (2010-2018)
# with the scraped PGA Tour dataset (2019-2025)
# Run this file first before any other script
#_______________________________________________________________________
 
library(dplyr)
library(tidyverse)
 
# load original dataset (2010-2018) sourced from Kaggle
data_original <- read.csv("golf.csv")
 
# load scraped dataset (2019-2025) collected via PGA Tour Scraper.ipynb
data_scraped <- read.csv("pga_tour_2019_2025.csv")
 
# keep only the columns that exist in both datasets
data_original <- data_original %>%
  select(Player.Name, Average.Score, Avg.Distance,
         Fairway.Percentage, gir, Average.Putts,
         Average.Scrambling, SG.OTT, SG.APR,
         SG.ARG, Average.SG.Putts, Year)
 
# rename and clean scraped data columns to match original dataset
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
    # the API started returning % signs in 2023 -- strip them before converting
    Fairway.Percentage = as.numeric(str_remove(Fairway.Percentage, "%")),
    gir = as.numeric(str_remove(gir, "%")),
    Average.Scrambling = as.numeric(str_remove(Average.Scrambling, "%"))
  )
 
# combine both datasets into one
data_combined <- bind_rows(data_original, data_scraped)
 
# confirm the merge
nrow(data_original)
nrow(data_scraped)
nrow(data_combined)
table(data_combined$Year)
 
# create datasets with only the columns needed
# dropping rows with missing values using na.omit()
 
# traditional metrics dataset
data_trad <- data_combined %>%
  select(Average.Score,
         Avg.Distance,
         Fairway.Percentage,
         gir,
         Average.Putts,
         Average.Scrambling,
         Year) %>%
  na.omit()
 
# strokes gained metrics dataset
data_sg <- data_combined %>%
  select(Average.Score,
         SG.OTT,
         SG.APR,
         SG.ARG,
         Average.SG.Putts,
         Year) %>%
  na.omit()
 
# save cleaned datasets for use in subsequent scripts
write.csv(data_combined, "data_combined.csv", row.names = FALSE)
write.csv(data_trad, "data_trad.csv", row.names = FALSE)
write.csv(data_sg, "data_sg.csv", row.names = FALSE)
