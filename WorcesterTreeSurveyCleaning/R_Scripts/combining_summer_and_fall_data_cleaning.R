pkgs <- c("dplyr", "ggplot2", "tidyr", "readxl", "stringr")
install.packages(pkgs)

sapply(pkgs, require, character.only = T)

# Update for new file path 
alltreedata <- read.csv("Y:\\Asian Longhorned Beetle\\HERO_2023\\Fall_DCR_Research\\Dataset_for_final_analysis_fall23_COMBINED_WITH_SUMMER.csv")
cleaning_treedata <- data.frame(alltreedata)
head(cleaning_treedata)
# Remove rows with duplicate OBJECTID and keep the final occurrence
#cleaning_treedata <- cleaning_treedata %>%
  #arrange(OBJECTID) %>%           # Sort the data frame by OBJECTID
  #filter(!duplicated(OBJECTID, fromLast = TRUE))

#save a backup before removing arborvitae and white fir  
#write.csv(cleaning_treedata, file = "Z:/HERO_2023/Fall_DCR_Research/Data/2014_2015_no_duplicates_mastersheet.csv", row.names = FALSE)


cleaning_treedata$SiteType <- as.character(cleaning_treedata$SiteType)
cleaning_treedata$SiteType[cleaning_treedata$SiteType %in% c("Back yard", "Backyard", "Back Yard")] <- "BY"
cleaning_treedata$SiteType[cleaning_treedata$SiteType %in% c("Front Yard", "Front yard")] <- "FY"
cleaning_treedata$SiteType[cleaning_treedata$SiteType %in% c("Parking Lot", "Park")] <- "MP"

cleaning_treedata$LandUse <- as.character(cleaning_treedata$LandUse)
cleaning_treedata$LandUse[cleaning_treedata$LandUse %in% c("Single-Family", "Single-family", "Single Family")] <- "SF"
cleaning_treedata$LandUse[cleaning_treedata$LandUse %in% c("Multi-family", "Multi-Familt","Multi-Family")] <- "MFR"
cleaning_treedata$LandUse[cleaning_treedata$LandUse %in% c("Commercial", "Park", "Maintained Park", "Industrial", "Golf Course", "Cemetery", "Institutional")] <- "INST"

cleaning_treedata$Mortality <- as.character(cleaning_treedata$Mortality)
cleaning_treedata$Mortality[cleaning_treedata$Mortality %in% c("Alive", "Good", "Fair")] <- "Alive"
cleaning_treedata$Mortality[cleaning_treedata$Mortality %in% c("Removed/Missing", "Remove/Missing","Removed/missing", "Removed", "Basal Sprout")] <- "Removed"


cleaning_treedata$Condition <- as.character(cleaning_treedata$Condition)
cleaning_treedata$Condition[cleaning_treedata$Condition %in% c("Critical")] <- "Poor"
cleaning_treedata$Condition[cleaning_treedata$Condition %in% c("fair")] <- "Fair"

"2023"
cleaning_treedata$SiteType_2023 <- as.character(cleaning_treedata$SiteType_2023)
cleaning_treedata$SiteType_2023[cleaning_treedata$SiteType_2023 %in% c("Back yard", "Backyard", "Back Yard")] <- "BY"
cleaning_treedata$SiteType_2023[cleaning_treedata$SiteType_2023 %in% c("Front Yard", "Front yard")] <- "FY"
cleaning_treedata$SiteType_2023[cleaning_treedata$SiteType_2023 %in% c("Parking Lot", "Park")] <- "MP"

cleaning_treedata$LandUse_2023 <- as.character(cleaning_treedata$LandUse_2023)
cleaning_treedata$LandUse_2023[cleaning_treedata$LandUse_2023 %in% c("Single-Family", "Single-family", "Single Family")] <- "SF"
cleaning_treedata$LandUse_2023[cleaning_treedata$LandUse_2023 %in% c("Multi-family", "Multi-Familt","Multi-Family")] <- "MFR"
cleaning_treedata$LandUse_2023[cleaning_treedata$LandUse_2023 %in% c("Commercial", "Park", "Maintained Park", "Industrial", "Golf Course", "Cemetery", "Institutional")] <- "INST"

cleaning_treedata$Mortality_2023 <- as.character(cleaning_treedata$Mortality_2023)
cleaning_treedata$Mortality_2023[cleaning_treedata$Mortality_2023 %in% c("Alive", "Good", "Fair")] <- "Alive"
cleaning_treedata$Mortality_2023[cleaning_treedata$Mortality_2023 %in% c("Removed/Missing", "Remove/Missing","Removed/missing", "Removed", "Basal Sprout")] <- "Removed"


cleaning_treedata$Condition_2023 <- as.character(cleaning_treedata$Condition_2023)
cleaning_treedata$Condition_2023[cleaning_treedata$Condition_2023 %in% c("Critical")] <- "Poor"
cleaning_treedata$Condition_2023[cleaning_treedata$Condition_2023 %in% c("fair")] <- "Fair"

library(stringr)

# Capitalize the first letter of every word in the SPECIES column
cleaning_treedata$SPECIES <- str_to_title(cleaning_treedata$SPECIES)

cleaning_treedata <- subset(cleaning_treedata, !is.na(SPECIES))
cleaning_treedata <- subset(cleaning_treedata, !(SPECIES == ""))
#checking which columns need to be cleaned
columns_to_check <- c(
  "SPECIES", "SiteType", "LandUse", "Species_1", 
  "MortalityS", "BasalSprou", "CrownDieba", "Condition", "CrownTrans"
)

# Create a list to store unique values for each column
unique_values_list <- list()

# Loop through each column and find unique values
for (column_name in columns_to_check) {
  unique_values <- unique(cleaning_treedata[[column_name]])
  unique_values_list[[column_name]] <- unique_values
}

# Print or access the unique values for each column
for (column_name in columns_to_check) {
  cat("Unique values in", column_name, ":", "\n")
  print(unique_values_list[[column_name]])
  cat("\n")
}
 
cleaning_treedata <- cleaning_treedata[, !names(cleaning_treedata) %in% c("Species_1", "POINT_X", "POINT_Y", "DataCollec", "DataColl_1", "DataColl_2", "DataColl_3", "DataColl_4", "DataColl_5", "CALIPER", "EQ_ACCESS", "FUNDING")]

# Rename columns in the dataframe
colnames(cleaning_treedata) <- gsub("DBH_in", "DBH", colnames(cleaning_treedata))
colnames(cleaning_treedata) <- gsub("DBH2_in", "DBH2", colnames(cleaning_treedata))
colnames(cleaning_treedata) <- gsub("MortalityS", "Mortality", colnames(cleaning_treedata))
colnames(cleaning_treedata) <- gsub("DBHHeight_", "DBH_Height", colnames(cleaning_treedata))
colnames(cleaning_treedata) <- gsub("DBH2Height", "DBH2_Height", colnames(cleaning_treedata))
colnames(cleaning_treedata) <- gsub("BasalSprou", "BasalSprouts", colnames(cleaning_treedata))
colnames(cleaning_treedata) <- gsub("CrownDieba", "CrownDieback", colnames(cleaning_treedata))
colnames(cleaning_treedata) <- gsub("Height_fin", "Height", colnames(cleaning_treedata))
colnames(cleaning_treedata) <- gsub("Width_fina", "Width", colnames(cleaning_treedata))


#write.csv(cleaning_treedata, file = "Z:/HERO_2023/Fall_DCR_Research/Data/2014_2015_cleanish_with_conifers.csv", row.names = FALSE)

# Remove rows where SPECIES is "American Arborvitae" or "White Fir"
cleaning_treedata <- subset(cleaning_treedata, !(SPECIES %in% c("American Arborvitae", "White Fir", "Juniper")))

write.csv(cleaning_treedata, file = "Y:\\Asian Longhorned Beetle\\HERO_2023\\Fall_DCR_Research\\summer_fall_combined_cleaned.csv")


# This function should return only "Alive", "Removed", "Unknown", "Stump", "Standing Dead", and " ".
#unique(alltreedata$Mortality1)


