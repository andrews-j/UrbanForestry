
pkgs <- c("dplyr", "ggplot2", "tidyr", "readxl", "stringr")
install.packages(pkgs)

sapply(pkgs, require, character.only = T)


alltreedata <- read.csv("Y:\\Asian Longhorned Beetle\\HERO_2023\\Fall_DCR_Research\\Dataset_for_final_analysis_fall23.csv")# Create a new column 'FULL_ADDRESS'
alltreedata <- alltreedata %>%
  mutate(FULL_ADDRESS = paste(HOUSE_NUMBER, STREET, TOWN, sep = ", "))

# Group by FULL_ADDRESS and calculate the number of trees and survival rate
tree_summary <- alltreedata %>%
  group_by(FULL_ADDRESS) %>%
  summarise(
    total_trees = n(),
    alive_trees = sum(Mortality_2023 == "Alive"),
    dead_trees = sum(Mortality_2023 == "Removed"),
    survival_rate = alive_trees / total_trees * 100
  )

"_____________________"
tree_summary %>%
  group_by(total_trees) %>%
  summarise(
    Mean_Survival_Rate = mean(survival_rate),
    Survival_Rate_StdDev = sd(survival_rate),
    Num_Properties = n()
  ) %>%
  filter(!is.na(Mean_Survival_Rate)) -> tree_survival_summary

# Create the plot
ggplot(tree_survival_summary, aes(x = total_trees, y = Mean_Survival_Rate)) +
  geom_bar(stat = "identity", fill = "blue", alpha = 0.7) +
  geom_errorbar(aes(ymin = Mean_Survival_Rate - Survival_Rate_StdDev, ymax = Mean_Survival_Rate + Survival_Rate_StdDev), width = 0.4, color = "black", position = position_dodge(0.9)) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(x = "Number of Trees", y = "Average Survival Rate") +
  theme_minimal()
# Display summary
print(tree_summary)

# Plotting the relationship between the number of trees and survival rate
ggplot(tree_summary, aes(x = total_trees, y = survival_rate)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "blue") +
  labs(x = "Number of Trees", y = "Survival Rate (%)", title = "Relationship between Number of Trees and Survival Rate")

#Number of unique addresses
library(dplyr)

# Assuming your data frame is named 'your_data_frame' and the address columns are 'HOUSE_NUMBER', 'STREET', and 'TOWN'
unique_address_count <- alltreedata %>%
  group_by(FULL_ADDRESS) %>%
  summarize() %>%
  nrow()

cat("Number of unique addresses:", unique_address_count, "\n")

"__________________________________________________________________________"
library(ggplot2)
library(dplyr)

# Group by the number of trees and calculate the mean mortality
tree_summary %>%
  group_by(total_trees) %>%
  summarize(
    Mean_Mortality = mean(Mean_Survivorship),
    Mortality_StdDev = sd(Mean_Survivorship),
    Num_Properties = n()
  ) %>%
  filter(!is.na(Num_Trees)) -> tree_mortality_summary

# Create the plot
ggplot(tree_mortality_summary, aes(x = Num_Trees, y = Mean_Mortality)) +
  geom_bar(stat = "identity", fill = "blue", alpha = 0.7) +
  geom_errorbar(aes(ymin = Mean_Mortality - Mortality_StdDev, ymax = Mean_Mortality + Mortality_StdDev), width = 0.4, color = "black", position = position_dodge(0.9)) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(x = "Number of Trees", y = "Average Mortality") +
  theme_minimal()



"-------------------------------------------------------------------------------------"
library(dplyr)

# Assuming 'Alive' status indicates survival
alltreedata <- alltreedata %>%
  mutate(Survived = ifelse(Mortality_2023 == "Alive", 1, 0))

# Group by FULL_ADDRESS and calculate the number of trees and survival rate
tree_summary <- alltreedata %>%
  group_by(FULL_ADDRESS) %>%
  summarise(
    total_trees = n(),
    alive_trees = sum(Survived),
    survival_rate = alive_trees / total_trees * 100
  )

# Specify bin width
bin_width <- 3

# Group by the number of trees and calculate the mean survival rate
tree_summary %>%
  group_by(total_trees_group = cut(total_trees, breaks = seq(0, max(total_trees) + bin_width, bin_width), include.lowest = TRUE)) %>%
  summarise(
    Mean_Survival_Rate = mean(survival_rate),
    Survival_Rate_StdDev = sd(survival_rate),
    Num_Properties = n()
  )# %>%
  #filter(!is.na(Mean_Survival_Rate)) -> tree_survival_summary

# Convert total_trees_group to numeric
# Remove rows with NA values
tree_survival_summary <- na.omit(tree_survival_summary)

tree_survival_summary$total_trees_group <- as.numeric(as.character(tree_survival_summary$total_trees))



# Create the plot
ggplot(tree_survival_summary, aes(x = total_trees_group, y = Mean_Survival_Rate)) +
  geom_bar(stat = "identity", fill = "blue", alpha = 0.7) +
  geom_errorbar(aes(ymin = Mean_Survival_Rate - Survival_Rate_StdDev, ymax = Mean_Survival_Rate + Survival_Rate_StdDev), width = 0.4, color = "black", position = position_dodge(0.9)) +
  geom_text(aes(label = Num_Properties), vjust = -0.5, position = position_dodge(0.9)) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(x = "Number of Trees", y = "Average Survival Rate") +
  theme_minimal()
