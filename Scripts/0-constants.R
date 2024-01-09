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


