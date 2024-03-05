# NEONForestAGB

This code uses the Jenkins et al. 2003 and Chojnacky et al. 2014 allometric equations fit to NEON taxon ID
information for 40 NEON terrestrial sites to generate estimate of aboveground biomass (AGB) for individuals.  

## Additional Notes
The Jenkins allometric equations classify trees into several groups (e.g., mixed hardwood,
pine, woodland) with a specific equation of the form:  


$$\LARGE e^{\beta_{1} + \beta_{2} \ln dbh}$$  

Where ${\beta_{1}}$ and ${\beta_{2}}$ are the group specific coefficients and $dbh$ is
the diameter-at-breast height in cm.  

Individual trees in the NEON data set are assigned a `taxonID` which was used to match with 
the assigned groups from Jenkins et al. 2003 and Chojnacky et al. (2014).  
However, where there was no initially obvious classification group that could be assigned,
the USDA PLANTS database and other sources were consulted and a best guess was made. Please feel free
to offer suggestions for improvements.  

Taxon classification information is found in the `./data/MasterTaxonList.csv` file.  


## References:  

Atkins, J. W., Fahey, R. T., Hardiman, B. S., & Gough, C. M. (2018). Forest canopy structural complexity and light absorption relationships at the subcontinental scale. Journal of Geophysical Research: Biogeosciences, 123(4), 1387-1405.  

Gough, C. M., Atkins, J. W., Fahey, R. T., & Hardiman, B. S. (2019). High rates of primary production in structurally complex forests.  

Jenkins, J. C., Chojnacky, D. C., Heath, L. S., & Birdsey, R. A. (2003). National-scale biomass estimators for United States tree species. Forest science, 49(1), 12-35.

Chojnacky ..... (2014)