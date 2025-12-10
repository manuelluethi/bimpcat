
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bimpcat

<!-- badges: start -->

<!-- badges: end -->

High-level functionality combining non-parametric bootstrap, imputation,
and model fitting involving sequential measurements of categorical data
for use in R.

## Description and motivation

The motivation behind this package is the technical nature of computing
reasonable confidence intervals for the statistic of interest in health
economic analysis, most importantly the so-called ICER, which is a ratio
of treatment effects. While there are analytic approaches to determine
confidence intervals, e.g., using Fieller’s theorem, these are rather
complex and often assume a good understanding of the underlying
distributions. That’s why **bootstrapping** offers an interesting
alternative.

In addition, the computation of the ICER is often based on an estimate
of the quality of life, which is obtained through scores provided by the
study subjects, e.g., the EQ-5D-5L indices. These are usually measured
at fixed time intervals and then aggregated to yield a value contained
within a fixed interval (with boundary values determined by the time
horizon). These measurements of quality of life are often heavily skewed
towards the boundaries and exhibit other behavior which render standard
approaches like the inverse logit transform rather implausible. Using
`mice`, we can **impute** the scores directly. However, imputation of
categorical data can be tricky, e.g., since the legitimacy of a given
method can depend on the number of levels and different methods have
different restrictions. As an example, note that on a given bootstrap
sample, the available measurements of a EQ-5D-5L score might be
constant, in which case the only reasonable imputation is by the given
constant value. This package attempts to handle this problem via
pre-defined behaviors. This will be helpful in applications, since the
error messages provided by `mice` aren’t too verbose.

Finally, consider a highly imbalanced binary predictor. On a given
bootstrap sample, the value of the predictor might be constant, in which
case most model fits like `lm()` or `glm()` will fail. Hence, this
package takes care of adjusting the model for constant predictors before
**fitting** to a given bootstrap sample. In the absence of random
effects, this is easily achieved using `terms()`. Surprisingly, I didn’t
find a direct way to remove/adapt random effects programmatically.
Therefore this package also implements this procedure, using
functionality provided by `lme4` and `reformulas` (and avoiding the use
of regular expressions).

The goal was to implement the functionality in as flexible a manner as I
could imagine. Therefore, we use the `R6` package to define classes with
properties and methods which allow us to interact with intermediate
results at any time, possibly changing model specifications along the
way, extending the number of bootstraps, and so on, without having to
rerun the procedure from scratch.

**Caveat:** As a consequence of the approach chosen, some of the usual
R-syntax might fail when used with this package. Our goal is to
eventually write wrappers for all public methods, i.e., so that we can
call `> fit(model, object)` instead of `object$fit(model)`. But this
might take some time.

## Dependencies

The package uses `dplyr`, `tidyr`, `R6`, `lme4`, `reformulas`, and
`mice`.

## Parallelization

For parallelization, we rely on `parallel`, which is included in the
base installation. In the end, the package calls high-level functions
passed as arguments to the methods and any more complicated
parallelization requires these functions to be parallelizable.

## Tested model classes

The package has been tested on the following model classes so far: -
`lm` - `glm` - `betareg` - `glmmTMB` - `lme4`

<!---
## Installation
&#10;You can install the development version of bimpcat from
[GitHub](https://github.com/) with:
&#10;``` r
# install.packages("pak")
pak::pak("manuelluethi/bimpcat-dev")
```
--->

## Example

I will soon provide an example which shows the package in action:

``` r
library(bimpcat)
## basic example code
```
