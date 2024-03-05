# Aboveground biomass (AGB) generation script
# This script queries the NEON vegetation structure data using the 'neonstore' package
# and then imports those data into the workspace. It then filters to sites that have 
# the keyword 'tree' in the 'productCode' or 'productName' field.
# This step is left in solely for demonstration purposes if one wanted to pursue using 
# this framework for something else.
# 
# The neon product used is "DP1.10098.011"
# 
# Contact Jeff Atkins @ jeffrey.atkins@usda.gov or jwatkins6@vcu.edu

# dependencies NEON Tree Biomass Script
library(neonstore)
library(tidyverse)
library(ggplot2)

################### 
# DEMONSTRATION CODE
# populate the index of available products
products <- neon_products()

# find the ones containing keyword "tree"
i <- grepl("tree", products$keywords)
products[i, c("productCode", "productName")]

grepl("tree", products$keywords)
products[i, c("productCode", "productName")]

################### 
# Downloading using neonstore
# download the "forest structure" data
neon_download("DP1.10098.001")

# this provides all the info for the files downloaded locally see '?neon_index()' for more info
x <- neon_index()

# Provides the list of sites
site.list <- unique(x$site)
 
# This section brings allometries
taxons <- read.csv("./data/MasterTaxonList.csv")
names(taxons)[names(taxons) == "PLANTS.Code"] <- "taxonID"

start.time <- Sys.time()
# FOR LOOP, BY SITE, FOR TREE LEVEL BIOMASS
for(i in site.list){
# getting mapping and inventory data
map <- neon_read(table = "vst_mappingandtagging-basic", site = i, release = "RELEASE-2023")

inv <- neon_read(table = "vst_apparentindividual-basic", site = i, release = "RELEASE-2023")

inv2 <-data.frame(inv)

##### merge only what we need
df <- merge(inv[ , c("individualID", "plotID", "siteID", "domainID", "date", "plantStatus","growthForm", "canopyPosition", "measurementHeight", "height" , "stemDiameter")],
              map[ , c("individualID", "taxonID", "scientificName",  "stemDistance", "stemAzimuth")], 
              by = c("individualID"), all.x = TRUE)

# add the year
df$year <- as.factor(substr(df$date, 0, 4))
### TREES & SAPLINGs

df %>%
  dplyr::filter(str_detect(growthForm, "tree|sapling")) %>%
  data.frame() -> df

# create DRC column if sapling and DBH < 130
df$drc <- NA
df$drc <- ifelse((df$growthForm == "sapling" & df$measurementHeight != 130), df$stemDiameter, NA)
df$drc <- -0.35031 +  1.03991 * log(df$drc)

# then merge together
df <- merge(df, taxons, by = "taxonID", all.x = TRUE)

###########
# for loop to make taper function
j = 1
for(j in 1:nrow(df)){
  if (df$growthForm[j] != "sapling"){
    # biomass should be in kg i think. this comes from jennifer jenkins 2003 paper
    df$AGBJenkins[j] <- exp(df$betaZero[j] + (df$betaOne[j] * log(df$stemDiameter[j])))
    df$AGBChojnacky[j] <- exp(df$beta0[j] + (df$beta1[j] * log(df$stemDiameter[j])))
  } else if (df$growthForm[j] == "sapling"){
    df$AGBJenkins[j] <- exp(df$betaZero[j] + (df$betaOne[j] * df$drc[j]))
    df$AGBChojnacky[j] <- exp(df$beta0[j] + (df$beta1[j] * df$drc[j]))
  } else {
    df$AGBJenkins[j] = NA
    df$aGBChojnacky[j] = NA
  }
}
########## 
# # sapling adjustment
# df$AGBJenkins <- ifelse(df$growthForm == 'sapling', df$AGBJenkins * df$Adj.Factor, df$AGBJenkins)
# df$AGBChojnacky  <- ifelse(df$growthForm == 'sapling', df$Chojnacky * df$Adj.Factor, df$AGBChojnacky)


# concatenate file name and write to disk
file.name <- paste("./data/biomass/", i, "_biomass.csv", sep = "")
write.csv(df, file.name, row.names = FALSE)
}
end.time <- Sys.time()
time.taken <- end.time - start.time
