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

data.frame(products)

# find the ones containing keyword "tree"
i <- grepl("tree", products$keywords)
products[i, c("productCode", "productName")]

grepl("tree", products$keywords)
products[i, c("productCode", "productName")]

################### 
# Downloading using neonstore
# download the "forest structure" data
# neon_download("DP1.10098.001")

# this provides all the info for the files downloaded locally see '?neon_index()' for more info
x <- neon_index()

# Provides the list of sites
site.list <- unique(x$site)
 
# This section brings allometries
taxons <- read.csv("./data/MasterTaxonList.csv")
names(taxons)[names(taxons) == "PLANTS.Code"] <- "taxonID"
# sapling allometry
sap.allometry <- read.csv("./data/SaplingAllometrySet.csv")


# cut out 
start.time <- Sys.time()
# FOR LOOP, BY SITE, FOR TREE LEVEL BIOMASS
for(i in site.list){
# getting mapping and inventory data
map <- neon_read(table = "vst_mappingandtagging-basic", site = i)

inv <- neon_read(table = "vst_apparentindividual-basic", site = i)


##### merge only what we need
df <- merge(inv[ , c("individualID", "plotID", "siteID", "domainID", "date", "plantStatus","growthForm", "canopyPosition", "measurementHeight", "basalStemDiameterMsrmntHeight",  "height" , "stemDiameter", "basalStemDiameter")],
              map[ , c("individualID", "taxonID",  "scientificName",  "stemDistance", "stemAzimuth")], 
              by = c("individualID"), all.x = TRUE)

# add the year
df$year <- as.factor(substr(df$date, 0, 4))
### TREES & SAPLINGs

df %>%
  dplyr::filter(str_detect(growthForm, "tree|sapling")) %>%
  data.frame() -> df

# # create DRC column if sapling and DBH < 130
# df$drc <- NA
# df$drc <- ifelse((df$growthForm == "sapling" & df$measurementHeight <= 10), df$stemDiameter, NA)
# df$est.dbh <- -0.35031 +  1.03991 * log(df$drc) # this returns a log(dbh) value per chojnacky et al 2014, kept as log for lines 84-85

# then merge together
df <- merge(df, taxons, by = "taxonID", all.x = TRUE)
df <- merge(df, sap.allometry, by = "Genus", all.x = TRUE)

###########
# for loop to make taper function
# j = 1
# for(j in 1:nrow(df)){
#   if (df$growthForm[j] != "sapling"){
#     # biomass should be in kg i think. this comes from jennifer jenkins 2003 paper
#     df$AGBJenkins[j] <- exp(df$betaZero[j] + (df$betaOne[j] * log(df$stemDiameter[j])))
#     df$AGBChojnacky[j] <- exp(df$beta0[j] + (df$beta1[j] * log(df$stemDiameter[j])))
#   } else if (df$growthForm[j] == "sapling"){
#     df$AGBJenkins[j] <- exp(df$betaZero[j] + (df$betaOne[j] * df$est.dbh[j]))
#     df$AGBChojnacky[j] <- exp(df$beta0[j] + (df$beta1[j] * df$est.dbh[j]))
#     
#   } else {
#     df$AGBJenkins[j] = NA
#     df$aGBChojnacky[j] = NA
#   }
# }
# 
# df %>% 
#   filter(df$stemDiameter <= 2.54) %>%
#   data.frame() -> df.check
# 
# df %>%
#   filter(df$growthForm == "sapling") %>%
#   data.frame() -> df.sap
# 
# df %>% 
#   filter(is.na(stemDiameter) & !is.na(basalStemDiameter)) %>%
#   range(stemDiameter)
# 
# df %>% 
#   filter(growthForm != "sapling" & stemDiameter > 12.7 & measurementHeight <= 50) %>%
#   data.frame() -> wtf
# for(j in 1:nrow(df)){
#   if (df$growthForm[j] != "sapling" & df$stemDiameter[j] <= 12.7 & df$measurementHeight[j] > 50){
#     # biomass should be in kg i think. this comes from jennifer jenkins 2003 paper
#     df$AGBJenkins[j] <- exp(df$betaZero[j] + (df$betaOne[j] * log(df$stemDiameter[j] * df$Adj.Factor[j])))
#     df$AGBChojnacky[j] <- exp(df$beta0[j] + (df$beta1[j] * log(df$stemDiameter[j] * df$Adj.Factor[j])))
#     df$AGBAnnighofer[j] = NA
#     df$flag[j] = "Good"
#   
#   } else if (df$growthForm[j] != "sapling" & df$stemDiameter[j] > 12.7 & df$measurementHeight[j] > 50){
#     df$AGBJenkins[j] <- exp(df$betaZero[j] + (df$betaOne[j] * log(df$stemDiameter[j])))
#     df$AGBChojnacky[j] <- exp(df$beta0[j] + (df$beta1[j] * log(df$stemDiameter[j])))
#     df$AGBAnnighofer[j] = NA
#     df$flag[j] = "Good"
#     # drc adjustment
#   } else if (df$growthForm[j] != "sapling" & df$stemDiameter[j] <= 12.7 & df$measurementHeight[j] <= 50){   # DOES THIS LEAVE ANY OUT
#     df$est.dbh[j] <- exp(-0.35031 +  1.03991 * log(df$stemDiameter[j]))
#     # unlog it and then multiply by adjustment factor
#     df$AGBJenkins[j] <- exp(df$betaZero[j] + (df$betaOne[j] * log(df$est.dbh[j] * df$Adj.Factor[j])))
#     df$AGBChojnacky[j] <- exp(df$beta0[j] + (df$beta1[j] * log(df$est.dbh[j] * df$Adj.Factor[j])))
#     df$AGBAnnighofer[j] = NA
#     df$flag[j] = "Good"
#     
#   } else if (df$growthForm[j] == "sapling" & is.na(df$basalStemDiameterMsrmntHeight[j]) & df$stemDiameter[j] <= 12.7){
#     df$AGBJenkins[j] <- exp(df$betaZero[j] + (df$betaOne[j] * log(df$stemDiameter[j] * df$Adj.Factor[j])))
#     df$AGBChojnacky[j] <- exp(df$beta0[j] + (df$beta1[j] * log(df$stemDiameter[j] * df$Adj.Factor[j])))
#     df$AGBAnnighofer[j] = NA
#     df$flag[j] = "Good"
#     
#   } else if (df$growthForm[j] == "sapling"|| df$growthForm[j] == "small tree" & !is.na(df$basalStemDiameterMsrmntHeight[j]) & !is.na(df$height[j])){
#     df$AGBAnnighofer[j] <- df$SapBeta1[j] * ((df$basalStemDiameter[j]^2 * df$height[j])^df$SapBeta2[j])
#     df$AGBJenkins[j] = NA
#     df$AGBChojnacky[j] = NA
#     df$flag = "Good"
#     
#   } else {
#     df$AGBJenkins[j] = NA
#     df$AGBChojnacky[j] = NA
#     df$AGBAnnighofer[j] = NA
#     df$flag = "Check"
#   }
# }

# empty values
df$est.dbh = NA
df$flag = "Check"
# df$AGBChojnacky = NA
# df$AGBJenkins = NA
# df$AGBAnnighofer = NA

####
for(j in 1:nrow(df)){
  #if (df$growthForm[j] == "single bole tree" || df$growthForm[j] == "multi-bole tree"){
      
  skip_to_next <- FALSE
  tryCatch(
      if (!is.na(df$measurementHeight[j] & df$stemDiameter[j])) {
        
        if (df$stemDiameter[j] <= 12.7 & df$measurementHeight[j] > 50) {
          # biomass should be in kg i think. this comes from jennifer jenkins 2003 paper
          df$AGBJenkins[j] <- exp(df$betaZero[j] + (df$betaOne[j] * log(df$stemDiameter[j] * df$Adj.Factor[j])))
          df$AGBChojnacky[j] <- exp(df$beta0[j] + (df$beta1[j] * log(df$stemDiameter[j] * df$Adj.Factor[j])))
          df$AGBAnnighofer[j] = NA
          df$flag[j] = "Good"
       
        } else if (df$stemDiameter[j] > 12.7 & df$measurementHeight[j] > 50){
          # these are normal nice looking data on actual real trees
          df$AGBJenkins[j] <- exp(df$betaZero[j] + (df$betaOne[j] * log(df$stemDiameter[j])))
          df$AGBChojnacky[j] <- exp(df$beta0[j] + (df$beta1[j] * log(df$stemDiameter[j])))
          df$AGBAnnighofer[j] = NA
          df$flag[j] = "Good"
        
        } else if (df$stemDiameter[j] <= 12.7 & df$measurementHeight[j] <= 50){   # DOES THIS LEAVE ANY OUT
          # applies the Jenkins et al. taper function        
          df$est.dbh[j] <- exp(-0.35031 +  1.03991 * log(df$stemDiameter[j]))
          # run biomass sets
          df$AGBJenkins[j] <- exp(df$betaZero[j] + (df$betaOne[j] * log(df$est.dbh[j] * df$Adj.Factor[j])))
          df$AGBChojnacky[j] <- exp(df$beta0[j] + (df$beta1[j] * log(df$est.dbh[j] * df$Adj.Factor[j])))
          df$AGBAnnighofer[j] = NA
          df$flag[j] = "Good"
          
        } 
      } else if (is.na(df$measurementHeight[j] | df$stemDiameter[j])) {
        print("somthing is up")
      } , error = function(e) { skip_to_next = TRUE})
  if(skip_to_next) {next}
      
}

# now do saplings
df$AGBAnnighofer <- df$SapBeta1 * ((df$basalStemDiameter^2 * df$height)^df$SapBeta2)
df$flag <- ifelse(!is.na(df$AGBAnnighofer), "Good", df$flag)

# # DCFS
# df$est.dbh <- exp(-0.35031 +  1.03991 * log(df$stemDiameter))
# df$AGBJenkins <- exp(df$betaZero + (df$betaOne* log(df$est.dbh * df$Adj.Factor)))

# 
# df %>%
#   filter(flag == "Check") %>%
#   data.frame() -> check
########## 
# # sapling adjustment


# concatenate file name and write to disk
file.name <- paste("./data/biomass/", i, "_biomass.csv", sep = "")
write.csv(df, file.name, row.names = FALSE)
}
end.time <- Sys.time()
time.taken <- end.time - start.time

print(time.taken)
