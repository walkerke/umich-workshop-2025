# umich-workshop-2025

This repository contains materials for a series of workshops on using Census data in R given for the University of Michigan's Social Science Data Analysis Network in February 2025.  

Workshop slides are available from the links below:

* February 5, 2025: [Analyzing Data from the 2023 American Community Survey in R](https://walker-data.com/umich-workshop-2025/acs-2023/)

* February 12, 2025: [Working with Decennial Census Data in R](https://walker-data.com/umich-workshop-2025/decennial-census/)

* February 26, 2025: Mapping and Spatial Analysis with US Census Data in R

---

## How to get the workshop materials: 

- Users new to R and RStudio should use the pre-built Posit Cloud environment available at https://posit.cloud/content/9689451.

- Advanced users familiar with R and RStudio should clone the repository to their computers with the command `git clone https://github.com/walkerke/umich-workshop-2025.git`.  They should then install the following R packages, if not already installed:

```r
pkgs <- c("tidycensus", "tidyverse", "mapview", "survey", "srvyr", "arcgislayers")

install.packages(pkgs)
```

Experienced users should re-install __tidycensus__ to get the latest updates and ensure that all code used in the workshop will run.  

Other packages used will be picked up as dependencies of these packages on installation. 


