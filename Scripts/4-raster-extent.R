## a295
## Carina Rauen Firkowski 
## January 09, 2024
##
## This script fixes the spatial extent of input raster files, so that the 
## transtion spatial multiplier files match the initial conditions files.



# Load constants
source("Scripts/0-constants.R")



# Load spatial data ------------------------------------------------------------

# Template raster
templateRaster <- rast(file.path(libraryInputsDir, "Initial Conditions Spatial",
                                 "primary_stratum_FocalArea.tif"))

# Raster files to be updated
agnosticRaster <- rast(file.path(libraryInputsDir, "Transition Spatial Multiplier",
                                 "spatialMultiplier_agnostic.tif"))
zonationRaster <- rast(file.path(libraryInputsDir, "Transition Spatial Multiplier",
                                 "spatialMultiplier_zonation.tif"))
prioritizrRaster <- rast(file.path(libraryInputsDir, "Transition Spatial Multiplier",
                                 "spatialMultiplier_prioritizr.tif"))



# Project to template raster extent --------------------------------------------

agnosticUpdated <- terra::project(agnosticRaster, templateRaster)
zonationUpdated <- terra::project(zonationRaster, templateRaster)
prioritizrUpdated <- terra::project(prioritizrRaster, templateRaster)



# Save to file -----------------------------------------------------------------

writeRaster(agnosticUpdated,
            filename = file.path(libraryInputsDir, "Transition Spatial Multiplier",
                                 "spatialMultiplier_agnostic_extent.tif"))
writeRaster(zonationUpdated,
            filename = file.path(libraryInputsDir, "Transition Spatial Multiplier",
                                 "spatialMultiplier_zonation_extent.tif"))
writeRaster(prioritizrUpdated,
            filename = file.path(libraryInputsDir, "Transition Spatial Multiplier",
                                 "spatialMultiplier_prioritizr_extent.tif"))




