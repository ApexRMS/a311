## a311
## Carina Rauen Firkowski
## December 12, 2023
##
## This script summarizes target area per MRC and compares the realized 
## transition areas per MSC approach to identify shortfalls in available area.



# Load constants
source("Scripts/0-constants.R")



# Load tabular data ------------------------------------------------------------

# Transition Targets
target <- read.csv(file.path(tabularDataDir, 
                             "Input - Transition Targets.csv"))

# Transition Area
agnosticArea <- read.csv(file.path(tabularDataDir,
                                   "Output - Transition Targets - Agnostic.csv"))
zonationArea <- read.csv(file.path(tabularDataDir,
                                   "Output - Transition Targets - Zonation.csv"))
prioritizrArea <- read.csv(file.path(tabularDataDir,
                                     "Output - Transition Targets - Prioritizr.csv"))



# Summarize target transition area per MSU -------------------------------------

# Target summary
# NOTE: only considering 2000 targets
totalTargetPerMSU <- target %>%
  filter(Timestep != 1990) %>%
  group_by(SecondaryStratumID) %>%
  summarise(TotalTarget = sum(Amount))

# Function to compare target and realized transition area
summarize_target <- function(dfMSC) {
  
  # Realized transition area
  mscAreaPerMSU <- dfMSC %>%
    filter(TransitionGroup == "Agricultural Expansion and Urbanization") %>%
    group_by(Timestep, SecondaryStratum) %>%
    summarise(TotalArea = sum(Amount))
  
  # Merge target and realized data
  summaryTable <- totalTargetPerMSU %>%
    merge(mscAreaPerMSU, 
          by.x = "SecondaryStratumID", by.y = "SecondaryStratum") %>%
    arrange(SecondaryStratumID, Timestep)
  
  # Target assessment 
  summaryTable$Assessment <- apply(summaryTable, 1, assess_target)
  
  return(summaryTable)
}

# Function to identify if target was met (=), not met (<), or exceeded (>)
assess_target <- function(x){
  if(as.numeric(x["TotalArea"]) == as.numeric(x["TotalTarget"])){
    assessment <- "Target met"
  } 
  if(as.numeric(x["TotalArea"]) >= as.numeric(x["TotalTarget"])){
    assessment <- "Target exceeded"
  } 
  if(as.numeric(x["TotalArea"]) <= as.numeric(x["TotalTarget"])){
    assessment <- "Target not met"
  } 
  return(assessment)
}

agnosticSummary <- summarize_target(agnosticArea)
zonationSummary <- summarize_target(zonationArea)
prioritizrSummary <- summarize_target(prioritizrArea)

# Merge approaches
mscSummary <- rbind(agnosticSummary, zonationSummary, prioritizrSummary)
mscSummary$MSC <- c(rep("Agnostic", dim(agnosticSummary)[1]),
                    rep("Zonation", dim(zonationSummary)[1]),
                    rep("Prioritizr", dim(prioritizrSummary)[1]))



# Plot -------------------------------------------------------------------------

# Realized transition by year per approach
ggplot(mscSummary, 
       aes(x = Timestep, y = TotalArea, color = MSC)) +
  labs(x = "Year", 
       y = "Total Urbanization and Agricultural Expansion Area (ha)") +
  geom_line() +
  geom_hline(aes(yintercept = TotalTarget, linetype = "Target")) +
  facet_wrap(~ SecondaryStratumID, scales = "free") +
  scale_linetype_manual(name = "", values = "dashed") +
  theme_classic() +
  theme(strip.background = element_blank())


# Save outputs -----------------------------------------------------------------

write.csv(agnosticSummary, 
          file = file.path(outputDir, "Transition Area Summary - Agnostic.csv"))
write.csv(zonationSummary, 
          file = file.path(outputDir, "Transition Area Summary - Zonation.csv"))
write.csv(prioritizrSummary, 
          file = file.path(outputDir, "Transition Area Summary - Prioritizr.csv"))


