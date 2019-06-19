#' @import stats
#' @import utils
#' @import shiny
#' @export

launch_photonBuild <- function(ui, server) {
  fpath <- system.file("application", package = "photon")
  # Use a modal dialog as a viewr.
  #viewer <- shiny::paneViewer()
  shiny::runGadget(shiny::shinyApp(fpath), viewer = shiny::paneViewer())
}

