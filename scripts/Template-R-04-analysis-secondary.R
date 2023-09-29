# Analysis - R - secondary sources Template
# Load necessary packages --------------------------

# install.packages("pacman")

packages <- c("tidyr", 
              "dplyr", 
              "ggplot2", 
              "corrplot", 
              "stargazer", 
              "gt", 
              "plm", 
              "here",
              "gridExtra",
              "tidyverse",
              "tinytex",
              "textTinyR",
              "sandwich",
              "moments",
              "here",
              "lmtest")

pacman::p_load(packages,
               character.only = TRUE,
               install = FALSE) # Change to TRUE to install the necessary packages

# Set path of our data 

# Set folder path to where you downloaded the data
# Set path of our data 
tidy_folder <- here("data")

# read data 

municipality_database <- read.csv(file.path(tidy_folder,
                                            "municipality_database.csv"))

state_database <- read.csv(file.path(tidy_folder,
                                     "state_database.csv"))

# -------------
# Task 1: Create Summary Statistics
# -------------

# In this task, generate summary statistics for both municipality and state databases.
variables <- c("college", "clinic", "university", "school", "hospital", "avg_d_mbps", "avg_u_mbps", "trimester")

municipality_summary <- stargazer::stargazer(municipality_database[variables], type="text", title="Summary Statistics for Municipality Database", median=TRUE, iqr=TRUE, skew=TRUE, kurt=TRUE, digits=2)
state_summary <- stargazer(state_database[variables], type="text", title="Summary Statistics for State Database", median=TRUE, iqr=TRUE, skew=TRUE, kurt=TRUE, digits=2)

library(grid)
library(gridExtra)

# Convert stargazer outputs to grid objects
convert_to_grob <- function(stargazer_output) {
  grob <- textGrob(stargazer_output, gp=gpar(fontsize=10))
  return(grob)
}

municipality_grob <- convert_to_grob(municipality_summary)
state_grob <- convert_to_grob(state_summary)


# Task 2: Visualization of Individual Variables ------------
# Function to generate plots for each variable
generate_plots <- function(data, title){
  plots_list <- list()
  
  for (var in variables){
    p1 <- ggplot(data, aes_string(x=var)) + geom_histogram(binwidth=0.5) + ggtitle(paste0("Histogram of ", var, " - ", title))
    p2 <- ggplot(data, aes_string(y=var)) + geom_boxplot() + ggtitle(paste0("Boxplot of ", var, " - ", title))
    plots_list[[var]] <- list(p1, p2)
  }
  
  return(plots_list)
}

municipality_plots <- generate_plots(municipality_database, "Municipality Database")
state_plots <- generate_plots(state_database, "State Database")



# Save the plots 
pdf(file.path(tidy_folder,
              "output_summary_and_plots.pdf"))

# Print the summary statistics
print(municipality_summary)
print(state_summary)

# Print the plots
for (var in variables){
  grid.arrange(grobs=municipality_plots[[var]], ncol=2)
  grid.arrange(grobs=state_plots[[var]], ncol=2)
}

dev.off()

pdf(file.path(tidy_folder,
              "output_summary_and_plots.pdf"))

# Draw the summary statistics tables
grid.draw(municipality_grob)
grid.draw(state_grob)

# Print the plots
for (var in variables){
  grid.arrange(grobs=municipality_plots[[var]], ncol=2)
  grid.arrange(grobs=state_plots[[var]], ncol=2)
}

dev.off()


# Task 3: Regression Analysis ------------------------

# Building Simple Linear Regression Model
# For avg_d_mbps_winsorized
model1 <- lm(avg_d_mbps_winsorized ~ college + clinic + university + school + hospital, data = municipality_database)

# For avg_u_mbps_winsorized
model2 <- lm(avg_u_mbps_winsorized ~ college + clinic + university + school + hospital, data = municipality_database)

# For avg_d_mbps_change
model3 <- lm(avg_d_mbps_change ~ college + clinic + university + school + hospital, data = municipality_database)

# For avg_u_mbps_change
model4 <- lm(avg_u_mbps_change ~ college + clinic + university + school + hospital, data = municipality_database)

# Multiple Regression Model with Clustered Standard Errors

cl_se_model1 <- coeftest(model1, vcov. = vcovCL, cluster = ~ADM1_ES, data = municipality_database)
cl_se_model2 <- coeftest(model2, vcov. = vcovCL, cluster = ~ADM1_ES, data = municipality_database)
cl_se_model3 <- coeftest(model3, vcov. = vcovCL, cluster = ~ADM1_ES, data = municipality_database)
cl_se_model4 <- coeftest(model4, vcov. = vcovCL, cluster = ~ADM1_ES, data = municipality_database)



# Save the model using stargazer
# Note: Use the stargazer package to create a neat table of your regression results. 
# Set different parameters in the stargazer function to customize the table according to your needs.

capture_summary <- function(model) {
  summary_text <- capture.output(summary(model))
  
  # Escape special LaTeX characters
  latex_escape <- function(text) {
    gsub("([%$#&_^{}])", "\\\\\\1", text)
  }
  
  return(paste(lapply(summary_text, latex_escape), collapse = "\n"))
}

models_list <- list(model1, model2, model3, model4, 
                    cl_se_model1, cl_se_model2, cl_se_model3, cl_se_model4)

summaries <- lapply(models_list, capture_summary)

latex_document <- c("\\documentclass{article}", 
                    "\\usepackage{hyperref}",  # Optional: For clickable links in the document
                    "\\begin{document}", 
                    "\\title{Regression Summaries}", 
                    "\\maketitle", 
                    paste(summaries, collapse = "\n\\newpage\n"), 
                    "\\end{document}")

writeLines(latex_document, "summary_results.tex")

# Compile the LaTeX document using LuaLaTeX
system("lualatex summary_results.tex")


# Task 4: Visual Analysis ------------------------

# Relationship Analysis
# Note: Use ggplot2 for scatter plots and add trend lines using geom_smooth() function. 
# Analyze the relationship between different variables visually.
# ....

# For avg_d_mbps_winsorized vs. college
ggplot(municipality_database, aes(x=college, y=avg_d_mbps_winsorized)) +
  geom_point() +
  geom_smooth(method="lm") +
  labs(title="Relationship between avg_d_mbps_winsorized and college")



# Change in Connectivity Analysis
# Note: Use ggplot2 to create a bar plot to visualize changes in connectivity. 
#You can use dplyr functions like filter, group_by, and summarize to process the data before plotting.

data_processed <- municipality_database %>%
  group_by(trimester) %>%  # Replace 'college' with other predictors as needed
  summarize(mean_avg_d_mbps = mean(avg_d_mbps_winsorized),
            mean_avg_u_mbps = mean(avg_u_mbps_winsorized))

ggplot(data_processed, aes(x=trimester, y=mean_avg_d_mbps)) +  # Change y to mean_avg_u_mbps for upload speeds
  geom_bar(stat="identity") +
  labs(title="Change in Connectivity per trimester")

# Task 5: Correlation Analysis ------------------------


# Correlation matrix
cor_matrix <- cor(municipality_database[,c("avg_d_mbps_winsorized", "avg_u_mbps_winsorized","college", "clinic", "university", "school", "hospital")])

# Visualize the correlation matrix
# Note: Use corrplot() function from corrplot package to visualize the correlation matrix.
# ....

corrplot(cor_matrix, method="shade")