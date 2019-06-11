#' @import stats
#' @import utils
#' @import shiny
#' @export

launch_photoBuild <- function(launch.browser = TRUE, ...) {
  fpath <- system.file("application", package = "photon")
  shiny::runApp(fpath, launch.browser = launch.browser, ...)
  }

