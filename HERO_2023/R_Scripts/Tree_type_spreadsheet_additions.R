#Tree type analysis
#general stats on trees planted so far

pkgs <- c("dplyr", "ggplot2", "tidyr", "readxl")
install.packages(pkgs)

sapply(pkgs, require, character.only = T)

# Update for new file path
filepath <- "Z:\\HERO_2023\\Fall_DCR_Research\\Data\\2014-15_Baseline_Final_with_manual_data_cleaning.csv"

alltreedata <- read.csv(filepath)

#Mortality Cleanup
alltreedata$Mortality <- as.character(alltreedata$Mortality)
# Create vectors of species for each category
shade_species <- c(
  "Red Oak", "Dawn Redwood", "Honeylocust", "Sweetgum", "Magnolia", 
  "Ginkgo", "White Oak", "Pin Oak", "Yellowwood", "Hophornbeam", 
  "Scarlet Oak", "Cucumber Magnolia", "Littleleaf Linden", "Tulip", 
  "Hornbeam", "Sourwood", "Swamp White Oak", "Fringetree", "Beech", 
  "Linden", "Japanese Pagoda Tree"
)

ornamental_species <- c(
  "Kousa Dogwood", "Japanese Stewartia", "Snow Goose Cherry", 
  "Japanese Lilac Tree", "Carolina Silverbell", "Japanese Snowbell", 
  "Zelkova", "Blackgum", "Crabapple", "Cherry", "Dogwood"
)

# Initialize columns to 0
alltreedata$SHADE <- 0
alltreedata$ORNAMENTAL <- 0
alltreedata$EVERGREEN <- 0

# Update "SHADE" and "ORNAMENTAL" based on the specified species
alltreedata$SHADE[alltreedata$SPECIES %in% shade_species] <- 1
alltreedata$ORNAMENTAL[alltreedata$SPECIES %in% ornamental_species] <- 1
alltreedata$EVERGREEN[!(alltreedata$SPECIES %in% c(ornamental_species,shade_species))] <- 1

# Print the updated data frame to verify the changes
head(alltreedata)
#write.csv(alltreedata, file = "Z:/HERO_2023/Fall_DCR_Research/Data/9_13_Baseline_with_tree_categories.csv", row.names = FALSE)

