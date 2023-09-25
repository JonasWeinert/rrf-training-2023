library(here)

# setting path of dataset
path <- here("data", "raw", "state_database.csv")

#Loading dataset
df <- read.csv(path)

df$sum <- df$college + df$clinic