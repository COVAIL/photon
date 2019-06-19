#' @title Launch an RStudio addin to build ShinyApp using Electron Framework 
#' 
#' @export 
#' 


photon_rstudioaddin <- function(RscriptRepostiry=NULL) {
  
  requireNamespace("shiny")
  requireNamespace("miniUI")
  requireNamespace("shinyFiles")
  

  ui <- miniUI::miniPage(
    # Shiny fileinput resethandler
    # shiny::tags$script('
    #                    Shiny.addCustomMessageHandler("resetFileInputHandler", function(x) {
    #                    var id = "#" + x + "_progress";
    #                    var idBar = id + " .bar";
    #                    $(id).css("visibility", "hidden");
    #                    $(idBar).css("width", "0%");
    #                    });
    #                    '),
    
    miniUI::gadgetTitleBar("Use photon to build your shiny app"),
    
    miniUI::miniTabstripPanel(
      miniUI::miniTabPanel(title = 'Build standalone Shiny App for first time', icon = shiny::icon("cloud-upload"),
                           miniUI::miniContentPanel(
                             #shiny::uiOutput('fileSelect'),
                             shiny::h4("Choose your Shiny App directory"),
                             shinyFiles::shinyDirButton('dirSelect', label='Select directory', title='Choose your Shiny App directory'),
                             shiny::br(),
                             shiny::br(),
                             shiny::fillRow(flex = c(3, 3),
                                            shiny::column(3,
                                                          shiny::div(class = "control-label", shiny::strong("Selected Rscript")),
                                                          shiny::verbatimTextOutput('currentdirselected'),
                                                          shiny::dateInput('date', label = "Creation date:", startview = "month", weekstart = 1, min = Sys.Date()),
                                                          shiny::textInput('rscript_args', label = "Additional arguments to Rscript", value = ""),
                                                          shiny::textInput('rscript_repository', label = "Rscript repository path: launch & log location", RscriptRepository)
                                            ),
                                            shiny::column(3,
                                                          shiny::textInput('jobdescription', label = "Job description", value = "Runs a model to predict survival outcomes"),
                                                          shiny::textInput('cran_packages', label = "CRAN packages", value = "mgcv,matrixStats"),
                                                          shiny::textInput('github_packages', label = "GitHub packages", value = "thomasp85/patchwork"),
                                                          shiny::textInput('bioc_packages', label = "Bioconductor packages", value = "SummarizedExperiemnt,VariantAnnotation")
                                                         
                                            ))
                           ),
                           miniUI::miniButtonBlock(border = "bottom",
                                                   shiny::actionButton('create', "Create job", icon = shiny::icon("play-circle"))
                           )
      ),
      miniUI::miniTabPanel(title = 'Update existing Shiny App', icon = shiny::icon("table"),
                           miniUI::miniContentPanel(
                             shiny::fillRow(flex = c(3, 3),
                                            shiny::column(6,
                                                          shiny::h4("Existing crontab"),
                                                          shiny::actionButton('showcrontab', "Show current crontab schedule", icon = shiny::icon("calendar")),
                                                          shiny::br(),
                                                          shiny::br(),
                                                          shiny::h4("Show/Delete 1 specific job"),
                                                          shiny::uiOutput("getFiles"),
                                                          shiny::actionButton('showjob', "Show job", icon = shiny::icon("clock-o")),
                                                          shiny::actionButton('deletejob', "Delete job", icon = shiny::icon("remove"))
                                            ),
                                            shiny::column(6,
                                                          shiny::h4("Save crontab"),
                                                          shiny::textInput('savecrontabpath', label = "Save current crontab schedule to", value = file.path(Sys.getenv("HOME"), "my_schedule.cron")),
                                                          shiny::actionButton('savecrontab', "Save", icon = shiny::icon("save")),
                                                          shiny::br(),
                                                          shiny::br(),
                                                          shiny::h4("Load crontab"),
                                                          #shiny::uiOutput('cronload'),
                                                          shinyFiles::shinyFilesButton('crontabSelect', label='Select crontab schedule', title='Select crontab schedule', multiple=FALSE),
                                                          #shiny::div(class = "control-label", strong("Selected crontab")),
                                                          shiny::br(),
                                                          shiny::br(),
                                                          shiny::actionButton('loadcrontab', "Load selected schedule", icon = shiny::icon("load")),
                                                          shiny::br(),
                                                          shiny::br(),
                                                          shiny::verbatimTextOutput('currentcrontabselected')
                                            ))
                           ),
                           miniUI::miniButtonBlock(border = "bottom",
                                                   shiny::actionButton('deletecrontab', "Completely clear current crontab schedule", icon = shiny::icon("delete"))
                           )
      )
    )
  )
  
  # Server code for the gadget.
  server <- function(input, output, session) {
    
    volumes <- c('Current working dir' = getwd(), 
                 'HOME' = Sys.getenv('HOME'),
                 'R Installation' = R.home(),
                 'Root' = "/")
    
    

    #input_path <- as.character(shinyFiles::parseDirPath(volumes, input$dirSelect))
    shinyFiles::shinyDirChoose(input, id = 'dirSelect', roots = volumes, session = session)
    output$dirSelect <- shiny::renderUI({shinyFiles::parseDirPath(volumes, input$dirSelect)})
    output$currentdirselected <- shiny::renderText({as.character(shinyFiles::parseDirPath(volumes, input$dirSelect))})
    #output$fileSelect <- shiny::renderUI({
    #  shiny::fileInput(inputId = 'file', 'Choose your Rscript',
    #            accept = c("R-bestand"),
    #            multiple = TRUE)
    #})
    shinyFiles::shinyFileChoose(input, id = 'crontabSelect', roots = volumes, session = session)
    # output$cronload <- shiny::renderUI({
    #   shiny::fileInput(inputId = 'crontabschedule', 'Load an existing crontab schedule & overwrite current schedule',
    #                    multiple = FALSE)
    # })
    
    # When path to Rscript repository has been changed
    # shiny::observeEvent(input$rscript_repository, {
    #   RscriptRepository <<- normalizePath(input$rscript_repository, winslash = "/")
    #   if(file.exists(RscriptRepository) && file.info(RscriptRepository)$isdir == TRUE){
    #     saveRDS(RscriptRepository, file = current_repo)
    #   }else {
    #     message(sprintf("RscriptRepository %s does not exist, make sure this is an existing directory without spaces", RscriptRepository))
    #   }
    # })
    # 
    ###########################
    # CREATE / OVERWRITE
    ###########################
    shiny::observeEvent(input$create, {
      #shiny::req(input$task)
      #shiny::req(input$file)
      

      rscript_args <- input$rscript_args
      
      
      #print(input$dirSelect)
      #print(getSelectedDir(inputui = input$dirSelect))
      
      #print(as.character(shinyFiles::parseDirPath(volumes, input$dirSelect)))
      
      photon::startFun(as.character(shinyFiles::parseDirPath(volumes, input$dirSelect)), 
               cran_packages=input$cran_packages,
               bioc_packages=input$bioc_packages,
               github_packages=input$github_packages)
    
    })
    
    
    # Listen for the 'done' event. This event will be fired when a user
    # is finished interacting with your application, and clicks the 'done'
    # button.
    shiny::observeEvent(input$done, {
      # Here is where your Shiny application might now go an affect the
      # contents of a document open in RStudio, using the `rstudioapi` package.
      # At the end, your application should call 'stopApp()' here, to ensure that
      # the gadget is closed after 'done' is clicked.
      shiny::stopApp()
    })
  }
  
  # Use a modal dialog as a viewr.
  viewer <- shiny::dialogViewer("Photon Shiny App Builder", width = 700, height = 800)
  #viewer <- shiny::paneViewer()
  shiny::runGadget(ui, server, viewer = paneViewer())
}
