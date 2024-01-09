# # 03 Habitat -------------------------------------
# 
# # Create nested folder
# habitatFolder <- folder(stconnectProject, folder = "03 Habitat",
#                         parentFolder = subscenarioFolder)
# 
# 
# # 01 Habitat Suitability ----------
# 
# # Create nested sub-folder
# habitatSuitabilityFolder <- folder(stconnectProject, 
#                                    folder = "01 Habitat Suitability",
#                                    parentFolder = habitatFolder)
# 
# # Create & edit sub-scenario
# targetScenario <- edit_subscenario(
#   scenarioName = "Habitat Suitability: Basic Landcover and Forest Age - 14 species",
#   scenarioInput = "Habitat Suitability.csv",
#   scenarioDatasheet = "stconnect_HSHabitatSuitability")
# 
# # Move scenario into folder
# folderId(targetScenario) <- folderId(habitatSuitabilityFolder)
# 
# 
# # 02 Habitat Patch ----------------
# 
# # Create nested sub-folder
# habitatPatchFolder <- folder(stconnectProject, 
#                                    folder = "02 Habitat Patch",
#                                    parentFolder = habitatFolder)
# 
# # Create & edit sub-scenario
# targetScenario <- edit_subscenario(
#   scenarioName = "Habitat Patch: 14 species",
#   scenarioInput = "Habitat Patch.csv",
#   scenarioDatasheet = "stconnect_HSHabitatPatch")
# 
# # Move scenario into folder
# folderId(targetScenario) <- folderId(habitatPatchFolder)
# 
# 
# 
# # 04 Circuitscape --------------------------------
# 
# # Create nested folder
# circuitscapeFolder <- folder(stconnectProject, folder = "04 Circuitscape",
#                              parentFolder = subscenarioFolder)
# 
# # 01 Resistance -------------------
# 
# # Create nested sub-folder
# resistanceFolder <- folder(stconnectProject,
#                            folder = "01 Resistance",
#                            parentFolder = circuitscapeFolder)
# 
# # Create & edit sub-scenario
# targetScenario <- edit_subscenario(
#   scenarioName = "Resistance: 14 species",
#   scenarioInput = "Resistance.csv",
#   scenarioDatasheet = "stconnect_CCResistance")
# 
# # Move scenario into folder
# folderId(targetScenario) <- folderId(resistanceFolder)