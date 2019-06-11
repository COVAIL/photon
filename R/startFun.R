#' @import stringr
#' @export

startFun <- function(input_path, cran_packages=NULL, bioc_packages=NULL, github_packages=NULL){
  library(stringr)
  message("Running Photon")
  message("The directory is ", input_path)
  input_path <- sprintf("%s/electron-quick-start", input_path) 
  #confirm versions greater than (node 8.4.0 and npm 5.3)
  nodeVersion <- system2("node", args="-v", stdout=TRUE, stderr=TRUE, wait=TRUE, env=environment())
  npmVersion <- system2("npm", args="-v", stdout=TRUE, stderr=TRUE, wait=TRUE, env=environment())
  #if node not available, notify to install node and npm globally 
  
  electronPackagerVersion <- system2("npm", args="list -g electron-packager" , stdout=TRUE, stderr=TRUE, wait=TRUE, env=environment())
  
  if(grepl("electron", electronPackagerVersion[2])){
    electronPackagerVersion <- str_extract(electronPackagerVersion[2], "[0-9]+\\.[0-9]+\\.[0-9]+")
  } else{
    system2("npm", args='install electron-packager -g', stdout=TRUE, stderr = TRUE, wait=TRUE, env=environment())
    electronPackagerVersion <- str_extract(electronPackagerVersion[2], "[0-9]+\\.[0-9]+\\.[0-9]+")
  }
  
  #confirm git is installed and available
  gitVersion <- system2("git", args="--version", stdout=TRUE, stderr=TRUE)
  gitVersion <- stringr::str_extract(gitVersion, "[0-9]+\\.[0-9]+\\.[0-9]+")
  #if git not available, notify to install git
  #git clone electron-shiny sample app
  
  if(!dir.exists(input_path)){
    system2("git", 
            args=c("clone https://github.com/ColumbusCollaboratory/electron-quick-start", input_path),
            stdout = TRUE, 
            stderr = TRUE,
            wait=TRUE, 
            env=environment())
  }
  
  
  # subDir <- tempdir()
  # 
  # if (!file.exists(subDir)){
  #   dir.create(file.path(subDir))
  # }
  # 
  #unlink("temp/*")
  
  
  ### this copies your app.R
  # file.copy(from=list.files('.', "*.R"), 
  #           to="./electron-quick-start", 
  #           overwrite=TRUE,
  #           recursive=TRUE, 
  #           copy.mode=TRUE)
  
  #Run R Portable for platform you are on.  Install packages needed for Shiny app
  
  # if(.Platform$OS.type=="unix"){
    r_portable_path <- sprintf("%s/R-Portable-Mac", input_path)
    
    
    r_electron_version <- system(sprintf("cd %s; ./R CMD BATCH --version", r_portable_path),
                                 intern = TRUE, wait=TRUE)[5]
    
    r_electron_version <- stringr::str_extract(r_electron_version, "[0-9]+\\.[0-9]+\\.[0-9]+")
    
    # run install packages
    # input <- list()
    # input$cran_packages <- paste("callr" , "tidyr", sep=",")
    # input$github_packages <- "bnosac/cronR"
    # input$bioc_packages <- "gwasurvivr"
    
    if(is.null(bioc_packages)){
      bioc_packages <- "NULL"
    } 
    
    if (is.null(cran_packages)){
      cran_packages <- "NULL"
    } 
    
    if (is.null(github_packages)){
      github_packages <- "NULL"
    }
    
    system(
      sprintf(
        "cd %s; ./R --file=./install_packages.R -q --slave --args cran_packages %s github_packages %s bioc_packages %s", 
        r_portable_path, 
        cran_packages,
        github_packages,
        bioc_packages
      ), wait=TRUE
      
    )
    
    
    system(sprintf("cd %s; npm run package-mac", r_portable_path))
  # }else if (.Platform$OS.type=="windows"){
  #   #### 
  # }
  # 
  
  
  # install R packages in portable directory 
  
  
  
  
  # npm package-mac
  
}
# debugonce(startFun)
# 
# startFun("~/Desktop/photon-shiny-addin/", cran_packages=NULL, bioc_packages = NULL, github_packages = NULL)

# system.time({startFun(input_path)})
# 
# #npm install
# 
# #npm start
# 
# 
# #??????  How to run install of packages for Windows if you are on a Mac.
# 
# #Run your R Project on Windows and use the Add-In to Install packages need for Shiny app
# 


