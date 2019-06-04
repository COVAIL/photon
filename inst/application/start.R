input_path <- "~/Desktop/photon-shiny-addin" 

startFun <- function(input_path, packages){
  input_path <- sprintf("%s/electron-quick-start", input_path) 
  #confirm versions greater than (node 8.4.0 and npm 5.3)
  nodeVersion <- system2("node", args="-v", stdout=TRUE, stderr=TRUE)
  npmVersion <- system2("npm", args="-v", stdout=TRUE, stderr=TRUE)
  #if node not available, notify to install node and npm globally 
  
  electronPackagerVersion <- system2("npm", args="list -g electron-packager" , stdout=TRUE, stderr=TRUE)
  
  if(grepl("electron", electronPackagerVersion[2])){
    electronPackagerVersion <- str_extract(electronPackagerVersion[2], "[0-9]+\\.[0-9]+\\.[0-9]+")
  } else{
    system2("npm", args='install electron-packager -g', stdout=TRUE, stderr = TRUE)
    electronPackagerVersion <- str_extract(electronPackagerVersion[2], "[0-9]+\\.[0-9]+\\.[0-9]+")
  }
  
  #confirm git is installed and available
  gitVersion <- system2("git", args="--version", stdout=TRUE, stderr=TRUE)
  gitVersion <- str_extract(gitVersion, "[0-9]+\\.[0-9]+\\.[0-9]+")
  #if git not available, notify to install git
  #git clone electron-shiny sample app
  
  if(!dir.exists(input_path)){
    system2("git", 
            args=c("clone https://github.com/ColumbusCollaboratory/electron-quick-start", input_path),
            stdout = TRUE, 
            stderr = TRUE)
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
  
  r_portable_path <- sprintf("%s/R-Portable-Mac", input_path)
  
  
  r_electron_version <- system(sprintf("cd %s; ./R CMD BATCH --version", r_portable_path),
                               intern = TRUE)[5]
  
  r_electron_version <- str_extract(r_electron_version, "[0-9]+\\.[0-9]+\\.[0-9]+")
  
  # run install packages
  
  packages <- paste("callr", sep=",")
  
  system(
    sprintf(
      "cd %s; ./R --file=./install_packages.R -q --slave --args packages %s", 
      r_portable_path, 
      packages
      )
    )
  
  
  system(sprintf("cd %s; npm run package-mac", r_portable_path))
  
  # install R packages in portable directory 
  
  
  
  
  # npm package-mac
  
}

system.time({startFun(input_path)})

#npm install

#npm start


#??????  How to run install of packages for Windows if you are on a Mac.

#Run your R Project on Windows and use the Add-In to Install packages need for Shiny app



