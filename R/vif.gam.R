#' Variance Inflation Factor
#'
#' This function takes a fitted mgcv model object and returns a data frame of
#' variance inflation factors
#'
#' @param object An object of class gam
#'
#' @return VIF.df A data frame consisting of the VIF values for each parametric
#' term in a fitted Generalised Additive Model
#'
#' @importFrom stats var
#' @importFrom mgcv summary.gam
#' @importFrom tibble tibble
#' @importFrom magrittr "%>%"
#' @export vif.gam
#' @export
#'
#' @examples
#'
#' library(mgcv)
#' library(dplyr)
#'
#' set.seed(101)

#' N <- 100
#' x1 <- runif(n=N)
#' x2 <- runif(n=N)
#' x3 <- runif(n=N) + 0.9*x1 - 1.75*x2
#'
#' df <- data.frame(x1 = x1,
#'                  x2 = x2,
#'                  x3 = x3) %>%
#'   mutate(y = rnorm(n=N,
#'                    mean = 1 - 2*x1 + 3*x2 - 0.5*x3,
#'                    sd = 0.5))
#'
#' fit1 <- gam(data=df, y ~ x1 + x2 + x3)
#'
#' summary(fit1)
#'
#' vif.gam(fit1)
#'
vif.gam <- function(object){

  obj.sum <- mgcv::summary.gam(object)

  s2 <- object$sig2 # estimate of standard deviation of residuals
  X <- object$model # data used to fit the model
  n <- nrow(X) # how many observations were used in fitting?
  v <- -1 # omit the intercept term, it can't inflate variance
  varbeta <- obj.sum$p.table[v,2]^2 # variance in estimates
  selected_col <- row.names(obj.sum$p.table)[v]
  selected_col <- gsub("TRUE", "", selected_col)
  varXj <- apply(X=X[, selected_col],MARGIN=2, var) # variance of all the explanatory variables
  VIF <- varbeta/(s2/(n-1)*1/varXj) # the variance inflation factor, obtained by rearranging
  # var(beta_j) = s^2/(n-1) * 1/var(X_j) * VIF_j

  VIF.df <- tibble::tibble(variable=names(VIF),
                           vif=VIF)

  return(VIF.df)
}
