# Plot results

# Load constants
source("Scripts/0-constants.R")

library(ggplot2)



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



# MRC raster
MRCraster <- rast("E:/gitprojects/a311/Libraries/a311-stconnect-deliverable3-15Mar2024.ssim.input/Scenario-4/stsim_InitialConditionsSpatial/secondary_stratum_FocalArea.tif")

# MRC ID
MRCfreq <- freq(MRCraster)
MRClist <- MRCfreq$value[MRCfreq$value != 0 & MRCfreq$value != 373]

# Split MRC into individual rasters
for(MRCid in MRClist){
  
  # Copy original raster
  targetRaster <- MRCraster
  
  # Set all but target ID pixels to NA
  targetRaster[targetRaster != MRCid] <- NA
  #plot(targetRaster)
  
  # Rename raster based on MRC ID
  assign(
    x = paste0("MRC", MRCid),
    value = targetRaster
  )
  
}


# Species names
speciesSet <- datasheet(stconnectProject, "stconnect_Species", includeKey = T)

# Scenario ID
scenarioID <- 32 # Agnostic
scenarioID <- 42 # Clumped random


# Timestep
#timestep <- 2011

#for(scenarioID in scenarioList){

# Open scenario
myScenario <- scenario(ssimObject = stconnectProject, scenario = scenarioID)



# Change in mean number of species per MRC -------------------------------------

# For each species, open habitat map
for(speciesID in 1:14){
  
  # Get species code
  speciesCode <- speciesSet[speciesID, "Code"]
  
  for(i in 1:10){
    
    # Open raster map
    targetRaster <- rast(file.path(
      libraryDir, 
      "a311-stconnect-deliverable3-15Mar2024.ssim.input", 
      paste0("Scenario-", scenarioID), 
      "stconnect_HSOutputHabitatPatch",
      paste0("HabitatPatch.", speciesCode, ".it", i, ".ts2060.tif")))
    
    # Set NA values to 0
    targetRaster[is.na(targetRaster)] <- 0
    
    # Rename raster based on species code
    assign(
      x = paste0(speciesCode, "habitat", i),
      value = targetRaster
    )
    
  }
  
  # Merge habitat across iterations
  targetRaster <- (eval(parse(text = paste0(speciesCode, "habitat", 1))) +
                     eval(parse(text = paste0(speciesCode, "habitat", 2))) +
                     eval(parse(text = paste0(speciesCode, "habitat", 3))) +
                     eval(parse(text = paste0(speciesCode, "habitat", 4))) +
                     eval(parse(text = paste0(speciesCode, "habitat", 5))) +
                     eval(parse(text = paste0(speciesCode, "habitat", 6))) +
                     eval(parse(text = paste0(speciesCode, "habitat", 7))) +
                     eval(parse(text = paste0(speciesCode, "habitat", 8))) +
                     eval(parse(text = paste0(speciesCode, "habitat", 9))) +
                     eval(parse(text = paste0(speciesCode, "habitat", 10))))
  
  # Divide by number of iterations
  targetRaster <- targetRaster/10
  
  # Rename raster based on species code
  assign(
    x = paste0(speciesCode, "habitat"),
    value = targetRaster
  )
  
}

# Merge habitat across species
habitatPatch <- (RASYhabitat + ODVIhabitat + PELEhabitat + LEAMhabitat + 
                   BLBRhabitat + SICAhabitat + PLCIhabitat + DRPIhabitat + SEAUhabitat +
                   URAMhabitat + STVAhabitat + SCMIhabitat + BUAMhabitat + MAAMhabitat)
#plot(habitatPatch)

# Calculate mean per MRC
for(MRCid in MRClist){
  
  # Mask probability map to MRC
  targetRaster <- mask(habitatPatch, 
                       eval(parse(text = paste0("MRC", MRCid))))
  #plot(targetRaster)
  
  # Calculate mean in area
  meanValue <- mean(targetRaster[,], na.rm = TRUE)
  # Calculate standard deviation
  sdValue <- sd(targetRaster[,], na.rm = TRUE)
  
  # Set all values to mean probability
  targetRaster[!is.na(targetRaster)] <- meanValue
  
  # Set all NA values to 0
  targetRaster[is.na(targetRaster)] <- 0
  
  # Rename raster based on species code
  assign(
    x = paste0("meanMRC", MRCid),
    value = targetRaster
  )
  
}

meanMRC2011 <- meanMRC46 + meanMRC47 + meanMRC48 + meanMRC53 + meanMRC54 + 
                  meanMRC55 + meanMRC56 + meanMRC57 + meanMRC58 + meanMRC59 + 
                  meanMRC67 + meanMRC68 + meanMRC69 + meanMRC70 + meanMRC71
#plot(meanMRC2011)
meanMRC2060 <- meanMRC46 + meanMRC47 + meanMRC48 + meanMRC53 + meanMRC54 + 
              meanMRC55 + meanMRC56 + meanMRC57 + meanMRC58 + meanMRC59 + 
              meanMRC67 + meanMRC68 + meanMRC69 + meanMRC70 + meanMRC71
#plot(meanMRC2060)

meanMRCdiff <- meanMRC2060 - meanMRC2011
#plot(meanMRCdiff)

# Mask
meanMRC2011_masked <- mask(meanMRC2011, MRCraster)
meanMRC2060_masked <- mask(meanMRC2060, MRCraster)
meanMRCdiff_masked <- mask(meanMRCdiff, MRCraster)

# Write raster with NA flag
writeRaster(meanMRC2011_masked,
            file.path(intermediatesDir,
                      "meanMRC2011_agnostic.tif"),
            NAflag = -9999, datatype = "FLT8S", overwrite = TRUE)
writeRaster(meanMRC2060_masked,
            file.path(intermediatesDir,
                      "meanMRC2060_agnostic.tif"),
            NAflag = -9999, datatype = "FLT8S", overwrite = TRUE)
writeRaster(meanMRCdiff_masked,
            file.path(intermediatesDir,
                      "meanMRCdiff_agnostic.tif"),
            NAflag = -9999, datatype = "FLT8S", overwrite = TRUE)

#}



# Change in mean current density per MRC ---------------------------------------

# For each species, open circuit current map
for(speciesID in 1:14){
  
  # Get species code
  speciesCode <- speciesSet[speciesID, "Code"]
  
  for(i in 1:10){
    
    # Open raster map
    targetRaster <- rast(file.path(
      libraryDir, 
      "a311-stconnect-deliverable3-15Mar2024.ssim.input", 
      paste0("Scenario-", scenarioID), 
      "stconnect_CCOutputCumulativeCurrent",
      paste0("cum_curmap.", speciesCode, ".it", i, ".ts2011.tif")))
    
    # Rename raster based on species code
    assign(
      x = paste0(speciesCode, "connectivity", i),
      value = targetRaster
    )
    
  }
  
  # Calculate mean across iterations
  targetRaster <- mean(
    c(eval(parse(text = paste0(speciesCode, "connectivity", 1))),
    eval(parse(text = paste0(speciesCode, "connectivity", 2))),
    eval(parse(text = paste0(speciesCode, "connectivity", 3))),
    eval(parse(text = paste0(speciesCode, "connectivity", 4))),
    eval(parse(text = paste0(speciesCode, "connectivity", 5))),
    eval(parse(text = paste0(speciesCode, "connectivity", 6))),
    eval(parse(text = paste0(speciesCode, "connectivity", 7))),
    eval(parse(text = paste0(speciesCode, "connectivity", 8))),
    eval(parse(text = paste0(speciesCode, "connectivity", 9))),
    eval(parse(text = paste0(speciesCode, "connectivity", 10)))))
  
  # Rename raster based on species code
  assign(
    x = paste0(speciesCode, "connectivity"),
    value = targetRaster
  )
  
}

# Calculate mean across species
sppConnectivity <- mean(
  c(RASYconnectivity, ODVIconnectivity, PELEconnectivity, LEAMconnectivity, 
    BLBRconnectivity, SICAconnectivity, PLCIconnectivity, DRPIconnectivity, 
    SEAUconnectivity, URAMconnectivity, STVAconnectivity, SCMIconnectivity, 
    BUAMconnectivity, MAAMconnectivity))
#plot(sppConnectivity)

# Calculate mean per MRC
for(MRCid in MRClist){
  
  # Mask probability map to MRC
  targetRaster <- mask(sppConnectivity, 
                       eval(parse(text = paste0("MRC", MRCid))))
  #plot(targetRaster)
  
  # Calculate mean in area
  meanValue <- mean(targetRaster[,], na.rm = TRUE)
  
  # Set all values to mean probability
  targetRaster[!is.na(targetRaster)] <- meanValue
  
  # Set all NA values to 0
  targetRaster[is.na(targetRaster)] <- 0
  
  # Rename raster based on species code
  assign(
    x = paste0("meanMRC", MRCid),
    value = targetRaster
  )
  
}

meanMRC2011 <- c(meanMRC46 + meanMRC47 + meanMRC48 + meanMRC53 + meanMRC54 + 
                 meanMRC55 + meanMRC56 + meanMRC57 + meanMRC58 + meanMRC59 + 
                 meanMRC67 + meanMRC68 + meanMRC69 + meanMRC70 + meanMRC71)
#plot(meanMRC2011)
meanMRC2060 <- c(meanMRC46 + meanMRC47 + meanMRC48 + meanMRC53 + meanMRC54 + 
                 meanMRC55 + meanMRC56 + meanMRC57 + meanMRC58 + meanMRC59 + 
                 meanMRC67 + meanMRC68 + meanMRC69 + meanMRC70 + meanMRC71)
#plot(meanMRC2060)


meanMRCdiff <- ((meanMRC2060*100)/meanMRC2011)-100
#plot(meanMRCdiff)

# Mask
meanMRC2011_masked <- mask(meanMRC2011, MRCraster)
meanMRC2060_masked <- mask(meanMRC2060, MRCraster)
meanMRCdiff_masked <- mask(meanMRCdiff, MRCraster)

# Write raster with NA flag
writeRaster(meanMRC2011_masked,
            file.path(intermediatesDir,
                      "connectivityPerMRC_2011.tif"),
            NAflag = -9999, datatype = "FLT4S", overwrite = TRUE)
writeRaster(meanMRC2060_masked,
            file.path(intermediatesDir,
                      "connectivityPerMRC_2060_clumpedRandom.tif"),
            NAflag = -9999, datatype = "FLT4S", overwrite = TRUE)
writeRaster(meanMRCdiff_masked,
            file.path(intermediatesDir,
                      "connectivityPerMRC_diff_clumpedRandom.tif"),
            NAflag = -9999, datatype = "FLT4S", overwrite = TRUE)

#}