#' @title Launch an RStudio addin to build ShinyApp using Electron Framework
#'
#' @export
#'


photon_rstudioaddin <- function(RscriptRepository = NULL) {
  requireNamespace("shiny")
  requireNamespace("miniUI")
  requireNamespace("shinyFiles")
  
  
  ui <- miniUI::miniPage(
    # Shiny fileinput resethandler
    
    miniUI::gadgetTitleBar("Use photon to build your shiny app"),
    
    miniUI::miniTabstripPanel(
      #miniUI::miniTabPanel(
      #title = 'Build standalone Shiny App for first time',
      #icon = shiny::icon("cloud-upload"),
      miniUI::miniContentPanel(
        shiny::h4("Choose your Shiny App directory"),
        shinyFiles::shinyDirButton('dirSelect',
                                   label = 'Select directory',
                                   title = 'Choose your Shiny App directory'),
        shiny::br(),
        shiny::br(),
        shiny::fillRow(
          flex = c(3, 3),
          shiny::column(
            3,
            shiny::div(class = "control-label",
                       shiny::strong("Selected Rscript")),
            shiny::verbatimTextOutput('currentdirselected'),
            shiny::dateInput(
              'date',
              label = "Creation date:",
              startview = "month",
              weekstart = 1,
              min = Sys.Date()
            ),
            shiny::textInput('rscript_args',
                             label = "Additional arguments to Rscript", 
                             value = ""),
            shiny::textInput('rscript_repository', 
                             label = "Rscript repository path: launch & log location",
                             value =NULL),
            shiny::actionButton('create', "Create job", icon = shiny::icon("play-circle"))
          ),
          shiny::column(
            3,
            shiny::textInput('jobdescription', 
                             label = "Job description",
                             value = "Photons light up!"),
            shiny::textInput('cran_packages',
                             label = "CRAN package (ex. mgcv,matrixStats)",
                             value = "NULL"),
            shiny::textInput('github_packages', 
                             label = "GitHub packages (ex. thomasp85/patchwork)",
                             value = "NULL"),
            
            shiny::textInput('bioc_packages', 
                             label = "Bioconductor packages (ex. SummarizedExperiemnt,VariantAnnotation)",
                             value = "NULL")
            
          )
        )
      )
    )
    
  )
  
  # Server code for the gadget.
  server <- function(input, output, session) {
    volumes <- c(
      'Current working dir' = getwd(),
      'HOME' = Sys.getenv('HOME'),
      'R Installation' = R.home(),
      'Root' = "/"
    )
    
    
    shinyFiles::shinyDirChoose(input,
                               id = 'dirSelect',
                               roots = volumes,
                               session = session)
    output$dirSelect <-
      shiny::renderUI({
        shinyFiles::parseDirPath(volumes, input$dirSelect)
      })
    output$currentdirselected <-
      shiny::renderText({
        as.character(shinyFiles::parseDirPath(volumes, input$dirSelect))
      })
    
    
    ###########################
    # CREATE / OVERWRITE
    ###########################
    shiny::observeEvent(input$create, {
      rscript_args <- input$rscript_args
      
      
      photon::startFun(
        as.character(shinyFiles::parseDirPath(volumes, input$dirSelect)),
        cran_packages = input$cran_packages,
        bioc_packages = input$bioc_packages,
        github_packages = input$github_packages
      )
      
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
  viewer <-
    shiny::dialogViewer("Photon Shiny App Builder",
                        width = 700,
                        height = 800)
  #viewer <- shiny::paneViewer()
  shiny::runGadget(ui, server, viewer = viewer)
}
