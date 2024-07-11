#general stats on trees planted so far


pkgs <- c("dplyr", "ggplot2", "tidyr", "readxl")

# Check if any of the packages are missing
if (!all(sapply(pkgs, requireNamespace, quietly = TRUE))) {
  # Install missing packages
  install.packages(pkgs)
}

# Load the packages
sapply(pkgs, require, character.only = TRUE)

# Update for new file path
filepath <- "X:\\Asian Longhorned Beetle\\HERO_2023\\Fall_DCR_Research\\Dataset_for_final_analysis_fall23_copied_LU_ST.csv"

alltreedata <- read.csv(filepath)

#Mortality Cleanup
alltreedata$Mortality_2023 <- as.character(alltreedata$Mortality_2023)
alltreedata$Mortality_2023[alltreedata$Mortality_2023 %in% c("SD", "dead")] <- "Standing Dead"
alltreedata$Mortality_2023[alltreedata$Mortality_2023 %in% c("a", "A", "a live", "alive", 
                                                     "Alive", "Alive?", "CK AP KS", "alibe", 
                                                     "Alice", "Tall tree")] <- "Alive"
alltreedata$Mortality[alltreedata$Mortality_2023 %in% c("r", "R", "R/U", "removed", "Removed", 
                                                     "Removed / Missing", "Removed/missing", 
                                                     "Removed/Missing", "Removed/Unknown", 
                                                     "Unknown/Removed", 
                                                     "Unknown/removed")] <- "Removed"
alltreedata$Mortality[alltreedata$Mortality_2023 %in% c("S", "s", "stump", "Stump")] <- "Stump"
alltreedata$Mortality[alltreedata$Mortality_2023 %in% c("U", "Unknown", 
                                                     "Unkown", "unknown")] <- "Unknown"

# This function should return only "Alive", "Removed", "Unknown", "Stump", "Standing Dead", and " ".
unique(alltreedata$Mortality_2023)

#Species Cleanup
summary(alltreedata$SPECIES)
treesurvey <- subset(alltreedata, Mortality_2023 %in% c("Alive", "Removed", "Standing Dead", "Stump", "Unknown"))
treesurvey <- as.character(treesurvey)

# Subset the data for alive and dead trees
alive_trees <- alltreedata[alltreedata$Mortality_2023 %in% c("Alive"), ]
dead_trees <- alltreedata[alltreedata$Mortality_2023 %in% c("Standing Dead", "Removed", "Stump"), ]
unknown_trees <- alltreedata[alltreedata$Mortality_2023 %in% c("Unknown"), ]



treesurvey <- subset(alltreedata, Mortality_2023 %in% c("Alive", "Removed", "Standing Dead", "Stump", "Unknown"))
treesurvey <- as.character(treesurvey)

"_________________________________________________________________________________________________________________________________________________"


library(ggplot2)
library(dplyr)
#SITE TYPE CALC

# Calculate the total count of trees for each site type
site_type_total_count <- alltreedata %>%
  group_by(SiteType_2023) %>%
  summarise(site_type_total_count = n())

# Calculate the count of vigor trees 1, 2, 3, 4, 5 within each site type
site_type_alive_count <- alltreedata %>%
  filter(Mortality_2023 == "Alive") %>%
  group_by(SiteType_2023) %>%
  summarise(site_type_alive_count = n())
#site_type_alive_count <- site_type_alive_count[-5,]
  
site_type_dead_count <- alltreedata %>%
  filter(Mortality_2023 %in% c("Stump", "Standing Dead", "Removed")) 
site_type_dead_count <- site_type_dead_count %>%
  group_by(SiteType_2023) %>%
  summarise(site_type_dead_count = n())
#site_type_dead_count <- site_type_dead_count[-5,]  

site_type_unknown_count <- alltreedata %>%
  filter(Mortality_2023 == "Unknown") %>%
  group_by(SiteType_2023) %>%
  summarise(site_type_unknown_count = n())
#site_type_unknown_count <- site_type_unknown_count[-5,]



# Calculate the percentage of trees alive, dead, and unknown within each site type
site_type_percentage_alive <- left_join(site_type_total_count, site_type_alive_count, by = "SiteType_2023") %>%
  mutate(site_type_Percentage_Alive = (site_type_alive_count / site_type_total_count) * 100)
#site_type_percentage_alive <- site_type_percentage_alive[-5,]


site_type_percentage_dead <- left_join(site_type_total_count, site_type_dead_count, by = "SiteType_2023") %>%
  mutate(site_type_Percentage_Dead = (site_type_dead_count / site_type_total_count) * 100)
#site_type_percentage_dead <- site_type_percentage_dead[-5,]

site_type_percentage_unknown <- left_join(site_type_total_count, site_type_unknown_count, by = "SiteType_2023") %>%
  mutate(site_type_Percentage_Unknown = (site_type_unknown_count / site_type_total_count) * 100)
#site_type_percentage_unknown <- site_type_percentage_unknown[-5,]


# Create a dataset for Land Use and vigor
specie <- c(rep("Front Yard", 3), rep("Side Yard", 3), rep("Backyard", 3), rep("Maintain Park", 3), rep("Natural Area", 3))
condition <- rep(c("Alive", "Dead", "Unknown"), 5)
value <- c(c(site_type_percentage_alive$site_type_percentage_alive[1], site_type_percentage_dead$site_type_percentage_dead[1], site_type_percentage_unknown$site_type_percentage_unknown[1]), 
           c(site_type_percentage_alive$site_type_percentage_alive[2], site_type_percentage_dead$site_type_percentage_dead[2], site_type_percentage_unknown$site_type_percentage_unknown[2]),
           c(site_type_percentage_alive$site_type_percentage_alive[3], site_type_percentage_dead$site_type_percentage_dead[3], site_type_percentage_unknown$site_type_percentage_unknown[3]), 
           c(site_type_percentage_alive$site_type_percentage_alive[4], site_type_percentage_dead$site_type_percentage_dead[4], site_type_percentage_unknown$site_type_percentage_unknown[4]),
           c(site_type_percentage_alive$site_type_percentage_alive[5], site_type_percentage_dead$site_type_percentage_dead[5], site_type_percentage_unknown$site_type_percentage_unknown[5]))
data <- data.frame(specie, condition, value)

# Reorder the levels of condition
data$condition <- factor(data$condition, levels = c("Unknown", "Dead", "Alive"))
# Reorder specie variable
data$specie <- factor(data$specie, levels = c("Front Yard", "Side Yard", "Backyard", "Natural Area", "Maintain Park"))
# Stacked + percent with improved label and modified legend

ggplot(data, aes(fill = condition, y = value, x = specie)) +
  geom_bar(position = "fill", stat = "identity", color = "white", size = 0) + # Set color and size to remove the border
  geom_text(aes(label = paste0(round(value), "%")), position = position_fill(vjust = 0.5)) +
  labs(x = "Site Type", y = "Percentage") +
  scale_fill_manual(
    values = c("Alive" = "cornflowerblue", "Dead" = "lightsteelblue1", "Unknown" = "thistle1"),
    guide = guide_legend(
      title = NULL,  # Remove legend title
      position = "bottom",  # Position the legend at the bottom
      label.position = "bottom",  # Position the legend labels below the keys
      label.hjust = 0.5,  # Center the legend labels horizontally
      label.theme = element_text(size = 10)  # Adjust the font size of the legend labels
    )
  ) +
  theme_minimal() +
  theme(
    panel.background = element_blank(),
    plot.background = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(color = "black"),
    legend.position = "bottom",  # Position the legend at the bottom
    legend.box = "horizontal",  # Display the legend as a horizontal box
    legend.margin = margin(t = 0, r = 0, b = 0, l = 0),  # Adjust the legend margin
    legend.title = element_blank(),
    legend.direction = "horizontal",  # Flip the legend direction
    legend.key.width = unit(1, "cm"),
    axis.text.x = element_text(size = 10, face = "bold"),  # Set font size and weight for x-axis labels
    axis.text.y = element_text(size = 10, face = "bold")  # Set font size and weight for y-axis labels
  ) +  # Adjust the width of legend keys
  scale_y_continuous(labels = scales::percent_format())  # Formats y-axis labels as percentages

#LAND USE CALC
#_________________________________________________________________________________________________________________#
total_count <- alltreedata %>%
  group_by(LandUse_2023) %>%
  summarise(Total_Count = n())

# Calculate the count of vigor trees 1, 2, 3, 4, 5 within each LandUse
alive_count <- alltreedata %>%
  filter(Mortality_2023 == "Alive") %>%
  group_by(LandUse_2023) %>%
  summarise(Alive_Count = n())
alive_count <- alive_count[-5,]

dead_count <- alltreedata %>%
  filter(Mortality_2023 %in% c("Stump", "Standing Dead", "Removed")) 
dead_count <- dead_count %>%
  group_by(LandUse_2023) %>%
  summarise(Dead_Count = n())
dead_count <- dead_count[-5,]  

unknown_count <- alltreedata %>%
  filter(Mortality_2023 == "Unknown") %>%
  group_by(LandUse_2023) %>%
  summarise(Unknown_Count = n())
unknown_count <- unknown_count[-5,]

###GPT
# Create data frames for 'MFR' and 'Natural Area' with 0 in 'Unknown_Count'
new_rows <- data.frame(LandUse_2023 = c('MFR', 'Natural Area'), Unknown_Count = c(0, 0))
# Combine the new rows with your existing dataframe
unknown_count <- rbind(unknown_count, new_rows)
# View the updated dataframe

#reorder the dataframes
total_count <- total_count[order(total_count$LandUse_2023), ]
alive_count <- alive_count[order(alive_count$LandUse_2023), ]
dead_count <- dead_count[order(dead_count$LandUse_2023), ]
unknown_count <- unknown_count[order(unknown_count$LandUse_2023), ]

#

# Calculate the percentage of trees alive, dead, and unknown within each LandUse
percentage_alive <- left_join(total_count, alive_count, by = "LandUse_2023") %>%
  mutate(Percentage_Alive = (Alive_Count / Total_Count) * 100)
#percentage_alive <- percentage_alive[-5,]


percentage_dead <- left_join(total_count, dead_count, by = "LandUse_2023") %>%
  mutate(Percentage_Dead = (Dead_Count / Total_Count) * 100)
#percentage_dead <- percentage_dead[-5,]

percentage_unknown <- left_join(total_count, unknown_count, by = "LandUse_2023") %>%
  mutate(Percentage_Unknown = (Unknown_Count / Total_Count) * 100)
#percentage_unknown <- percentage_unknown[-5,]


# Create a dataset for Land Use and vigor
specie <- c(rep("SFR-D", 3), rep("SFR-A", 3), rep("MFR", 3), rep("INST", 3))
condition <- rep(c("Alive", "Dead", "Unknown"), 3)
value <- c(c(percentage_alive$Percentage_Alive[1], percentage_dead$Percentage_Dead[1], percentage_unknown$Percentage_Unknown[1]), 
           c(percentage_alive$Percentage_Alive[2], percentage_dead$Percentage_Dead[2], percentage_unknown$Percentage_Unknown[2]),
           c(percentage_alive$Percentage_Alive[3], percentage_dead$Percentage_Dead[3], percentage_unknown$Percentage_Unknown[3]),
           c(percentage_alive$Percentage_Alive[4], percentage_dead$Percentage_Dead[4], percentage_unknown$Percentage_Unknown[4]))
data <- data.frame(specie, condition, value)

# Reorder the levels of condition
data$condition <- factor(data$condition, levels = c("Unknown", "Dead", "Alive"))
# Reorder specie variable
data$specie <- factor(data$specie, levels = c("INST", "MFR", "SFR-D", "SFR-A" ))
# Stacked + percent with improved label and modified legend

ggplot(data, aes(fill = condition, y = value, x = specie)) +
  geom_bar(position = "fill", stat = "identity", color = "white", size = 0) + # Set color and size to remove the border
  geom_text(aes(label = paste0(round(value), "%")), position = position_fill(vjust = 0.5)) +
  labs(x = "LandUse_2023", y = "Percentage") +
  scale_fill_manual(
    values = c("Alive" = "cornflowerblue", "Dead" = "lightsteelblue1", "Unknown" = "thistle1"),
    guide = guide_legend(
      title = NULL,  # Remove legend title
      position = "bottom",  # Position the legend at the bottom
      label.position = "bottom",  # Position the legend labels below the keys
      label.hjust = 0.5,  # Center the legend labels horizontally
      label.theme = element_text(size = 10)  # Adjust the font size of the legend labels
    )
  ) +
  theme_minimal() +
  theme(
    panel.background = element_blank(),
    plot.background = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(color = "black"),
    legend.position = "bottom",  # Position the legend at the bottom
    legend.box = "horizontal",  # Display the legend as a horizontal boxhttp://127.0.0.1:33641/graphics/381d722f-5bc8-41dd-a33a-896f46351db0.png
    legend.margin = margin(t = 0, r = 0, b = 0, l = 0),  # Adjust the legend margin
    legend.title = element_blank(),
    legend.direction = "horizontal",  # Flip the legend direction
    legend.key.width = unit(1, "cm"),
    axis.text.x = element_text(size = 10, face = "bold"),  # Set font size and weight for x-axis labels
    axis.text.y = element_text(size = 10, face = "bold")  # Set font size and weight for y-axis labels
  ) +  # Adjust the width of legend keys
  scale_y_continuous(labels = scales::percent_format())  # Formats y-axis labels as percentages

