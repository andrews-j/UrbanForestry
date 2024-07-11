
pkgs <- c("dplyr", "ggplot2", "tidyr", "readxl", "stringr")
install.packages(pkgs)

sapply(pkgs, require, character.only = T)


alltreedata <- read.csv("Y:\\Asian Longhorned Beetle\\HERO_2023\\Fall_DCR_Research\\Dataset_for_final_analysis_fall23.csv")# Create a new column 'FULL_ADDRESS'
alltreedata <- alltreedata %>%
  mutate(FULL_ADDRESS = paste(HOUSE_NUMBER, STREET, TOWN, sep = ", "))

# Assuming 'Alive' status indicates survival
alltreedata <- alltreedata %>%
  mutate(Survived = as.numeric(Mortality == "Alive"))

# Group by FULL_ADDRESS and calculate the number of trees and survival rate
tree_summary <- alltreedata %>%
  group_by(FULL_ADDRESS) %>%
  summarise(
    total_trees = n(),
    Mean_Survival_Rate = mean(Survived) * 100
  )

# Group by the number of trees and calculate the mean survival rate
tree_summary %>%
  group_by(total_trees) %>%
  summarise(
    Mean_Survival_Rate = mean(Mean_Survival_Rate),
    Survival_Rate_StdDev = sd(Mean_Survival_Rate),
    Num_Properties = n()
  ) %>%
  filter(!is.na(Mean_Survival_Rate)) -> tree_survival_summary

# Calculate the correlation
correlation <- cor(tree_survival_summary$total_trees, tree_survival_summary$Mean_Survival_Rate)

# Create the scatterplot
ggplot(tree_survival_summary, aes(x = total_trees, y = Mean_Survival_Rate)) +
  geom_point() +
  geom_errorbar(aes(ymin = Mean_Survival_Rate - Survival_Rate_StdDev, ymax = Mean_Survival_Rate + Survival_Rate_StdDev), width = 0.4, color = "black", position = position_dodge(0.9)) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  geom_text(aes(label = Num_Properties), vjust = -0.5, position = position_dodge(0.9)) +
  labs(x = "Number of Trees", y = "Average Survival Rate") +
  annotate("text", x = max(tree_survival_summary$total_trees), y = max(tree_survival_summary$Mean_Survival_Rate), label = paste("Correlation:", round(correlation, 2)), hjust = 1, vjust = 1) +
  theme_minimal()

