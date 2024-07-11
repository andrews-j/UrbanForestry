#Fall 23 data cleaning 
pkgs <- c("dplyr", "ggplot2", "tidyr", "readxl", "stringr")
install.packages(pkgs)

sapply(pkgs, require, character.only = T)

# Update for new file path 
alltreedata <- read.csv("X:\\Asian Longhorned Beetle\\HERO_2023\\Fall_DCR_Research\\combined_dead_alive_11_14.csv")
cleaning_treedata <- data.frame(alltreedata)
head(cleaning_treedata)


cleaning_treedata$Mortality_2023[is.na(cleaning_treedata$Mortality_2023)] <- "Removed"
# This code will change "SF" in 'LandUse' to "SFR-A" if 'LandUse_2023' is "A",
# and to "SFR-D" if 'LandUse_2023' is "D", and leave the other values in 'LandUse' unchanged.
#finding differences
# Find rows with different values in 'SiteType' and 'SiteType_2023'
different_site_types <- subset(cleaning_treedata, SiteType != SiteType_2023)

# Now, different_site_types contains the rows with different 'SiteType' and 'SiteType_2023'
# Find rows with different values in 'LandUse' and 'LandUse_2023'
different_land_uses <- subset(cleaning_treedata, LandUse != LandUse_2023)



# Now, different_land_uses contains the rows with different 'LandUse' and 'LandUse_2023'
write.csv(cleaning_treedata, "Dataset_for_final_analysis_fall23.csv")
getwd()

#seeing unique values in relevant columns:
# Create an empty list to store unique values for each column
unique_lists <- list()

# Specify the columns you want to check for unique values
columns_to_check <- c("SPECIES", "TOWN", "LandUse_2023", "SiteType_2023", "Vigor_2023", "Mortality_2023", "Condition_2023", "BasalSprouts_2023")

# Loop through the specified columns
for (col in columns_to_check) {
  unique_lists[[col]] <- unique(cleaning_treedata[[col]])
}
unique_lists
