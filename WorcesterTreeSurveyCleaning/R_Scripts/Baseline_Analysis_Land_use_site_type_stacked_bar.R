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
filepath <- "Y:\\Asian Longhorned Beetle\\HERO_2023\\Fall_DCR_Research\\Dataset_for_final_analysis_fall23.csv"

alltreedata <- read.csv(filepath)

#Mortality Cleanup
# This function should return only "Alive", "Removed", "Unknown", "Stump", "Standing Dead", and " ".
unique(alltreedata$Mortality )

#Species Cleanup
summary(alltreedata$SPECIES)
treesurvey <- subset(alltreedata, Mortality  %in% c("Alive", "Removed", "Standing Dead", "Stump", "Unknown"))
treesurvey <- as.character(treesurvey)

# Subset the data for alive and dead trees
alive_trees <- alltreedata[alltreedata$Mortality  %in% c("Alive"), ]
dead_trees <- alltreedata[alltreedata$Mortality  %in% c("Standing Dead", "Removed", "Stump"), ]
unknown_trees <- alltreedata[alltreedata$Mortality  %in% c("Unknown"), ]



treesurvey <- subset(alltreedata, Mortality  %in% c("Alive", "Removed", "Standing Dead", "Stump", "Unknown"))
treesurvey <- as.character(treesurvey)

"_________________________________________________________________________________________________________________________________________________"


library(ggplot2)
library(dplyr)
#SITE TYPE CALC

# Calculate the total count of trees for each site type
site_type_total_count <- alltreedata %>%
  group_by(SiteType) %>%
  summarise(site_type_total_count = n())

# Calculate the count of vigor trees 1, 2, 3, 4, 5 within each site type
site_type_alive_count <- alltreedata %>%
  filter(Mortality  == "Alive") %>%
  group_by(SiteType) %>%
  summarise(site_type_alive_count = n())
#site_type_alive_count <- site_type_alive_count[-5,]

site_type_dead_count <- alltreedata %>%
  filter(Mortality  %in% c("Stump", "Standing Dead", "Removed")) 
site_type_dead_count <- site_type_dead_count %>%
  group_by(SiteType) %>%
  summarise(site_type_dead_count = n())
#site_type_dead_count <- site_type_dead_count[-5,]  

site_type_unknown_count <- alltreedata %>%
  filter(Mortality  == "Unknown") %>%
  group_by(SiteType) %>%
  summarise(site_type_unknown_count = n())%>%
  replace_na(list(site_type_percentage_unknown = 0))
#site_type_unknown_count <- site_type_unknown_count[-5,]



site_type_percentage_alive <- left_join(site_type_total_count, site_type_alive_count, by = "SiteType") %>%
  mutate(site_type_percentage_alive = (site_type_alive_count / site_type_total_count) * 100)
#site_type_percentage_alive <- site_type_percentage_alive[-5,]


site_type_percentage_dead <- left_join(site_type_total_count, site_type_dead_count, by = "SiteType") %>%
  mutate(site_type_percentage_dead = (site_type_dead_count / site_type_total_count) * 100)
#site_type_percentage_dead <- site_type_percentage_dead[-5,]

site_type_percentage_unknown <- left_join(site_type_total_count, site_type_unknown_count, by = "SiteType") %>%
  mutate(site_type_percentage_unknown = (site_type_unknown_count / site_type_total_count) * 100) %>%
  replace_na(list(site_type_percentage_unknown = 0))


# Create a dataset for Land Use and vigor
#MAKE SURE SPECIE IS IN THE SAME ORDER AS YOUR PERCENTAGE DFs
specie <- c(rep("Backyard", 3), rep("Front Yard", 3), rep("Maintain Park", 3), rep("Natural Area", 3))
condition <- rep(c("Alive", "Dead", "Unknown"), 4)
value <- c(c(site_type_percentage_alive$site_type_percentage_alive[1], site_type_percentage_dead$site_type_percentage_dead[1], site_type_percentage_unknown$site_type_percentage_unknown[1]), 
           c(site_type_percentage_alive$site_type_percentage_alive[2], site_type_percentage_dead$site_type_percentage_dead[2], site_type_percentage_unknown$site_type_percentage_unknown[2]),
           c(site_type_percentage_alive$site_type_percentage_alive[3], site_type_percentage_dead$site_type_percentage_dead[3], site_type_percentage_unknown$site_type_percentage_unknown[3]), 
           c(site_type_percentage_alive$site_type_percentage_alive[4], site_type_percentage_dead$site_type_percentage_dead[4], site_type_percentage_unknown$site_type_percentage_unknown[4]))
data <- data.frame(specie, condition, value)

# Reorder the levels of condition
data$condition <- factor(data$condition, levels = c("Unknown", "Dead", "Alive"))
# Reorder specie variable
data$specie <- factor(data$specie, levels = c("Backyard", "Front Yard", "Maintain Park","Natural Area"))
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

library(ggplot2)
library(dplyr)
#LAND USE CALC

# Calculate the total count of trees for each land use
land_use_total_count <- alltreedata %>%
  group_by(LandUse ) %>%
  summarise(land_use_total_count = n())

# Calculate the count of vigor trees 1, 2, 3, 4, 5 within each land use
land_use_alive_count <- alltreedata %>%
  filter(Mortality  == "Alive") %>%
  group_by(LandUse ) %>%
  summarise(land_use_alive_count = n())

land_use_dead_count <- alltreedata %>%
  filter(Mortality  %in% c("Stump", "Standing Dead", "Removed")) 
land_use_dead_count <- land_use_dead_count %>%
  group_by(LandUse ) %>%
  summarise(land_use_dead_count = n())

land_use_unknown_count <- alltreedata %>%
  filter(Mortality  == "Unknown") %>%
  group_by(LandUse ) %>%
  summarise(land_use_unknown_count = n())

# Calculate the percentage of trees alive, dead, and unknown within each land use
land_use_percentage_alive <- left_join(land_use_total_count, land_use_alive_count, by = "LandUse") %>%
  mutate(land_use_percentage_alive = (land_use_alive_count / land_use_total_count) * 100)
land_use_percentage_dead <- left_join(land_use_total_count, land_use_dead_count, by = "LandUse") %>%
  mutate(land_use_percentage_dead = (land_use_dead_count / land_use_total_count) * 100)

land_use_percentage_unknown <- left_join(land_use_total_count, land_use_unknown_count, by = "LandUse") %>%
  mutate(land_use_percentage_unknown = (land_use_unknown_count / land_use_total_count) * 100) %>%
  replace_na(list(land_use_percentage_unknown = 0))

# Create a dataset for Land Use and vigor
specie <- c(rep("Institutional", 3),  rep("Multi-Family-Residential", 3), rep("Single Family Attached", 3), rep("Single Family Detached", 3))
condition <- rep(c("Alive", "Dead", "Unknown"), 4)
value <- c(c(land_use_percentage_alive$land_use_percentage_alive[1], land_use_percentage_dead$land_use_percentage_dead[1], land_use_percentage_unknown$land_use_percentage_unknown[1]), 
           c(land_use_percentage_alive$land_use_percentage_alive[2], land_use_percentage_dead$land_use_percentage_dead[2], land_use_percentage_unknown$land_use_percentage_unknown[2]),
           c(land_use_percentage_alive$land_use_percentage_alive[3], land_use_percentage_dead$land_use_percentage_dead[3], land_use_percentage_unknown$land_use_percentage_unknown[3]), 
           c(land_use_percentage_alive$land_use_percentage_alive[4], land_use_percentage_dead$land_use_percentage_dead[4], land_use_percentage_unknown$land_use_percentage_unknown[4]))
data <- data.frame(specie, condition, value)

# Reorder the levels of condition
data$condition <- factor(data$condition, levels = c("Unknown", "Dead", "Alive"))
# Reorder specie variable
data$specie <- factor(data$specie, levels = c("Institutional", "Multi-Family-Residential", "Single Family Attached","Single Family Detached"))

# Stacked + percent with improved label and modified legend
ggplot(data, aes(fill = condition, y = value, x = specie)) +
  geom_bar(position = "fill", stat = "identity", color = "white", size = 0) + 
  geom_text(aes(label = paste0(round(value), "%")), position = position_fill(vjust = 0.5)) +
  labs(x = "Land Use", y = "Percentage") +
  scale_fill_manual(
    values = c("Alive" = "cornflowerblue", "Dead" = "lightsteelblue1", "Unknown" = "thistle1"),
    guide = guide_legend(
      title = NULL,
      position = "bottom",
      label.position = "bottom",
      label.hjust = 0.5,
      label.theme = element_text(size = 10)
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
    legend.position = "bottom",
    legend.box = "horizontal",
    legend.margin = margin(t = 0, r = 0, b = 0, l = 0),
    legend.title = element_blank(),
    legend.direction = "horizontal",
    legend.key.width = unit(1, "cm"),
    axis.text.x = element_text(size = 10, face = "bold"),
    axis.text.y = element_text(size = 10, face = "bold")
  ) +
  scale_y_continuous(labels = scales::percent_format())

