# QA/QC
# This script builds the initial unformatted agb product after going through and 
# clearing out any issues
# 
# contact Jeff W. Atkins for anything:  jeffrey.atkins@usda.gov or jwatkins6@vcu.edu
 
# dependencies
library(tidyverse)
library(data.table)
library(ggplot2)

##### CUSTOM PLOT THEME
try_theme <- function() {
  theme(
    # add border 1)
    panel.border = element_rect(colour = "black", fill = NA, size = 0.5),
    # color background 2)
    #panel.background = element_rect(fill = "white"),
    # modify grid 3)
    panel.grid.major.x = element_line(colour = "#333333", linetype = 3, size = 0.5),
    panel.grid.minor.x = element_line(colour = "darkgrey", linetype = 3, size = 0.5),
    panel.grid.major.y = element_line(colour = "#333333", linetype = 3, size = 0.5),
    panel.grid.minor.y = element_line(colour = "darkgrey", linetype = 3, size = 0.5),
    # modify text, axis and colour 4) and 5)
    axis.text = element_text(colour = "black", family = "Times New Roman"),
    axis.title = element_text(colour = "black", family = "Times New Roman"),
    axis.ticks = element_line(colour = "black"),
    axis.ticks.length=unit(-0.1, "cm"),
    # legend at the bottom 6)
    legend.position = "bottom",
    strip.text.x = element_text(size=10, color="black",  family = "Times New Roman"),
    strip.text.y = element_text(size=10, color="black",  family = "Times New Roman"),
    strip.background = element_blank()
  )
}

# lists all the biomass files
list.files(path = "./data/biomass/", pattern = "_biomass", full.names= TRUE, recursive = FALSE) %>% 
  map_df(~fread(.))  -> neon.bio

# convert to data frame
neon.bio <- data.frame(neon.bio)

# fix checks if AGB is there
neon.bio$flag <- ifelse(!is.na(neon.bio$AGBJenkins| neon.bio$AGBAnnighofer), "Good", "Check")

###################### NOW FOR THE PROBLEMS
# look at check first
neon.bio %>%
  filter(flag == "Check") %>%
  data.frame() -> df.check

neon.bio %>%
  filter(flag == "Good") %>%
  data.frame() -> df.good
  
# 1) look at sites where the measurementHeight value is 10 cm or less,
# and could be an issue with the wrong entry should be in basaldiameter...
df.check %>%
  filter(measurementHeight <= 10) %>%
  data.frame() -> df.ten.cm.msmt.ht

a <- df.ten.cm.msmt.ht

table(a$Genus)
a$AGBAnnighofer <- a$SapBeta1 * ((a$stemDiameter^2 * a$height)^a$SapBeta2)

df.ten.cm.msmt.ht <- a


# okay that is 2178 with msmts and no corresponding allometries




#########
# 2) weird msmsts between 10 and 100
df.check %>%
  filter(measurementHeight > 10 & measurementHeight < 50) %>%
  data.frame() -> df.ten.fifty

b <- df.ten.fifty

# now do the allometries
b$AGBJenkins <- exp(b$betaZero + (b$betaOne * log(b$est.dbh * b$Adj.Factor)))
b$AGBChojnacky <- exp(b$beta0 + (b$beta1 * log(b$est.dbh * b$Adj.Factor)))

# missing allometries and an adjustment factor for one small tree



#########
# 3) chceking the big trees
df.check %>%
  filter(measurementHeight > 50) %>%
  data.frame() -> df.fifty

c <- df.fifty
c$AGBJenkins <- exp(c$betaZero + (c$betaOne * log(c$stemDiameter)))
c$AGBChojnacky <- exp(c$beta0 + (c$beta1 * log(c$stemDiameter)))

# na for jenkins went from 7145 to 2562 5784 replacements!

# 4) look at the saplings
df.check %>%
  filter(!is.na(basalStemDiameterMsrmntHeight)) %>%
  data.frame() -> df.basal.stem

d <- df.basal.stem

d$AGBAnnighofer <- d$SapBeta1 * ((d$basalStemDiameter^2 * d$height)^d$SapBeta2)

# looks like there are 25879 saplings with basal stem diameters, no heights or no allometry and no estimates of biomass
# 
e <- df.check
e$AGBJenkins <- exp(e$betaZero + (e$betaOne * log(e$stemDiameter)))
e$AGBChojnacky <- exp(e$beta0 + (e$beta1 * log(e$stemDiameter)))



#### NOW WE BRING TOGETHER
df <- rbind(df.good, e)

# fix checks if AGB is there
df$flag <- ifelse(!is.na(df$AGBJenkins| df$AGBAnnighofer), "Validated", "Check")


#### RECHECK STEM DIAMETER MSMTS
# df %>%
#   filter(flag == "Check") %>%
#   filter(!is.na(stemDiameter)) %>%
#   data.frame() -> df.stem2
# 

# look at the stats
table(df$growthForm)

# set final quality flags

df %>%
  mutate(qualityFlag = case_when(
    flag == "Check" & is.na(stemDiameter) & is.na(basalStemDiameter) ~ "missing values",
    flag == "Check" & is.na(jenkins_model) ~ "missing allometry",
    flag == "Check" & jenkins_model == "" ~ "missing allometry",
    flag == "Check" & !is.na(basalStemDiameter) & !is.na(height) ~ "missing allometry",
    flag == "Check" & !is.na(basalStemDiameter) & is.na(height) ~ "missing allometry",
    flag == "Validated" ~ "validated"
  )) %>%
  data.frame() -> df.qa.qc


# if you want to look at what is going on
df.qa.qc %>%
  filter(is.na(qualityFlag)) %>%
  data.frame() -> wtf


# writes the file previous to building AGB product
#write.csv(df.qa.qc, "NEONForestAGB_20240405.csv")


