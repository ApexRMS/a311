## a311
## Carina Rauen Firkowski 
## February 06, 2024
##
## This script opens a stconnect library from backup and updates the scenarios
## for deliverable 1. 



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

# 03 Habitat -------------------------------------

# Create nested folder
habitatFolder <- folder(stconnectProject, folder = "03 Habitat",
                        parentFolder = "Sub-Scenarios")
 
 
# 01 Habitat Suitability ----------
 
# Create nested sub-folder
habitatSuitabilityFolder <- folder(stconnectProject, 
                                   folder = "01 Habitat Suitability",
                                   parentFolder = "03 Habitat")

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

# Create & edit sub-scenario
targetScenario <- edit_subscenario(
 scenarioName = "Habitat Suitability: Basic Landcover and Forest Age - 14 species",
 scenarioInput = "Habitat Suitability.csv",
 scenarioDatasheet = "stconnect_HSHabitatSuitability")
 
# Move scenario into folder
folderId(targetScenario) <- folderId(habitatSuitabilityFolder)
 

# 02 Habitat Patch ----------------

# Create nested sub-folder
habitatPatchFolder <- folder(stconnectProject, 
                             folder = "02 Habitat Patch",
                             parentFolder = "03 Habitat")

# Create & edit sub-scenario
targetScenario <- edit_subscenario(
 scenarioName = "Habitat Patch: 14 species",
 scenarioInput = "Habitat Patch.csv",
 scenarioDatasheet = "stconnect_HSHabitatPatch")

# Move scenario into folder
folderId(targetScenario) <- folderId(habitatPatchFolder)
 
 
 
# 04 Circuitscape --------------------------------

# Create nested folder
circuitscapeFolder <- folder(stconnectProject, folder = "04 Circuitscape",
                             parentFolder = "Sub-Scenarios")
 
# 01 Resistance -------------------

# Create nested sub-folder
resistanceFolder <- folder(stconnectProject,
                          folder = "01 Resistance",
                          parentFolder = "04 Circuitscape")
 
# Create & edit sub-scenario
targetScenario <- edit_subscenario(
 scenarioName = "Resistance: 14 species",
 scenarioInput = "Resistance.csv",
 scenarioDatasheet = "stconnect_CCResistance")
 
# Move scenario into folder
folderId(targetScenario) <- folderId(resistanceFolder)


# 02 Sources ----------------------

# Create nested sub-folder
sourcesFolder <- folder(stconnectProject,
                        folder = "02 Sources",
                        parentFolder = "04 Circuitscape")

# Create & edit sub-scenario
targetScenario <- edit_subscenario(
  scenarioName = "Sources: PA network",
  scenarioInput = "Sources - PA network.csv",
  scenarioDatasheet = "stconnect_CCSources")

# Move scenario into folder
folderId(targetScenario) <- folderId(sourcesFolder)


# 00 Pipeline ------------------------------------

# Create & edit sub-scenario

# Landscape change, Habitat Suitability & Circuitscape transformers
targetScenario <- edit_subscenario(
  scenarioName = "Pipeline: Landscape Change, Habitat Suitability, Circuitscape",
  scenarioInput = "Pipeline - Landscape Change, Habitat Suitability, Circuitscape.csv",
  scenarioDatasheet = "core_Pipeline")
# Move scenario into folder
folderId(targetScenario) <- folderId(folder(stconnectProject, "00 Pipeline"))

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

# # Benchmark scenarios ----------------------------
# 
# # 2010-2011, 1 iteration, historic ----
# 
# # Set common dependencies
# # NOTE: integers reflect scenario IDs
# coreDependencies <- c(39, 2, 4, 5, 6, 8, 9, 13, 14, 15, 16, 17, 36, 37, 38)
# 
# # Agnostic
# targetScenario <- create_fullscenario(
#   scenarioName = "Agnostic: 2010-2011; 1 iteration; Historic; Full run",
#   #destinationFolder = benchmarkFolder,
#   dependenciesCore = coreDependencies,
#   dependenciesUnique = 10)
# 
# # Zonation
# targetScenario <- create_fullscenario(
#   scenarioName = "Zonation: 2010-2011; 1 iteration; Historic",
#   destinationFolder = benchmarkFolder,
#   dependenciesCore = coreDependencies,
#   dependenciesUnique = 11)
# 
# # Prioritizr
# targetScenario <- create_fullscenario(
#   scenarioName = "Prioritizr: 2010-2011; 1 iteration; Historic",
#   destinationFolder = benchmarkFolder,
#   dependenciesCore = coreDependencies,
#   dependenciesUnique = 12)
# 
# 
# # 2010-2060, 1 iteration, historic ----
# 
# # Set common dependencies
# # NOTE: integers reflect scenario IDs
# coreDependencies <- c(1, 3, 4, 5, 6, 8, 9, 13, 14, 15, 16, 17)
# 
# # Agnostic
# targetScenario <- create_fullscenario(
#   scenarioName = "Agnostic: 2010-2060; 1 iteration; Historic",
#   destinationFolder = benchmarkFolder,
#   dependenciesCore = coreDependencies,
#   dependenciesUnique = 10)
# 
# # Zonation
# targetScenario <- create_fullscenario(
#   scenarioName = "Zonation: 2010-2060; 1 iteration; Historic",
#   destinationFolder = benchmarkFolder,
#   dependenciesCore = coreDependencies,
#   dependenciesUnique = 11)
# 
# # Prioritizr
# targetScenario <- create_fullscenario(
#   scenarioName = "Prioritizr: 2010-2060; 1 iteration; Historic",
#   destinationFolder = benchmarkFolder,
#   dependenciesCore = coreDependencies,
#   dependenciesUnique = 12)
# 
# 
# # 2010-2060, 1 iteration, 0.5x urbanization ---
# 
# # Set common dependencies
# # NOTE: integers reflect scenario IDs
# coreDependencies <- c(1, 3, 4, 5, 7, 8, 9, 13, 14, 15, 16, 17)
# 
# # Agnostic
# targetScenario <- create_fullscenario(
#   scenarioName = "Agnostic: 2010-2060; 1 iteration; 0.5x Urbanization",
#   destinationFolder = benchmarkFolder,
#   dependenciesCore = coreDependencies,
#   dependenciesUnique = 10)
# 
# # Zonation
# targetScenario <- create_fullscenario(
#   scenarioName = "Zonation: 2010-2060; 1 iteration; 0.5x Urbanization",
#   destinationFolder = benchmarkFolder,
#   dependenciesCore = coreDependencies,
#   dependenciesUnique = 11)
# 
# # Prioritizr
# targetScenario <- create_fullscenario(
#   scenarioName = "Prioritizr: 2010-2060; 1 iteration; 0.5x Urbanization",
#   destinationFolder = benchmarkFolder,
#   dependenciesCore = coreDependencies,
#   dependenciesUnique = 12)


# Analysis scenarios -----------------------------

# 2010-2050, 10 iterations, historic --

# Set common dependencies
# NOTE: integers reflect scenario IDs
coreDependencies <- c(1,  # Pipeline: ST-Sim only
                      31, # Run Control
                      4, 5, 6, 8, 9, 13, 14, 15, 16, 17, 27, 28)

# Agnostic
targetScenario <- create_fullscenario(
  scenarioName = "Agnostic: 2010-2060; 10 iterations; Historic; Landscape",
  destinationFolder = analysisFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = 10)

# Zonation
targetScenario <- create_fullscenario(
  scenarioName = "Zonation: 2010-2060; 10 iterations; Historic; Landscape",
  destinationFolder = analysisFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = 11)

# Prioritizr
targetScenario <- create_fullscenario(
  scenarioName = "Prioritizr: 2010-2060; 10 iterations; Historic; Landscape",
  destinationFolder = analysisFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = 12)


# 2010-2060, 10 iterations, 0.5x urbanization -

# Set common dependencies
# NOTE: integers reflect scenario IDs
coreDependencies <- c(1,  # Pipeline: ST-Sim only
                      31, # Run Control
                      4, 5, 7, 8, 9, 13, 14, 15, 16, 17, 27, 28)

# Agnostic
targetScenario <- create_fullscenario(
  scenarioName = "Agnostic: 2010-2060; 10 iterations; 0.5x Urbanization; Landscape",
  destinationFolder = analysisFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = 10)

# Zonation
targetScenario <- create_fullscenario(
  scenarioName = "Zonation: 2010-2060; 10 iterations; 0.5x Urbanization; Landscape",
  destinationFolder = analysisFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = 11)

# Prioritizr
targetScenario <- create_fullscenario(
  scenarioName = "Prioritizr: 2010-2060; 10 iterations; 0.5x Urbanization; Landscape",
  destinationFolder = analysisFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = 12)



# Backup library ---------------------------------------------------------------

# Create backup of current library version
backup(stconnectLibrary)


