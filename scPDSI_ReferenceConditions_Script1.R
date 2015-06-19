# Author: Sparkle L. Malone
# Date: June 2015
# Objective: Aggregate scPDSI and extract reference conditions. 

rm(list=ls())

library(raster)
library(rgdal)

# Import scPDSI Data form local directory:
setwd('/Volumes/Promise Pegasus/Data/PRISM_scPDSI')
scpdsi.file.list <- list.files(path='.', pattern="scpdsi") # List of all files in the directory

# Create Index:
library(splitstackshape) # Used to extract the date from the file names.
scpdsi.index.df <- as.data.frame(scpdsi.file.list) # Creates a dataframe from the list of files.
scpdsi.index.df <- concat.split(scpdsi.index.df, 1, sep='_', drop=F) # Breaks up the file name.
library(zoo)
scpdsi.index.df[,4]<- sprintf("%02d", scpdsi.index.df[,4])
scpdsi.index <- as.yearmon(paste(as.numeric(scpdsi.index.df[,3]),
                                 as.numeric(scpdsi.index.df[,4]), sep="-"))

# Create raster stack:
scpdsi<- stack(scpdsi.file.list)

# Add index to raster stack
scpdsi <- setZ(scpdsi,scpdsi.index, 'yearmon')
names(scpdsi) <- scpdsi.index

# Aggregate by year
scpdsi.yr <- zApply(scpdsi, by=year, fun=mean) 

# Creates an index for annnula data:
yr.index <- data.frame(names(scpdsi.yr))
yr.index <- concat.split(yr.index, 1, sep='X', drop=T)
yr.index <- list(yr.index[ , -1])

# Reclassify raster:
rc <- matrix(c(-Inf, -0.41, NA, -0.4, 0.4, 1,  0.41, Inf, NA), ncol=3, byrow=TRUE) # Matrix
scpdsi.yr.normals <- reclassify(scpdsi.yr, rc, right=T)
scpdsi.yr.normals <- setZ(scpdsi.yr.normals,yr.index,'year') # adds year
names(scpdsi.yr.normals) <- getZ(scpdsi.yr.normals) # Changes names to match year

# Mask Parameters with the scPDSI Normals to set Thresholds for each Eco-Region:



