% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/conditionalEval.R
\name{conditionalEval}
\alias{conditionalEval}
\title{Conditional quantile estimates with additional variables for model evaluation}
\usage{
conditionalEval(
  mydata,
  obs = "obs",
  mod = "mod",
  var.obs = "var.obs",
  var.mod = "var.mod",
  type = "default",
  bins = 31,
  statistic = "MB",
  xlab = "predicted value",
  ylab = "statistic",
  col = brewer.pal(5, "YlOrRd"),
  col.var = "Set1",
  var.names = NULL,
  auto.text = TRUE,
  ...
)
}
\arguments{
\item{mydata}{A data frame containing the field \code{obs} and \code{mod}
representing observed and modelled values.}

\item{obs}{The name of the observations in \code{mydata}.}

\item{mod}{The name of the predictions (modelled values) in \code{mydata}.}

\item{var.obs}{Other variable observations for which statistics should be
calculated. Can be more than length one e.g. \code{var.obs = c("nox.obs", "ws.obs")}. Note that including other variables could reduce the number of
data available to plot due to the need of having non-missing data for all
variables.}

\item{var.mod}{Other variable predictions for which statistics should be
calculated. Can be more than length one e.g. \code{var.obs = c("nox.obs", "ws.obs")}.}

\item{type}{\code{type} determines how the data are split i.e. conditioned,
and then plotted. The default is will produce a single plot using the
entire data. Type can be one of the built-in types as detailed in
\code{cutData} e.g. "season", "year", "weekday" and so on. For example,
\code{type = "season"} will produce four plots --- one for each season.

It is also possible to choose \code{type} as another variable in the data
frame. If that variable is numeric, then the data will be split into four
quantiles (if possible) and labelled accordingly. If type is an existing
character or factor variable, then those categories/levels will be used
directly. This offers great flexibility for understanding the variation of
different variables and how they depend on one another.}

\item{bins}{Number of bins to be used in calculating the different quantile
levels.}

\item{statistic}{Statistic(s) to be plotted. Can be \dQuote{MB},
\dQuote{NMB}, \dQuote{r}, \dQuote{COE}, \dQuote{MGE}, \dQuote{NMGE},
\dQuote{RMSE} and \dQuote{FAC2}, as described in \code{modStats}. When
these statistics are chosen, they are calculated from \code{var.mod} and
\code{var.mod}.

\code{statistic} can also be a value that can be supplied to
\code{cutData}. For example, \code{statistic = "season"} will show how
model performance varies by season across the distribution of predictions
which might highlight that at high concentrations of NOx the model tends to
underestimate concentrations and that these periods mostly occur in winter.
\code{statistic} can also be another variable in the data frame --- see
\code{cutData} for more information. A special case is \code{statistic = "cluster"} if clusters have been calculated using \code{trajCluster}.}

\item{xlab}{label for the x-axis, by default \dQuote{predicted value}.}

\item{ylab}{label for the y-axis, by default \dQuote{observed value}.}

\item{col}{Colours to be used for plotting the uncertainty bands and median
line. Must be of length 5 or more.}

\item{col.var}{Colours for the additional variables to be compared. See
\code{openColours} for more details.}

\item{var.names}{Variable names to be shown on plot for plotting
\code{var.obs} and \code{var.mod}.}

\item{auto.text}{Either \code{TRUE} (default) or \code{FALSE}. If \code{TRUE}
titles and axis labels etc. will automatically try and format pollutant
names and units properly e.g.  by subscripting the `2' in NO2.}

\item{...}{Other graphical parameters passed onto \code{conditionalQuantile}
and \code{cutData}. For example, \code{conditionalQuantile} passes the
option \code{hemisphere = "southern"} on to \code{cutData} to provide
southern (rather than default northern) hemisphere handling of \code{type = "season"}. Similarly, common axis and title labelling options (such as
\code{xlab}, \code{ylab}, \code{main}) are passed to \code{xyplot} via
\code{quickText} to handle routine formatting.}
}
\description{
This function enhances \code{\link[=conditionalQuantile]{conditionalQuantile()}} by also considering how other
variables vary over the same intervals. Conditional quantiles are very useful
on their own for model evaluation, but provide no direct information on how
other variables change at the same time. For example, a conditional quantile
plot of ozone concentrations may show that low concentrations of ozone tend
to be under-predicted. However, the cause of the under-prediction can be
difficult to determine. However, by considering how well the model predicts
other variables over the same intervals, more insight can be gained into the
underlying reasons why model performance is poor.
}
\details{
The \code{conditionalEval} function provides information on how other
variables vary across the same intervals as shown on the conditional quantile
plot. There are two types of variable that can be considered by setting the
value of \code{statistic}. First, \code{statistic} can be another variable in
the data frame. In this case the plot will show the different proportions of
\code{statistic} across the range of predictions. For example \code{statistic = "season"} will show for each interval of \code{mod} the proportion of
predictions that were spring, summer, autumn or winter. This is useful
because if model performance is worse for example at high concentrations of
\code{mod} then knowing that these tend to occur during a particular season
etc. can be very helpful when trying to understand \emph{why} a model fails.
See \code{\link[=cutData]{cutData()}} for more details on the types of variable that can
be \code{statistic}. Another example would be \code{statistic = "ws"} (if
wind speed were available in the data frame), which would then split wind
speed into four quantiles and plot the proportions of each.

Second, \code{conditionalEval} can simultaneously plot the model performance
of other observed/predicted variable \strong{pairs} according to different
model evaluation statistics. These statistics derive from the
\code{\link[=modStats]{modStats()}} function and include \dQuote{MB}, \dQuote{NMB},
\dQuote{r}, \dQuote{COE}, \dQuote{MGE}, \dQuote{NMGE}, \dQuote{RMSE} and
\dQuote{FAC2}. More than one statistic can be supplied e.g. \code{statistic = c("NMB", "COE")}. Bootstrap samples are taken from the corresponding values
of other variables to be plotted and their statistics with 95\\% confidence
intervals calculated. In this case, the model \emph{performance} of other
variables is shown across the same intervals of \code{mod}, rather than just
the values of single variables. In this second case the model would need to
provide observed/predicted pairs of other variables.

For example, a model may provide predictions of NOx and wind speed (for which
there are also observations available). The \code{conditionalEval} function
will show how well these other variables are predicted for the same intervals
of the main variables assessed in the conditional quantile e.g. ozone. In
this case, values are supplied to \code{var.obs} (observed values for other
variables) and \code{var.mod} (modelled values for other variables). For
example, to consider how well the model predicts NOx and wind speed
\code{var.obs = c("nox.obs", "ws.obs")} and \code{var.mod = c("nox.mod", "ws.mod")} would be supplied (assuming \verb{nox.obs, nox.mod, ws.obs, ws.mod} are present in the data frame). The analysis could show for example,
when ozone concentrations are under-predicted, the model may also be shown to
over-predict concentrations of NOx at the same time, or under-predict wind
speeds. Such information can thus help identify the underlying causes of poor
model performance. For example, an under-prediction in wind speed could
result in higher surface NOx concentrations and lower ozone concentrations.
Similarly if wind speed predictions were good and NOx was over predicted it
might suggest an over-estimate of NOx emissions. One or more additional
variables can be plotted.

A special case is \code{statistic = "cluster"}. In this case a data frame is
provided that contains the cluster calculated by \code{\link[=trajCluster]{trajCluster()}}
and \code{\link[=importTraj]{importTraj()}}. Alternatively users could supply their own
pre-calculated clusters. These calculations can be very useful in showing
whether certain back trajectory clusters are associated with poor (or good)
model performance. Note that in the case of \code{statistic = "cluster"}
there will be fewer data points used in the analysis compared with the
ordinary statistics above because the trajectories are available for every
three hours. Also note that \code{statistic = "cluster"} cannot be used
together with the ordinary model evaluation statistics such as MB. The output
will be a bar chart showing the proportion of each interval of \code{mod} by
cluster number.

Far more insight can be gained into model performance through conditioning
using \code{type}. For example, \code{type = "season"} will plot conditional
quantiles and the associated model performance statistics of other variables
by each season. \code{type} can also be a factor or character field e.g.
representing different models used.

See Wilks (2005) for more details of conditional quantile plots.
}
\references{
Wilks, D. S., 2005. Statistical Methods in the Atmospheric
Sciences, Volume 91, Second Edition (International Geophysics), 2nd
Edition. Academic Press.
}
\seealso{
The \code{verification} package for comprehensive functions for
forecast verification.

Other model evaluation functions: 
\code{\link{TaylorDiagram}()},
\code{\link{conditionalQuantile}()},
\code{\link{modStats}()}
}
\author{
David Carslaw
}
\concept{model evaluation functions}
