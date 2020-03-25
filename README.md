### please note: Photon doesn't work with any package that has to be compiled; where the binaries are not fully available (without compiling). The reason is that that would require management of the temporary directory for libPath to be used for compiling packages and that needs to be changed in the bash script that launches R. We haven't had time to try to address this issue in photon (in the bash scripting).

# Photon Package
Photon is an R package that contains an RStudio add-in miniUI that builds a Photon application. Photon builds standalone Shiny app by leveraging the Electron framework in Mac OS and Windows operating systems. This package clones the [Columbus Collaboratory electron-quick-start repository](https://github.com/ColumbusCollaboratory/electron-quick-start) which is forked to the electron-quick-start git repository plus Mac and Windows R portables. Photon will be extended to Linux in the near future. This work is still underdevelopment.

# Requirements

1. [git](https://git-scm.com/)    
2. [Node.js](https://nodejs.org/en/download/) -- this comes with [npm](http://npmjs.com/)  

# Usage

```r
remotes::install_github("ColumbusCollaboratory/photon")
library(photon)
```

Invocation of the miniUI display can be done in two ways:

1. Use the function `photon::photon_rstudioaddin()` in R.     
2. In RStudio -- click Tools > Addins > Browse Addins. Look for "photon" and select it. Click "Execute".  

# Installing Packages
The Mac and Windows R Portables currently come many pre-loaded packages that were selected by popularity. If additional packages (currently only CRAN and Bioconductor packages work; GitHub coming soon) are required, users can enter in a comma-separated string containing the package names of interest in the miniUI. These packages will install the packages to the relative version of R portable that will be subsequently packaged in to an Electron standalone application.    

If no packages are needed to install, type `NULL` as the entry for those specific repositories.

# Issues
Please submit a pull request for issues related to this package.  

# Contact
For photon questions contact pgordon@cbuscollaboratory.com   
For questions about the implementation of Electron, Chromium or node.js contact pgordon@cbuscollaboratory.com   
For questions about the R portable contact snikitin@cbuscollaboratory.com  







