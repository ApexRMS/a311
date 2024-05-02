## a311
## Carina Rauen Firkowski 
## February 29, 2024
##
## This script generates a purely random PA network by randomly placing 
## protected area cells in unprotected natural areas until 5% of landscape is 
## protected.



# Load constants
source("Scripts/0-constants.R")

library(landscapeR)



# Setup workspace --------------------------------------------------------------

# Load spatial data
currentLULC <- rast(file.path(libraryInputsDir,
                              "Initial Conditions Spatial",
                              "stateclasses_FocalArea.tif"))
PAraster <- rast(file.path(spatialDataDir, "Protected Areas",
                           "protectedAreasTerrestrial_FocalArea.tif"))
agnosticRaster <- rast(file.path(libraryInputsDir, 
                                 "Transition Spatial Multiplier",
                                 "spatialMultiplier_agnostic_extent.tif"))
zonationRaster <- rast(file.path(libraryInputsDir, 
                                 "Transition Spatial Multiplier",
                                 "spatialMultiplier_zonation_extent.tif"))
prioritizrRaster <- rast(file.path(libraryInputsDir, 
                                   "Transition Spatial Multiplier",
                                   "spatialMultiplier_prioritizr_extent.tif"))



# Prepare random PA network canvas ---------------------------------------------

# Project PA raster to target extent
PArasterExtent <- terra::project(PAraster, currentLULC)

# Merge LULC and PA maps
LULCandPA <- merge(PArasterExtent, currentLULC)

# Get total amount of landscape cells
totalFreq <- freq(LULCandPA)
totalCells <- sum(totalFreq$count)
PAfreq <- freq(PArasterExtent)

# Number of cells corresponding to 5% of natural areas cells
maxPAcells <- numberCellsToKeep <- round((totalCells * 0.05), digits = 0) - PAfreq$count

# Set to NA all protected and non-natural areas
reclassTable <- matrix(c(1, NA,    # PA
                         100, NA,  # Agriculture
                         400, NA,  # Urban
                         410, NA,  # Road
                         511, 1,      # Deciduous forest
                         512, 1,
                         513, 1,
                         521, 1,      # Mixed forest
                         522, 1,
                         523, 1,
                         531, 1,      # Coniferous forest
                         532, 1,
                         533, 1,
                         700, NA,   # Water
                         800, 1,      # Open wetland
                         810, 1       # Forested wetland
), ncol = 2, byrow = TRUE)
naturalAreas <- randomPAraster <- classify(LULCandPA, reclassTable)

# Remove NAs from PA raster
PArasterNoNA <- PArasterExtent
PArasterNoNA[is.na(PArasterNoNA)] <- 0
PArasterNoNA <- mask(PArasterNoNA, LULCandPA)

# Generate purely random PA network --------------------------------------------

for(i in 1:10){
  
  # Start PA raster
  randomPAraster <- classify(LULCandPA, reclassTable)
  
  # Get ID of natural cells to keep
  naturalAreasVector <- randomCells <- cells(naturalAreas)
  
  # Sample random cells to keep
  cellsToKeep <- sample(naturalAreasVector, numberCellsToKeep)
  
  # Set cells to remove to NA in vector
  randomCells[!(randomCells %in% cellsToKeep)] <- NA
  randomPAcells <- randomCells %>%
    as.data.frame() %>%
    filter(!is.na(.))
  
  # Set PA to 2 and everything else to 1
  randomPAraster[randomPAcells] <- 2
  randomPAraster[randomPAraster != 2] <- 1
  randomPAraster[is.na(randomPAraster)] <- 1
  #plot(randomPAraster)
  
  # Mask to study area
  randomPAstudy <- mask(randomPAraster, LULCandPA)
  #plot(randomPAstudy)
  
  # Merge with PA map
  randomAndPA <- randomPAstudy + PArasterNoNA
  #plot(randomAndPA)
  
  # Set PA to 0
  randomApproach <- randomAndPA
  randomApproach[randomApproach == 2] <- 0
  #plot(randomApproach)
  
  # Project to target extent
  randomApproachUpdated <- terra::project(randomApproach, currentLULC)
  #plot(randomApproachUpdated)
  #freq(randomApproachUpdated)
  
  # Write to file
  writeRaster(randomApproachUpdated, datatype = "INT1U",
              filename = file.path(
                intermediatesDir, "Spatial Multipliers",
                paste0("spatialMultiplier_pure_random_it", i, ".tif")),
              overwrite = TRUE, datatype = "INT1U")
}



# Generate patchy random PA network --------------------------------------------

# Invert raster (i.e., set 0 to 1 and 1 to 0)
agnosticPA <- classify(agnosticRaster, matrix(c(1, 0,
                                                0, 1), ncol = 2, byrow = TRUE))
zonationPA <- classify(zonationRaster, matrix(c(1, 0,
                                                0, 1), ncol = 2, byrow = TRUE))
prioritizrPA <- classify(prioritizrRaster, matrix(c(1, 0,
                                                    0, 1), ncol = 2, byrow = TRUE))

# Exclude existing PA
agnosticPA[agnosticPA == PArasterExtent] <- 0
zonationPA[zonationPA == PArasterExtent] <- 0
prioritizrPA[prioritizrPA == PArasterExtent] <- 0

# Detect unique patches
agnosticPatches <- patches(agnosticPA, zeroAsNA = TRUE, directions = 8)
zonationPatches <- patches(zonationPA, zeroAsNA = TRUE, directions = 8)
prioritizrPatches <- patches(prioritizrPA, zeroAsNA = TRUE, directions = 8)

# Get distribution of patch sizes 
agnosticFreq <- freq(agnosticPatches)
zonationFreq <- freq(zonationPatches)
prioritizrFreq <- freq(prioritizrPatches)
PAdistribution <- c(agnosticFreq$count, 
                    zonationFreq$count, 
                    prioritizrFreq$count)
#hist(log(prioritizrFreq$count))

# Get mean number of patches
numberPatches <- mean(c(dim(agnosticFreq)[1], dim(zonationFreq)[1], dim(prioritizrFreq)[1]))

# Generate an aggregated random landscape for each iteration
for(i in 1:10){
  
  startTime <- Sys.time()
  
  # Pick random patch sizes from distribution
  patchSize <- 0
  while(sum(patchSize) == 0 | sum(patchSize) > 48000){
    patchSize <- sample(x = PAdistribution, size = round(numberPatches))
  }
  
  # Load empty target raster for PA
  patchyRandomPA <- raster::raster(file.path(intermediatesDir,
                                             "candidatePAcells.tif"))
  
  # Starting number of PA cells
  PAcells <- 0
  
  # Create a new patch for each patch size
  for(ps in patchSize){
    
    # Check if enough pixels are available in its surroundings
    condition <- TRUE
    while(isTRUE(condition)){
      
      # Update list of cell IDs for available natural areas
      PAcellsMask <- rast(patchyRandomPA)
      PAcellsMask[PAcellsMask == 2] <- NA
      naturalPixelsID <- cells(PAcellsMask)
      
      # Pick random natural pixel to seed a new patch
      firstCell <- sample(naturalPixelsID, 1)
      
      # Test function with target seed and patch size
      condition <- tryCatch(
        expr = { 
          # Create and grow patch
          patchyRandomPA <- makeClass(patchyRandomPA, 
                                      npatch = 1, size = ps, 
                                      pts = firstCell, bgr = 1, val = 2)
        },
        error = function(cond) { 
          message("An error occured")
          TRUE },
        warning = function(cond) {
          message("A warning occured")
          TRUE }
        
      ) # end tryCatch
    } # end while
    
    PAcells <- PAcells + ps
    cat(paste0(PAcells, " "))
    
  } # end patchSize
  
  # Remove NAs
  patchyRandomPA[is.na(patchyRandomPA)] <- 0
  
  # Set non-PA cells to 0
  patchyRandomPAraster <- classify(rast(patchyRandomPA), 
                                   matrix(c(1, 0), ncol = 2, byrow = TRUE))
  
  # Combine with existing PA
  patchyAndPA <- patchyRandomPAraster + PAraster
  patchyRandomPAraster <- mask(patchyAndPA, LULCandPA)
  
  # Set PA 0 and everything else to 1
  patchyRandomPAraster <- classify(patchyRandomPAraster, 
                                   matrix(c(0, 1,
                                            1, 0,
                                            2, 0), ncol = 2, byrow = TRUE))
  
  plot(patchyRandomPAraster)
  freq(patchyRandomPAraster)
  
  # Save iteration raster to file
  writeRaster(patchyRandomPAraster, 
              file = file.path(intermediatesDir, "Spatial Multipliers",
                               paste0("aggregated_random_it", i, ".tif")),
              overwrite = TRUE, datatype = "INT1U")
  
  endTime <- Sys.time()
  cat(endTime - startTime)
  
}

# Invert raster (i.e., set 0 to 1 and 1 to 0)
PArasterInv <- classify(patchyRandomPAraster, 
                        matrix(c(1, 0,
                                 0, 1), ncol = 2, byrow = TRUE))

# Detect patches
randomPatches <- patches(PArasterInv, zeroAsNA = TRUE)

# Get distribution of patch sizes 
randomFreq <- freq(randomPatches)
hist(log(randomFreq$count))

listAmount <- data.frame(Iteration = as.numeric(),
                         Amount = as.numeric())


# Get range for percentage of landscape under protection for clumped random ----

for(i in 1:10){
  openRaster <- rast(file.path(intermediatesDir, "Spatial Multipliers",
                               paste0("aggregated_random_it", i, ".tif")))
  rasterFreq <- freq(openRaster)
  PAamount <- (rasterFreq$count[rasterFreq$value == 0]/
                 (rasterFreq$count[rasterFreq$value == 0]+
                    rasterFreq$count[rasterFreq$value == 1]))*100
  newRow <- data.frame(Iteration = i,
                       Amount = round(PAamount, 1))
  listAmount <- rbind(listAmount, newRow)
  
  projectedRaster <- terra::project(openRaster, currentLULC)
  
  # Save iteration raster to file
  writeRaster(projectedRaster, 
              file = file.path(intermediatesDir, "Spatial Multipliers",
                               paste0("spatialMultiplier_aggregated_random_it", i, ".tif")),
              overwrite = TRUE, datatype = "INT1U")
}



# Fix raster extent for clumped random -----------------------------------------

for(i in 1:10){
  openRaster <- rast(file.path(intermediatesDir, "Spatial Multipliers",
                               paste0("aggregated_random_it", i, ".tif")))
  
  projectedRaster <- terra::project(openRaster, currentLULC)
  
  writeRaster(projectedRaster, 
              file = file.path(intermediatesDir, "Spatial Multipliers",
                               paste0("spatialMultiplier_aggregated_random_it", i, ".tif")),
              overwrite = TRUE, datatype = "INT1U")
}




#############
# test code #
#############

# NOTE: Takes too long to run

# Starting number of PA cells
PAcells <- 0
# Starting PA raster
patchyRandomPA <- classify(LULCandPA, reclassTable)
# Starting distribution
PAdistributionIteration <- PAdistribution
# writeRaster(patchyRandomPA, filename = file.path(intermediatesDir,
#                                                  "candidatePAcells.tif"),
#             datatype = "INT1U")

patchyRandomPA <- raster::raster(file.path(intermediatesDir,
                                           "candidatePAcells.tif"))

# Run loop until 5% of the landscape is protected
while(PAcells <= maxPAcells){
  
  # Pick random number for patch size
  patchSize <- sample(x = PAdistributionIteration, size = 1)
  
  # Remove patch size number from distribution
  IDtoRemove <- match(patchSize, PAdistributionIteration)
  PAdistributionIteration <- PAdistributionIteration[-IDtoRemove]
  
  # Check if selected patch size is <= to max. number of PA cells
  #if(PAcells + patchSize <= maxPAcells){
  
  # Pick random natural pixel for patch starting location
  firstCell <- sample(naturalPixelsID, 1)
  # Remove cell from list
  naturalPixelsID <- naturalPixelsID[-(match(firstCell, naturalPixelsID))]
  
  # Check if seed point is valid
  if(patchyRandomPA[firstCell] != 2){
    
    # Create and grow patch
    patchyRandomPA <- makeClass(patchyRandomPA, 
                                npatch = 1, size = patchSize, 
                                pts = firstCell, bgr = 1, val = 2)
    #plot(patchyRandomPA)
    
    # Update number of PA cells
    PAfreq <- as.data.frame(raster::freq(patchyRandomPA, useNA = "no"))
    PAcells <- PAfreq$count[PAfreq$value == 2]
    
    cat(PAcells)
    #} else { next }
    
  } else { next }
  
}

#raster::plot(patchyRandomPA)

# Set non-PA cells to 0 and PA to 1
patchyRandomPAraster <- classify(rast(patchyRandomPA), 
                                 matrix(c(2, 0), ncol = 2))
patchyRandomPAraster[is.na(patchyRandomPAraster)] <- 1
patchyRandomPAraster2 <- mask(patchyRandomPAraster, LULCandPA)

