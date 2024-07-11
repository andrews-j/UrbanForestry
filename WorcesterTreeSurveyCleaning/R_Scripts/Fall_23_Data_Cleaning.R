#Fall 23 data cleaning 
pkgs <- c("dplyr", "ggplot2", "tidyr", "readxl", "stringr")
install.packages(pkgs)

sapply(pkgs, require, character.only = T)

# Update for new file path 
alltreedata <- read.csv("Z:/HERO_2023/Fall_DCR_Research/Fall23_Hero_Final.csv")
cleaning_treedata <- data.frame(alltreedata)
head(cleaning_treedata)

# Remove rows with duplicate OBJECTID and keep the final occurrence
cleaning_treedata <- cleaning_treedata %>%
  arrange(OBJECTID) %>%           # Sort the data frame by OBJECTID
  filter(!duplicated(OBJECTID, fromLast = TRUE))




cleaning_treedata$LandUse <- ifelse(cleaning_treedata$LandUse == "SF" & cleaning_treedata$LandUse_2023 == "SFR-A", "SFR-A",
                                    ifelse(cleaning_treedata$LandUse == "SF" & cleaning_treedata$LandUse_2023 == "SFR-D", "SFR-D",
                                           cleaning_treedata$LandUse))


cleaning_treedata$LandUse_2023 <- as.character(cleaning_treedata$LandUse_2023)
cleaning_treedata$LandUse_2023[cleaning_treedata$LandUse_2023 %in% c("MF")] <- "MFR"
cleaning_treedata$LandUse_2023[cleaning_treedata$LandUse_2023 %in% c("Natural area")] <- "Natural Area"
cleaning_treedata$LandUse_2023[cleaning_treedata$LandUse_2023 %in% c("SF")] <- "SFR-D"



cleaning_treedata$Mortality_2023 <- as.character(cleaning_treedata$Mortality_2023)
cleaning_treedata$Mortality_2023[cleaning_treedata$Mortality_2023 %in% c("Alive ")] <- "Alive"
cleaning_treedata$Mortality_2023[cleaning_treedata$Mortality_2023 %in% c("Removed ")] <- "Removed"
cleaning_treedata$Mortality_2023[cleaning_treedata$Mortality_2023 %in% c("STUMP")] <- "Stump"
cleaning_treedata$Mortality_2023[cleaning_treedata$Mortality_2023 %in% c("Unknown ")] <- "Unknown"
cleaning_treedata$Mortality_2023[cleaning_treedata$Mortality_2023 %in% c("Standing dead")] <- "Standing Dead"

cleaning_treedata$BasalSprouts_2023 <- as.character(cleaning_treedata$BasalSprouts_2023)
cleaning_treedata$BasalSprouts_2023[cleaning_treedata$BasalSprouts_2023 %in% c("No ", "0")] <- "N"
cleaning_treedata$BasalSprouts_2023[cleaning_treedata$BasalSprouts_2023 %in% c("Yes","y", "1")] <- "Y"


cleaning_treedata$Condition_2023 <- as.character(cleaning_treedata$Condition_2023)
cleaning_treedata$Condition_2023[cleaning_treedata$Condition_2023 %in% c("Fair ")] <- "Fair"
# This code will change "SF" in 'LandUse' to "SFR-A" if 'LandUse_2023' is "A",
# and to "SFR-D" if 'LandUse_2023' is "D", and leave the other values in 'LandUse' unchanged.
#finding differences
# Find rows with different values in 'SiteType' and 'SiteType_2023'
different_site_types <- subset(cleaning_treedata, SiteType != SiteType_2023)

# Now, different_site_types contains the rows with different 'SiteType' and 'SiteType_2023'
# Find rows with different values in 'LandUse' and 'LandUse_2023'
different_land_uses <- subset(cleaning_treedata, LandUse != LandUse_2023)

# Now, different_land_uses contains the rows with different 'LandUse' and 'LandUse_2023'
write.csv(cleaning_treedata, "midclean_1.csv")
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
