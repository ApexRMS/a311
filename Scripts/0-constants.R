## a311
## Carina Rauen Firkowski
## December 11, 2023
##
## This script is used to define constants and load necessary functions in a
## reproducible way across scripts.



# Workspace -------------------------------------------------------------------

# Load packages
library(terra)
library(sf)
library(tidyverse)
library(rsyncrosim)




# Directories ------------------------------------------------------------------

# Core directories
rootDir <- "."
dataDir <- file.path(rootDir, "Data")
intermediatesDir <- file.path(rootDir, "Intermediates")
outputDir <- file.path(rootDir, "Outputs")
libraryDir <- file.path(rootDir, "Libraries")

# Composite directories
tabularDataDir <- file.path(dataDir, "Tabular")
spatialDataDir <- file.path(dataDir, "Spatial")
libraryInputsDir <- file.path(libraryDir, "Inputs", "stconnect v1.1.20")



# Functions --------------------------------------------------------------------

# Create or update sub-scenarios
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

# Create scenario and set dependencies
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

