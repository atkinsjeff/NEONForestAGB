#' Import NEON aboveground forest biomass data
#' 
#' @returns The NEONForestAGB data set and metadata
#' @examples
#' df <- getAGB()

getAGB <- function() {
message("Thank you for using the NEONForestAGB data product. 
Please cite this data product if it is used in your work: 

Atkins, Jeff; Meier, Courtney; Alveshere, Brandon; Breland, Sabrie; 
Langley, Michael (2024).NEONForestAGBv2. figshare. Dataset. 
https://doi.org/10.6084/m9.figshare.25625352.v1", appendLF = TRUE)
  
  # Direct download from NEON
  read.csv("https://figshare.com/ndownloader/files/45710721", header = TRUE)
}





#' Import NEON aboveground forest metadata
#' 
#' @returns The NEONForestAGB dataset metadata
#' @examples
#' df <- getAGBMeta()

getAGBMeta <- function() {
  # get the metadata
  read.csv("https://figshare.com/ndownloader/files/45711171", header = TRUE)
}





#' Import NEON aboveground forest master taxon list
#' 
#' @returns The NEONForestAGB master taxon list
#' @examples
#' df <- getAGBTaxons()

getAGBTaxons<- function(){
  # get the metadata
  read.csv("https://figshare.com/ndownloader/files/45711174", header = TRUE)
}
