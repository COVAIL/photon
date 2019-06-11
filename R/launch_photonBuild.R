#' @import stats
#' @import utils
#' @import shiny
#' @export

launch_photoBuild <- function(launch.browser = TRUE, ...) {
  fpath <- system.file("application", package = "photon")
  # Use a modal dialog as a viewr.
  viewer <- shiny::dialogViewer("Photon Shiny App Builder", width = 700, height = 800)
  #viewer <- shiny::paneViewer()
  shiny::runGadget(ui, server, viewer = shiny::paneViewer(), ...)
  }

