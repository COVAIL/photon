input_path <- "~/Desktop" 

startFun <- function(input_path){
  input_path <- paste0(input_path,  "/", "electron-quick-start")
  #confirm versions greater than (node 8.4.0 and npm 5.3)
  nodeVersion <- system2("node", args="-v", stdout=TRUE, stderr=TRUE)
  npmVersion <- system2("npm", args="-v", stdout=TRUE, stderr=TRUE)
  #if node not available, notify to install node and npm globally 
  #npm i –g electron-packager
  #electronPackagerVersion <- system("npm list -g electron-packager", intern=TRUE)
  electronPackagerVersion <- system2("npm", args="list -g electron-packager" , stdout=TRUE, stderr=TRUE)
  #confirm git is installed and available
  gitVersion <- system2("git", args="--version", stdout=TRUE, stderr=TRUE)
  #if git not available, notify to install git
  #git clone electron-shiny sample app
  
  if(!dir.exists(input_path)){
    system2("git", 
            args=c("clone https://github.com/ColumbusCollaboratory/electron-quick-start", input_path),
            stdout = TRUE, 
            stderr = TRUE)
  }
  
  
  subDir <- tempdir()
  
  if (!file.exists(subDir)){
    dir.create(file.path(subDir))
  }
  unlink("temp/*")
  
  file.copy(from=list.files('.', "*.R"), 
            to="./electron-quick-start", 
            overwrite=TRUE,
            recursive=TRUE, 
            copy.mode=TRUE)
  
  #Run R Portable for platform you are on.  Install packages needed for Shiny app
  setwd("./electron-quick-start/R-Portable-Mac")
  system2("R", "--no-save", stdout = TRUE, stderr = TRUE)  
  
  
  
}

#npm install

#npm start


#??????  How to run install of packages for Windows if you are on a Mac.

#Run your R Project on Windows and use the Add-In to Install packages need for Shiny app



