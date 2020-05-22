#' The main photon function
#' @param input_path input path for Shiny app.R
#' @param cran_packages comma separated CRAN packages
#' @param bioc_packages comma separated Bioconductor packages
#' @param github_packages comma separated github packages
#' @import stringr
#' @import glue
#' @export
startFun <- function(input_path, cran_packages=NULL, bioc_packages=NULL, github_packages=NULL){
  # library(stringr)
  # input_path <- "C:/Users/collab/Desktop"
  message("Running Photon")

  input_path <- normalizePath(input_path)
  electron_path <- normalizePath(
    file.path(
      input_path,
      "electron-quick-start"
      )
    )

  #confirm versions greater than (node 8.4.0 and npm 5.3)
  nodeVersion <- system2('node', 
                         args='-v', 
                         stdout=TRUE, 
                         stderr=TRUE)
  
  npmVersion <- system2("npm",
                        args="-v", 
                        stdout=TRUE, 
                        stderr=TRUE)
  #if node not available, notify to install node and npm globally 
  
  electronPackagerVersion <- system2("npm", args="list -g electron-packager" , stdout=TRUE, stderr=TRUE, wait=TRUE)
  
  if(grepl("electron", electronPackagerVersion[2])){
    electronPackagerVersion <- stringr::str_extract(electronPackagerVersion[2], "[0-9]+\\.[0-9]+\\.[0-9]+")
  } else{
    system2("npm",
            args='install electron --verbose', 
            stdout = TRUE, 
            stderr = TRUE, 
            wait = TRUE)
    system2("npm",
            args='install electron-packager -g', 
            stdout = TRUE, 
            stderr = TRUE, 
            wait = TRUE)
    electronPackagerVersion <- system2("npm", 
                                       args="list -g electron-packager",
                                       stdout=TRUE, 
                                       stderr=TRUE, 
                                       wait=TRUE)
    electronPackagerVersion <- stringr::str_extract(electronPackagerVersion[2],
                                                    "[0-9]+\\.[0-9]+\\.[0-9]+")
  }
    
  #confirm git is installed and available
  gitVersion <- system2("git", args="--version", stdout=TRUE, stderr=TRUE)
  gitVersion <- stringr::str_extract(gitVersion, "[0-9]+\\.[0-9]+\\.[0-9]+")
  #if git not available, notify to install git
  #git clone electron-shiny sample app
  
  if(!dir.exists(electron_path)){
    system2("git", 
            args=c("clone https://github.com/ColumbusCollaboratory/electron-quick-start", electron_path),
            stdout = TRUE, 
            stderr = TRUE,
            wait=TRUE)
  }
  

  
  if(.Platform$OS.type=="windows"){
    
    r_portable_path <- normalizePath(file.path(electron_path, "R-Portable-Win", "bin"))
  
    if(is.null(bioc_packages)){
      bioc_packages <- "NULL"
    } 
    
    if (is.null(cran_packages)){
      cran_packages <- "NULL"
    } 
    
    if (is.null(github_packages)){
      github_packages <- "NULL"
    }
    
    
    shell(
      sprintf(
        "%s/R.exe --file=%s/install_packages.R -q --slave --args cran_packages %s github_packages %s bioc_packages %s", 
        r_portable_path, 
        r_portable_path,
        cran_packages,
        github_packages,
        bioc_packages
      )
    )
    
    #input_app_dir <- stringr::str_replace_all(input_path, "/", "\\\\")
    #electron_win_dir <- stringr::str_replace_all(electron_path, "/", "\\\\")
    input_app_dir <- input_path
    electron_win_dir <- electron_path
    
    
    
    
    file.copy(normalizePath(file.path(input_app_dir, "app.R")), 
                      electron_win_dir,
              overwrite=TRUE)
    
    shell(sprintf("cd %s && npm install",
                  electron_win_dir))
    
    shell(sprintf("cd %s && npm run package-win",
                  electron_win_dir))
    
    
  } else if(.Platform$OS.type=="unix") {
    r_portable_path <- normalizePath(file.path(input_path, "R-Portable-Mac"))
    
    
    r_electron_version <- system(sprintf("cd %s; ./R CMD BATCH --version", 
                                         r_portable_path),
                                 intern = TRUE, 
                                 wait=TRUE)[5]
    
    r_electron_version <- stringr::str_extract(r_electron_version,
                                               "[0-9]+\\.[0-9]+\\.[0-9]+")
    
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
    
    file.copy(sprintf("%s/app.R",
                      input_path),
              sprintf("%s/electron-quick-start",
                      input_path),
              overwrite=TRUE)

    system(sprintf("cd %s; npm install; npm run package-mac", 
                   r_portable_path))
  }
}


