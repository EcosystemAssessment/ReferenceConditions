# ReferenceConditions
## Objectives:
* Define baseline conditions for ecosystem classes (i.e. forests and rangelands) by ecoregion (ECO Map 2007). 
    * We will calculate baseline conditions by averaging cells where scPDSI is neutral (scPDSI 0.4 to -0.4). We will report baseline conditions for climate, NDVI, NPP, GPP, and LAI.

To access data in  R from github without downloading the files:
* copy the file’s raw GitHub URL
*code: 
	URL <- 'https://raw.githubusercontent.com/EcosystemAssessment/ReferenceConditions/master/scpdsi_normals.tif'

	test<- raster(URL)


