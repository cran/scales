% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bounds.R
\name{rescale_max}
\alias{rescale_max}
\title{Rescale numeric vector to have specified maximum}
\usage{
rescale_max(x, to = c(0, 1), from = range(x, na.rm = TRUE))
}
\arguments{
\item{x}{numeric vector of values to manipulate.}

\item{to}{output range (numeric vector of length two)}

\item{from}{input range (numeric vector of length two).  If not given, is
calculated from the range of \code{x}}
}
\description{
Rescale numeric vector to have specified maximum
}
\examples{
rescale_max(1:100)
rescale_max(runif(50))
rescale_max(1)
}
