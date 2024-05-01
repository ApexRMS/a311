## a311
## Carina Rauen Firkowski 
## April 16, 2024
##
## This script creates the spatial plots of the difference in habitat amount and
## connectivity across MRC and between current and projected conditions (Fig. 4).

## This script also creates a tabular summary of habitat and connectivity per MRC
## and per scenario (see line 75).


# Set working directory
setwd("E:/gitprojects/a311")

# Load constants
source("Scripts/0-constants.R")

# Load additional library
library(ggplot2)



# ST-Connect Library -----------------------------------------------------------

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



# MRC --------------------------------------------------------------------------

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
  
  # Rename raster based on MRC ID
  assign(
    x = paste0("MRC", MRCid),
    value = targetRaster
  )
  
}



# Parameters -------------------------------------------------------------------

# Species names
speciesSet <- datasheet(stconnectProject, "stconnect_Species", includeKey = T)

# Scenario ID
#scenarioList <- c(32, 34, 36, 38, 42)

scenarioID <- 32

# Empty dataframe for summary statistics
habitatSummary <- data.frame(Scenario = as.character(), 
                             Period = as.numeric(),
                             MRC = as.numeric(), 
                             Mean = as.numeric(), 
                             SD = as.numeric())
connectivitySummary <- data.frame(Scenario = as.character(), 
                                  Period = as.numeric(),
                                  MRC = as.numeric(), 
                                  Mean = as.numeric(), 
                                  SD = as.numeric())



# Summarize habitat probability ------------------------------------------------

for(scenarioID in scenarioList){
  
  cat(paste0(scenarioID, " "))
  
  # Open scenario
  myScenario <- scenario(ssimObject = stconnectProject, scenario = scenarioID)
    
  # Get scenario name
  scenarioName <- name(myScenario)
  
  # Step 1. Obtain summed maps across species ------ 
  #         for each iteration and timestep
  
  for(timestep in c(2011, 2060)){
    
      if(timestep == 2011 & scenarioID == 32 | timestep == 2060){
        
        # For each iteration, sum habitat maps across species
        for(i in 1:10){
          
          # Get habitat maps for each species
          for(speciesID in 1:14){
            
            # Get species code
            speciesCode <- speciesSet[speciesID, "Code"]
            
            # Open habitat raster map
            targetRaster <- rast(file.path(
              libraryDir, 
              "a311-stconnect-deliverable3-15Mar2024.ssim.input", 
              paste0("Scenario-", scenarioID), 
              "stconnect_HSOutputHabitatPatch",
              paste0("HabitatPatch.", speciesCode, ".it", i, ".ts", timestep, ".tif")))
            
            # Set NA values to 0
            targetRaster[is.na(targetRaster)] <- 0
            
            # Rename raster based on MRC, species code & iteration
            assign(
              x = paste0("spp_it_habitat", timestep, "_it", i, "_spp", speciesCode),
              value = targetRaster
            )
            
          } # end species
          
          # Get list of maps for the target iteration and all species 
          targetList <- mget(ls(pattern = paste0("spp_it_habitat", timestep, "_it", i, "_spp*")))
          
          # Stack species maps
          sppHabitatStack <- sprc(targetList)
          
          # Sum across species
          sppHabitatSum <- mosaic(sppHabitatStack, fun = "sum")
          
          # Rename raster based on MRC & iteration
          assign(
            x = paste0("it_habitat", timestep, "_it", i),
            value = sppHabitatSum
          )
          
          # Clear environment
          rm(list = names(targetList))
          
        } # end iterations
        
      } # end if
      
    } # end year
    
    
    
    # Step 2. Mask each summed habitat map to --------
    #         each MRC & calculate difference 
    #         between timesteps
    
    for(MRCid in MRClist){
          
      # For each iteration, mask summed habitat map to MRC and calculate difference
      for(i in 1:10){
            
        # Mask summed habitat map to MRC
        if(scenarioID == 32){
          targetRaster2011 <- mask(eval(parse(text = paste0("it_habitat2011", "_it", i))), 
                                   eval(parse(text = paste0("MRC", MRCid))))
          assign(
            x = paste0("mrc_it_habitat2011", "_mrc", MRCid, "_it", i),
            value = targetRaster2011
          )
        }
        targetRaster2060 <- mask(eval(parse(text = paste0("it_habitat2060", "_it", i))), 
                                 eval(parse(text = paste0("MRC", MRCid))))
        assign(
          x = paste0("mrc_it_habitat2060", "_mrc", MRCid, "_it", i),
          value = targetRaster2060
        )
        
        # Calculate difference
        targetRasterDiff <- targetRaster2060 - eval(parse(text = paste0("mrc_it_habitat2011", "_mrc", MRCid, "_it", i)))
          
        # Rename raster based on MRC & iteration
        assign(
          x = paste0("mrc_it_habitatDiff", "_mrc", MRCid, "_it", i),
          value = targetRasterDiff
        )
            
      } # end iterations
      
    } # end MRC
      
    
    
    # Step 3. Extract cell values for each MRC, ------
    #         calculate mean and s.d., & merge
    #         mean MRC maps per period 
    
    # For each period, calculate statistics across iterations
    for(periodName in c("2060", "Diff")){       # "2011"
        
      for(MRCid in MRClist){
        
        # Get list of MRC summed habitat maps for all iterations
        itMRCHabitatList <-  mget(ls(pattern = paste0("mrc_it_habitat", periodName, "_mrc", MRCid))) 
        
        # Create empty vector to receive cell values
        rasterValues <- as.numeric()
        
        # Get MRC area
        templateMRC <- eval(parse(text = paste0("MRC", MRCid)))
        
        # For each map in list
        for(i in 1:10){
          
          # Get map
          targetRaster <- itMRCHabitatList[[i]]
          
          # Mask to MRC area
          targetRaster_masked <- mask(targetRaster, templateMRC)
          
          # Get values
          singleValues <- targetRaster_masked[,]
          
          # Remove NAs
          singleValues <- singleValues[!is.na(singleValues)]
          
          # Save to vector
          rasterValues <- c(rasterValues, singleValues)
          
        } # end maps in list
        
        # Remove 0s
        #rasterValues <- rasterValues[rasterValues != 0]
        
        # Calculate mean in area
        meanValue <- mean(rasterValues)
        sdValue <- sd(rasterValues)
        
        # Add entry to table
        summaryValues <- data.frame(Scenario = scenarioName, 
                                    Period = periodName,
                                    MRC = MRCid, 
                                    Mean = meanValue, 
                                    SD = sdValue)
        habitatSummary <- rbind(habitatSummary, summaryValues)
        
        # Set all values to mean probability
        templateMRC[!is.na(templateMRC)] <- meanValue
        
        # Set all NA values to 0
        templateMRC[is.na(templateMRC)] <- 0
        
        # Rename raster based on MRC and period
        assign(
          x = paste0("meanSingleMRC", MRCid),
          value = templateMRC
        )
        
      } # end MRC
      
      # Get list of mean per MRC maps
      meanMRCHabitatList <-  mget(ls(pattern = "meanSingleMRC")) 
      
      # Stack mean MRC maps
      meanMRCStack <- sprc(meanMRCHabitatList)
      
      # Sum across species
      meanMRCSum <- mosaic(meanMRCStack, fun = "sum")
      
      # Mask to study area
      meanMRCSum_masked <- mask(meanMRCSum, MRCraster)
      
      # Rename raster based on MRC & iteration
      assign(
        x = paste0("meanMRC", periodName),
        value = meanMRCSum_masked
      )
      
    } # end period
  
} # end scenario

# Write raster with NA flag
writeRaster(meanMRC2011,
            file.path(intermediatesDir,
                      "meanMRC2011_noZeros_agnostic.tif"),
            NAflag = -9999, datatype = "FLT8S", overwrite = TRUE)
writeRaster(meanMRC2060,
            file.path(intermediatesDir,
                      "meanMRC2060_noZeros_agnostic.tif"),
            NAflag = -9999, datatype = "FLT8S", overwrite = TRUE)
writeRaster(meanMRCDiff,
            file.path(intermediatesDir,
                      "meanMRCDiff_noZeros_agnostic.tif"),
            NAflag = -9999, datatype = "FLT8S", overwrite = TRUE)

# Save summary statistic
write.csv(habitatSummary, file = file.path(intermediatesDir, "habitatSummary-all.csv"))



# Change in mean current density per MRC ---------------------------------------

for(scenarioID in scenarioList){
  
  cat(paste0(scenarioID, " "))
  
  # Open scenario
  myScenario <- scenario(ssimObject = stconnectProject, scenario = scenarioID)
  
  # Get scenario name
  scenarioName <- name(myScenario)
  
  # Step 1. Obtain connectivity maps for ------ 
  #         each timestep, iteration and species
      
  # For each iteration, ...
  for(i in 1:10){
        
    # ... for each species, ...
    for(speciesID in 1:14){
      
      # ... and each timestep, get connectivity map
      for(timestep in c(2011, 2060)){
        
        if(timestep == 2011 & scenarioID == 32 | timestep == 2060){
          
          # Get species code
          speciesCode <- speciesSet[speciesID, "Code"]
          
          # Open raster map
          targetRaster <- rast(file.path(
            libraryDir, 
            "a311-stconnect-deliverable3-15Mar2024.ssim.input", 
            paste0("Scenario-", scenarioID), 
            "stconnect_CCOutputCumulativeCurrent",
            paste0("cum_curmap.", speciesCode, ".it", i, ".ts", timestep, ".tif")))
          
          # Rename raster based on species code
          assign(
            x = paste0("spp_it_connectivity", timestep, "_it", i, "_spp", speciesCode),
            value = targetRaster
          )
        
        } # end if
        
      } # end timestep
      
      # Get maps for each timestep
      targetRaster2011 <- eval(parse(text = paste0("spp_it_connectivity2011", "_it", i, "_spp", speciesCode)))
      targetRaster2060 <- eval(parse(text = paste0("spp_it_connectivity2060", "_it", i, "_spp", speciesCode)))

      # Calculate % difference
      #targetRasterDiff <- ((targetRaster2060*100)/ targetRaster2011) - 100
      # Calculate difference
      targetRasterDiff <- targetRaster2060 - targetRaster2011
      
      # Rename raster based on iteration & species
      assign(
        x = paste0("spp_it_connectivityDiff", "_it", i, "_spp", speciesCode),
        value = targetRasterDiff
      )
      
    } # end species
    
  } # end iteration
  
  
  
  # Step 2. Mask to each MRC and calculate --------
  #         summary statistics
  
  # For each period, calculate statistics across species and iterations
  for(periodName in c("2011", "2060", "Diff")){       # "2011"
      
    for(MRCid in MRClist){
      
      cat(paste0(MRCid, " "))
      
      for(i in 1:10){
        
        for(speciesID in 1:14){
          
          # Get species code
          speciesCode <- speciesSet[speciesID, "Code"]
          
          # Mask map to MRC
          targetRaster <- mask(eval(parse(text = paste0("spp_it_connectivity", periodName, "_it", i, "_spp", speciesCode))), 
                               eval(parse(text = paste0("MRC", MRCid))))
          assign(
            x = paste0("mrc_it_spp_connectivity", periodName, "_mrc", MRCid, "_it", i, "_spp", speciesCode),
            value = targetRaster
          )
          
        } # end species
      } # end iteration
      
      # Get list of MRC maps for all iterations & species
      itSppMRCConnectivityList <- mget(ls(pattern = paste0("mrc_it_spp_connectivity", periodName, "_mrc", MRCid, "*"))) 
     
      # Create empty vector to receive cell values
      rasterValues <- as.numeric()
        
      # For each map in list
      for(j in 1:length(itSppMRCConnectivityList)){
        
        # Get map
        targetRaster <- itSppMRCConnectivityList[[j]]
        
        # Get values
        singleValues <- targetRaster[,]
        
        # Remove NAs
        singleValues <- singleValues[!is.na(singleValues)]
        # Remove Infs
        singleValues <- singleValues[singleValues != Inf]
        
        # Save to vector
        rasterValues <- c(rasterValues, singleValues)
        
      } # end maps in list
      
      # Calculate mean in area
      meanValue <- mean(rasterValues)
      sdValue <- sd(rasterValues)
      
      # Add entry to table
      summaryValues <- data.frame(Scenario = scenarioName, 
                                  Period = periodName,
                                  MRC = MRCid, 
                                  Mean = meanValue, 
                                  SD = sdValue)
      connectivitySummary <- rbind(connectivitySummary, summaryValues)
      
      # Get MRC area
      templateMRC <- eval(parse(text = paste0("MRC", MRCid)))
      
      # Set all values to mean probability
      templateMRC[!is.na(templateMRC)] <- meanValue
      
      # Set all NA values to 0
      templateMRC[is.na(templateMRC)] <- 0
      
      # Rename raster based on MRC and period
      assign(
        x = paste0("meanSingleMRC", periodName, MRCid),
        value = templateMRC
      )
      
      # Clean environment
      rm(list = names(itSppMRCConnectivityList))
      
    } # end MRC
      
  } # end period
  
  # Step 3. Merge mean MRC maps per period ---------
  
  # For each period, calculate statistics across iterations
  for(periodName in c("2011", "2060", "Diff")){       # "2011"
   
   # Get list of mean per MRC maps
   meanMRCconnectivityList <-  mget(ls(pattern = paste0("meanSingleMRC", periodName, "*"))) 
   
   # Stack mean MRC maps
   meanMRCStack <- sprc(meanMRCconnectivityList)
   
   # Sum
   meanMRCSum <- mosaic(meanMRCStack, fun = "sum")
   
   # Mask to study area
   meanMRCSum_masked <- mask(meanMRCSum, MRCraster)
   
   # Rename raster based on MRC & iteration
   assign(
     x = paste0("meanMRC", periodName),
     value = meanMRCSum_masked
   )
   
  } # end period
  
} # end scenario

# Write raster with NA flag
writeRaster(meanMRC2011,
            file.path(intermediatesDir,
                      "meanMRC2011_connectivity_agnostic.tif"),
            NAflag = -9999, datatype = "FLT8S", overwrite = TRUE)
writeRaster(meanMRC2060,
            file.path(intermediatesDir,
                      "meanMRC2060_connectivity_agnostic.tif"),
            NAflag = -9999, datatype = "FLT8S", overwrite = TRUE)
writeRaster(meanMRCDiff,
            file.path(intermediatesDir,
                      "meanMRCjustDiff_connectivity_agnostic.tif"),
            NAflag = -9999, datatype = "FLT8S", overwrite = TRUE)

# Save summary statistic
write.csv(connectivitySummary, file = file.path(intermediatesDir, "connectivitySummary-all-difference.csv"))


