#' Spin the Globe!
#'
#' Render an interactive 3D globe.
#'
#' @import htmlwidgets
#'
#' @param .data A data frame with a at least two columns.
#' @param isoIdCol Column name of an ISO-3166 formatted country code.
#' @param valueCol Column name of the value to shade.
#' @param colorRamp1 The bottom of the rendered color ramp.
#' @param colorRamp2 The top of the rendered color ramp.
#'
#' @export
quickglobe <- function(.data, isoIdCol, valueCol, colorRamp1 = "#fff7ec", colorRamp2 = "#7f0000") {

  if (!inherits(.data, "data.frame")) {
    stop("data must be a data frame.", call. = FALSE)
  }

  id <- rlang::ensym(isoIdCol)
  val <- rlang::ensym(valueCol)
  data <- dplyr::select(.data, !!!id, !!!val)
  names(data) <- c("id", "val")

  settings <- list(
    colorRamp1 = colorRamp1,
    colorRamp2 = colorRamp2
  )

  x = list(
    data = data,
    settings = settings
  )

  htmlwidgets::createWidget(
    name = 'quickglobe',
    x,
    package = 'quickglobe'
  )
}

#' Shiny bindings for quickglobe
#'
#' Output and render functions for using quickglobe within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a quickglobe
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name quickglobe-shiny
#'
#' @export
quickglobeOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'quickglobe', width, height, package = 'quickglobe')
}

#' @rdname quickglobe-shiny
#' @export
renderQuickglobe <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, quickglobeOutput, env, quoted = TRUE)
}
