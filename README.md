# bimpcat
High-level functionality combining non-parametric bootstrap, imputation, and model fitting involving sequential measurements of categorical data for use in R.

## Motivating use case
The motivation behind this package is the technical nature of computing reasonable confidence intervals for the statistic of interest in health economic analysis, most importantly the so-called ICER, which is a ratio of treatment effects. While there are analytic approaches to determine confidence intervals, e.g., using Fieller's theorem, these are rather complex and often assume a good understanding of the underlying distributions. That's why **bootstrapping** offers an interesting alternative.

In addition, the computation of the ICER is often based on an estimate of the quality of life, which is obtained through scores provided by the study subjects, e.g., the EQ-5D-5L indices. These are usually measured at fixed time intervals and then aggregated to yield a value contained within a fixed interval (with boundary values determined by the time horizon). These measurements of quality of life are often heavily skewed towards the boundaries and exhibit other behavior which render standard approaches like the inverse logit transform raather implausible. Using `mice`, we can **impute** the scores directly. However, imputation of categorical data can be tricky, e.g., since the legitimacy of a given method can depend on the number of levels and different methods have different restrictions. As an example, note that on a given bootstrap sample, the available measurements of a EQ-5D-5L score might be constant, in which case the only reasonable imputation is by the given constant value. This package attempts to handle this problem via pre-defined behaviors. This will be helpful in applications, since the error messages provided by `mice` aren't too verbose.

Finally, consider a highly imbalanced binary predictor. On a given bootstrap sample, the value of the predictor might be constant, in which case most model fits like `lm()` or `glm()` will fail. Hence, this package takes care of adjusting the model for constant predictors before **fitting** to a given bootstrap sample.

## Dependencies
The package uses `dplyr`, `tidyr`, and `mice`.

## Parallelization
For parallelization, we rely on `parallel`, which is included in the base
installation. In the end, the package calls high-level functions passed as
arguments to the methods and any more complicated parallelization requires these
functions to be parallelizable.

## Tested model classes
The package has been tested on the following model classes so far:
- `lm`
- `glm`
- `betareg`
- `glmmTMB`
- `lme4`
