#PLAN
#Take last 2 digits from Datayear_F
pkgs <- c("dplyr", "ggplot2", "tidyr", "readxl")
install.packages(pkgs)

sapply(pkgs, require, character.only = T)
alltreedata <- read.csv("Y:\\Asian Longhorned Beetle\\HERO_2023\\Fall_DCR_Research\\Dataset_for_final_analysis_fall23.csv")



# This function should return only "Alive", "Removed", "Unknown", "Stump", "Standing Dead", and " ".
unique(alltreedata$Mortality_2023)
unique(alltreedata$Mortality)


treesurvey <- subset(alltreedata, Mortality_2023 %in% c("Alive", "Removed", "Standing Dead", "Stump", "Unknown"))
treesurvey <- as.character(treesurvey)

# Subset the data for alive and dead trees
alive_trees <- alltreedata[alltreedata$Mortality_2023 %in% c("Alive"), ]
dead_trees <- alltreedata[alltreedata$Mortality_2023 %in% c("Standing Dead", "Removed", "Stump"), ]
unknown_trees <- alltreedata[alltreedata$Mortality_2023 %in% c("Unknown"), ]

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



filtered_species_df <- combined_species_df %>%
  filter(Total_count >= 14)

# Calculate the percentage survivorship for each species
filtered_species_df_2023 <- filtered_species_df %>%
  mutate(Percentage_survivorship = Count_alive / Total_count * 100)

"___________________________________________________________________________________________________"

treedata <- alltreedata %>%
  mutate(plantdate = SEASON_PLANTED)

# Replace planting season with date
treedata$plantdate[treedata$plantdate == "Fall 2010"] <- ("2010/09/22")
treedata$plantdate[treedata$plantdate == "Spring 2011"] <- ("2010/03/20")
treedata$plantdate[treedata$plantdate == "Fall 2011"] <- ("2010/09/23")
treedata$plantdate[treedata$plantdate == "Spring 2012"] <- ("2012/03/20")
treedata$plantdate[treedata$plantdate == ""] <- ("2012/03/20")

unique(treedata$plantdate)
# get age per tree in 2023
mortalitydata_2023 <- treedata %>%
  mutate(survey23date = EditDate %>% as.Date(format = "%m/%d/%Y")) %>%
  #select(SPECIES, plantdate, Observatio, Observdate, Observat_1, survey23date,
         #Datayear_F, ) %>%
  select(SPECIES, plantdate, Observation_date, survey23date) %>%
  mutate(plantdate = as.Date(plantdate)) %>%
  mutate(age23 = survey23date - plantdate) %>%
  mutate(age23 = as.numeric(age23) /365) # get age in years

# calculate mean age per species in 2023 survey
meanage23 <- mortalitydata_2023 %>% group_by(SPECIES) %>%
  summarise_at(vars(age23), list(meanage23 = mean))

# # looking at 14, 15, 16 surveys
# mortalitydata_2023$Datayear_F[mortalitydata_2023$Datayear_F == "141516"] <- ("16")
# mortalitydata_2023$Datayear_F[mortalitydata_2023$Datayear_F == "1516"] <- ("16")
# mortalitydata_2023$Datayear_F[mortalitydata_2023$Datayear_F == "1416"] <- ("16")
# mortalitydata_2023$Datayear_F[mortalitydata_2023$Datayear_F == "1415"] <- ("15")


mortalitydata_2023 <- mortalitydata_2023 %>%
  mutate(survey2010sdate = Observation_date)


mortalitydata_2023 <- mortalitydata_2023 %>%
  mutate(survey2010sdate = as.Date(survey2010sdate, format = "%m/%d/%Y")) %>%
  mutate(age2010s = survey2010sdate - plantdate) %>%
  mutate(age2010s = as.numeric(age2010s) / 365) # get age in years
"_______________________________________"



# Calculate average age by species using age23 column
average_age2023 <- mortalitydata_2023 %>%
  group_by(SPECIES) %>%
  summarize(avg_age = mean(age23, na.rm = TRUE))

average_age2010s <- mortalitydata_2023 %>%
  group_by(SPECIES) %>%
  summarize(avg_age = mean(age2010s, na.rm = TRUE))


# Rename SPECIES column to Species in average_age dataframe
names(average_age2023)[names(average_age2023) == "SPECIES"] <- "Species"

# Perform intersection based on Species column
intersection <- intersect(average_age2023$Species, filtered_species_df_2023$Species)

# Filter species in filtered_species_df_2023 based on intersection
filtered_species_df_2023 <- filtered_species_df_2023[filtered_species_df_2023$Species %in% intersection, ]
average_age2023 <- average_age2023[average_age2023$Species %in% intersection, ]
# Combine filtered_species_df_2023 and average_age using cbind
combined_data <- cbind(filtered_species_df_2023, average_age2023)

# Remove the second Species column
combined_data <- combined_data[, -7]

#rename
names(combined_data)[names(combined_data) == "avg_age"] <- "avg_age2023"
# Calculate annual death rate

filtered_species_df_2023$Annual_death_rate <- ((100 - combined_data$Percentage_survivorship) / combined_data$avg_age2023)


"_____________________________________________________________________________________________________________"


alltreedata$Mortality <- as.character(alltreedata$Mortality)



"______________________________________________________________________________________________________"
treesurvey <- subset(alltreedata, Mortality %in% c("Alive", "Removed", "Standing Dead", "Stump", "Unknown"))
treesurvey <- as.character(treesurvey)

# Subset the data for alive and dead trees
alive_trees <- alltreedata[alltreedata$Mortality %in% c("Alive"), ]
dead_trees <- alltreedata[alltreedata$Mortality %in% c("Standing Dead", "Removed", "Stump"), ]
unknown_trees <- alltreedata[alltreedata$Mortality %in% c("Unknown"), ]

# Calculate species distribution for alive and dead trees
alive_species_dist <- table(alive_trees$SPECIES)
dead_species_dist <- table(dead_trees$SPECIES)
unknown_species_dist <- table(unknown_trees$SPECIES)
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

filtered_species_df_2010 <- combined_species_df %>%
  filter(Total_count >= 14)

# Calculate the percentage survivorship for each species
filtered_species_df_2010 <- filtered_species_df_2010 %>%
  mutate(Percentage_survivorship = Count_alive / Total_count * 100)

# Rename SPECIES column to Species in average_age dataframe
names(average_age2010s)[names(average_age2010s) == "SPECIES"] <- "Species"

# Perform intersection based on Species column
intersection <- intersect(average_age2010s$Species, filtered_species_df_2023$Species)

# Filter species in filtered_species_df_2023 based on intersection
filtered_species_df_2023 <- filtered_species_df_2023[filtered_species_df_2023$Species %in% intersection, ]
average_age2010s <- average_age2010s[average_age2010s$Species %in% intersection, ]
# Combine filtered_species_df_2023 and average_age using cbind
combined_data <- cbind(filtered_species_df_2023, average_age2010s)

# Remove the second Species column
combined_data <- combined_data[, -7]

# Calculate annual death rate
filtered_species_df_2023$Annual_death_rate <- ((100 - combined_data$Percentage_survivorship) / combined_data$avg_age)

"_______________________________________________________________________________________________________"

intersect_species <- intersect(filtered_species_df_2023$Species, filtered_species_df_2010$Species)

filtered_species_df_2023_intersect <- filtered_species_df_2023 %>% 
  filter(Species %in% intersect_species)
average_age2010s <- average_age2010s %>% filter(Species %in% intersect_species)
average_age2023 <- average_age2023 %>% filter(Species %in% intersect_species)

age_and_mortality <- cbind(filtered_species_df_2023_intersect, average_age2023, filtered_species_df_2010, average_age2010s) #%>%
  #mutate(Annual_death_rate = (100 - Percentage_survivorship) / avg_age)
age_and_mortality <- age_and_mortality[,-c(7,8,10,16)]


new_column_names <- c("Species", "Count_alive_2023", "Count_dead_2023", "Count_unknown_2023", "Total_count_2023", 
                      "Percentage_survivorship_2023","Avg_age_2023", "Count_alive_2010s", "Count_dead_2010s", 
                      "Count_unknown_2010s", "Total_count_2010s", "Percentage_survivorship_2010s", "Avg_age_2010s")

age_and_mortality <- age_and_mortality %>%
  rename_all(~ new_column_names)



#paste code

# Create a new dataframe with the same column names
new_age_and_mortality <- age_and_mortality

# Subtract Count_dead_2023 from Count_dead_2010s
new_age_and_mortality$Count_dead_2010s <- age_and_mortality$Count_dead_2023 - age_and_mortality$Count_dead_2010s

# Recalculate Total_count_2010s
new_age_and_mortality$Total_count_2010s <- age_and_mortality$Count_alive_2010s +
  new_age_and_mortality$Count_dead_2010s +
  age_and_mortality$Count_unknown_2010s

# Recalculate Percentage_survivorship_2010s
new_age_and_mortality$Percentage_survivorship_2010s <- (age_and_mortality$Count_alive_2010s / new_age_and_mortality$Total_count_2010s) * 100

# Set Avg_age_2010s column
new_age_and_mortality$Avg_age_2023 <- age_and_mortality$Avg_age_2023 - age_and_mortality$Avg_age_2010s

# Rename columns
colnames(new_age_and_mortality) <- new_column_names




#


new_age_and_mortality <- new_age_and_mortality %>%
  mutate(Annual_survivorship_decline_2023 = (100 - Percentage_survivorship_2023) / Avg_age_2023,
         Annual_survivorship_decline_2010s = (100 - Percentage_survivorship_2010s) / Avg_age_2010s)



"_______________________________________________________________________________________________________________"

age_and_mortality_all <- new_age_and_mortality %>%
  mutate(Difference =  Annual_survivorship_decline_2023 - Annual_survivorship_decline_2010s)

# Create the horizontal bar chart
# Create the horizontal bar chart with sorted data
# Create the horizontal bar chart with increased axis label text size
ggplot(age_and_mortality_all, aes(x = Difference, y = reorder(Species, Difference), fill = Difference > 0)) +
  geom_bar(stat = "identity", position = "identity") +
  scale_fill_manual(values = c("FALSE" = "#DDCC77", "TRUE" = "#116622")) +
  labs(x = "Difference in Survivorship (2023 - Baseline)", y = "Species") +
  theme_minimal() +
  theme(panel.grid.major.y = element_blank(),
        axis.text.y = element_text(hjust = 0, margin = margin(r = 3), size = 12),
        axis.text.x = element_text(margin = margin(t = 3), size = 12),
        axis.title.y = element_text(margin = margin(r = 15), size = 15),  # Increase size of y-axis label text
        axis.title.x = element_text(margin = margin(t = 15), size = 12),  # Increase size of x-axis label text
        legend.position = "none") +
  scale_x_continuous(breaks = c(-4, -2, 0, 2, 4, 6, 8, 10),
                     labels = c("-4%", "-2%", "No Change", "2%", "4%", "6%", "8%", "10%"))
write.csv(age_and_mortality_all, "age_and_mortality_all.csv")

