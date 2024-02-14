## a311
## Carina Rauen Firkowski 
## February 16, 2024
##
## This script opens a stconnect library from backup and updates the scenarios
## for deliverable 2.



# Load constants
source("Scripts/0-constants.R")



# stconnect Library ------------------------------------------------------------

# Open a new SyncroSim session
stconnectSession <- session()

# Open existing stconnect Library
stconnectLibrary <- ssimLibrary(
  name = file.path("a311-deliverable3-16Feb2024.ssim"),
  session = stconnectSession, overwrite = FALSE,
  package = "stconnect")

# Open default Project
stconnectProject <- rsyncrosim::project(ssimObject = stconnectLibrary, 
                                        project = "Definitions")


# Function to create or update sub-scenarios
edit_subscenario <- function(scenarioName, scenarioInput, scenarioDatasheet){
  
  # Create a scenario
  newScenario <- scenario(
    ssimObject = stconnectProject,
    scenario = scenarioName)
  
  # Load input file
  inputDS <- read.csv(file.path(libraryInputsDir, scenarioInput))
  
  # Save datasheet
  saveDatasheet(ssimObject = newScenario, 
                data = inputDS, 
                name = scenarioDatasheet)
  
  return(newScenario)
}



# 00 Pipeline ------------------------------------

# Create & edit sub-scenario
# Landscape change & Habitat Suitability 
targetScenario <- edit_subscenario(
  scenarioName = "Pipeline: Landscape Change, Habitat Suitability",
  scenarioInput = "Pipeline - Landscape Change, Habitat Suitability.csv",
  scenarioDatasheet = "core_Pipeline")

# Move scenario into folder
folderId(targetScenario) <- folderId(folder(stconnectProject, "00 Pipeline"))


# 01 Run Control ---------------------------------

# Create & edit sub-scenario
# 2010-2060, 10 iterations
targetScenario <- edit_subscenario(
  scenarioName = "Run Control: Spatial; 2010 - 2060; 10 iterations",
  scenarioInput = "Run Control - 10 iteration 50 timesteps.csv",
  scenarioDatasheet = "stsim_RunControl")

# Move scenario into folder
folderId(targetScenario) <- folderId(folder(stconnectProject, "01 Run Control"))



# Full scenarios ---------------------------------------------------------------

# Function to create scenario and set dependencies
create_fullscenario <- function(scenarioName, 
                                destinationFolder = NA,
                                dependenciesCore, dependenciesUnique){
  
  # Create scenario
  newScenario <- scenario(ssimObject = stconnectProject,
                          scenario = scenarioName)
  # Move scenario into folder
  if(suppressWarnings(!is.na(destinationFolder))){
    folderId(newScenario) <- folderId(destinationFolder)
  }
  # Set dependencies
  dependency(newScenario, dependency = c(dependenciesCore, 
                                         dependenciesUnique))
  
}

# Analysis scenarios -----------------------------

# 2010-2050, 10 iterations, historic --

# Set common dependencies
# NOTE: integers reflect scenario IDs
coreDependencies <- c("pipeline",
                      "runcontol",
                      4, 5, 6, 8, 9, 13, 14, 15, 16, 17, 36, 37)

# Agnostic
targetScenario <- create_fullscenario(
  scenarioName = "Agnostic: 2010-2050; 10 iterations; Historic; Landscape & Habitat",
  #destinationFolder = benchmarkFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = 10)

# Zonation
targetScenario <- create_fullscenario(
  scenarioName = "Zonation: 2010-2050; 10 iterations; Historic; Landscape & Habitat",
  destinationFolder = benchmarkFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = 11)

# Prioritizr
targetScenario <- create_fullscenario(
  scenarioName = "Prioritizr: 2010-2050; 10 iterations; Historic; Landscape & Habitat",
  destinationFolder = benchmarkFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = 12)


# 2010-2060, 10 iterations, 0.5x urbanization -

# Set common dependencies
# NOTE: integers reflect scenario IDs
coreDependencies <- c("pipeline",
                      "runcontol",
                      4, 5, 7, 8, 9, 13, 14, 15, 16, 17, 36, 37)

# Agnostic
targetScenario <- create_fullscenario(
  scenarioName = "Agnostic: 2010-2060; 10 iterations; 0.5x Urbanization; Landscape & Habitat",
  destinationFolder = benchmarkFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = 10)

# Zonation
targetScenario <- create_fullscenario(
  scenarioName = "Zonation: 2010-2060; 10 iterations; 0.5x Urbanization; Landscape & Habitat",
  destinationFolder = benchmarkFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = 11)

# Prioritizr
targetScenario <- create_fullscenario(
  scenarioName = "Prioritizr: 2010-2060; 10 iterations; 0.5x Urbanization; Landscape & Habitat",
  destinationFolder = benchmarkFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = 12)






