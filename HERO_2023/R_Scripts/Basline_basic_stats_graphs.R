pkgs <- c("dplyr", "ggplot2", "tidyr", "readxl", "stringr")
install.packages(pkgs)

sapply(pkgs, require, character.only = T)


alltreedata <- read.csv("Y:\\Asian Longhorned Beetle\\HERO_2023\\Fall_DCR_Research\\Dataset_for_final_analysis_fall23.csv")

# Subset the data for alive and dead trees
alive_trees <- alltreedata[alltreedata$Mortality %in% c("Alive"), ]
dead_trees <- alltreedata[alltreedata$Mortality %in% c("Standing Dead", "Removed", "Stump"), ]
unknown_trees <- alltreedata[alltreedata$Mortality %in% c("Unknown"), ]

# Calculate species distribution for alive and dead trees
alive_species_dist <- table(alive_trees$SPECIES)
dead_species_dist <- table(dead_trees$SPECIES)
unknown_species_dist <- table(unknown_trees$SPECIES)
#removed_species_dist <- table(dead_trees$SPECIES)

# Print the species distribution for alive, dead, and unknown trees
print("Species distribution of alive trees:")
print(alive_species_dist)

print("Species distribution of dead trees:")
print(dead_species_dist)

print("Species distribution of unknown trees:")
print(unknown_species_dist)

# Convert the species distribution tables to data frames
library(ggplot2)

# Convert the species distribution tables to data frames
alive_species_df <- as.data.frame(alive_species_dist)
dead_species_df <- as.data.frame(dead_species_dist)
unknown_species_df <- as.data.frame(unknown_species_dist)

# Rename the columns
colnames(alive_species_df) <- c("Species", "Count_alive")
colnames(dead_species_df) <- c("Species", "Count_dead")
colnames(unknown_species_df) <- c("Species", "Count_unknown")


#combining data frames
combined_species_df <- merge(alive_species_df, dead_species_df, by = "Species", all = TRUE)
combined_species_df <- merge(combined_species_df, unknown_species_df, by = "Species", all = TRUE)
colnames(combined_species_df) <- c("Species", "Count_alive", "Count_dead", "Count_unknown")
combined_species_df$Count_alive[is.na(combined_species_df$Count_alive)] <- 0
combined_species_df$Count_dead[is.na(combined_species_df$Count_dead)] <- 0
combined_species_df$Count_unknown[is.na(combined_species_df$Count_unknown)] <- 0
combined_species_df$Total_count <- combined_species_df$Count_alive + combined_species_df$Count_dead + combined_species_df$Count_unknown

#get total count of all the trees
total_count <- sum(combined_species_df$Total_count)

"_______________________________________________________________________________________________________"
library(ggplot2)
library(tidyr)
#graph survivorship by species
# Reshape the data into a long format
combined_species_df_long <- combined_species_df %>%
  pivot_longer(cols = starts_with("Count"), names_to = "Status", values_to = "Count")

# Order the levels of the Species factor based on Total_count
combined_species_df_long$Species <- factor(
  combined_species_df_long$Species,
  levels = combined_species_df$Species[order(combined_species_df$Total_count, decreasing = TRUE)]
)

# Calculate the total count
print_count <- sum(combined_species_df$Total_count)
"__________________________________________________________________________________________________________"
#ALL TREES/No Arborvitae SORTED BY SURVIVORSHIP.... OR 


organized_species_df <- combined_species_df_long %>%
  mutate(Percentage_survivorship = Count / Total_count * 100)

#organized_species_df <- organized_species_df %>%
#filter(Total_count > 15 & Species != 'American Arborvitae' & Species != 'White Fir')

#organized_species_df <- organized_species_df %>%
#filter(Total_count > 15)   #CHANGE THIS TO CHANGE # OF SPECIES SEEN
# Calculate the maximum Percentage_survivorship for each species
max_survivorship <- organized_species_df %>%
  filter(Status == "Count_alive") %>%
  group_by(Species) %>%
  summarize(max_percentage_survivorship = max(Percentage_survivorship))

# Join the maximum Percentage_survivorship to the original data
organized_species_df <- organized_species_df %>%
  left_join(max_survivorship, by = "Species")

# Arrange the data based on the maximum Percentage_survivorship
organized_species_df <- organized_species_df %>%
  arrange(desc(Total_count))  #CHANGE THIS TO CHANGE SORTING

# Reorder the levels of Species based on the order of the data
organized_species_df$Species <- factor(organized_species_df$Species, levels = unique(organized_species_df$Species))
organized_species_df$Status <- factor(organized_species_df$Status, levels = c("Count_unknown", "Count_dead", "Count_alive"))
ggplot(organized_species_df, aes(x = Species, y = Count, fill = Status)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = ifelse(Count > 5, Count, "")), position = position_stack(vjust = 0.5), color = "black", size = 4.4) +
  annotate("text", x = Inf, y = Inf, label = paste("Total Count:", sum(organized_species_df$Total_count)/3), hjust = 1, vjust = 2, size = 4.4, color = "black") +
  labs(title = "", x = "Species", y = "Count") +
  scale_fill_manual(
    values = c(Count_alive = "#4DAC19", Count_dead = "#F3A2B9", Count_unknown = "gray"),
    labels = c(Count_alive = "Alive", Count_dead = "Dead", Count_unknown = "Unknown")
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 20, face = "bold"),
    axis.title = element_text(size = 17),
    axis.text = element_text(size = 17),
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
    legend.position = c(0.95, 0.7),
    legend.box.margin = margin(0, 0, 0, 10),
    legend.title.align = 0.5,
    legend.title = element_text(size = 15),
    legend.text.align = 0.5,
    legend.text = element_text(size = 17),
    plot.margin = margin(40, 10, 10, 20, "pt"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_blank()
  )
mean(organized_species_df$Total_count)
mortality_average23 <- median(organized_species_df$max_percentage_survivorship)



#Graph sorted by survivorship without Arborvitae
organized_species_df <- organized_species_df %>%
  filter(Total_count >= 15 & Species != 'American Arborvitae' & Species != 'White Fir')

max_survivorship <- organized_species_df %>%
  filter(Status == "Count_alive") %>%
  group_by(Species) %>%
  summarize(max_percentage_survivorship = max(Percentage_survivorship))

print_count_sans <- sum(organized_species_df$Total_count)/3
ggplot(organized_species_df, aes(x = Species, y = Count, fill = Status)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = ifelse(Count > 0, Count, "")), position = position_stack(vjust = 0.5), color = "black", size = 4.4) +
  annotate("text", x = Inf, y = Inf, label = paste("Total Count:", print_count_sans), hjust = 1, vjust = 2, size = 4.4, color = "black") +
  labs(title = "", x = "Species", y = "Count") +
  scale_fill_manual(
    values = c(Count_alive = "#4DAC19", Count_dead = "#F3A2B9", Count_unknown = "gray"),
    labels = c(Count_alive = "Alive", Count_dead = "Dead", Count_unknown = "Unknown")
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 20, face = "bold"),
    axis.title = element_text(size = 17),
    axis.text = element_text(size = 17),
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
    legend.position = c(0.95, 0.7),
    legend.box.margin = margin(0, 0, 0, 10),
    legend.title.align = 0.5,
    legend.text.align = 0.5,
    plot.margin = margin(40, 10, 10, 10, "pt"),
    panel.grid.major = element_blank(),  # Remove major grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    panel.background = element_blank()
  )

"_____________________________________________________________________________________________________" 

# Filter the combined_species_df for species with a minimum count of 15
filtered_species_df_all <- combined_species_df 
filtered_species_df_all <- filter(filtered_species_df_all, Total_count >= 15)
# Calculate the percentage survivorship for each species
filtered_species_df_all <- filtered_species_df_all %>%
  mutate(Percentage_survivorship = Count_alive / Total_count * 100)

# Round the percentage survivorship to 2 decimals
filtered_species_df_all$Percentage_survivorship <- round(filtered_species_df_all$Percentage_survivorship, 0)

# Order the filtered_species_df based on survivorship percentage
ordered_species_df_all <- filtered_species_df_all %>%
  arrange(desc(Percentage_survivorship)) #%>%
#head(10)

# Reorder the Species factor based on survivorship percentage
ordered_species_df_all$Species <- factor(ordered_species_df_all$Species, levels = ordered_species_df_all$Species)

ggplot(ordered_species_df_all, aes(x = Species, y = Percentage_survivorship, fill = Species)) +
  geom_bar(stat = "identity", fill = "#4DAC19") +
  geom_text(
    aes(label = paste0(Total_count)),
    position = position_stack(vjust = 0.5),  # Place the text in the middle of the bar
    color = "black", size = 4.4
  ) +
  geom_text(
    aes(label = paste0(round(Percentage_survivorship, 2))),
    position = position_stack(vjust = 1.1),  # Place the text above the bar
    color = "black", size = 4.4
  ) +
  labs(title = "", x = "Species", y = "Percentage Survivorship") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 20, face = "bold"),
    axis.title = element_text(size = 17),
    axis.text = element_text(size = 17),
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    legend.position = "none"
  )

"__________________________________________________________________________________________________________"
# library(ggplot2)
# library(dplyr)
# #All Species ordered based on survivorship
# # Filter the combined_species_df for species with a minimum count of 15
# filtered_species_df <- combined_species_df %>%
#   filter(Total_count >= 15)
# 
# # Calculate the percentage survivorship for each species
# filtered_species_df <- filtered_species_df %>%
#   mutate(Percentage_survivorship = Count_alive / Total_count * 100)
# 
# # Round the percentage survivorship to 2 decimals
# filtered_species_df$Percentage_survivorship <- round(filtered_species_df$Percentage_survivorship, 0)
# 
# # Order the filtered_species_df based on survivorship percentage
# ordered_species_df <- filtered_species_df %>%
#   arrange(desc(Percentage_survivorship)) 
# 
# # Reorder the Species factor based on survivorship percentage
# ordered_species_df$Species <- factor(ordered_species_df$Species, levels = ordered_species_df$Species)
# 
# # Create the stacked bar chart for the top 10 species with bar height dependent on Percentage_survivorship
# ggplot(ordered_species_df, aes(x = Species, y = Percentage_survivorship, fill = Species)) +
#   geom_bar(stat = "identity", fill = "#4DAC19") +
#   geom_text(aes(label = ifelse(Percentage_survivorship > 0, paste0(Percentage_survivorship), "")),
#             position = position_stack(vjust = 0.5), color = "black", size = 4.4) +
#   labs(title = "", x = "Species", y = "Percentage Survivorship") +
#   theme_minimal() +
#   theme(plot.title = element_text(size = 20, face = "bold"),
#         axis.title = element_text(size = 17),
#         axis.text = element_text(size = 17),
#         axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
#         panel.grid.major = element_blank(),  # Remove major grid lines
#         panel.grid.minor = element_blank(),  # Remove minor grid lines
#         panel.background = element_blank(),
#         legend.position = "none") +
#   scale_y_continuous(breaks=c(0, 25, 50, 75),labels=c("0%", "25%", "50%", "75%"))
# annotate("text", x = Inf, y = Inf, label = paste("Total Count:", sum(ordered_species_df$Total_count)), hjust = 1, vjust = 1, size = 4, color = "black")
"__________________________________________________________________________________________________________"

# library(ggplot2)
# library(dplyr)
# #All Species ordered based on survivorship min count 15
# # Filter the combined_species_df for species with a minimum count of 15
# filtered_species_df <- combined_species_df %>%
#   filter(Total_count >= 15 & Species != 'White Fir' & Species != 'American Arborvitae')
# 
# # Calculate the percentage survivorship for each species
# filtered_species_df <- filtered_species_df %>%
#   mutate(Percentage_survivorship = Count_alive / Total_count * 100)
# 
# # Round the percentage survivorship to 2 decimals
# filtered_species_df$Percentage_survivorship <- round(filtered_species_df$Percentage_survivorship, 0)
# 
# # Order the filtered_species_df based on survivorship percentage
# ordered_species_df <- filtered_species_df %>%
#   arrange(desc(Percentage_survivorship)) 
# 
# # Reorder the Species factor based on survivorship percentage
# ordered_species_df$Species <- factor(ordered_species_df$Species, levels = ordered_species_df$Species)
# 
# # Create the stacked bar chart for the top 10 species with bar height dependent on Percentage_survivorship
# ggplot(ordered_species_df, aes(x = Species, y = Percentage_survivorship, fill = Species)) +
#   geom_bar(stat = "identity", fill = "#4DAC19") +
#   geom_text(aes(label = ifelse(Percentage_survivorship > 0, paste0(Percentage_survivorship), "")),
#             position = position_stack(vjust = 1.04), color = "black", size = 4.4) +
#   labs(title = "", x = "Species", y = "Percentage Survivorship") +
#   theme_minimal() +
#   theme(plot.title = element_text(size = 20, face = "bold"),
#         axis.title = element_text(size = 17),
#         axis.text = element_text(size = 17),
#         axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
#         panel.grid.major = element_blank(),  # Remove major grid lines
#         panel.grid.minor = element_blank(),  # Remove minor grid lines
#         panel.background = element_blank(),
#         legend.position = "none") +
#   scale_y_continuous(breaks=c(0, 25, 50, 75),labels=c("0%", "25%", "50%", "75%"))
# annotate("text", x = Inf, y = Inf, label = paste("Total Count:", sum(ordered_species_df$Total_count)), hjust = 1, vjust = 1, size = 4, color = "black") 

"__________________________________________________________________________________________________________"
#TOP 10 BASED ON SURVIVORSHIP SANS ARBORVITAE
library(ggplot2)
library(dplyr)
# Filter the combined_species_df for species with a minimum count of 15
filtered_species_df_sans <- combined_species_df %>%
  filter(Total_count >= 15)

# Filter out specific species
#filtered_species_df_sans <- filter(filtered_species_df_sans, Species != 'American Arborvitae' & Species != 'White Fir' & Species != 'Juniper')

# Calculate the percentage survivorship for each species
filtered_species_df_sans <- filtered_species_df_sans %>%
  mutate(Percentage_survivorship = Count_alive / Total_count * 100)

# Round the percentage survivorship to 2 decimals
filtered_species_df_sans$Percentage_survivorship <- round(filtered_species_df_sans$Percentage_survivorship, 0)

# Order the filtered_species_df based on survivorship percentage
ordered_species_df_sans <- filtered_species_df_sans %>%
  arrange(desc(Percentage_survivorship)) %>%
  head(10)

# Reorder the Species factor based on survivorship percentage
ordered_species_df_sans$Species <- factor(ordered_species_df_sans$Species, levels = ordered_species_df_sans$Species)

# Create the stacked bar chart for the top 10 species with bar height dependent on Percentage_survivorship
ggplot(ordered_species_df_sans, aes(x = Species, y = Percentage_survivorship, fill = Species)) +
  geom_bar(stat = "identity", fill = "#4DAC19") +
  geom_text(
    aes(label = paste0(Total_count)),
    position = position_stack(vjust = 0.5),  # Place the text in the middle of the bar
    color = "black", size = 4.4
  ) +
  geom_text(
    aes(label = paste0(round(Percentage_survivorship, 2), '%')),
    position = position_stack(vjust = 1.1),  # Place the text above the bar
    color = "black", size = 4.4
  ) +
  labs(title = "", x = "Species", y = "Percentage Survivorship") +
  theme_minimal() +
  theme(plot.title = element_text(size = 20, face = "bold"),
        axis.title = element_text(size = 17),
        axis.text = element_text(size = 17),
        axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        legend.position = "right",
        legend.title = element_blank(),
        legend.text = element_text(size = 17)) +
  scale_y_continuous(breaks=c(0, 25, 50, 75),labels=c("0%", "25%", "50%", "75%")) +
  annotate("text", x = Inf, y = Inf, label = paste("Total Count:", sum(ordered_species_df_sans$Total_count)), hjust = 1, vjust = 1, size = 4, color = "black")

"__________________________________________________________________________________________________________"
#Worst 10 survivors
# Filter the combined_species_df for species with a minimum count of 15
filtered_species_df <- combined_species_df %>%
  filter(Total_count >= 15)

# Calculate the percentage survivorship for each species
filtered_species_df <- filtered_species_df %>%
  mutate(Percentage_survivorship = Count_alive / Total_count * 100)

# Round the percentage survivorship to 2 decimals
filtered_species_df$Percentage_survivorship <- round(filtered_species_df$Percentage_survivorship, 0)

# Order the filtered_species_df based on survivorship percentage
ordered_species_df <- filtered_species_df %>%
  arrange(desc(Percentage_survivorship)) %>%
  tail(10)

# Reorder the Species factor based on survivorship percentage
ordered_species_df$Species <- factor(ordered_species_df$Species, levels = ordered_species_df$Species)

ggplot(ordered_species_df, aes(x = Species, y = Percentage_survivorship, fill = Species)) +
  geom_bar(stat = "identity", fill = "#4DAC19") +
  geom_text(
    aes(label = paste0(Total_count)),
    position = position_stack(vjust = 0.5),  # Place the text in the middle of the bar
    color = "black", size = 4.4
  ) +
  geom_text(
    aes(label = paste0(round(Percentage_survivorship, 2), '%')),
    position = position_stack(vjust = 1.1),  # Place the text above the bar
    color = "black", size = 4.4
  ) +
  labs(title = "", x = "Species", y = "Percentage Survivorship") +
  theme_minimal() +
  theme(plot.title = element_text(size = 20, face = "bold"),
        axis.title = element_text(size = 17),
        axis.text = element_text(size = 17),
        axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        legend.position = "right",
        legend.title = element_blank(),
        legend.text = element_text(size = 17)) +
  scale_y_continuous(breaks=c(0, 25, 50, 75),labels=c("0%", "25%", "50%", "75%")) +
  annotate("text", x = Inf, y = Inf, label = paste("Total Count:", sum(ordered_species_df$Total_count)), hjust = 1, vjust = 1, size = 4, color = "black")


"__________________________________________________________________________________________________________"

#Best 10 survivors
# Filter the combined_species_df for species with a minimum count of 15
filtered_species_df <- combined_species_df %>%
  filter(Total_count >= 15)

# Calculate the percentage survivorship for each species
filtered_species_df <- filtered_species_df %>%
  mutate(Percentage_survivorship = Count_alive / Total_count * 100)

# Round the percentage survivorship to 2 decimals
filtered_species_df$Percentage_survivorship <- round(filtered_species_df$Percentage_survivorship, 0)

# Order the filtered_species_df based on survivorship percentage
ordered_species_df <- filtered_species_df %>%
  arrange(desc(Percentage_survivorship)) %>%
  head(10)

# Reorder the Species factor based on survivorship percentage
ordered_species_df$Species <- factor(ordered_species_df$Species, levels = ordered_species_df$Species)

# Create the stacked bar chart for the top 10 species with bar height dependent on Percentage_survivorship
ggplot(ordered_species_df, aes(x = Species, y = Percentage_survivorship, fill = Species)) +
  geom_bar(stat = "identity", fill = "#4DAC19") +
  geom_text(aes(label = ifelse(Percentage_survivorship > 0, paste0(Percentage_survivorship, "%"), "")),
            position = position_stack(vjust = 0.5), color = "black", size = 4.4) +
  labs(title = "", x = "Species", y = "Percentage Survivorship") +
  theme_minimal() +
  theme(plot.title = element_text(size = 20, face = "bold"),
        axis.title = element_text(size = 17),
        axis.text = element_text(size = 17),
        axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
        panel.grid.major = element_blank(),  # Remove major grid lines
        panel.grid.minor = element_blank(),  # Remove minor grid lines
        panel.background = element_blank(),
        legend.position = "right",
        legend.title = element_blank(),
        legend.text = element_text(size = 17)) +
  scale_y_continuous(breaks=c(0, 25, 50, 75),labels=c("0%", "25%", "50%", "75%")) +
  annotate("text", x = Inf, y = Inf, label = paste("Total Count:", sum(ordered_species_df$Total_count)), hjust = 1, vjust = 1, size = 4, color = "black")

#SAME PLOT but with labels
ggplot(ordered_species_df, aes(x = Species, y = Percentage_survivorship, fill = Species)) +
  geom_bar(stat = "identity", fill = "#4DAC19") +
  geom_text(aes(label = ifelse(Percentage_survivorship > 0, paste0(Percentage_survivorship, "%"), "")),
            position = position_stack(vjust = 0.5), color = "black", size = 4.4) +
  
  # Add labels with counts on top of each bar
  geom_text(aes(label = Total_count), vjust = -0.5, size = 4, color = "black") +
  
  labs(title = "", x = "Species", y = "Percentage Survivorship") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 20, face = "bold"),
    axis.title = element_text(size = 17),
    axis.text = element_text(size = 17),
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
    panel.grid.major = element_blank(),  # Remove major grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    panel.background = element_blank(),
    legend.position = "right",
    legend.title = element_blank(),
    legend.text = element_text(size = 17)
  ) +
  scale_y_continuous(breaks = c(0, 25, 50, 75), labels = c("0%", "25%", "50%", "75%")) +
  annotate(
    "text",
    x = Inf,
    y = Inf,
    label = paste("Total Count:", sum(ordered_species_df$Total_count)),
    hjust = 1,
    vjust = 1,
    size = 4,
    color = "black"
  )
"__________________________________________________________________________________________________________"
#NEW CODE
library(ggplot2)
#bad bar chart
# 
# # Create dataframes with counts
# alive_trees <- data.frame(Mortality = "Alive", Count = sum(alive_trees))
# dead_trees <- data.frame(Mortality = "Dead", Count = sum(dead_trees))
# unknown_trees <- data.frame(Mortality = "Unknown", Count = sum(unknown_trees))
# 
# # Combine the counts into a single dataframe
# tree_counts <- rbind(alive_trees, dead_trees, unknown_trees)
# 
# # Calculate percentages
# tree_counts <- tree_counts %>%
#   group_by(Mortality) %>%
#   mutate(Percentage = round((Count / sum(tree_counts$Count)) * 100), 1)
# 
# # Create the bar graph
# ggplot(tree_counts, aes(x = Mortality, y = Count, fill = Mortality)) +
#   geom_bar(stat = "identity") +
#   geom_text(aes(label = paste0(Percentage, "%")), 
#             position = position_stack(vjust = 0.5), color = "black", size = 4.4) +  # Add percentage labels
#   labs(title = "Distribution of Trees by Mortality", x = "Mortality", y = "Count") +
#   scale_fill_manual(
#     values = c("Alive" = "#4DAC19", "Dead" = "#F3A2B9", "Unknown" = "gray"),
#     labels = c("Alive", "Dead", "Unknown")
#   ) +
#   theme_minimal() +
#   theme(
#     plot.title = element_text(size = 20, face = "bold"),
#     axis.title = element_text(size = 17),
#     axis.text = element_text(size = 17),
#     panel.grid.major = element_blank(),  # Remove major grid lines
#     panel.grid.minor = element_blank(),  # Remove minor grid lines
#     panel.background = element_blank(),
#     legend.position = "none"
#   )

"_____________________________________________________________________"

