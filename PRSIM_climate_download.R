# Author: (https://github.com/ropensci/prism)
# Objective: Download PRISM DATA 

library(devtools)
install_github("ropensci/prism")
library(prism)

# ______________________________________Sample Code______________________________________________________________
# Save data here
options(prism.path = "/Volumes/Sparkle Malone/Data/PRISM_Temperature/MIN")

# Normals 30yr 1981 to 2010:
get_prism_normals(type="tmax",resolution = "4km",month = 1:12, annual=T, keepZip=F) # keepZip aka save files on machine.

# Get monthly/annual data:
get_prism_monthlys(type="tmean", year = 1990:2000, month = NULL, keepZip=F)

# get daily data
get_prism_dailys(type="tmean", minDate = "2013-06-01", maxDate = "2013-06-14", keepZip=F)

ls_prism_data() # View the list of files you downloaded
ls_prism_data(absPath = TRUE) # the raster function needs the absolute path
ls_prism_data(name = TRUE) # See the name of the files
prism_image(ls_prism_data()[1]) # plot of prism file

# _________________________________Code To Download Data_________________________________________________________

# Annual Normals is currently not working:

# Precipitation (Annual):
options(prism.path = '/Volumes/Promise Pegasus/Data/PRISM/Precipitation/Annual')
get_prism_monthlys(type="ppt", year = 2000:2014, month = NULL, keepZip=F)

# Precipitation (Annual/ Normals): #######Currently Not Working##############
options(prism.path = "/Volumes/Sparkle Malone/Data/PRISM/Precipitation/Normals/Annual")
get_prism_normals(type="ppt", resolution = "800m",month = NULL, annual=TRUE, keepZip=F)

# Precipitation (Monthly/ Normals):
options(prism.path = "/Volumes/Sparkle Malone/Data/PRISM/Precipitation/Normals/Monthly")
get_prism_normals(type="ppt", resolution = "800m", month = 1:12, keepZip=F)

# Temperature_Mean (Annual):
options(prism.path = "/Volumes/Sparkle Malone/Data/PRISM/Temperature_mean/Annual")
get_prism_monthlys(type="tmean", year = 2000:2013, month = NULL, keepZip=F)

# Temperature_mean (MONTHLY/ Normals): 
options(prism.path = "/Volumes/Sparkle Malone/Data/PRISM/Temperature_mean/Normals/Monthly")
get_prism_normals(type="tmean",resolution = "4km",month = 1:12, annual=T, keepZip=F) 

# Temperature_MIN (Annual):
options(prism.path = "/Volumes/Sparkle Malone/Data/PRISM/Temperature_min/Annual")
get_prism_monthlys(type="tmin", year = 2000:2013, month = NULL, keepZip=F)

# Temperature_min (MONTHLY/ Normals): 
options(prism.path = "/Volumes/Sparkle Malone/Data/PRISM/Temperature_min/Normals/Monthly")
get_prism_normals(type="tmin",resolution = "4km",month = 1:12, annual=T, keepZip=F) 

# Temperature_MAX (Annual):
options(prism.path = "/Volumes/Sparkle Malone/Data/PRISM/Temperature_max/Annual")
get_prism_monthlys(type="tmax", year = 2000:2013, month = NULL, keepZip=F)

# Temperature_max (MONTHLY/ Normals): 
options(prism.path = "/Volumes/Sparkle Malone/Data/PRISM/Temperature_max/Normals/Monthly")
get_prism_normals(type="tmax",resolution = "4km",month = 1:12, annual=T, keepZip=F) 
