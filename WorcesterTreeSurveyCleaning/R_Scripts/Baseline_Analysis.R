pkgs <- c("dplyr", "ggplot2", "tidyr", "readxl", "stringr")
install.packages(pkgs)

sapply(pkgs, require, character.only = T)

# Update for new file path 
alltreedata <- read.csv("Z:/HERO_2023/Fall_DCR_Research/Data/2014_2015_inprogress_mastersheet.csv")
cleaning_treedata <- data.frame(alltreedata)
head(cleaning_treedata)
# Remove rows with duplicate OBJECTID and keep the final occurrence
cleaning_treedata <- cleaning_treedata %>%
  arrange(OBJECTID) %>%           # Sort the data frame by OBJECTID
  filter(!duplicated(OBJECTID, fromLast = TRUE))

#save a backup before removing arborvitae and white fir  
#write.csv(cleaning_treedata, file = "Z:/HERO_2023/Fall_DCR_Research/Data/2014_2015_no_duplicates_mastersheet.csv", row.names = FALSE)
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

#cleaning_treedata <- cleaning_treedata




cleaning_treedata$SiteType <- as.character(cleaning_treedata$SiteType)
cleaning_treedata$SiteType[cleaning_treedata$SiteType %in% c("Back yard", "Backyard", "Back Yard")] <- "BY"
cleaning_treedata$SiteType[cleaning_treedata$SiteType %in% c("Front Yard", "Front yard")] <- "FY"
cleaning_treedata$SiteType[cleaning_treedata$SiteType %in% c("")] <- "Stump"
cleaning_treedata$SiteType[cleaning_treedata$SiteType %in% c("U", "unknown", "Unkown")] <- "Unknown"
#alltreedata$Mortality1[alltreedata$Mortality1 %in% c(" ")] <- "Empty"
#empty = sum(alltreedata$Mortality1=" ")

# This function should return only "Alive", "Removed", "Unknown", "Stump", "Standing Dead", and " ".
unique(alltreedata$Mortality1)

#Species Cleanup
summary(alltreedata$SPECIES)
alltreedata$SPECIES[alltreedata$SPECIES =="Japanese tree lilac"] <- "Japanese Tree Lilac"
alltreedata$SPECIES[alltreedata$SPECIES =="White Fur"] <- "White Fir"
alltreedata$SPECIES[alltreedata$SPECIES =="Honey locust"] <- "Honeylocust"
alltreedata$SPECIES[alltreedata$SPECIES =="White Oak"] <- "Swamp White Oak"
alltreedata$SPECIES[alltreedata$SPECIES =="Blackgum is"] <- "Blackgum"

treesurvey <- subset(alltreedata, Mortality1 %in% c("Alive", "Removed", "Standing Dead", "Stump", "Unknown"))
treesurvey <- as.character(treesurvey)

# Subset the data for alive and dead trees
alive_trees <- alltreedata[alltreedata$Mortality1 %in% c("Alive"), ]
dead_trees <- alltreedata[alltreedata$Mortality1 %in% c("Standing Dead", "Removed", "Stump"), ]
unknown_trees <- alltreedata[alltreedata$Mortality1 %in% c("Unknown"), ]