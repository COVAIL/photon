#' @import stats
#' @import utils
#' @import shiny
#' @export

launch_photoBuild <- function() {
  fpath <- system.file("application", package = "photon")
  # Use a modal dialog as a viewr.
  #viewer <- shiny::paneViewer()
  shiny::runGadget(shinyApp(fpath), viewer = shiny::paneViewer())
}

