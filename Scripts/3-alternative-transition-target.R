## a311
## Carina Rauen Firkowski
## December 12, 2023
##
## This script modifies the business as usual (BAU) Transition Target datasheet 
## by reducing the urbanization rate by half.



# Load constants
source("Scripts/0-constants.R")



# Load tabular data ------------------------------------------------------------

# Transition Targets
target <- read.csv(file.path(tabularDataDir, 
                             "Input - Transition Targets.csv"))



# Create alternative urbanization target ---------------------------------------

# Rate of change relative to BAU
urbanizationRate <- 0.5

# Update transition target for transitions to "Urban"
targetAlternative <- target
targetAlternative$Amount <- apply(target, 1, function(x){
  if(grepl("->Urban", x["TransitionGroupID"], fixed = TRUE)) {
    newAmount <- as.numeric(x["Amount"]) * 0.5
  } else {
    newAmount <- as.numeric(x["Amount"])
  }
})



# Save outputs -----------------------------------------------------------------

write.csv(targetAlternative, 
          file = file.path(intermediatesDir, 
                           "Transition Target - Alternative.csv"))


