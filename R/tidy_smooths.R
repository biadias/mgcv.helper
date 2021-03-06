#' Tidy Data Frame of Smooth Terms
#'
#' Returns a tidy data frame containing the mean and confidence intervals
#' for fitted smooths from a model of class \code{"gam"} from package
#' \code{"mgcv"}.
#' @param object a fitted model object of class \code{"gam"}.
#' @param dimension the dimension of the smooths that are desired for extraction.
#' @param parm a specification of which parameters are to be given confidence
#' intervals, either a vector of numbers or a vector of names. If missing, all
#' parameters are considered (not yet implemented).
#' @param level the confidence level required.
#' @param ... not implemented
#'
#' @return A tidy data frame containing parameter names, estimates and
#' confidence intervals for non-parametric terms
#'
#'
#' @importFrom tibble as.tibble
#' @importFrom dplyr filter
#' @importFrom mgcv plot.gam
#' @importFrom stats qt
#'
#' @export tidy_smooths
#' @export
#'
#' @examples
#' set.seed(101)
#' library(dplyr)
#' library(mgcv)
#' library(mgcv.helper)
#' dat <- data.frame(x = runif(n=100),
#'                   y = runif(n=100)) %>%
#'   dplyr::mutate(z = rnorm(n=100,
#'                    mean = 1 - 2*x - sin(2*pi*y),
#'                    sd = 0.1))
#'
#' fit1 <- gam(data=dat, z ~ y + s(x))
#'
#' tidy_smooths(fit1, dimension=1)
#'
#'
#'


#' @export
tidy_smooths <- function(object, dimension=1, level=0.95, parm=NULL){

  if (!(dimension %in% c(1,2))){
    stop("Unsupported smooth dimension. Please choose dimension = 1 or 2")
  }

  extract_smooth_internal <- function(X, dimension){



    if (dimension == 1){
      tidied <- with(X,
                     data.frame(x=x,
                                y=fit,
                                ymin=fit - se*se.mult,
                                ymax=fit + se*se.mult,
                                xlab=xlab,
                                ylab=ylab))

    }

    if (dimension == 2){
      tidied <- with(X,
                     data.frame(x=x,
                                y=y,
                                z=fit,
                                zmin=fit - se*se.mult,
                                zmax=fit + se*se.mult,
                                xlab=xlab,
                                ylab=ylab,
                                main=main))

    }



    return(tidied)

  }

  # this is awful practice
  get_lengths_internal <- function(x){
    unlist(lapply(x[c("x", "y","fit")], FUN="length"))
  }

  # can only handle 1 and 2d smooths at this point

  list.object <- mgcv::plot.gam(object,
                                select=0,
                                se=abs(stats::qt(p = (1-level)/2,
                                                 df = object$df.residual)))



  lengths <- lapply(FUN = get_lengths_internal, list.object)
  dimensions <- sapply(X = lengths,
                       FUN = function(x){"y" %in% names(x)}) + 1

  plot.me <- which(dimensions == dimension)

  if (is.null(parm)){
    parm <- unlist(lapply(X=list.object, FUN = function(x){c(x$xlab, x$ylab)}))
  }

  return(filter(tibble::as_tibble(do.call(rbind, lapply(X = list.object[plot.me],
                                                 FUN = extract_smooth_internal,
                                                 dimension=dimension))),
                xlab %in% parm | ylab %in% parm))

}

