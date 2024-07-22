# allometry run 2
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
################### 
# download script
################### 
# DEMONSTRATION CODE
# populate the index of available products
products <- neon_products()

data.frame(products)

# find the ones containing keyword "tree"
i <- grepl("tree", products$keywords)
products[i, c("productCode", "productName")]

grepl("tree", products$keywords)
products[i, c("productCode", "productName")]

# DEMONSTRATION CODE
# neon_download(product = "DP1.10098.001", dir = "./data/neonstore/", site = "YELL")
# this provides all the info for the files downloaded locally see '?neon_index()' for more info
x <- neon_index()

# Provides the list of sites
site.list <- unique(y$site)

# remove the testy buggers
site.list <- site.list[!site.list %in% c("LAJA", "DCFS", "WOOD", "NOGP", "CPER")]

table(y$site, y$release)

# mostly done "NIWO",  "SRER", 
#site.list <- site.list[site.list %in% c( "ONAQ", "ABBY", "WREF","SJER" ,"SOAP", "TEAK", "BONA", "DEJU", "HEAL" ,"PUUM")] 
# This section brings allometries
taxons <- read.csv("./data/MasterTaxonList.csv")
names(taxons)[names(taxons) == "PLANTS.Code"] <- "taxonID"
# sapling allometry
sap.allometry <- read.csv("./data/SaplingAllometrySet.csv")

# niwo and srer

# cut out 
start.time <- Sys.time()
# FOR LOOP, BY SITE, FOR TREE LEVEL BIOMASS
for(i in site.list){
  # getting mapping and inventory data
  map <- neon_read(table = "vst_mappingandtagging-basic", site = i, release = "RELEASE-2024")
  
  inv <- neon_read(table = "vst_apparentindividual-basic", site = i, realese = "RELEASE-2024")
  
  
  ##### merge only what we need
  df <- merge(inv[ , c("individualID", "plotID", "siteID", "domainID",  "date", "plantStatus","growthForm", "canopyPosition", "measurementHeight", "basalStemDiameterMsrmntHeight",  "height" , "stemDiameter", "basalStemDiameter")],
              map[ , c("individualID", "pointID", "taxonID",  "scientificName",  "stemDistance", "stemAzimuth")], 
              by = c("individualID"), all.x = TRUE)
  
  # add the year
  df$year <- as.factor(substr(df$date, 0, 4))
  ### TREES & SAPLINGs
  
  df %>%
    dplyr::filter(str_detect(growthForm, "tree|sapling")) %>%
    data.frame() -> df
  

# then merge together
df <- merge(df, taxons, by = "taxonID", all.x = TRUE)
df <- merge(df, sap.allometry, by = "Genus", all.x = TRUE)
  
#### FILTER OUT
df %>%
  filter(!is.na(stemDiameter) & !is.na(measurementHeight)) %>%
    data.frame() -> df.stemD



  
# empty values
df.stemD$est.dbh = NA
df.stemD$flag = "Check"
# df$AGBChojnacky = NA
# df$AGBJenkins = NA
# df$AGBAnnighofer = NA

####
for(j in 1:nrow(df.stemD)){
    #if (df.stemD$growthForm[j] == "single bole tree" || df.stemD$growthForm[j] == "multi-bole tree"){
        if (df.stemD$stemDiameter[j] <= 10 & df.stemD$measurementHeight[j] > 50) {
          # biomass should be in kg i think. this comes from jennifer jenkins 2003 paper
          df.stemD$AGBJenkins[j] <- exp(df.stemD$betaZero[j] + (df.stemD$betaOne[j] * log(df.stemD$stemDiameter[j] * df.stemD$Adj.Factor[j])))
          df.stemD$AGBChojnacky[j] <- exp(df.stemD$beta0[j] + (df.stemD$beta1[j] * log(df.stemD$stemDiameter[j] * df.stemD$Adj.Factor[j])))
          df.stemD$AGBAnnighofer[j] = NA
          #df.stemD$flag[j] = "Good"
          
        } else if (df.stemD$stemDiameter[j] > 10 & df.stemD$measurementHeight[j] > 50){
          # these are normal nice looking data on actual real trees
          df.stemD$AGBJenkins[j] <- exp(df.stemD$betaZero[j] + (df.stemD$betaOne[j] * log(df.stemD$stemDiameter[j])))
          df.stemD$AGBChojnacky[j] <- exp(df.stemD$beta0[j] + (df.stemD$beta1[j] * log(df.stemD$stemDiameter[j])))
          df.stemD$AGBAnnighofer[j] = NA
          #df.stemD$flag[j] = "Good"
          
        } else if (df.stemD$stemDiameter[j] <= 10 & df.stemD$measurementHeight[j] <= 50){   # DOES THIS LEAVE ANY OUT
          # applies the Jenkins et al. taper function        
          df.stemD$est.dbh[j] <- exp(-0.35031 +  1.03991 * log(df.stemD$stemDiameter[j]))
          # run biomass sets
          df.stemD$AGBJenkins[j] <- exp(df.stemD$betaZero[j] + (df.stemD$betaOne[j] * log(df.stemD$est.dbh[j] * df.stemD$Adj.Factor[j])))
          df.stemD$AGBChojnacky[j] <- exp(df.stemD$beta0[j] + (df.stemD$beta1[j] * log(df.stemD$est.dbh[j] * df.stemD$Adj.Factor[j])))
          df.stemD$AGBAnnighofer[j] = NA
          #df.stemD$flag[j] = "Good"
          
        } 
}

  
######  
# now do saplings
df %>%
  filter(!is.na(basalStemDiameter) & !is.na(basalStemDiameterMsrmntHeight)) %>%
  data.frame() -> df.stemB
  
# empty values
df.stemB$est.dbh = NA
df.stemB$flag = "Check"
df.stemB$AGBJenkins = NA
df.stemB$AGBChojnacky = NA

# apply allometry
df.stemB$AGBAnnighofer <- df.stemB$SapBeta1 * ((df.stemB$basalStemDiameter^2 * df.stemB$height)^df.stemB$SapBeta2)
df.stemB$flag <- ifelse(!is.na(df.stemB$AGBAnnighofer), "Good", df.stemB$flag)
  
# now for the one's that are problematic
df %>%
  filter(is.na(basalStemDiameter) & is.na(basalStemDiameterMsrmntHeight) & is.na(stemDiameter) & is.na(measurementHeight)) %>%
  data.frame() -> df.empty

# add the missing columns
# empty values
df.empty$est.dbh = NA
df.empty$flag = "Check"
df.empty$AGBJenkins = NA
df.empty$AGBChojnacky = NA
df.empty$AGBAnnighofer = NA
  


# bring together
df.all <- rbind(df.stemD, df.stemB, df.empty)

# do check
#df.all$flag <- ifelse(!is.na(neon.bio$AGBJenkins| neon.bio$AGBAnnighofer), "Good", "Check")
  # concatenate file name and write to disk
  file.name <- paste("./data/biomass/", i, "_biomass.csv", sep = "")
  write.csv(df.all, file.name, row.names = FALSE)
}

end.time <- Sys.time()
time.taken <- end.time - start.time

print(time.taken)
