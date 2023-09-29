# Dependencies

# PLEASE NOTE:
#   YOU CAN SET INSTALL = FALSE in the 4 scripts below to disable package installation

packages <- c("here")

pacman::p_load (packages,
                character.only = TRUE,
                install = TRUE) # Change to TRUE to install the necessary packages

# setting path of dataset
datapath <- here("data")


# Project Name: Data Analysis Project
# Description: This script is the master script for the Artist
# Data Analysis Project
#coordinating the execution of all other scripts
# Date: 25-09-2023
# Author: Jonas Weinert


# Tidying data
source(here("scripts", "Template-R-01-tidying-secondary.R"))

# Cleaning
source(here("scripts", "Template-R-02-cleaning-secondary.R"))

# Outcome construction
source(here("scripts", "Template-R-03-construction-secondary.R"))

# data analysis & visualisation
source(here("scripts", "Template-R-04-analysis-secondary.R"))

# Step 3: Print completion message
print("Data analysis complete")
