## README: Reproducibility Package for Data Analysis Project

### Project Details
- **Name**: Data Analysis Project
- **Description**: This package contains all the necessary scripts and data files for the Data Analysis Project, focusing on Colombia's connectivity and infrastructure. 
- **Date**: 25-09-2023
- **Author**: Jonas Weinert

### Data Files:
1. `colombia_connectivity_wide.csv`: Contains data related to Colombia's connectivity. Sourced from Ookla and Humanitarian Data Exchange.
2. `colombia_infrastructure_wide.csv`: Contains data on Colombia's infrastructure. Sourced from Open Street Maps and Humanitarian Data Exchange.
3. `municipality_database.csv`: Contains data at the municipality level.
4. `state_database.csv`: Contains data at the state level.

### R Scripts:
1. `main_script.R`: The master script that coordinates the execution of all other scripts.
2. `Template-R-01-tidying-secondary.R`: Responsible for tidying secondary data.
3. `Template-R-02-cleaning-secondary.R`: Handles the cleaning of secondary data.
4. `Template-R-03-construction-secondary.R`: Used for constructing or transforming secondary data.
5. `Template-R-04-analysis-secondary.R`: Used for analyzing secondary data.

### Dependencies:
- R package: `here`
- Make sure to have `pacman` installed to handle other potential package dependencies.

### How to Run:
1. Ensure you have R and the above dependencies installed.
2. Set the working directory to the root of this package.
3. Execute `main_script.R`. It will coordinate the running of all other scripts in the specified order.
4. You might need to set `install` to `TRUE` in `pacman::p_load` if the necessary packages aren't already installed.

### Data Statement:
The data for this project is composed of two main datasets: Colombia's connectivity and Colombia's infrastructure. The connectivity dataset is sourced from Ookla and the Humanitarian Data Exchange, while the infrastructure dataset is sourced from Open Street Maps and the Humanitarian Data Exchange.

