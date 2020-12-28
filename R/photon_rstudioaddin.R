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
    
    miniUI::gadgetTitleBar("Use Photon to Build Standalone Shiny Apps",
                           left = NULL, right = NULL),
    
    miniUI::miniTabstripPanel(
      #miniUI::miniTabPanel(
      #title = 'Build standalone Shiny App for first time',
      #icon = shiny::icon("cloud-upload"),
      miniUI::miniContentPanel(
        shiny::h4("Shiny App Directory:"),
        fillRow(flex = c(1, 3),
                 shinyFiles::shinyDirButton('dirSelect', label = 'Select directory',
                                   title = 'Choose your Shiny App directory'),
                 shiny::verbatimTextOutput('currentdirselected')
          ),
        shiny::br(),
        actionButton("done", "Done",
                     style="color: #fff; background-color: #337ab7; border-color: #2e6da4")
        shiny::br(),
        shiny::h4("CRAN Packages:"),
        shiny::textInput('cran_packages',
                         label = ("ex: mgcv,matrixStats"),
                         value = "NULL"),
        shiny::br(),

        shinyBS::bsCollapse(id = "adv", open = NULL,
          shinyBS::bsCollapsePanel(
            shiny::tags$b("> Click for Advanced Options"), NULL,
            shiny::textInput('github_packages',
                               label = "GitHub packages (ex. thomasp85/patchwork):",
                               value = "NULL", width = "100%"),

              shiny::textInput('bioc_packages',
                               label = "Bioconductor packages (ex. SummarizedExperiment,VariantAnnotation):",
                               value = "NULL", width = "100%")
             
                   # shiny::textInput('rscript_args',
                   #                  label = "Additional arguments to Rscript",
                   #                  value = ""),
                   # shiny::textInput('rscript_repository',
                   #                  label = "R script repository path: launch & log location",
                   #              value =NULL, width = "100%")))
       
        )))),
      miniUI::miniButtonBlock(
        actionButton("create", "Build", icon("play-circle"),
                     style="color: #fff; background-color: #337ab7; border-color: #2e6da4")
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
        req(input$dirSelect)
        
        print(paste("Selected directory:", 
                     as.character(shinyFiles::parseDirPath(volumes, input$dirSelect))))
      })
    
    observeEvent(input$coll, ({
      shinyBS::updateCollapse(session, "adv", open = "Advanced Options")
    }))
    
    
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

