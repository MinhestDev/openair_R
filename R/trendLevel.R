#' Plot heat map trends
#'
#' The trendLevel function provides a way of rapidly showing a large amount of
#' data in a condensed form. In one plot, the variation in the concentration of
#' one pollutant can to shown as a function of three other categorical
#' properties. The default version of the plot uses y = hour of day, x = month
#' of year and type = year to provide information on trends, seasonal effects
#' and diurnal variations. However, x, y and type and summarising statistics can
#' all be modified to provide a range of other similar plots.
#'
#' \code{trendLevel} allows the use of third party summarising functions via the
#' \code{statistic} option. Any additional function arguments not included
#' within a function called using \code{statistic} should be supplied as a list
#' of named parameters and sent using \code{stat.args}. For example, the encoded
#' option \code{statistic = "mean"} is equivalent to \code{statistic = mean,
#' stat.args = list(na.rm = TRUE)} or the R command \code{mean(x, na.rm= TRUE)}.
#' Many R functions and user's own code could be applied in a similar fashion,
#' subject to the following restrictions: the first argument sent to the
#' function must be the data series to be analysed; the name `x' cannot be used
#' for any of the extra options supplied in \code{stat.args}; and the function
#' should return the required answer as a numeric or \code{NA}. Note: If the
#' supplied function returns more than one answer, currently only the first of
#' these is retained and used by \code{trendLevel}. All other returned
#' information will be ignored without warning. If the function terminates with
#' an error when it is sent an empty data series, the option
#' \code{stat.safe.mode} should not be set to \code{FALSE} or \code{trendLevel}
#' may fail. Note: The \code{stat.safe.mode = TRUE} option returns an NA without
#' warning for empty data series.
#'
#' @param mydata The openair data frame to use to generate the \code{trendLevel}
#'   plot.
#' @param pollutant The name of the data series in \code{mydata} to sample to
#'   produce the \code{trendLevel} plot.
#' @param x The name of the data series to use as the \code{trendLevel} x-axis.
#'   This is used with the \code{y} and \code{type} options to bin the data
#'   before applying \code{statistic} (see below). Other data series in
#'   \code{mydata} can also be used. (Note: \code{trendLevel} does not allow
#'   duplication in \code{x}, \code{y} and \code{type} options within a call.)
#' @param y The names of the data series to use as the \code{trendLevel} y-axis
#'   and for additional conditioning, respectively. As \code{x} above.
#' @param type See \code{y}.
#' @param rotate.axis The rotation to be applied to \code{trendLevel} \code{x}
#'   and \code{y} axes. The default, \code{c(90, 0)}, rotates the x axis by 90
#'   degrees but does not rotate the y axis. (Note: If only one value is
#'   supplied, this is applied to both axes; if more than two values are
#'   supplied, only the first two are used.)
#' @param n.levels The number of levels to split \code{x}, \code{y} and
#'   \code{type} data into if numeric. The default, \code{c(10, 10, 4)}, cuts
#'   numeric \code{x} and \code{y} data into ten levels and numeric \code{type}
#'   data into four levels. (Notes: This option is ignored for date conditioning
#'   and factors.  If less than three values are supplied, three values are
#'   determined by recursion; if more than three values are supplied, only the
#'   first three are used.)
#' @param limits The colour scale range to use when generating the
#'   \code{trendLevel} plot.
#' @param cols The colour set to use to colour the \code{trendLevel} surface.
#'   \code{cols} is passed to \code{openColours} for evaluation. See
#'   \code{?openColours} for more details.
#' @param auto.text Automatic routine text formatting. \code{auto.text = TRUE}
#'   passes common \code{lattice} labelling terms (e.g. \code{xlab} for the
#'   x-axis, \code{ylab} for the y-axis and \code{main} for the title) to the
#'   plot via \code{quickText} to provide common text formatting.  The
#'   alternative \code{auto.text = FALSE} turns this option off and passes any
#'   supplied labels to the plot without modification.
#' @param key.header,key.footer Adds additional text labels above and/or below
#'   the scale key, respectively. For example, passing the options
#'   \code{key.header = "", key.footer = c("mean","nox")} adds the addition text
#'   as a scale footer. If enabled (\code{auto.text = TRUE}), these arguments
#'   are passed to the scale key (\code{drawOpenKey}) via \code{quickText} to
#'   handle formatting. The term \code{"get.stat.name"}, used as the default
#'   \code{key.header} setting, is reserved and automatically adds statistic
#'   function names or defaults to \code{"level"} when unnamed functions are
#'   requested via \code{statistic}.
#' @param key.position Location where the scale key should be plotted.  Allowed
#'   arguments currently include \dQuote{top}, \dQuote{right}, \dQuote{bottom}
#'   and \dQuote{left}.
#' @param key Fine control of the scale key via \code{drawOpenKey}. See
#'   \code{?drawOpenKey} for further details.
#' @param labels If a categorical colour scale is required then these labels
#'   will be used. Note there is one less label than break. For example,
#'   \code{labels = c("good", "bad", "very bad")}. \code{breaks} must also be
#'   supplied if labels are given.
#' @param breaks If a categorical colour scale is required then these breaks
#'   will be used. For example, \code{breaks = c(0, 50, 100, 1000)}. In this
#'   case \dQuote{good} corresponds to values between 0 and 50 and so on. Users
#'   should set the maximum value of \code{breaks} to exceed the maximum data
#'   value to ensure it is within the maximum final range e.g. 100--1000 in this
#'   case. \code{labels} must also be supplied.
#' @param statistic The statistic method to be use to summarise locally binned
#'   \code{pollutant} measurements with. Three options are currently encoded:
#'   \dQuote{mean} (default), \dQuote{max} and \dQuote{frequency}. (Note:
#'   Functions can also be sent directly via \code{statistic}.  However, this
#'   option is still in development and should be used with caution. See Details
#'   below.)
#' @param stat.args Additional options to be used with \code{statistic} if this
#'   is a function. The extra options should be supplied as a list of named
#'   parameters. (see Details below.)
#' @param stat.safe.mode An addition protection applied when using functions
#'   directly with \code{statistic} that most users can ignore. This option
#'   returns \code{NA} instead of running \code{statistic} on binned subsamples
#'   that are empty. Many common functions terminate with an error message when
#'   applied to an empty dataset. So, this option provides a mechanism to work
#'   with such functions. For a very few cases, e.g. for a function that counted
#'   missing entries, it might need to be set to \code{FALSE} (see Details
#'   below.)
#' @param drop.unused.types Hide unused/empty \code{type} conditioning cases.
#'   Some conditioning options may generate empty cases for some data sets, e.g.
#'   a hour of the day when no measurements were taken. Empty \code{x} and
#'   \code{y} cases generate 'holes' in individual plots. However, empty
#'   \code{type} cases would produce blank panels if plotted. Therefore, the
#'   default, \code{TRUE}, excludes these empty panels from the plot. The
#'   alternative \code{FALSE} plots all \code{type} panels.
#' @param col.na Colour to be used to show missing data.
#' @param plot Should a plot be produced? \code{FALSE} can be useful when
#'   analysing data to extract plot components and plotting them in other ways.
#' @param ... Addition options are passed on to \code{cutData} for \code{type}
#'   handling and \code{levelplot} in \code{lattice} for finer control of the
#'   plot itself.
#' @export
#' @return an [openair][openair-package] object.
#' @author Karl Ropkins and David Carslaw
#' @family time series and trend functions
#' @examples
#' #basic use
#' #default statistic = "mean"
#' trendLevel(mydata, pollutant = "nox")
#'
#' #applying same as 'own' statistic
#' my.mean <- function(x) mean(x, na.rm = TRUE)
#' trendLevel(mydata, pollutant = "nox", statistic = my.mean)
#'
#' #alternative for 'third party' statistic
#' #trendLevel(mydata, pollutant = "nox", statistic = mean,
#' #           stat.args = list(na.rm = TRUE))
#'
#' \dontrun{
#' # example with categorical scale
#' trendLevel(mydata, pollutant = "no2",
#' border = "white", statistic = "max",
#' breaks = c(0, 50, 100, 500),
#' labels = c("low", "medium", "high"),
#' cols = c("forestgreen", "yellow", "red"))
#' }
trendLevel <- function(mydata, pollutant = "nox", x = "month", y = "hour",
                       type = "year", rotate.axis = c(90, 0), n.levels = c(10, 10, 4),
                       limits = c(0, 100), cols = "default", auto.text = TRUE,
                       key.header = "use.stat.name", key.footer = pollutant,
                       key.position = "right", key = TRUE, labels = NA,
                       breaks = NA,
                       statistic = c("mean", "max", "frequency"),
                       stat.args = NULL, stat.safe.mode = TRUE, drop.unused.types = TRUE,
                       col.na = "white", plot = TRUE,
                       ...) {

  ## greyscale handling
  if (length(cols) == 1 && cols == "greyscale") {
    trellis.par.set(list(strip.background = list(col = "white")))
  }


  ## set graphics
  current.strip <- trellis.par.get("strip.background")
  current.font <- trellis.par.get("fontsize")

  ## reset graphic parameters
  on.exit(trellis.par.set(

    fontsize = current.font
  ))

  category <- FALSE ## assume pollutant scale is not a categorical value

  if (any(!is.na(labels)) && any(!is.na(breaks))) category <- TRUE


  ## check.valid function
  check.valid <- function(a, x, y) {
    if (length(x) > 1) x <- x[1] # take first as default

    if (is.null(x)) {
      stop(
        paste0(
          "\ttrendLevel does not allow 'NULL' ", a, " option.",
          "\n\t[suggest one of following: ", paste(y, collapse = ", "), "]"
        ),
        call. = FALSE
      )
    }

    out <- y[pmatch(x, y)] # match to options

    if (is.na(out)) {
      stop(
        paste0(
          "\ttrendLevel could not evaluate ", a, " term '", x,
          "'.\n\t[suggest one of following: ", paste(y, collapse = ", "), "]"
        ),
        call. = FALSE
      )
    }

    ## code here for shorten cases x != out
    out
  }

  ## extra.args
  extra.args <- list(...)

  ## label controls
  extra.args$xlab <- if ("xlab" %in% names(extra.args)) {
    quickText(extra.args$xlab, auto.text)
  } else {
    quickText(x, auto.text)
  }

  extra.args$ylab <- if ("ylab" %in% names(extra.args)) {
    quickText(extra.args$ylab, auto.text)
  } else {
    quickText(y, auto.text)
  }

  extra.args$main <- if ("main" %in% names(extra.args)) {
    quickText(extra.args$main, auto.text)
  } else {
    quickText("", auto.text)
  }

  if ("fontsize" %in% names(extra.args)) {
    trellis.par.set(fontsize = list(text = extra.args$fontsize))
  }

  ## ##############################
  ## check lengths of x, y, type
  ## ##############################

  if (length(x) > 1) {
    warning(paste(
      "\ttrendLevel does not allow multiple 'x' values.",
      "\n\t[ignoring all but first]",
      sep = ""
    ), call. = FALSE)
    x <- x[1]
    xlab <- xlab[1]
  }
  if (length(y) > 1) {
    warning(paste(
      "\ttrendLevel does not allow multiple 'y' values.",
      "\n\t[ignoring all but first]",
      sep = ""
    ), call. = FALSE)
    y <- y[1]
    ylab <- ylab[1]
  }

  if (length(type) > 2) {
    warning(paste(
      "\ttrendLevel allows up to two 'type' values.",
      "\n\t[ignoring all but first two]",
      sep = ""
    ), call. = FALSE)
    type <- type[1]
  }

  ## #################################
  ## check x, y and type do not match
  ## #################################

  temp <- unique(c(x, y, type)[duplicated(c(x, y, type))])

  if (length(temp) > 0) {
    stop(paste0(
      "\ttrendLevel could not rationalise plot structure.",
      "\n\t[duplicate term(s) in pollutant, x, y, type structure]",
      "\n\t[term(s): ", paste(temp, collapse = ", "), "]"
    ), call. = FALSE)
  }


  ## ###############################
  ## number vector handling
  ## ###############################
  ## used for rotate.axis and n.levels
  ls.check.fun <- function(vector, vector.name, len) {
    if (!is.numeric(vector)) {
      warning(paste0(
        "\ttrendLevel ignored unrecognised '", vector.name, "' option.",
        "\n\t[check ?trendLevel for details]"
      ), call. = FALSE)
      ## use current default
      vector <- eval(formals(trendLevel)[[vector.name]])
    }

    if (length(vector) < len) vector <- rep(vector, len)[1:len]
    ## insert default if not given
    ifelse(is.na(vector), eval(formals(trendLevel)[[vector.name]]), vector)
  }
  rotate.axis <- ls.check.fun(rotate.axis, "rotate.axis", 2)
  n.levels <- ls.check.fun(n.levels, "n.levels", 3)

  ## #######################
  ## statistic handling
  ## #######################
  if (is.character(statistic) | is.function(statistic)) {
    if (is.character(statistic)) {
      ## ########################
      ## hardcoded statistic options
      ## ########################

      statistic <- check.valid(
        "statistic", statistic,
        eval(formals(trendLevel)$statistic)
      )
      if (statistic == "mean") {
        stat.fun <- mean
        stat.args <- list(na.rm = TRUE)
      }

      if (statistic == "max") {
        stat.fun <- function(x, ...) {
          if (all(is.na(x))) {
            NA
          } else {
            max(x, ...)
          }
        }
        stat.args <- list(na.rm = TRUE)
      }

      if (statistic == "frequency") {
        stat.fun <- function(x, ...) {
          if (all(is.na(x))) {
            NA
          } else {
            length(na.omit(x))
          }
        }
        stat.args <- NULL
      }

      stat.name <- statistic
    } else {
      ## ######################
      ## user defined function handling
      ## ######################
      ## default unnameed stats to 'level'

      stat.name <- substitute(statistic)
      if (length(stat.name) != 1) stat.name <- "level"

      if (stat.safe.mode) {
        stat.fun <- function(x, ...) {
          if (all(is.na(x))) NA else statistic(x, ...)[1]
        }
      } else {
        stat.fun <- function(x, ...) statistic(x, ...)[1]
      }
    }
  } else {
    ## ######################
    ## early end for bad stats
    ## ######################
    ## unknown stat option
    stop(
      paste0(
        "\ttrendLevel could not apply statistic option '", substitute(statistic),
        "'.\n\t[suggest valid function or character vector]",
        "\n\t[currect character vectors options: '",
        paste(eval(formals(trendLevel)$statistic), collapse = "', '"), "']"
      ),
      call. = FALSE
    )
  }

  ## ###########################
  ## key.header, footer stat.name recovery
  ## ###########################
  if (!is.null(key.header)) {
    if (is.character(key.header)) {
      key.header <- gsub("use.stat.name", stat.name, key.header)
    }
  }
  if (!is.null(key.footer)) {
    if (is.character(key.footer)) {
      key.footer <- gsub("use.stat.name", stat.name, key.footer)
    }
  }

  ## ##########################
  ## checkPrep
  ## ##########################
  ## keep date if about
  temp <- if ("date" %in% names(mydata)) {
    c("date", pollutant)
  } else {
    pollutant
  }

  ## all of x, y, temp need to be handled as type here
  mydata <- checkPrep(mydata, temp, type = c(x, y, type), remove.calm = FALSE)

  ## ##########################
  ## cutData
  ## ##########################
  ## get pollutant value
  ## NOTE: this can be same as one of x, y, type
  ## so need a temp case

  ## different n.levels for axis and type
  ## is.axis applied for x and y
  newdata <- cutData(mydata, x, n.levels = n.levels[1], is.axis = TRUE, ...)
  newdata <- cutData(newdata, y, n.levels = n.levels[2], is.axis = TRUE, ...)
  newdata <- cutData(newdata, type, n.levels = n.levels[3], ...)
  newdata <- newdata[c(pollutant, x, y, type)]


  ## ##########################
  ## calculate statistic
  ## ##########################

  calc.stat <- function(...)
    tapply(newdata[[pollutant]], newdata[c(x, y, type)], stat.fun, ...)


  if (is.null(stat.args)) {
    newdata <- try(calc.stat(), silent = TRUE)
  } else {
    newdata <- try(do.call(calc.stat, stat.args), silent = TRUE)
  }

  ## ####################
  ## error handling for stat
  ## ####################
  if (is(newdata)[1] == "try-error") {
    stop(
      paste0(
        "\ttrendLevel could not complete supplied statistic operation '",
        stat.name, "'.\n\t[R error below]", "\n\t", temp[1]
      ),
      call. = FALSE
    )
  }


  ## ############################
  ## restructure new data for plot
  ## ############################
  newdata <- data.frame(
    expand.grid(dimnames(newdata)),
    matrix(unlist(newdata), byrow = TRUE)
  )
  pollutant <- paste(pollutant, stat.name, sep = ".")
  names(newdata)[ncol(newdata)] <- pollutant


  ## ############################
  ## plot setup
  ## ############################
  temp <- paste(type, collapse = "+")
  myform <- formula(paste0(pollutant, " ~ ", x, " * ", y, " | ", temp))

  if (type == "default") myform <- formula(paste0(pollutant, " ~ ", x, " * ", y))

  ## special case handling
  ## layout for wd
  if (length(type) == 1 & type[1] == "wd" & !"layout" %in% names(extra.args)) {
    ## re-order to make sensible layout

    wds <- c("NW", "N", "NE", "W", "E", "SW", "S", "SE")
    newdata$wd <- ordered(newdata$wd, levels = wds)
    wd.ok <- sapply(wds, function(x) if (x %in% unique(newdata$wd)) FALSE else TRUE)
    skip <- c(wd.ok[1:4], TRUE, wd.ok[5:8])
    newdata$wd <- factor(newdata$wd)
    extra.args$layout <- c(3, 3)
    if (!"skip" %in% names(extra.args)) {
      extra.args$skip <- skip
    }
  }

  temp <- if (is.factor(newdata[, type[1]])) {
    levels(newdata[, type[1]])
  } else {
    unique(newdata[, type[1]])
  }
  temp <- sapply(temp, function(x) quickText(x, auto.text))
  if (is.factor(temp)) temp <- as.character(temp)
  strip <- strip.custom(
    factor.levels = temp, strip.levels = c(TRUE, FALSE),
    strip.names = FALSE
  )

  strip.left <- if (length(type) == 1) {
    FALSE
  } else {
    temp <- sapply(unique(newdata[, type[2]]), function(x)
      quickText(x, auto.text))
    if (is.factor(temp)) temp <- as.character(temp)
    strip.custom(factor.levels = temp)
  }

  suppressWarnings(trellis.par.set(list(strip.background = list(col = "white"))))

  scales <- list(
    x = list(rot = rotate.axis[1]),
    y = list(rot = rotate.axis[2])
  )

  ## categorical colour scale or not? #####################################

  if (category) {
    ## check the breaks and labels are consistent
    if (length(labels) + 1 != length(breaks)) stop("Need one more break than labels")

    ## cut data into categories
    newdata$cuts <- cut(
      newdata[, pollutant],
      breaks = breaks, labels = labels,
      include.lowest = TRUE
    )
    n <- length(levels(newdata$cuts))

    col.regions <- openColours(cols, n)
    col.scale <- breaks
    legend <- list(
      col = col.regions, space = key.position, auto.text = auto.text,
      labels = levels(newdata$cuts), footer = key.footer,
      header = key.header, height = 0.8, width = 1.5, fit = "scale",
      plot.style = "other"
    )

    col.scale <- breaks
    legend <- makeOpenKeyLegend(key, legend, "windRose")
  } else { ## continuous colour scale

    ## auto-scaling
    nlev <- 200 ## preferred number of intervals

    ## handle missing breaks arguments

    if (missing(limits)) {
      breaks <- seq(
        min(newdata[, pollutant], na.rm = TRUE),
        max(newdata[, pollutant], na.rm = TRUE),
        length.out = nlev
      )

      labs <- pretty(breaks, 7)
      labs <- labs[labs >= min(breaks) & labs <= max(breaks)]
      at <- labs
    } else {

      ## handle user limits and clipping
      breaks <- seq(min(limits), max(limits), length.out = nlev)
      labs <- pretty(breaks, 7)
      labs <- labs[labs >= min(breaks) & labs <= max(breaks)]
      at <- labs

      ## case where user max is < data max
      if (max(limits) < max(newdata[, pollutant], na.rm = TRUE)) {
        id <- which(newdata[, pollutant] > max(limits))
        newdata[id, pollutant] <- max(limits)
        labs[length(labs)] <- paste(">", labs[length(labs)])
      }

      ## case where user min is > data min
      if (min(limits) > min(newdata[, pollutant], na.rm = TRUE)) {
        id <- which(newdata[, pollutant] < min(limits))
        newdata[id, pollutant] <- min(limits)
        labs[1] <- paste("<", labs[1])
      }
    }

    nlev2 <- length(breaks)

    col.regions <- openColours(cols, (nlev2 - 1))

    col.scale <- breaks

    legend <- list(
      col = col.regions, at = col.scale,
      labels = list(labels = labs, at = at),
      space = key.position, auto.text = auto.text,
      footer = key.footer, header = key.header,
      height = 1, width = 1.5, fit = "all"
    )
    legend <- makeOpenKeyLegend(key, legend, "polarPlot")
  }


  ## #turn off colorkey
  colorkey <- FALSE

  ## stop overlapping labels
  yscale.lp <- function(...) {
    ans <- yscale.components.default(...)
    ans$left$labels$check.overlap <- TRUE
    ans$left$labels$labels <- levels(newdata[, y])
    ans$left$labels$at <- seq_along(levels(newdata[, y]))

    ans
  }
  xscale.lp <- function(...) {
    ans <- xscale.components.default(...)
    ans$bottom$labels$check.overlap <- TRUE
    ans$bottom$labels$labels <- levels(newdata[, x])
    ans$bottom$labels$at <- seq_along(levels(newdata[, x]))
    ans
  }

  ## ############################
  ## plot
  ## ############################
  ## note: The following listUpdate steps are used to stop this falling
  ## over with a lattice error if the user passes any of
  ## the locally defined options below as part of call.
  ## If they do reset it is obviously Caveat emptor...

  ## the axes are discrete factors - therefore can define exactly
  xlim <- range(as.numeric(newdata[, x])) + c(-0.5, 0.5)
  ylim <- range(as.numeric(newdata[, y])) + c(-0.5, 0.5)

  ## lattice does not display all labels - even if requested when there are many
  ## make a bit more space when there are >25
  if (length(levels(newdata[[y]])) > 25) ylim <- ylim + c(-0.3, 0.3)
  if (length(levels(newdata[[x]])) > 25) xlim <- xlim + c(-0.3, 0.3)

  ## openair defaults for plot
  levelplot.args <- list(
    x = myform, data = newdata, as.table = TRUE,
    legend = legend, colorkey = colorkey,
    at = breaks, col.regions = col.regions,
    scales = scales,
    yscale.components = yscale.lp,
    xscale.components = xscale.lp,
    par.strip.text = list(cex = 0.8),
    strip = strip, strip.left = strip.left,
    xlim = xlim, ylim = ylim,
    panel = function(x, y, ...) {
      panel.fill(col = col.na)
      panel.levelplot(x, y, ...)
    }
  )
  ## reset for extra.args
  levelplot.args <- listUpdate(levelplot.args, extra.args)
  plt <- do.call(levelplot, levelplot.args)

  ## ############################
  ## update for two levels
  ## ############################
  ## uses iseOuterStrips in latticeExtra
  if (length(type) > 1) {
    plt <- useOuterStrips(plt, strip = strip, strip.left = strip.left)
  }

  ## ############################
  ## openair output
  ## ############################
  if (plot) plot(plt)

  output <- list(plot = plt,
                 data = dplyr::tibble(newdata),
                 call = match.call())
  class(output) <- "openair"
  invisible(output)
}
