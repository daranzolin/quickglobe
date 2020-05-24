#' Spin the Globe!
#'
#' Render an interactive 3D globe.
#'
#' @importFrom dplyr select left_join pull mutate
#' @importFrom rlang enquo as_label !! :=
#'
#' @param data A data frame with a at least two columns.
#' @param identifier Column name of country identifier.
#' @param fill Column name of the value to shade.
#' @param legend Whether to include a legend
#' @param title Viz title, centered on top of globe.
#'
#' @export
quickglobe <- function(data,
                       identifier,
                       fill,
                       legend = TRUE,
                       title = NULL) {

  if (!inherits(data, "data.frame")) {
    stop("data must be a data frame.", call. = FALSE)
  }

  id <- enquo(identifier)
  id_str <- as_label(id)
  id_vec <- pull(data, !!id)
  fill <- enquo(fill)
  fill_vec <- pull(data, !!fill)

  if (is.factor(id_vec)) {
    data <- mutate(data, !!id := as.character(!!id))
  }

  if (is.numeric(fill_vec)) {
    palette <- "interpolateViridis"
    domain <- range(fill_vec, na.rm = TRUE)
    fill_type <- "interpolate"
  } else {
    palette <- "schemeSet1"
    domain <- unique(fill_vec)
    fill_type <- "scheme"
  }

  identifiers <- data.frame(as.character(id_vec))
  names(identifiers) <- id_str
  identifiers$id <- NA
  unmatched <- c()
  for (i in seq_along(identifiers[[id_str]])) {
    cntry <- identifiers[[id_str]][i]
    for (j in seq_along(country_identifiers)) {
      greps <- grep(cntry, unlist(country_identifiers[,j]), fixed = TRUE)
      if (!all(lengths(greps) == 0)) {
        ind <- greps[which(greps > 0)][1]
        identifiers$id[i] <- country_identifiers$iso_n3[ind]
        break
      } else {
        unmatched <- c(unmatched, cntry)
      }
    }
  }

  if (length(unmatched) > 0) {
    unique_unmatched <- unique(unmatched)
    for (i in seq_along(unique_unmatched)) {
      w <- paste("Could not match identifier '", unique_unmatched[i], "'", sep = "")
      warning(w, call. = FALSE)
    }
  }

  data_out <- left_join(data, identifiers, by = id_str)
  data_out <- select(data_out, id, val = !!fill)

  x = list(
    data = data_out,
    domain = domain,
    palette = palette,
    legend = legend,
    fill_type = fill_type,
    title = title
  )

  htmlwidgets::createWidget(
    name = 'quickglobe',
    x,
    package = 'quickglobe'
  )
}

#' Style a quickglobe
#'
#' @param quickglobe An object of class 'quickglobe'
#' @param palette A D3 color palette
#' @param titleFontFamily font family of title label
#' @param formatLegendTicks D3 formatter to legend ticks
#' @param legendCells number of legend cells
#'
#' @return quickglobe
#' @export
#'
#' @examples
qg_style <- function(quickglobe,
                     palette = NULL,
                     titleFontFamily = NULL,
                     formatLegendTicks = NULL,
                     legendCells = NULL) {

  if (!inherits(quickglobe, 'quickglobe')) {
    stop("quickglobe must be of class 'quickglobe'")
  }

  if (!is.null(palette)) {
    if (is.numeric(quickglobe$x$domain)) {
      palette = paste0("interpolate", palette)
    } else {
      palette = paste0("scheme", palette)
    }
    quickglobe$x$palette <- palette
  }

  if (!is.null(titleFontFamily)) {
    quickglobe$x$titleFontFamily <- titleFontFamily
  }

  if (!is.null(formatLegendTicks)) {
    quickglobe$x$formatLegendTicks <- formatLegendTicks
  }

  if (!is.null(legendCells)) {
    quickglobe$x$legendCells <- legendCells
  }

  return(quickglobe)
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
