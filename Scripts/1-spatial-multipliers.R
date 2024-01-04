## a311
## Carina Rauen Firkowski
## December 11, 2023
##
## This script transforms raster maps of the selected prioritization approaches
## into transition spatial multipliers (i.e., binary maps), where pixels 
## identified by the prioritization approach and within protected areas receive
## a value 0, and all other pixels receive a value of 1.



# Load constants
source("Scripts/0-constants.R")



# Load spatial data ------------------------------------------------------------

# Protected areas
PA <- rast(file.path(spatialDataDir, "Protected Areas",
                     "protectedAreasTerrestrial_FocalArea.tif"))

# Prioritization approaches
agnostic <- rast(file.path(spatialDataDir, "Prioritization Approaches",
                           "Generic-Resistance0.05.tif"))
zonation <- rast(file.path(spatialDataDir, "Prioritization Approaches",
                           "CAZ_Density_0.05.tif"))
prioritizr <- rast(file.path(spatialDataDir, "Prioritization Approaches",
                             "Maximum-Utility-Species-Density0.05.tif"))

# Focal area
studyArea <- st_read(dsn = file.path(spatialDataDir, "Study Area"),
                     layer = "regio_s") %>%
  st_transform(crs(PA))



# Create binary maps -----------------------------------------------------------

# Set Montérégie as focal area
focalArea <- studyArea[studyArea$RES_NM_REG == "Montérégie",]

# Resample PA raster to match extent
PAextent <- PA %>% 
  resample(agnostic, method = "near")

# Set PA pixels to 0
PAcopy <- PAextent
PAcopy[PAextent == 1] <- 0
PAcopy[is.na(PAextent)] <- 1

# Mask PA to focal area
PAmultiplier <- PAcopy %>%
  mask(focalArea) %>%
  crop(focalArea)

# Function to reclassify prioritization raster
reclassifyApproaches <- function(prioritizationRaster) {
  
  # Create copy of raster
  rasterCopy <- prioritizationRaster
  
  # Set prioritization pixels to 0
  rasterCopy[prioritizationRaster == 1] <- 0
  # Set non-prioritization pixels to 1
  rasterCopy[prioritizationRaster == 0] <- 1
  # Set NA values within focal area to 1
  rasterCopy[is.na(rasterCopy)] <- 1
  
  # Mask to focal area
  MSCmultiplier <- rasterCopy %>%
    mask(focalArea) %>%
    crop(focalArea)
  
  return(MSCmultiplier)
}

# Calculate transition spatial multiplier
agnosticMultiplier <- reclassifyApproaches(agnostic)
zonationMultiplier <- reclassifyApproaches(zonation)
prioritizrMultiplier <- reclassifyApproaches(prioritizr)

# Combine MSC and PA multipliers
agnosticPAmultiplier <- agnosticMultiplier + PAmultiplier
zonationPAmultiplier <- zonationMultiplier + PAmultiplier
prioritizrPAmultiplier <- prioritizrMultiplier + PAmultiplier

# Set prioritization pixels to 0
agnosticPAmultiplier[agnosticPAmultiplier == 1] <- 0
zonationPAmultiplier[zonationPAmultiplier == 1] <- 0
prioritizrPAmultiplier[prioritizrPAmultiplier == 1] <- 0
# Set non-prioritization pixels to 1
agnosticPAmultiplier[agnosticPAmultiplier == 2] <- 1
zonationPAmultiplier[zonationPAmultiplier == 2] <- 1
prioritizrPAmultiplier[prioritizrPAmultiplier == 2] <- 1


# Save outputs -----------------------------------------------------------------

writeRaster(agnosticPAmultiplier, 
            file.path(intermediatesDir, "Spatial Multipliers", 
                      "spatialMultiplier_agnostic.tif"), 
            overwrite = TRUE)
writeRaster(zonationPAmultiplier, 
            file.path(intermediatesDir, "Spatial Multipliers", 
                      "spatialMultiplier_zonation.tif"), 
            overwrite = TRUE)
writeRaster(prioritizrPAmultiplier, 
            file.path(intermediatesDir, "Spatial Multipliers", 
                      "spatialMultiplier_prioritizr.tif"), 
            overwrite = TRUE)


