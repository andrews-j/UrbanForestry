#create combined dataframe with the dead trees added back in
pkgs <- c("dplyr", "ggplot2", "tidyr", "readxl", "stringr")
install.packages(pkgs)

sapply(pkgs, require, character.only = T)

# use the baseline as pre survey, and the newest survey data as survey23_data
survey23_data <- read.csv("X:\\Asian Longhorned Beetle\\HERO_2023\\Fall_DCR_Research\\Fall23_Hero_Final_Cleaned.csv")
survey23_data <- data.frame(survey23_data)

treedata_pre_survey <- read.csv("X:\\Asian Longhorned Beetle\\HERO_2023\\Fall_DCR_Research\\Data\\2014-15_Baseline_with_tree_categories_9_13.csv")
treedata_pre_survey <- data.frame(treedata_pre_survey)

combined_data <- bind_rows(survey23_data, treedata_pre_survey)


#check for duplicates
duplicates <- combined_data %>%
  group_by(ID) %>%
  filter(n() > 1)

# Remove rows with empty or NA values in Mortality_2023 if there is a duplicate ID
combined_data <- combined_data %>%
  filter(!(is.na(Mortality_2023) | Mortality_2023 == "") | !(ID %in% duplicates$ID))
write.csv(combined_data, "combined_dead_alive_23_test1.csv", row.names = FALSE)
getwd()
