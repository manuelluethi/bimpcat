set.seed(42)
n_subjects <- 140
n_visits <- 8
age <- sample(seq(20,70), n_subjects, replace=TRUE)
sex <- sample(c("male", "female"), n_subjects, replace=TRUE)
sex_numeric <- as.integer(sex == "female")
height <- round(rnorm(n_subjects, 177.4, 6.52) - 12.4 * sex_numeric, 0)
treatment <- sample(c("A", "B"), n_subjects, replace=TRUE)
treatment_numeric <- as.integer(treatment == "B")
weight <- round(rnorm(n_subjects, 0, 2) + 0.1 * (age - 20) + 0.9 * (height - 152) + rep(50, n_subjects) - 4.5 * sex_numeric, 0)
bmi <- weight / (height / 100)^2
bmi_dev <- (bmi - 22)^2
hepatitis_pre <- sample(c("", "A", "B"), n_subjects, replace=TRUE,
                        prob=c(0.875,0.12,0.005))
# We want to code the hepatitis precondition for building the linear predictor
# (the hepatits precondition is a fixed factor)
hepatitis_pre_coding <- Vectorize(function(s){ 
  if(s == "A"){
    return(1)
  } else if(s == "B"){
    return(5)
  } else {
    return(0)
  }
}, USE.NAMES=FALSE)
hepatitis_pre_numeric <- hepatitis_pre_coding(hepatitis_pre)
# 2 centers:
# VLH = very large hospital
# HSC = highly specialized clinic
center <- sample(c("VLH", "HSC"), n_subjects, replace=TRUE, prob=c(0.93,0.07))
# We code the center as Bernoulli (the center will introduce a random effect)
center_numeric <- as.integer(center == "HSC")
# We introduce 8 visits during which EQ-5D-5L-scores are measured
# We first define the intervals between individual visits
t1 <- 0 # first measurement at time 0 
t2 <- 10 # first follow after approximately 10 days
t3 <- 30 # second after approximately 30 days
t4 <- 90
t5 <- 180
t6 <- 365
t7 <- 730
t8 <- 1450
# We model the time difference between consecutive visits in days. For the
# earlier visits, we cluster them more closely around the planned differemce.
# afterwards we spread them out uniformly. This only introduces noise, since the
# relevant scores actually won't depend on that.
time_diff_V2 <- t2 - t1 + sample(c(-2,-1,0,1,2), n_subjects, replace=TRUE, prob=c(0.1,0.2,0.4,0.2,0.1))
time_diff_V3 <- t3 - t2 + sample(c(-2,-1,0,1,2), n_subjects, replace=TRUE, prob=c(0.1,0.2,0.4,0.2,0.1))
time_diff_V4 <- t4 - t3 + sample(c(-3,-2,-1,0,1,2,3), n_subjects, replace=TRUE, prob=c(0.05,0.1,0.2,0.3,0.2,0.1,0.05))
time_diff_V5 <- t5 - t4 + sample(seq(-5,5), n_subjects, replace=TRUE)
time_diff_V6 <- t6 - t5 + sample(seq(-5,5), n_subjects, replace=TRUE)
time_diff_V7 <- t7 - t6 + sample(seq(-5,5), n_subjects, replace=TRUE,)
time_diff_V8 <- t8 - t7 + sample(seq(-5,5), n_subjects, replace=TRUE)
dt4<- t4 - t3
dt5<- t5 - t4
dt6<- t6 - t5
dt7<- t7 - t6
dt8<- t8 - t7
eq5d5l_names <- c("mobility", "self_care", "usual_activities",
                  "pain_discomfort", "anxiety_depression")
# We define the base linear predictor b for the EQ-5D-5L starting point
# At visit one, the reported EQ-5D-5L scores are obtained as follows. We
# partition the unit interval into five subintervals I1 , ... , I5 and fix a map
# f : R -> (0,1), the standard logistic function. We draw a random real number
# ejd per dimension d and per individual j (i.i.d. standard normal). The score
# at visit one for dimension d and individual j is then given by the unique k
# such that f(b + ejd) is contained in Ik.
eq5d5l_linear_pred_base <- bmi_dev / 5 + hepatitis_pre_numeric / 2 + (age - 45) / 10 + sex_numeric * (age - 55) / 5
categorize <- Vectorize(function(x){
  if(x <= 0.93){
    return(1)
  } else if(x <= 0.99){
    return(2)
  } else if(x <= 0.997){
    return(3)
  } else if(x <= 0.999){
    return(4)
  } else {
    return(5)
  }})
# We construct the eq5d5l scores as lists of data frames
base_df <- as.data.frame(replicate(n_visits, rep(0, n_subjects)))
df_list <- setNames(rep(list(base_df), length(eq5d5l_names)), eq5d5l_names)
df_list <- setNames(
  lapply(names(df_list), 
    function(name){
      names(df_list[[name]]) <- paste0("eq5d5l_", name, "_", names(df_list[[name]]))
      return(df_list[[name]])
    }), 
    eq5d5l_names)
df_list <- setNames(
  lapply(names(df_list), 
    function(name){
      df_list[[name]][,1] <- categorize(plogis(eq5d5l_linear_pred_base + rnorm(n_subjects,0,1)))
      return(df_list[[name]])
  }),
  eq5d5l_names)
# The development of the eq5d5l-scores depends on the treatment
advance_score <- function(scores){
  new_scores <- pmin(5, pmax(1, scores + sample(c(0,-1), n_subjects, replace=TRUE, prob = c(0.65, 0.35)) * treatment_numeric + sample(c(-1,0,1), n_subjects, replace=TRUE, prob=c(0.1, 0.8, 0.1)) + runif(n_subjects) * bmi_dev / 6 + runif(n_subjects) * (age - 40) / 65) )
  return(new_scores)
}
df_list <- setNames(
  lapply(names(df_list), 
    function(name){
      for(i in seq(2,n_visits)){
        df_list[[name]][,i] <- as.integer(advance_score(df_list[[name]][,i-1]))
      }
      return(df_list[[name]])
  }),
  eq5d5l_names)
