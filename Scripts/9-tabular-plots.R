## a311
## Carina Rauen Firkowski 
## April 16, 2024
##
## This script creates the tabular plots presented in the report (Figs. 5 & 6).


# Load constants
source("Scripts/0-constants.R")

library(ggplot2)



# stconnect Library ------------------------------------------------------------

# Open a new SyncroSim session
stconnectSession <- session()

# Create a new stconnect Library
stconnectLibrary <- ssimLibrary(
  name = file.path(libraryDir, 
                   "a311-stconnect-deliverable3-15Mar2024.ssim"),
  session = stconnectSession, overwrite = FALSE,
  package = "stconnect")

# Open default Project
stconnectProject <- rsyncrosim::project(ssimObject = stconnectLibrary, 
                                        project = "Definitions")

# Open scenario
agnosticHistoric <- scenario(
  ssimObject = stconnectProject,
  scenario = 32)
agnosticLessUrban <- scenario(
  ssimObject = stconnectProject,
  scenario = 33)
zonationHistoric <- scenario(
  ssimObject = stconnectProject,
  scenario = 34)
zonationLessUrban <- scenario(
  ssimObject = stconnectProject,
  scenario = 35)
prioritizrHistoric <- scenario(
  ssimObject = stconnectProject,
  scenario = 36)
prioritizrLessUrban <- scenario(
  ssimObject = stconnectProject,
  scenario = 37)
pureRandomHistoric <- scenario(
  ssimObject = stconnectProject,
  scenario = 38)
pureRandomLessUrban <- scenario(
  ssimObject = stconnectProject,
  scenario = 39)
clumpedRandomHistoric <- scenario(
  ssimObject = stconnectProject,
  scenario = 42)
clumpedRandomLessUrban <- scenario(
  ssimObject = stconnectProject,
  scenario = 43)

# Habitat amount
agnosticHistoric_Habitat <- datasheet(agnosticHistoric, 
                                      "stconnect_HSOutputMetric")
agnosticLessUrban_Habitat <- datasheet(agnosticLessUrban, 
                                      "stconnect_HSOutputMetric")
zonationHistoric_Habitat <- datasheet(zonationHistoric, 
                                      "stconnect_HSOutputMetric")
zonationLessUrban_Habitat <- datasheet(zonationLessUrban, 
                                       "stconnect_HSOutputMetric")
prioritizrHistoric_Habitat <- datasheet(prioritizrHistoric, 
                                      "stconnect_HSOutputMetric")
prioritizrLessUrban_Habitat <- datasheet(prioritizrLessUrban, 
                                       "stconnect_HSOutputMetric")
pureRandomHistoric_Habitat <- datasheet(pureRandomHistoric, 
                                        "stconnect_HSOutputMetric")
pureRandomLessUrban_Habitat <- datasheet(pureRandomLessUrban, 
                                         "stconnect_HSOutputMetric")
clumpedRandomHistoric_Habitat <- datasheet(clumpedRandomHistoric, 
                                        "stconnect_HSOutputMetric")
clumpedRandomLessUrban_Habitat <- datasheet(clumpedRandomLessUrban, 
                                         "stconnect_HSOutputMetric")

# Effective resistance distance
agnosticHistoric_Connectivity <- datasheet(agnosticHistoric, 
                                      "stconnect_CCOutputMetric")
agnosticLessUrban_Connectivity <- datasheet(agnosticLessUrban, 
                                       "stconnect_CCOutputMetric")
zonationHistoric_Connectivity <- datasheet(zonationHistoric, 
                                      "stconnect_CCOutputMetric")
zonationLessUrban_Connectivity <- datasheet(zonationLessUrban, 
                                       "stconnect_CCOutputMetric")
prioritizrHistoric_Connectivity <- datasheet(prioritizrHistoric, 
                                        "stconnect_CCOutputMetric")
prioritizrLessUrban_Connectivity <- datasheet(prioritizrLessUrban, 
                                         "stconnect_CCOutputMetric")
pureRandomHistoric_Connectivity <- datasheet(pureRandomHistoric, 
                                        "stconnect_CCOutputMetric")
pureRandomLessUrban_Connectivity <- datasheet(pureRandomLessUrban, 
                                         "stconnect_CCOutputMetric")
clumpedRandomHistoric_Connectivity <- datasheet(clumpedRandomHistoric, 
                                             "stconnect_CCOutputMetric")
clumpedRandomLessUrban_Connectivity <- datasheet(clumpedRandomLessUrban, 
                                              "stconnect_CCOutputMetric")

# Initial conditions
Habitat_2011 <- agnosticHistoric_Habitat %>%
  filter(Timestep == 2011 & Iteration == 1) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(Proportion), Min = NA, Max = NA) %>%
  mutate(Timestep = 2011, Scenario = "1 - Initial conditions")
Connectivity_2011 <- agnosticHistoric_Connectivity %>%
  filter(Timestep == 2011 & Iteration == 1) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(EffectivePermeability), Min = NA, Max = NA) %>%
  mutate(Timestep = 2011, Scenario = "1 - Initial conditions")
 
# 0.5x Urbanization
agnosticLessUrban_2060 <- agnosticLessUrban_Habitat %>%
  filter(Timestep == 2060) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(Proportion), Min = min(Proportion), Max = max(Proportion)) %>%
  mutate(Timestep = 2060, Scenario = "2 - Agnostic, 0.5x Urbanization")
zonationLessUrban_2060 <- zonationLessUrban_Habitat %>%
  filter(Timestep == 2060) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(Proportion), Min = min(Proportion), Max = max(Proportion)) %>%
  mutate(Timestep = 2060, Scenario = "3 - Zonation, 0.5x Urbanization")
prioritizrLessUrban_2060 <- prioritizrLessUrban_Habitat %>%
  filter(Timestep == 2060) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(Proportion), Min = min(Proportion), Max = max(Proportion)) %>%
  mutate(Timestep = 2060, Scenario = "4 - Prioritizr, 0.5x Urbanization")
pureRandomLessUrban_2060 <- pureRandomLessUrban_Habitat %>%
  filter(Timestep == 2060) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(Proportion), Min = min(Proportion), Max = max(Proportion)) %>%
  mutate(Timestep = 2060, Scenario = "5 - Pure random, 0.5x Urbanization")
clumpedRandomLessUrban_2060 <- clumpedRandomLessUrban_Habitat %>%
  filter(Timestep == 2060) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(Proportion), Min = min(Proportion), Max = max(Proportion)) %>%
  mutate(Timestep = 2060, Scenario = "6 - Clumped random, 0.5x Urbanization")

# Historic
agnosticHistoric_Habitat_2060 <- agnosticHistoric_Habitat %>%
  filter(Timestep == 2060) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(Proportion), Min = min(Proportion), Max = max(Proportion)) %>%
  mutate(Timestep = 2060, Scenario = "7 - Agnostic, Historic")
zonationHistoric_Habitat_2060 <- zonationHistoric_Habitat %>%
  filter(Timestep == 2060) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(Proportion), Min = min(Proportion), Max = max(Proportion)) %>%
  mutate(Timestep = 2060, Scenario = "8 - Zonation, Historic")
prioritizrHistoric_Habitat_2060 <- prioritizrHistoric_Habitat %>%
  filter(Timestep == 2060) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(Proportion), Min = min(Proportion), Max = max(Proportion)) %>%
  mutate(Timestep = 2060, Scenario = "9 - Prioritizr, Historic")
pureRandomHistoric_Habitat_2060 <- pureRandomHistoric_Habitat %>%
  filter(Timestep == 2060) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(Proportion), Min = min(Proportion), Max = max(Proportion)) %>%
  mutate(Timestep = 2060, Scenario = "10 - Pure random, Historic")
clumpedRandomHistoric_Habitat_2060 <- clumpedRandomHistoric_Habitat %>%
  filter(Timestep == 2060) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(Proportion), Min = min(Proportion), Max = max(Proportion)) %>%
  mutate(Timestep = 2060, Scenario = "11 - Clumped random, Historic")


# Connectivity ---------------------

# 0.5x Urbanization
agnosticLessUrban_Connectivity_2060 <- agnosticLessUrban_Connectivity %>%
  filter(Timestep == 2060) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(EffectivePermeability), Min = min(EffectivePermeability), Max = max(EffectivePermeability)) %>%
  mutate(Timestep = 2060, Scenario = "2 - Agnostic, 0.5x Urbanization")
zonationLessUrban_Connectivity_2060 <- zonationLessUrban_Connectivity %>%
  filter(Timestep == 2060) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(EffectivePermeability), Min = min(EffectivePermeability), Max = max(EffectivePermeability)) %>%
  mutate(Timestep = 2060, Scenario = "3 - Zonation, 0.5x Urbanization")
prioritizrLessUrban_Connectivity_2060 <- prioritizrLessUrban_Connectivity %>%
  filter(Timestep == 2060) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(EffectivePermeability), Min = min(EffectivePermeability), Max = max(EffectivePermeability)) %>%
  mutate(Timestep = 2060, Scenario = "4 - Prioritizr, 0.5x Urbanization")
pureRandomLessUrban_Connectivity_2060 <- pureRandomLessUrban_Connectivity %>%
  filter(Timestep == 2060) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(EffectivePermeability), Min = min(EffectivePermeability), Max = max(EffectivePermeability)) %>%
  mutate(Timestep = 2060, Scenario = "5 - Pure random, 0.5x Urbanization")
clumpedRandomLessUrban_Connectivity_2060 <- clumpedRandomLessUrban_Connectivity %>%
  filter(Timestep == 2060) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(EffectivePermeability), Min = min(EffectivePermeability), Max = max(EffectivePermeability)) %>%
  mutate(Timestep = 2060, Scenario = "6 - Clumped random, 0.5x Urbanization")

# Historic
agnosticHistoric_Connectivity_2060 <- agnosticHistoric_Connectivity %>%
  filter(Timestep == 2060) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(EffectivePermeability), Min = min(EffectivePermeability), Max = max(EffectivePermeability)) %>%
  mutate(Timestep = 2060, Scenario = "7 - Agnostic, Historic")
zonationHistoric_Connectivity_2060 <- zonationHistoric_Connectivity %>%
  filter(Timestep == 2060) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(EffectivePermeability), Min = min(EffectivePermeability), Max = max(EffectivePermeability)) %>%
  mutate(Timestep = 2060, Scenario = "8 - Zonation, Historic")
prioritizrHistoric_Connectivity_2060 <- prioritizrHistoric_Connectivity %>%
  filter(Timestep == 2060) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(EffectivePermeability), Min = min(EffectivePermeability), Max = max(EffectivePermeability)) %>%
  mutate(Timestep = 2060, Scenario = "9 - Prioritizr, Historic")
pureRandomHistoric_Connectivity_2060 <- pureRandomHistoric_Connectivity %>%
  filter(Timestep == 2060) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(EffectivePermeability), Min = min(EffectivePermeability), Max = max(EffectivePermeability)) %>%
  mutate(Timestep = 2060, Scenario = "10 - Pure random, Historic")
clumpedRandomHistoric_Connectivity_2060 <- clumpedRandomHistoric_Connectivity %>%
  filter(Timestep == 2060) %>%
  group_by(SpeciesID) %>%
  summarise(Mean = mean(EffectivePermeability), Min = min(EffectivePermeability), Max = max(EffectivePermeability)) %>%
  mutate(Timestep = 2060, Scenario = "11 - Clumped random, Historic")

# Set label names
labelNames <- c(
  "1 - Initial conditions" = "Initial conditions (2010)",
  "2 - Agnostic, 0.5x Urbanization" = "Agnostic, Reduced urbanization (2060)",
  "3 - Zonation, 0.5x Urbanization" = "Zonation, Reduced urbanization (2060)",
  "4 - Prioritizr, 0.5x Urbanization" = "Prioritizr, Reduced urbanization (2060)",
  "5 - Pure random, 0.5x Urbanization" = "Fully random, Reduced urbanization (2060)",
  "6 - Clumped random, 0.5x Urbanization" = "Clumped random, Reduced urbanization (2060)",
  "7 - Agnostic, Historic" = "Agnostic, Business-as-usual (2060)",
  "8 - Zonation, Historic" = "Zonation, Business-as-usual (2060)",
  "9 - Prioritizr, Historic" = "Prioritizr, Business-as-usual (2060)",
  "10 - Pure random, Historic" = "Fully random, Business-as-usual (2060)",
  "11 - Clumped random, Historic" = "Clumped random, Business-as-usual (2060)")

# Set break names
breaksNames <- c(
  "1 - Initial conditions",
  "2 - Agnostic, 0.5x Urbanization",
  "3 - Zonation, 0.5x Urbanization",
  "4 - Prioritizr, 0.5x Urbanization",
  "5 - Pure random, 0.5x Urbanization",
  "6 - Clumped random, 0.5x Urbanization",
  "7 - Agnostic, Historic",
  "8 - Zonation, Historic",
  "9 - Prioritizr, Historic",
  "10 - Pure random, Historic",
  "11 - Clumped random, Historic")

# Combine results
habitatToPlot <- rbind(Habitat_2011,
                       agnosticHistoric_Habitat_2060, 
                       agnosticLessUrban_2060,
                       zonationHistoric_Habitat_2060,
                       zonationLessUrban_2060,
                       prioritizrHistoric_Habitat_2060,
                       prioritizrLessUrban_2060,
                       pureRandomHistoric_Habitat_2060,
                       pureRandomLessUrban_2060,
                       clumpedRandomHistoric_Habitat_2060,
                       clumpedRandomLessUrban_2060)
connectivityToPlot <- rbind(Connectivity_2011,
                       agnosticHistoric_Connectivity_2060, 
                       agnosticLessUrban_Connectivity_2060,
                       zonationHistoric_Connectivity_2060,
                       zonationLessUrban_Connectivity_2060,
                       prioritizrHistoric_Connectivity_2060,
                       prioritizrLessUrban_Connectivity_2060,
                       pureRandomHistoric_Connectivity_2060,
                       pureRandomLessUrban_Connectivity_2060,
                       clumpedRandomHistoric_Connectivity_2060,
                       clumpedRandomLessUrban_Connectivity_2060)

# Set plot layout
plotLayout <- list(theme(strip.text.x = element_text(hjust = 0, 
                                                     vjust = 1, 
                                                     size=10, 
                                                     margin = margin(1,0,1,0)),
                         strip.background = element_blank(),
                         axis.line = element_line(size = 0.1),
                         axis.ticks.x = element_blank(),
                         axis.ticks.y = element_line(size = 0.1),
                         axis.text.x = element_blank(),
                         axis.text.y = element_text(size = 8),
                         axis.title.y = element_text(size = 10),
                         axis.title.x = element_blank(),
                         legend.title = element_text(size = 10),
                         legend.text = element_text(size = 8),
                         panel.background = element_blank(),
                         legend.key=element_blank()))

# Plot habitat amount
ggplot(habitatToPlot, 
       aes(x = factor(Scenario, levels = breaksNames), y = Mean*100)) +
  labs(y = "Habitat amount (%)", colour = "Scenarios") +
  geom_point(aes(colour = factor(Scenario, levels = breaksNames)), 
             stat = "identity", show.legend = F) +
  geom_errorbar(aes(ymin = Min*100, ymax = Max*100, 
                   colour = factor(Scenario, levels = breaksNames)), 
               width = 0.2, show.legend = F) +
  scale_colour_discrete(labels = labelNames) +
  scale_x_discrete(breaks = breaksNames) +
  facet_wrap(~ SpeciesID, scales = "free") +
  plotLayout

# Plot connectivity
ggplot(connectivityToPlot, 
       aes(x = factor(Scenario, levels = breaksNames), y = Mean*100)) +
  labs(y = "Effective resistance distance", colour = "Scenarios") +
  geom_point(aes(colour = factor(Scenario, levels = breaksNames)), stat = "identity", show.legend = F) +
  geom_errorbar(aes(ymin = Min*100, ymax = Max*100, 
                    colour = factor(Scenario, levels = breaksNames)), 
                width = 0.2, show.legend = F) +
  scale_colour_discrete(labels = labelNames) +
  scale_x_discrete(breaks = breaksNames) +
  facet_wrap(~ SpeciesID, scales = "free") +
  plotLayout


