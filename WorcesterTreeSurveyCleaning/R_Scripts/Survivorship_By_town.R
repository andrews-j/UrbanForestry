#by town survivorship

pkgs <- c("dplyr", "ggplot2", "tidyr", "readxl")
install.packages(pkgs)

sapply(pkgs, require, character.only = T)

# Update for new file path
filepath <- "Y:\\Asian Longhorned Beetle\\HERO_2023\\Fall_DCR_Research\\Dataset_for_final_analysis_fall23_copied_LU_ST.csv"

alltreedata <- read.csv(filepath)

#Mortality Cleanup
alltreedata$Mortality <- as.character(alltreedata$Mortality)
alltreedata$Mortality[alltreedata$Mortality %in% c("SD", "dead")] <- "Standing Dead"
alltreedata$Mortality[alltreedata$Mortality %in% c("a", "A", "a live", "alive", 
                                                   "Alive", "Alive?", "CK AP KS", "alibe", 
                                                   "Alice", "Tall tree")] <- "Alive"
alltreedata$Mortality[alltreedata$Mortality %in% c("r", "R", "R/U", "removed", "Removed", 
                                                   "Removed / Missing", "Removed/missing", 
                                                   "Removed/Missing", "Removed/Unknown", 
                                                   "Unknown/Removed", 
                                                   "Unknown/removed")] <- "Removed"
alltreedata$Mortality[alltreedata$Mortality %in% c("S", "s", "stump", "Stump")] <- "Stump"
alltreedata$Mortality[alltreedata$Mortality %in% c("U", "Unknown", 
                                                   "Unkown", "unknown")] <- "Unknown"

# This function should return only "Alive", "Removed", "Unknown", "Stump", "Standing Dead", and " ".
unique(alltreedata$Mortality)

#Species Cleanup
summary(alltreedata$SPECIES)
treesurvey <- subset(alltreedata, Mortality %in% c("Alive", "Removed", "Standing Dead", "Stump", "Unknown"))
treesurvey <- as.character(treesurvey)

# Subset the data for alive and dead trees
alive_trees <- alltreedata[alltreedata$Mortality %in% c("Alive"), ]
dead_trees <- alltreedata[alltreedata$Mortality %in% c("Standing Dead", "Removed", "Stump"), ]
unknown_trees <- alltreedata[alltreedata$Mortality %in% c("Unknown"), ]



# Load the ggplot2 library
library(ggplot2)

# Calculate the percentage survivorship and total count for each town
survivorship_by_town <- alltreedata %>%
  group_by(TOWN) %>%
  summarise(Percentage_Survivorship = sum(Mortality == "Alive") / n() * 100,
            Total_Count = n())

# Create the bar chart
ggplot(survivorship_by_town, aes(x = TOWN, y = Percentage_Survivorship)) +http://127.0.0.1:28225/graphics/plot_zoom_png?width=1200&height=900
  geom_bar(stat = "identity", fill = "#4DAC19") +
  geom_text(aes(label = Total_Count), vjust = -0.5, size = 3) + # Add total count labels
  labs(title = "Percentage Survivorship by Town with Total Count",
       x = "Town",
       y = "Percentage Survivorship") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_blank(),  # Remove major grid lines
        panel.grid.minor = element_blank())  # Remove minor grid lines
"_____________________________________________________________________________________________________"
library(ggplot2)
library(dplyr)

# Assuming your data frame is named alltreedata
percentage_alive <- alltreedata %>%
  summarise(Percentage_Alive = mean(Mortality == "Alive") * 100)

# Calculate the percentage survivorship and total count for each town
survivorship_by_town <- alltreedata %>%
  group_by(TOWN) %>%
  summarise(Percentage_Survivorship = sum(Mortality == "Alive") / n() * 100,
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


