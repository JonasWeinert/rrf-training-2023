# Construction - R - secondary sources
# Load necessary packages --------------------------

# install.packages("pacman")
packages <- c("tidyr", "dplyr", "ggplot2", "here")
pacman::p_load(packages, character.only = TRUE, install = TRUE)

# Set path of our data 
tidy_folder <- here("data")
output <- here("outputs")



# read data 
colombia_connectivity_clean <- read.csv(file.path(tidy_folder, "colombia_connectivity_cleaned.csv"))
colombia_infraestructure <- read.csv(file.path(tidy_folder, "colombia_infrastructure_cleaned.csv"))

# Check the initial shape of the datasets
print(paste0("Initial shape of connectivity_data: ", dim(colombia_connectivity_clean)[1], ", ", dim(colombia_connectivity_clean)[2]))
print(paste0("Initial shape of infrastructure_data: ", dim(colombia_infraestructure)[1], ", ", dim(colombia_infraestructure)[2]))

##### Task 1  --------------------------
# Connectivity Analysis Dataset:
#   Unit of Observation: Administrative level 2 (e.g., cities or counties).
# Metrics: Average download and upload speeds, average latency, number of tests, and number of devices.
# Breakdown: By trimester and connection type.
# Infrastructure Analysis Dataset:
#   Unit of Observation: Administrative level 2 (e.g., cities or counties).
# Metrics: Number of colleges, clinics, universities, schools, and hospitals.
# Connectivity and Infrastructure Correlation Dataset:
#   Unit of Observation: Administrative level 2 (e.g., cities or counties).
# Metrics: Correlation coefficients between connectivity and infrastructure variables.
# Quarterly Connectivity Performance Dataset:
#   Unit of Observation: Trimester.
# Metrics: Quarterly average download and upload speeds, and average latency.
##### Task 2  --------------------------
# Convert kbps to Mbps
colombia_connectivity_clean$avg_d_mbps <- colombia_connectivity_clean$avg_d_kbps / 1000
colombia_connectivity_clean$avg_u_mbps <- colombia_connectivity_clean$avg_u_kbps / 1000
colombia_connectivity_clean <- subset(colombia_connectivity_clean, select = -c(avg_d_kbps, avg_u_kbps))

# Check after conversion
# Assert that the shape is the same as before
stopifnot(dim(colombia_connectivity_clean) == c(60414, 14))

##### Task 3  --------------------------
# Visual identification of outliers through plots
library(ggplot2)
ggplot(colombia_connectivity_clean, aes(y = avg_d_mbps)) + geom_boxplot() + ggtitle("Distribution of Average Download Speed (Mbps)")
ggplot(colombia_connectivity_clean, aes(y = avg_u_mbps)) + geom_boxplot() + ggtitle("Distribution of Average Upload Speed (Mbps)")
ggplot(colombia_connectivity_clean, aes(y = avg_lat_ms)) + geom_boxplot() + ggtitle("Distribution of Average Latency (ms)")

# Winsorize the data for the identified combinations
winsor_function <- function(dataset, var, min = 0.00, max = 0.99){
  var_sym <- sym(var)
  
  percentiles <- quantile(
    dataset %>% pull(!!var_sym), probs = c(min, max), na.rm = TRUE
  )
  
  min_percentile <- percentiles[1]
  max_percentile <- percentiles[2]
  
  dataset %>%
    mutate(
      !!paste0(var, "_winsorized") := case_when(
        is.na(!!var_sym) ~ NA_real_,
        !!var_sym <= min_percentile ~ percentiles[1],
        !!var_sym >= max_percentile ~ percentiles[2],
        TRUE ~ !!var_sym
      )
    )
}

grouped_counts <- colombia_connectivity_clean %>% group_by(connection, trimester) %>% tally()
combinations_to_winsorize <- filter(grouped_counts, n > 100)

for(i in 1:nrow(combinations_to_winsorize)) {
  condition <- colombia_connectivity_clean$connection == combinations_to_winsorize$connection[i] & colombia_connectivity_clean$trimester == combinations_to_winsorize$trimester[i]
  
  colombia_connectivity_clean$avg_d_mbps[condition] <- winsor_function(colombia_connectivity_clean[condition, ], "avg_d_mbps", 0.01, 0.99)$avg_d_mbps_winsorized
  colombia_connectivity_clean$avg_u_mbps[condition] <- winsor_function(colombia_connectivity_clean[condition, ], "avg_u_mbps", 0.01, 0.99)$avg_u_mbps_winsorized
  colombia_connectivity_clean$avg_lat_ms[condition] <- winsor_function(colombia_connectivity_clean[condition, ], "avg_lat_ms", 0.01, 0.99)$avg_lat_ms_winsorized
}

# Assert that the shape is the same as before
stopifnot(dim(colombia_connectivity_clean) == c(60414, 14))

##### Task 4  --------------------------
# Create indicators
avg_speeds <- colombia_connectivity_clean %>%
  group_by(trimester, ADM1_ES, ADM2_ES) %>%
  summarise(avg_d_mbps = mean(avg_d_mbps, na.rm = TRUE),
            avg_u_mbps = mean(avg_u_mbps, na.rm = TRUE)) %>%
  ungroup()

infrastructure_counts <- colombia_infraestructure %>%
  group_by(ADM1_ES, ADM2_ES) %>%
  summarise(
    college = sum(college, na.rm = TRUE),
    clinic = sum(clinic, na.rm = TRUE),
    university = sum(university, na.rm = TRUE),
    school = sum(school, na.rm = TRUE),
    hospital = sum(hospital, na.rm = TRUE)
  ) %>%
  ungroup()

ggplot(colombia_connectivity_clean, aes(y = avg_d_mbps)) + geom_boxplot() + ggtitle("Distribution of Average Download Speed (Mbps)")
ggplot(colombia_connectivity_clean, aes(y = avg_u_mbps)) + geom_boxplot() + ggtitle("Distribution of Average Upload Speed (Mbps)")
ggplot(colombia_connectivity_clean, aes(y = avg_lat_ms)) + geom_boxplot() + ggtitle("Distribution of Average Latency (ms)")


# Develop quarterly change indicators of connectivity speeds by municipality
avg_speeds$download_speed_change <- ave(avg_speeds$avg_d_mbps, avg_speeds$ADM2_ES, FUN = function(x) c(0, diff(x)))
avg_speeds$upload_speed_change <- ave(avg_speeds$avg_u_mbps, avg_speeds$ADM2_ES, FUN = function(x) c(0, diff(x)))

quarterly_change <- select(avg_speeds, trimester, ADM1_ES, ADM2_ES, download_speed_change, upload_speed_change)

##### Task 5  --------------------------
# Calculate the number of unique combinations of trimester & ADM2_ES in connectivity data
unique_combinations_con <- nrow(unique(colombia_connectivity_clean[c("trimester", "ADM2_ES","ADM1_ES")]))
print(unique_combinations_con)
# Calculate the number of unique combinations of trimester & ADM2_ES in infrastructure data
unique_combinations_inf <- nrow(unique(colombia_infraestructure[c("ADM2_ES","ADM1_ES")]))
print(unique_combinations_inf)

# Save the final datasets
connectivity_speeds_data <- select(avg_speeds, trimester, ADM1_ES, ADM2_ES, avg_d_mbps, avg_u_mbps)
stopifnot(dim(connectivity_speeds_data) == c(unique_combinations_con, 5))

amenities_count_data <- infrastructure_counts
stopifnot(dim(amenities_count_data) == c(unique_combinations_inf, 7))

connectivity_change_data <- quarterly_change
stopifnot(dim(connectivity_speeds_data) == c(unique_combinations_con, 5))

combined_data <- merge(
  select(connectivity_speeds_data, ADM1_ES, ADM2_ES, avg_d_mbps, avg_u_mbps, trimester),
  select(colombia_infraestructure, ADM1_ES, ADM2_ES, college, clinic, university, school, hospital),
  by = c("ADM1_ES", "ADM2_ES"),
  #all.x = FALSE
)
print(paste0(" shape of combined: ", dim(combined_data)[1], ", ", dim(combined_data)[2]))

combined_data_outer <- merge(
  select(connectivity_speeds_data, ADM1_ES, ADM2_ES, avg_d_mbps, avg_u_mbps, trimester),
  select(colombia_infraestructure, ADM1_ES, ADM2_ES, college, clinic, university, school, hospital),
  by = c("ADM1_ES", "ADM2_ES"),
  #all.x = FALSE
)


write.csv(connectivity_speeds_data, file.path(tidy_folder, "connectivity_speeds_data.csv"), row.names = FALSE)
write.csv(amenities_count_data, file.path(tidy_folder, "amenities_count_data.csv"), row.names = FALSE)
write.csv(connectivity_change_data, file.path(tidy_folder, "connectivity_change_data.csv"), row.names = FALSE)
write.csv(combined_data, file.path(tidy_folder, "combined_data.csv"), row.names = FALSE)


cat(paste("\nAll checks passed and data processing completed!\n\n",
  "Tasks completed in the script:\n",
  "1. Loaded necessary packages and set path of data.\n",
  "2. Converted download and upload speeds from kbps to Mbps.\n",
  "3. Winsorized extreme values in the data for certain combinations of connection type and trimester.\n",
  "4. Created indicators for average speeds and infrastructure counts, and developed quarterly change indicators of connectivity speeds by municipality.\n",
  "5. Saved the final datasets to CSV files.\n",
  "All checks passed and data processing completed!\n", sep = ""))
