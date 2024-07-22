#USDA to FIA
# This script matches FIA and USDA Taxon ID information in order to create
# a coherent way to sort, filter, and munge NEON data
# 
# Contact Jeff Atkins @ jeffrey.atkins@usda.gov or jwatkins6@vcu.edu

# dependencies
require(tidyverse)
fia <- read.csv("./data/FIAMaster.csv")
usda <- read.csv("./data/neon_taxon_jenkins2.csv")

# filter down
fia %>%
  select( Genus, Species, PLANTS.Code, FIA.Code) %>%
  data.frame() -> FIA

# make names play nice
names(usda)[names(usda) == "taxonID"] <- "PLANTS.Code"

# make a merge and have it play nice
usda.fia <- merge(usda, FIA, by = c("PLANTS.Code"), all.x = TRUE)

##### # lines to fix

# fix by PLANTS
# 139	CECAC	Cercis canadensis L. var. canadensis	eastern redbud	Fabaceae	mixed hardwood	tree	NA	NA	471
# 140	CECO	Ceanothus cordulatus Kellogg	whitethorn ceanothus	Rhamnaceae		shrub	NA	NA	NA  ### FIA 471
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='CECAC'] <- 471

# 317	ILEX	Ilex L.	holly	Aquifoliaceae	mixed hardwood	tree	NA	NA	NA   ### 591 FIA
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='ILEX'] <- 591

# 389	MAGNO	Magnolia L.	magnolia	Magnoliaceae	mixed hardwood	tree	NA	NA	NA  #### FIA 652
# 390	MAGR4	Magnolia grandiflora L.	southern magnolia	Magnoliaceae	mixed hardwood	tree	Magnolia	grandiflora	652
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='MAGNO'] <- 650  # see FIA code



# 418	NYAQ2	Nyssa aquatica L.	water tupelo	Cornaceae	mixed hardwood	tree	Nyssa	aquatica	691
# 419	NYBI	Nyssa biflora Walter	swamp tupelo	Cornaceae	mixed hardwood	tree	Nyssa	biflora	694
# 420	NYSSA	Nyssa L.	tupelo	Cornaceae	mixed hardwood	tree	NA	NA	NA
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='NYSSA'] <- 690 # see FIA data

# OAKS
# 516	QUCH	Quercus chapmanii Sarg.	Chapman oak	Fagaceae	hard maple/oak/hickory/beech	tree	NA	NA	NA
# 524	QUGE2	Quercus geminata Small	sand live oak	Fagaceae	hard maple/oak/hickory/beech	tree	Quercus	geminata	8441
# 534	QUMA13	Quercus margaretta (Ashe) Small	sand post oak	Fagaceae	hard maple/oak/hickory/beech	tree	NA	NA	NA
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='QUCH'] <- 8441 # see FIA data, sub sand live oak
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='QUMA13'] <- 8441 # see FIA data, sub sand live oak

# 521	QUERC	Quercus L.	oak	Fagaceae	hard maple/oak/hickory/beech	tree	NA	NA	NA
# 544	QUPA	Quercus ×palaeolithicola Trel.	hybrid oak	Fagaceae	hard maple/oak/hickory/beech	tree	NA	NA	NA
# 542	QUNE	Quercus ×neopalmeri Sudw. ex Palmer	hybrid oak	Fagaceae	hard maple/oak/hickory/beech	tree	NA	NA	NA
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='QUERC'] <- 833 # guessing red oak for all
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='QUPA'] <- 833 # guessing red oak for all
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='QUNE'] <- 833 # guessing red oak for all

# 547	QUPH	Quercus phellos L.	willow oak	Fagaceae	hard maple/oak/hickory/beech	tree	Quercus	phellos	831
# 525	QUHE	Quercus Ã—heterophylla Michx. f. (pro sp.)	Bartram oak	Fagaceae	hard maple/oak/hickory/beech	tree	NA	NA	NA
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='QUHE'] <- 831 # see FIA data, sub willow based on DNA similarity

# 549	QURU	Quercus rubra L.	northern red oak	Fagaceae	hard maple/oak/hickory/beech	tree	Quercus	rubra	833
# 550	QURUR	Quercus rubra L. var. rubra	northern red oak	Fagaceae	hard maple/oak/hickory/beech	tree	NA	NA	NA
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='QURUR'] <- 833 # see FIA data

# name change from Scrub oak???
# 528	QUIN7	Quercus inopina Ashe	sandhill oak	Fagaceae	hard maple/oak/hickory/beech	tree	NA	NA	NA
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='QUIN7'] <- 816 # see FIA data, sub willow based on DNA similarity


# 539	QUMO4	Quercus montana Willd.	chestnut oak	Fagaceae	hard maple/oak/hickory/beech	tree	NA	NA	NA
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='QUMO4'] <- 832 # see FIA data


# # changed to shrub, no allometry given
# 548	QUPU80	Quercus pumila Walter	running oak	Fagaceae	hard maple/oak/hickory/beech	tree	NA	NA	NA

# 617	SAPE2	Salix pedicellaris Pursh	bog willow	Salicaceae	aspen/alder/cottonwood/willow	tree	NA	NA	NA
# 618	SAPE5	Salix petiolaris Sm.	meadow willow	Salicaceae	aspen/alder/cottonwood/willow	tree	NA	NA	NA
# 619	SAPU15	Salix pulchra Cham.	tealeaf willow	Salicaceae	aspen/alder/cottonwood/willow	tree	NA	NA	NA
# 620	SAPY	Salix pyrifolia Andersson	balsam willow	Salicaceae	aspen/alder/cottonwood/willow	tree	Salix	pyrifolia	926
# 622	SARI4	Salix richardsonii Hook.	Richardson's willow	Salicaceae	aspen/alder/cottonwood/willow	tree	NA	NA	NA
# 623	SASC	Salix scouleriana Barratt ex Hook.	Scouler's willow	Salicaceae	aspen/alder/cottonwood/willow	tree	NA	NA	NA
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='SAPE2'] <- 926 # see FIA data
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='SAPE5'] <- 926 # see FIA data
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='SAPU15'] <- 926 # see FIA data
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='SARI4'] <- 926 # see FIA data
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='SASC'] <- 926 # see FIA data
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='QUMO4'] <- 926 # see FIA data

# none for generic abies fir
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='ABIES'] <- 12 # see FIA data, assigning balsam fir


# 684	ULAL	Ulmus alata Michx.	winged elm	Ulmaceae	mixed hardwood	tree	Ulmus	alata	971
# 685	ULAM	Ulmus americana L.	American elm	Ulmaceae	mixed hardwood	tree	Ulmus	americana	972
# 686	ULCR	Ulmus crassifolia Nutt.	cedar elm	Ulmaceae	mixed hardwood	tree	Ulmus	crassifolia	973
# 687	ULMUS	Ulmus L.	elm	Ulmaceae	mixed hardwood	tree	NA	NA	NA
# 688	ULPU	Ulmus pumila L.	Siberian elm	Ulmaceae	mixed hardwood	tree	Ulmus	pumila	974
# 689	ULRU	Ulmus rubra Muhl.	slippery elm	Ulmaceae	mixed hardwood	tree	Ulmus	rubra	975
usda.fia$FIA.Code[usda.fia$PLANTS.Code =='ULMUS'] <- 972 # see FIA data, made american elm


#### ADD SPECIFIC GRAVITY
grav <- read.csv("./data/SaplingAdjustment.csv")

# redo fia.code as factor
usda.fia$FIA.Code <- as.factor(usda.fia$FIA.Code)
grav$FIA.Code <- as.factor(grav$FIA.Code)

# make a merge and have it play nice
usda.fia <- merge(usda.fia, grav, by = c("FIA.Code"), all.x = TRUE)

# for all trees not direclty listed, the ref says use 0.840
usda.fia <- within(usda.fia, Adj.Factor[is.na(Adj.Factor) & habit == 'tree'] <- 0.840)
# 
# ### add in the chojnacky model type
# choj <- read.csv("./data/ChojnackyEquations.csv")
# FIAToChaj <- read.csv("./data/FIAToChojnacky.csv")
# 
# 
# # merge
# usda.fia <- merge(usda.fia, FIAToChaj, by = c("FIA.Code"), all.x = TRUE)

##### # ### ALLOMETRIES
jenkins_model <- c("aspen/alder/cottonwood/willow", "soft maple/birch", "mixed hardwood", "hard maple/oak/hickory/beech", "cedar/larch", "doug fir", "fir/hemlock", "pine", "spruce", "juniper/oak/mesquite")
model_name <- c("hw1", "hw2", "hw3", "hw4", "sw1", "sw2", "sw3", "sw4", "sw5", "wl")
betaZero <- c(-2.20294, -1.9123, -2.4800, -2.0127, -2.0336, -2.2304, -2.5384, -2.5356, -2.0773, -0.7152)
betaOne <- c(2.3867, 2.3651, 2.4835, 2.4342, 2.2592, 2.4435, 2.4814, 2.4349, 2.3323, 1.7029)

# create jenkins data frame for modeling
jenkins <- data.frame(jenkins_model, model_name, betaZero, betaOne)
choj <- read.csv("./data/ChojnackyEquations2.csv")

# merge chaj
choj <- merge(FIAToChaj, choj)


usda.fia <- merge(usda.fia, jenkins, by = c("jenkins_model"), all.x = TRUE)
usda.fia <- merge(usda.fia, choj, by = c("FIA.Code"), all.x = TRUE)
# # change to work with NEON data PLANTS.code == taxonID
# names(chaj_plus)[names(chaj_plus) == "PLANTS.Code"] <- "taxonID"




# writes to file, but already done
#write.csv(usda.fia, "MasterTaxonList.csv", row.names = FALSE)












