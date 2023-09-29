# Cleaning data - R - secondary sources - template
# Load necessary packages --------------------------

# install.packages("pacman")

packages <- c("tidyr", 
              "dplyr", 
              "labelled", 
              "stringi",
              "BiocManager",
              "haven",
              "Hmisc")

pacman::p_load(packages,
               character.only = TRUE,
               install = TRUE) # Change to TRUE to install the necessary packages


tidy_folder <- here("data")


# Exercise 1 part 1 ---------------------------------------

# Step 0: Read data
# Reset
to_remove <- ls()[unlist(lapply(ls(), function(x) is.data.frame(get(x))))]
rm(list=to_remove)

colomcon <- read.csv(file.path(tidy_folder, "colombia_connectivity_decleaned.csv")) 


# Step 1: Remove duplicate entries
data <- colomcon[!duplicated(colomcon), ]


# Step 2: Ensure there is at least one identifying variable in the data
head(data)
unique(data$quadkey)

# Step 3: Encode choice questions and ensure correct data types

# Convert string columns (except quadkey) to numeric and use the strings as labels
for(col in names(data)) {
  if (col != "quadkey") {
    data[[col]] <- as.numeric(as.factor(data[[col]]))
  }
}

# Displaying the first few rows of the cleaned dataset
head(data)

# Step 4: Handle missing values

# Dropping rows with missing values from the cleaned dataset
data <- na.omit(data)

# Checking the shape of the dataset after dropping missing values
cat("Shape after dropping missing values:", dim(data), "\n")


# Verifying the changes by checking unique values in ADM1_ES and ADM2_ES columns
unique_adm1_es <- unique(data$ADM1_ES)
unique_adm2_es <- unique(data$ADM2_ES)

cat("Unique ADM1_ES values:\n", unique_adm1_es, "\n")
cat("First 10 unique ADM2_ES values:\n", head(unique_adm2_es, 10), "\n")


# Step 5: Drop data collection metadata variables not needed for analysis
# Remove unnecessary columns from your dataset
data = subset(data, select = -c(id_test_data) )


# Step 6: Ensure all variables have English names and no special characters

# Replace non-ASCII characters with their closest English counterparts
string_columns <- c("ADM0_ES", "ADM1_ES", "ADM2_ES", "connection", "trimester")
for(col in string_columns) {
  data[[col]] <- stri_trans_general(data[[col]], "latin-ascii")
}

# Step 7: Adding variable labels
# Add descriptive labels to your variables with a maximum of 80 characters each

# Creating a named list of variable labels
var_labels <- c(
  quadkey = "The unique identifier representing each tile. Useful for spatial indexing, partitioning, and storing and deriving the tile geometry.",
  ADM0_PC = "The code representing a specific country. The National boundary.",
  ADM0_ES = "The name representing a specific country in Spanish. The National boundary.",
  ADM1_PC = "The code representing a subdivision of a country, such as a state or province. First-level administrative divisions.",
  ADM1_ES = "The name representing a subdivision of a country in Spanish. First-level administrative divisions.",
  ADM2_PC = "The code representing a further subdivision, such as a municipality. Second-level administrative divisions",
  ADM2_ES = "The name representing a further subdivision in Spanish. Second-level administrative divisions",
  connection = "Type of connection consulted",
  trimester = "Trimester of the year for the data",
  avg_d_kbps = "The average download speed of all tests performed in the tile, measured in kilobits per second.",
  avg_u_kbps = "The average upload speed of all tests performed in the tile, measured in kilobits per second.",
  avg_lat_ms = "The average latency of all tests performed in the tile, measured in milliseconds.",
  tests = "The total number of tests taken in the tile.",
  devices = "The total number of unique devices contributing tests in the tile."
)

# Applying the labels to the dataframe column by column
for (col_name in names(var_labels)) {
  label(data[[col_name]]) <- var_labels[col_name]
}



# Exercise 1 part 2 ---------------------------------------

# Metadata
# Step 0: Get data type and labels for each column
# Get the class/type and labels of each column in your cleaned data

column_classes <- sapply(data, class)
column_labels <- sapply(names(data), function(col_name) {
  label(data[[col_name]])
})


# Step 1: Create a data frame for the codebook
# Create a codebook data frame using the info gathered in the previous step

codebook <- data.frame(
  Variable = names(data),
  DataType = column_classes,
  Label = column_labels,
  stringsAsFactors = FALSE
)

# Step 2: Save the cleaned data and the codebook
# Save your cleaned data and the codebook as CSV files

write.csv(data, file.path(tidy_folder, "cleaned_data.csv"), row.names = FALSE) 
write.csv(codebook, file.path(tidy_folder, "codebook.csv"), row.names = FALSE)
