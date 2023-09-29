# Tidying data - R - secondary sources - template
# Load necessary packages --------------------------

# install.packages("pacman")

packages <- c("tidyr",
              "tidyverse",
              "dplyr")

pacman::p_load(packages,
               character.only = TRUE,
               install = TRUE) # Change to TRUE to install the necessary packages

# Set path of our data 

# Set folder path to where you downloaded the data
tidy_folder <- here("data")

# Reset
to_remove <- ls()[unlist(lapply(ls(), function(x) is.data.frame(get(x))))]
rm(list=to_remove)


# Exercise 1 ---------------------------------------

# Step 1: Read the wide format data

connectivity_wide <- read.csv(file.path(tidy_folder, "colombia_connectivity_wide.csv")) 

# Step 2: Remove duplicates 

connectivity_wide <- connectivity_wide[!duplicated(connectivity_wide), ]

# Step 3: Reshape data

library(tidyverse)
head(connectivity_wide)

connectivity_long <- connectivity_wide %>%
  pivot_longer(
    cols = ends_with(c("_01","_04")),
    names_to = c(".value", "trimester"),
    values_to = ".value",
    names_pattern = "(.+)_(\\d+)"
  )


# Step 4: Verify your dataset has the desired structure
head(connectivity_long)
head(connectivity_wide)

# Exercise 2 ----------------------------

# Step 1: Read the long format data for infrastructure 
infrastructure_long <- read.csv(file.path(tidy_folder, "colombia_infrastructure_lng.csv"))

# Step 2: Explore the data 

head(infrastructure_long)

# ADM2_PC:  code for the second-level administrative division 
# ADM2_ES:  name of the second-level administrative division.
# ADM1_PC:  first-level administrative division
# ADM1_ES:  name of the first-level administrative division.
# ADM0_PC:  code for the country.
# ADM0_ES:  name of the country.
# amenities: types of amenities
# value: count or quantity of the respective amenity in the given administrative region.

# Step 3: Reshape the data. 

library(tidyverse)

infrastructure_wide <- infrastructure_long %>%
  pivot_wider(
    names_from = amenities,
    values_from = value
  )

head(infrastructure_wide)


# Challenges  --------------------------

##### Part 1.1: municipality with more download speed
# Long:
result <- connectivity_long %>%
  filter(trimester == "04") %>%
  group_by(ADM2_ES) %>%
  summarise(avg_d_kbps = mean(avg_d_kbps, na.rm = TRUE)) %>%
  arrange(desc(avg_d_kbps)) %>%
  head(1)

print(result)

# Wide:
head(connectivity_wide)
result_wide <- connectivity_wide %>%
  group_by(ADM2_ES) %>%
  summarise(avg_d_kbps_04 = mean(avg_d_kbps_04, na.rm = TRUE)) %>%
  arrange(desc(avg_d_kbps_04)) %>%
  head(1)
print(result)


##### Part 1.2: Amenity count

#Wide:
library(dplyr)
head(infrastructure_wide)
result <- infrastructure_wide %>%
  mutate(total_education = college + university + school, na.rm=TRUE) %>%
  arrange(desc(total_education)) %>%
  select(ADM2_ES, total_education) %>%
  head(2)

print(result)

#Long:

result <- infrastructure_long %>%
  filter(amenities %in% c("college", "university", "school")) %>%
  group_by(ADM2_ES) %>%
  summarise(total_education = sum(value, na.rm=TRUE)) %>%
  arrange(desc(total_education)) %>%
  head(2)
print(result)


##### Part 2: municipality with more educational institutions 

# rest of the exercise 

