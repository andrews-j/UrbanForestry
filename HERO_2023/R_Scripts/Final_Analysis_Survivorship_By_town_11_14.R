#by town survivorship

pkgs <- c("dplyr", "ggplot2", "tidyr", "readxl")
install.packages(pkgs)

sapply(pkgs, require, character.only = T)

# Update for new file path
filepath <- "X:\\Asian Longhorned Beetle\\HERO_2023\\Fall_DCR_Research\\Dataset_for_final_analysis_fall23_copied_LU_ST.csv"

alltreedata <- read.csv(filepath)


# This function should return only "Alive", "Removed", "Unknown", "Stump", "Standing Dead".
unique(alltreedata$Mortality_2023)

#Species Cleanup
summary(alltreedata$SPECIES)
treesurvey <- subset(alltreedata, Mortality_2023 %in% c("Alive", "Removed", "Standing Dead", "Stump", "Unknown"))
treesurvey <- as.character(treesurvey)

# Subset the data for alive and dead trees
alive_trees <- alltreedata[alltreedata$Mortality_2023 %in% c("Alive"), ]
dead_trees <- alltreedata[alltreedata$Mortality_2023 %in% c("Standing Dead", "Removed", "Stump"), ]
unknown_trees <- alltreedata[alltreedata$Mortality_2023 %in% c("Unknown"), ]



# Load the ggplot2 library
library(ggplot2)

# Calculate the percentage survivorship and total count for each town
survivorship_by_town <- alltreedata %>%
  group_by(TOWN) %>%
  summarise(Percentage_Survivorship = sum(Mortality_2023 == "Alive") / n() * 100,
            Total_Count = n())

# Create the bar chart
ggplot(survivorship_by_town, aes(x = TOWN, y = Percentage_Survivorship)) +
  geom_bar(stat = "identity", fill = "#4DAC19") +
  geom_text(aes(label = Total_Count), vjust = -0.5, size = 3) + # Add total count labels
  labs(title = "Percentage Survivorship by Town with Total Count",
       x = "Town",
       y = "Percentage Survivorship") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_blank(),  # Remove major grid lines
        panel.grid.minor = element_blank())  # Remove minor grid lines


"_____________________________________________________"
#Alternate graph with red line with mean survivorship
library(ggplot2)
library(dplyr)

# Assuming your data frame is named alltreedata
percentage_alive <- alltreedata %>%
  summarise(Percentage_Alive = mean(Mortality_2023 == "Alive") * 100)

# Calculate the percentage survivorship and total count for each town
survivorship_by_town <- alltreedata %>%
  group_by(TOWN) %>%
  summarise(Percentage_Survivorship = sum(Mortality_2023 == "Alive") / n() * 100,
            Total_Count = n())

# Create the bar chart
ggplot(survivorship_by_town, aes(x = TOWN, y = Percentage_Survivorship)) +
  geom_bar(stat = "identity", fill = "#4DAC19") +
  geom_text(aes(label = Total_Count), vjust = -0.5, size = 3) + # Add total count labels
  labs(title = "Percentage Survivorship by Town with Total Count",
       x = "Town",
       y = "Percentage Survivorship") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_blank(),  # Remove major grid lines
        panel.grid.minor = element_blank()) +  # Remove minor grid lines
  geom_hline(yintercept = percentage_alive$Percentage_Alive, linetype = "dashed", color = "red", size = 1.5)

print(percentage_alive)

