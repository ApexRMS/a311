## a311
## Carina Rauen Firkowski 
## March 8, 2024
##
## This script generates a stconnect library for deliverable 3 for the complete
## analysis, which includes 10 iterations, 50 timesteps, 14 focal species, and 
## a factorial design for 5 protected area approaches (agnostic, zonation, 
## prioritizr, pure random, and aggregated random) and 2 land use change rates
## (historic and 0.5x urbanization).
##
## The library is available to collaborators from SyncroSim Cloud at 
## https://cloud.syncrosim.com/carina-firkowski/Deliverable%203%20-%20Protected%20Areas%20Multispecies%20Connectivity/map/4?variable=stsim_sc&timestep=2011&scenario=32
## 
## NOTE: In order to run this script, please review line 49 to properly setup
##       the path to the Julia software on your machine.
##       Additionally, the paths to input data used in this script assume the 
##       working directory is set to "C:/gitprojects/A311". If setting a  
##       different working directory, make sure to update the following files:
##          - Initial Conditions Spatial Files.csv
##          - Transition Spatial Multipliers - Agnostic.csv
##          - Transition Spatial Multipliers - Zonation.csv
##          - Transition Spatial Multipliers - Prioritizr.csv
##          - Transition Spatial Multipliers - Pure random.csv
##          - Transition Spatial Multipliers - Aggregated random.csv



# Load constants
source("Scripts/0-constants.R")



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


# Julia Configuration datasheet ------------------

# Set path to Julia executable
juliaConfiguration <- data.frame(Filename = "C:\\Users\\Administrator\\AppData\\Local\\Programs\\Julia-1.10.0\\bin\\julia.exe")

# Save datasheet
saveDatasheet(ssimObject = stconnectLibrary, 
              data = juliaConfiguration, 
              name = "stconnect_CCJuliaConfig")



# stconnect Project ------------------------------------------------------------

# Function to create or update sub-scenarios
edit_project <- function(projectInput, projectDatasheet){
  
  # Load input file
  inputDS <- read.csv(file.path(libraryInputsDir, projectInput))
  
  # Save datasheet
  saveDatasheet(ssimObject = stconnectProject, 
                data = inputDS, 
                name = projectDatasheet)
  
}

# Datasheet: Species
edit_project(projectInput = "Species.csv",
             projectDatasheet = "stconnect_Species")

# Datasheet: Terminology
edit_project(projectInput = "Terminology.csv",
             projectDatasheet = "stsim_Terminology")

# Datasheet: Ecoregion
edit_project(projectInput = "Ecoregion.csv",
             projectDatasheet = "stsim_Stratum")

# Datasheet: MRC
edit_project(projectInput = "MRC.csv",
             projectDatasheet = "stsim_SecondaryStratum")

# Datasheet: Terrain type
edit_project(projectInput = "TerrainType.csv",
             projectDatasheet = "stsim_TertiaryStratum")

# Datasheet: Class
edit_project(projectInput = "Class.csv",
             projectDatasheet = "stsim_StateLabelX")

# Datasheet: Subclass
edit_project(projectInput = "Subclass.csv",
             projectDatasheet = "stsim_StateLabelY")

# Datasheet: State class
edit_project(projectInput = "State Class.csv",
             projectDatasheet = "stsim_StateClass")

# Datasheet: Transition type
edit_project(projectInput = "Transition Type.csv",
             projectDatasheet = "stsim_TransitionType")

# Datasheet: Transition group
edit_project(projectInput = "Transition Group.csv",
             projectDatasheet = "stsim_TransitionGroup")

# Datasheet: Transition types by group
edit_project(projectInput = "Transition Types by Group.csv",
             projectDatasheet = "stsim_TransitionTypeGroup")

# Datasheet: Transition simulation groups
edit_project(projectInput = "Transition Simulation Groups.csv",
             projectDatasheet = "stsim_TransitionSimulationGroup")

# Datasheet: State attribute type
edit_project(projectInput = "State Attribute Type.csv",
             projectDatasheet = "stsim_StateAttributeType")

# Datasheet: Transition attribute type
edit_project(projectInput = "Transition Attribute Type.csv",
             projectDatasheet = "stsim_TransitionAttributeType")



# Sub-scenarios ----------------------------------------------------------------

# Create folder
subscenarioFolder <- folder(stconnectProject, folder = "Sub-Scenarios")


# 00 Pipeline ------------------------------------

# Create nested folder
pipelineFolder <- folder(stconnectProject, folder = "00 Pipeline",
                         parentFolder = subscenarioFolder)

# Landscape change, Habitat Suitability & Circuitscape transformers
targetScenario <- edit_subscenario(
  scenarioName = "Pipeline: Landscape Change, Habitat Suitability, Circuitscape",
  scenarioInput = "Pipeline - Landscape Change, Habitat Suitability, Circuitscape.csv",
  scenarioDatasheet = "core_Pipeline")
# Move scenario into folder
folderId(targetScenario) <- folderId(folder(stconnectProject, "00 Pipeline"))



# 01 Run control ---------------------------------

# Create nested folder
runcontrolFolder <- folder(stconnectProject, folder = "01 Run Control",
                           parentFolder = subscenarioFolder)

# Create & edit sub-scenario
# 2010-2060, 10 iterations
targetScenario <- edit_subscenario(
  scenarioName = "Run Control: Spatial; 2010 - 2060; 10 iterations",
  scenarioInput = "Run Control - 10 iterations 50 timesteps.csv",
  scenarioDatasheet = "stsim_RunControl")
# Move scenario into folder
folderId(targetScenario) <- folderId(runcontrolFolder)


# 02 Landscape change ----------------------------

# Create nested folder
landscapeChangeFolder <- folder(stconnectProject, folder = "02 Landscape Change",
                                parentFolder = subscenarioFolder)


# 01 Transition pathways ----------

# Create nested sub-folder
transitionPathwaysFolder <- folder(stconnectProject, 
                                   folder = "01 Transition Pathways",
                                   parentFolder = landscapeChangeFolder)

# Create & edit sub-scenario
# Datasheet: States
targetScenario <- edit_subscenario(
  scenarioName = "Transition Pathways: LULC; Forest Composition x Age; TST Min 20",
  scenarioInput = "Transition Pathways - States.csv",
  scenarioDatasheet = "stsim_DeterministicTransition")
# Datasheet: Transitions
targetScenario <- edit_subscenario(
  scenarioName = "Transition Pathways: LULC; Forest Composition x Age; TST Min 20",
  scenarioInput = "Transition Pathways - Transitions.csv",
  scenarioDatasheet = "stsim_Transition")
# Move scenario into folder
folderId(targetScenario) <- folderId(transitionPathwaysFolder)


# 02 Initial conditions -----------

# Create nested sub-folder
initialConditionsFolder <- folder(stconnectProject, 
                                  folder = "02 Initial Conditions",
                                  parentFolder = landscapeChangeFolder)

# Create & edit sub-scenario
targetScenario <- edit_subscenario(
  scenarioName = "Initial Conditions: Spatial 90m; Monteregie",
  scenarioInput = "Initial Conditions Spatial Files.csv",
  scenarioDatasheet = "stsim_InitialConditionsSpatial")
# Move scenario into folder
folderId(targetScenario) <- folderId(initialConditionsFolder)


# 03 Transition targets -----------

# Create nested sub-folder
transitionTargetsFolder <- folder(stconnectProject, 
                                  folder = "03 Transition Targets",
                                  parentFolder = landscapeChangeFolder)

# Create & edit sub-scenario
# Historic
targetScenario <- edit_subscenario(
  scenarioName = "Transition Targets: LULC Historic 1990 - 2010",
  scenarioInput = "Transition Targets - Historic.csv",
  scenarioDatasheet = "stsim_TransitionTarget")
# Move scenario into folder
folderId(targetScenario) <- folderId(transitionTargetsFolder)

# 0.5x urbanization
targetScenario <- edit_subscenario(
  scenarioName = "Transition Targets: 0.5x Urbanization 1990 - 2010",
  scenarioInput = "Transition Targets - 0.5x Urbanization.csv",
  scenarioDatasheet = "stsim_TransitionTarget")
# Move scenario into folder
folderId(targetScenario) <- folderId(transitionTargetsFolder)


# 04 Output options ---------------

# Create nested sub-folder
outputOptionsFolder <- folder(stconnectProject, 
                              folder = "04 Output Options",
                              parentFolder = landscapeChangeFolder)

# Create & edit sub-scenario
# Datasheet: Options
targetScenario <- edit_subscenario(
  scenarioName = "Output Options",
  scenarioInput = "Output Options.csv",
  scenarioDatasheet = "stsim_OutputOptions")
# Datasheet: Spatial
targetScenario <- edit_subscenario(
  scenarioName = "Output Options",
  scenarioInput = "Output Options Spatial.csv",
  scenarioDatasheet = "stsim_OutputOptionsSpatial")
# Datasheet: Spatial Averages
targetScenario <- edit_subscenario(
  scenarioName = "Output Options",
  scenarioInput = "Output Options Spatial Averages.csv",
  scenarioDatasheet = "stsim_OutputOptionsSpatialAverage")

# Move scenario into folder
folderId(targetScenario) <- folderId(outputOptionsFolder)


# 05 Transition Multipliers -------

# Create nested sub-folder
transitionMultiplierFolder <- folder(stconnectProject, 
                                     folder = "05 Transition Multipliers",
                                     parentFolder = landscapeChangeFolder)

# Create & edit sub-scenario
targetScenario <- edit_subscenario(
  scenarioName = "Transition Multipliers: Climate Baseline",
  scenarioInput = "Transition Multipliers.csv",
  scenarioDatasheet = "stsim_TransitionMultiplierValue")

# Move scenario into folder
folderId(targetScenario) <- folderId(transitionMultiplierFolder)


# 06 Transition Spatial Multiplier ---

# Create nested sub-folder
spatialMultiplierFolder <- folder(stconnectProject,
                                  folder = "06 Transition Spatial Multiplier",
                                  parentFolder = landscapeChangeFolder)

# Create & edit sub-scenario
# Agnostic
targetScenario <- edit_subscenario(
  scenarioName = "Transition Spatial Multiplier: Agnostic",
  scenarioInput = "Transition Spatial Multipliers - Agnostic.csv",
  scenarioDatasheet = "stsim_TransitionSpatialMultiplier")
# Move scenario into folder
folderId(targetScenario) <- folderId(spatialMultiplierFolder)

# Zonation
targetScenario <- edit_subscenario(
  scenarioName = "Transition Spatial Multiplier: Zonation",
  scenarioInput = "Transition Spatial Multipliers - Zonation.csv",
  scenarioDatasheet = "stsim_TransitionSpatialMultiplier")
# Move scenario into folder
folderId(targetScenario) <- folderId(spatialMultiplierFolder)

# Prioritizr
targetScenario <- edit_subscenario(
  scenarioName = "Transition Spatial Multiplier: Prioritizr",
  scenarioInput = "Transition Spatial Multipliers - Prioritizr.csv",
  scenarioDatasheet = "stsim_TransitionSpatialMultiplier")
# Move scenario into folder
folderId(targetScenario) <- folderId(spatialMultiplierFolder)

# Pure random
targetScenario <- edit_subscenario(
  scenarioName = "Transition Spatial Multiplier: Pure random",
  scenarioInput = "Transition Spatial Multipliers - Pure random.csv",
  scenarioDatasheet = "stsim_TransitionSpatialMultiplier")
# Move scenario into folder
folderId(targetScenario) <- folderId(spatialMultiplierFolder)

# Aggregated random
targetScenario <- edit_subscenario(
  scenarioName = "Transition Spatial Multiplier: Aggregated random",
  scenarioInput = "Transition Spatial Multipliers - Aggregated random.csv",
  scenarioDatasheet = "stsim_TransitionSpatialMultiplier")
# Move scenario into folder
folderId(targetScenario) <- folderId(spatialMultiplierFolder)


# 07 Transition Adjacency Multiplier ---

# Create nested sub-folder
adjacencyMultiplierFolder <- folder(stconnectProject, 
                                    folder = "07 Transition Adjacency Multiplier",
                                    parentFolder = landscapeChangeFolder)

# Create & edit sub-scenario
# Datasheet: Multipliers
targetScenario <- edit_subscenario(
  scenarioName = "Transition Adjacency Multiplier: Agriculture and Urban",
  scenarioInput = "Transition Adjacency Multipliers.csv",
  scenarioDatasheet = "stsim_TransitionAdjacencyMultiplier")
# Datasheet: Settings
targetScenario <- edit_subscenario(
  scenarioName = "Transition Adjacency Multiplier: Agriculture and Urban",
  scenarioInput = "Transition Adjacency Setting.csv",
  scenarioDatasheet = "stsim_TransitionAdjacencySetting")
# Move scenario into folder
folderId(targetScenario) <- folderId(adjacencyMultiplierFolder)


# 08 Attributes -------------------

# Create nested sub-folder
attributesFolder <- folder(stconnectProject,
                           folder = "08 Attributes",
                           parentFolder = landscapeChangeFolder)

# Create & edit sub-scenario
# State values
targetScenario <- edit_subscenario(
  scenarioName = "State Attribute Values",
  scenarioInput = "State Attribute Values.csv",
  scenarioDatasheet = "stsim_StateAttributeValue")
# Move scenario into folder
folderId(targetScenario) <- folderId(attributesFolder)

# Transition values
targetScenario <- edit_subscenario(
  scenarioName = "Transition Attribute Values",
  scenarioInput = "Transition Attribute Values.csv",
  scenarioDatasheet = "stsim_TransitionAttributeValue")
# Move scenario into folder
folderId(targetScenario) <- folderId(attributesFolder)


# 09 Transition Size --------------

# Create nested sub-folder
transitionSizeFolder <- folder(stconnectProject, 
                               folder = "09 Transition Size",
                               parentFolder = landscapeChangeFolder)

# Create & edit sub-scenario
# Datasheet: Distribution
targetScenario <- edit_subscenario(
  scenarioName = "Transition Size",
  scenarioInput = "Transition Size Distribution.csv",
  scenarioDatasheet = "stsim_TransitionSizeDistribution")
# Datasheet: Prioritization 
targetScenario <- edit_subscenario(
  scenarioName = "Transition Size",
  scenarioInput = "Transition Size Prioritization.csv",
  scenarioDatasheet = "stsim_TransitionSizePrioritization")

# Move scenario into folder
folderId(targetScenario) <- folderId(transitionSizeFolder)


# 10 Time Since Transition --------

# Create nested sub-folder
tstFolder <- folder(stconnectProject,
                    folder = "10 Time Since Transition",
                    parentFolder = landscapeChangeFolder)

# Create & edit sub-scenario
# Datasheet: Group
targetScenario <- edit_subscenario(
  scenarioName = "Time Since Transition: 20",
  scenarioInput = "Time Since Transition Group.csv",
  scenarioDatasheet = "stsim_TimeSinceTransitionGroup")
# Datasheet: Randomize
targetScenario <- edit_subscenario(
  scenarioName = "Time Since Transition: 20",
  scenarioInput = "Initial TST Randomize.csv",
  scenarioDatasheet = "stsim_TimeSinceTransitionRandomize")

# Move scenario into folder
folderId(targetScenario) <- folderId(tstFolder)



# 03 Habitat -------------------------------------

# Create nested folder
habitatFolder <- folder(stconnectProject, folder = "03 Habitat",
                        parentFolder = "Sub-Scenarios")


# 01 Habitat Suitability ----------

# Create nested sub-folder
habitatSuitabilityFolder <- folder(stconnectProject, 
                                   folder = "01 Habitat Suitability",
                                   parentFolder = "03 Habitat")

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



# Full scenarios ---------------------------------------------------------------

# Create folder
fullScenarioFolder <- folder(stconnectProject, folder = "Full Scenarios")


# Analysis scenarios -----------------------------

# Create nested folders
analysisFolder <- folder(stconnectProject, folder = "Analysis",
                         parentFolder = fullScenarioFolder)

# Set common dependencies
# NOTE: integers correspond to scenario IDs
coreDependencies <- c(1:4, 7:8, 14:21)

# Agnostic
targetScenario <- create_fullscenario(
  scenarioName = "Agnostic, Historic",
  destinationFolder = analysisFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = c(5,9))
targetScenario <- create_fullscenario(
  scenarioName = "Agnostic, 0.5x Urbanization",
  destinationFolder = analysisFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = c(6,9))

# Zonation
targetScenario <- create_fullscenario(
  scenarioName = "Zonation, Historic",
  destinationFolder = analysisFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = c(5,10))
targetScenario <- create_fullscenario(
  scenarioName = "Zonation, 0.5x Urbanization",
  destinationFolder = analysisFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = c(6,10))

# Prioritizr
targetScenario <- create_fullscenario(
  scenarioName = "Prioritizr, Historic",
  destinationFolder = analysisFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = c(5,11))
targetScenario <- create_fullscenario(
  scenarioName = "Prioritizr, 0.5x Urbanization",
  destinationFolder = analysisFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = c(6,11))

# Pure random
targetScenario <- create_fullscenario(
  scenarioName = "Pure random, Historic",
  destinationFolder = analysisFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = c(5,12))
targetScenario <- create_fullscenario(
  scenarioName = "Pure random, 0.5x Urbanization",
  destinationFolder = analysisFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = c(6,12))

# Aggregated random
targetScenario <- create_fullscenario(
  scenarioName = "Aggregated random, Historic",
  destinationFolder = analysisFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = c(5,13))
targetScenario <- create_fullscenario(
  scenarioName = "Aggregated random, 0.5x Urbanization",
  destinationFolder = analysisFolder,
  dependenciesCore = coreDependencies,
  dependenciesUnique = c(6,13))



# Backup library ---------------------------------------------------------------

# Add output folders to backup
backupDS <- datasheet(stconnectLibrary,
                      name = "core_Backup")
backupDS$IncludeOutput <- TRUE
saveDatasheet(ssimObject = stconnectLibrary, 
              data = backupDS, 
              name = "core_Backup")

# Create backup of current library version
backup(stconnectLibrary)



