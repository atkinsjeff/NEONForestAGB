# BUILD AGB PRODUCT
# This script builds the final data product using the created biomass files
# which are produced at the site level
# 
# Contact Jeff Atkins @ jeffrey.atkins@usda.gov or jwatkins6@vcu.edu

# dependencies
require(tidyverse)

# import collated product
#df <- read.csv("./summary/NEONForestAGB_20240321.csv")
df <- read.csv("./summary/NEONForestAGB_20240405.csv")

# sorted
x <- df[ ,c("domainID",
            "siteID",
            "plotID",
            "taxonID",
            "individualID",
            "Genus",
            "scientificName",
            "date",
            "habit",
            "growthForm",
            "plantStatus",
            "canopyPosition",
            "measurementHeight",
            "stemDiameter",
            "basalStemDiameter",
            "basalStemDiameterMsrmntHeight",
            "height",
            "AGBJenkins",
            "AGBChojnacky",
            "AGBAnnighofer",
            "qualityFlag")]

df %>%
  filter(est.dbh < 0 & growthForm == "sapling") %>%
  data.frame() -> shorty

df %>%
  select(individualID, growthForm) %>%
  distinct() %>%
  data.frame() -> df.ind

table(df.ind$growthForm)

# make wide
x %>% 
  pivot_longer(
    cols = starts_with("AGB"),
    names_to = "allometry",
    values_to = "AGB",
    values_drop_na = FALSE) %>%
  data.frame() -> df.agb




# write em to file
## write.csv(df.agb, "NEONForestAGBv2.csv", row.names = FALSE)


