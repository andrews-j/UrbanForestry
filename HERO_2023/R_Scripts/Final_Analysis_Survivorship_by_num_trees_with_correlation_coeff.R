# Install and load necessary packages
pkgs <- c("dplyr", "ggplot2", "tidyr", "readxl", "stringr")
install.packages(pkgs)
sapply(pkgs, require, character.only = TRUE)

# Read data and create FULL_ADDRESS column
alltreedata <- read.csv("Y:\\Asian Longhorned Beetle\\HERO_2023\\Fall_DCR_Research\\Dataset_for_final_analysis_fall23.csv") %>%
  mutate(FULL_ADDRESS = paste(HOUSE_NUMBER, STREET, TOWN, sep = ", "))

# Calculate tree summary
tree_summary <- alltreedata %>%
  group_by(FULL_ADDRESS) %>%
  summarise(
    total_trees = n(),
    alive_trees = sum(Mortality_2023 == "Alive"),
    dead_trees = sum(Mortality_2023 == "Removed"),
    survival_rate = alive_trees / total_trees * 100
  )

# Display summary
cat("Number of unique addresses:", nrow(unique(tree_summary)), "\n")
print(tree_summary)

# Plotting the relationship between the number of trees and survival rate
ggplot(tree_summary, aes(x = total_trees, y = survival_rate)) +
  geom_point(stat = "summary", fun = "mean", color = "blue", size = 3) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(x = "Number of Trees", y = "Average Survival Rate", title = "Relationship between Number of Trees and Survival Rate")


correlation_coefficient <- cor(tree_summary$total_trees, tree_summary$survival_rate)

# Create a scatter plot with a linear regression line
ggplot(data = tree_summary, aes(x = total_trees, y = survival_rate)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(x = "X Variable", y = "Y Variable", title = "Scatter Plot with Linear Regression Line") +
  annotate("text", x = Inf, y = Inf, vjust = 1, hjust = 1,
           label = paste("Correlation Coefficient:", round(correlation_coefficient, 2)))

# Group by the number of trees and calculate the mean survival rate
tree_summary %>%
  group_by(total_trees) %>%
  summarise(
    Mean_Survival_Rate = mean(survival_rate),
    Survival_Rate_StdDev = sd(survival_rate),
    Num_Properties = n()
  ) %>%
  filter(!is.na(Mean_Survival_Rate)) -> tree_survival_summary

# Create the plot for survival rate with specified bins
ggplot(tree_survival_summary, aes(x = total_trees, y = Mean_Survival_Rate)) +
  geom_bar(stat = "identity", fill = "blue", alpha = 0.7, bins = 3) +
  geom_errorbar(aes(ymin = Mean_Survival_Rate - Survival_Rate_StdDev, ymax = Mean_Survival_Rate + Survival_Rate_StdDev), width = 0.4, color = "black", position = position_dodge(0.9)) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(x = "Number of Trees", y = "Average Survival Rate") +
  theme_minimal()
