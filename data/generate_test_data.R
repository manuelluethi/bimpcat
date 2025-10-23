set.seed(42)
n <- 140
age <- sample(seq(20,70), n, replace=TRUE)
sex <- sample(c("male", "female"), n, replace=TRUE)
sex_numeric <- as.integer(sex == "female")
height <- round(rnorm(n, 177.4, 6.52) - 12.4 * sex_numeric, 0)
treatment <- sample(c("A", "B"), n, replace=TRUE)
treatment_numeric <- as.integer(treatment == "B")
weight <- round(rnorm(n, 0, 2) + 0.1 * (age - 20) + 0.9 * (height - 152) +
                rep(50, n) - 4.5 * sex_numeric, 0)
bmi <- weight / (height / 100)^2
bmi_dev <- (bmi - 22)^2
hepatitis_pre <- sample(c("", "A", "B"), n, replace=TRUE,
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
center <- sample(c("VLH", "HSC"), n, replace=TRUE, prob=c(0.93,0.07))
# We code the center as Bernoulli (the center will introduce a random effect)
center_numeric <- as.integer(center == "HSC")
# We introduce 4 visits
eq5d5l_names <- c("mobility", "self_care", "usual_activities",
                  "pain_discomfort", "anxiety_depression")
# We define the base linear predictor for the EQ-5D-5L starting point
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
eq5d5l_mobility_V1 <- cat_one(plogis(eq5d5l_linear_pred_base + rnorm(n,0,1)))
eq5d5l_self_care_V1 <- cat_one(plogis(eq5d5l_linear_pred_base + rnorm(n,0,1)))
eq5d5l_usual_activities_V1 <- cat_one(plogis(eq5d5l_linear_pred_base + rnorm(n,0,1)))
eq5d5l_pain_discomfort_V1 <- cat_one(plogis(eq5d5l_linear_pred_base + rnorm(n,0,1)))
eq5d5l_anxiety_depression_V1 <- cat_one(plogis(eq5d5l_linear_pred_base + rnorm(n,0,1)))
# The development of the eq5d5l-scores depends on the treatment
for(i in seq(2,4)){
  eq5d5l_mobility_Vi <- previous with certain probability depending on treatment decreased or raised
}
