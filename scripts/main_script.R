library(here)

# setting path of dataset
path <- here("data", "state_database.csv")

#Loading dataset
df <- read.csv(path)

df$sum <- df$college * 2

write.csv(df, path)


# Project Name: Data Analysis Project
# Description: This script is the master script for the Artist
# Data Analysis Project
#coordinating the execution of all other scripts
# Date: 25-09-2023
# Author: Jonas Weinert

# Step 1: Load necessary libraries
install.packages ("tidyr","dplyr","labelled","stringi","Hmisc","stringr")
packages <- c("tidyr",
              "dplyr",
              "labelled",
              "stringi",
              "Hmisc",
              "stringr")

pacman::p_load (packages,
                character.only = TRUE,
                install = FALSE) # Change to TRUE to install the necessary packages


# Step 2: Source external scripts

# Script for reading data
source(here("scripts", "01_data.R"))

# Script for data cleaning
source(here("scripts", "02_cleaning.R"))

# Script for generating summaries
source(here("scripts", "03_construction.R"))

# Script for data analysis
source(here("scripts", "04_analysis.R"))

# Script for data visualization
source(here("scripts", "05_visualization.R"))

# Step 3: Print completion message
print("Data analysis complete")
