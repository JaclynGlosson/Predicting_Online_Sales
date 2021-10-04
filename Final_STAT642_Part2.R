#------------------------------------------
## STAT 642
## Jaclyn Glosson Final Project
#------------------------------------------
rm(list=ls())

#install.packages("ggcorrplot")

## Load libraries
library(caret)
library(rpart)
library(rpart.plot)
library(e1071)
library(NeuralNetTools)

#------------------------------------------
######## PreProcessing #########
#------------------------------------------

data <- read.csv(file = "OnlineSales.csv", 
                 na.strings = c("", " "))

## Prepare Target (Y) Variable
data$Revenue <- factor(data$Revenue)

#Categorical variables
facs <- c("OperatingSystems", "Browser", "Region", "TrafficType", 
          "VisitorType", "Weekend","Month")

data[ ,facs] <- lapply(X = data[ , facs], 
                       FUN = factor)

#Numeric Variables
nums <-  c("Administrative", "Administrative_Duration", "Informational",
           "Informational_Duration", "ProductRelated", "ProductRelated_Duration",
           "BounceRates", "ExitRates", "PageValues", "SpecialDay")

#Combined into one vector
vars <- c(nums, facs)

#Duplicated Data
duplicated<-data[duplicated(data), ]
data <- data[!duplicated(data), ]

summary(data)

#------------------------------------------
### Class Imbalance
##There is a class imbalance.
##Analysis 2 will address it.
#------------------------------------------

summary(data$Revenue)

plot(data$Revenue,main = "Revenue")

#------------------------------------------
## Analysis 1
## Decision Tree w/ Class Imbalance
#------------------------------------------
## Decision trees handle missing data, redundant data,
## and they don't need standardization.
## Splitting the data into training and testing sets 

set.seed(114) 

sub1 <- createDataPartition(y = data$Revenue, 
                            p = 0.85, 
                            list = FALSE)

train1 <- data[sub1, ] 
test1 <- data[-sub1, ] 

#------------------------------------------
### Hyperparameter Tuning Model
#------------------------------------------

grids <- expand.grid(cp = seq(from = 0,
                              to = 0.05,
                              by = 0.005))
grids

ctrl <- trainControl(method = "repeatedcv",
                     number = 10,
                     repeats = 3,
                     search = "grid")

set.seed(114)

DTFit <- train(form = Revenue ~ ., #y
               data = train1[ ,c(vars, "Revenue")], 
               method = "rpart", 
               trControl = ctrl, 
               tuneGrid = grids)
DTFit
#Optimal cp value is 0.005

confusionMatrix(DTFit)

# Which variables are the most important
#Pagevalues, productrelated, bouncerates
varImp(DTFit)

#------------------------------------------
## Tree Plot
#------------------------------------------
prp(x = DTFit$finalModel, extra = 2) 

#------------------------------------------
## Tuned Model Performance
#------------------------------------------
## Training Performance
## Accuracy .908
## Kappa .628
## Sensitivity .62
## F1 .68
#------------------------------------------
tune.trpreds <- predict(object = DTFit,
                        newdata = train1)

DT_trtune_conf <- confusionMatrix(data = tune.trpreds, 
                                  reference = train1$Revenue, 
                                  positive = "TRUE",
                                  mode = "everything")
DT_trtune_conf

#------------------------------------------
## Testing Performance
## Accuracy .89
## Kappa .585
## Sensitivity .625
## F1 .647
#------------------------------------------
tune.tepreds <- predict(object = DTFit,
                        newdata = test1)

DT_tetune_conf <- confusionMatrix(data = tune.tepreds, 
                                  reference = test1$Revenue,
                                  positive = "TRUE",
                                  mode = "everything")
DT_tetune_conf

#------------------------------------------
## Goodness of Fit
#------------------------------------------
# Overall
Analysis1Overall <- cbind(Training = DT_trtune_conf$overall,
      Testing = DT_tetune_conf$overall)

Analysis1Overall

# Class-Level
Analysis1Class <-cbind(Training = DT_trtune_conf$byClass,
      Testing = DT_tetune_conf$byClass)

Analysis1Class
#------------------------------------------
## Analysis 2
## Decision Tree without Class Imbalance
#------------------------------------------
## Class imbalanced will be addressed using
## Case weighting
#------------------------------------------

target_var <- train1$Revenue # identify target variable

weights <- c(sum(table(target_var))/(nlevels(target_var)*table(target_var)))

weights

# Use case weights
wghts <- weights[match(x = target_var, 
                       table = names(weights))]
set.seed(114)

DTFit2 <- train(form = Revenue ~ ., #y
               data = train1[ ,c(vars, "Revenue")], 
               method = "rpart", 
               trControl = ctrl, 
               tuneGrid = grids,
               weights = wghts)
DTFit2

# Which variables are the most important
#Pagevalues, Exit Rates, ProductRelated_Duration,
# BounceRates, ProductRelated.
varImp(DTFit2)

plot(varImp(DTFit2))

#------------------------------------------
## Tree Plot
#------------------------------------------
prp(x = DTFit2$finalModel, extra = 2) 

#------------------------------------------
## Tuned Model & Balanced Class Performance
#------------------------------------------
## Training Performance
## Accuracy .87
## Kappa .602
## Sensitivity .83
## F1 .67
## Though our accuracy is lower than analysis 1,
## our sensitivity is much higher.
#------------------------------------------

tune.trpreds2 <- predict(object = DTFit2,
                         newdata = train1)

DT_trtune_conf2 <- confusionMatrix(data = tune.trpreds2, 
                                   reference = train1$Revenue, 
                                   positive = "TRUE",
                                   mode = "everything")
DT_trtune_conf2

#------------------------------------------
## Testing Performance
## Accuracy .874
## Kappa .602
## Sensitivity .83
## F1 .67
#------------------------------------------
tune.tepreds2 <- predict(object = DTFit2,
                         newdata = test1)

DT_tetune_conf2 <- confusionMatrix(data = tune.tepreds2, 
                                   reference = test1$Revenue,
                                   positive = "TRUE",
                                   mode = "everything")
DT_tetune_conf2

#------------------------------------------
## Goodness of Fit
## The model is balanced, with no under or
## overfitting.
#------------------------------------------
# Overall
Analysis2Overall <- cbind(Training = DT_trtune_conf2$overall,
                          Testing = DT_tetune_conf2$overall)

round(Analysis2Overall,2)

# Class-Level
Analysis2Class <-cbind(Training = DT_trtune_conf2$byClass,
                       Testing = DT_tetune_conf2$byClass)

round(Analysis2Class,2)
#------------------------------------------
## Compare with and without class imbalance 
#------------------------------------------

A1andA2OverallTesting <- cbind(TestCA = DT_tetune_conf$overall,
                               TestNoCA = DT_tetune_conf2$overall)
A1andA2OverallTesting

A1andA2ClassTesting <- cbind(TestCA = DT_tetune_conf$byClass,
                                TestNoCA = DT_tetune_conf2$byClass)
A1andA2ClassTesting

## Sensitivity and F1 are higher for our Analysis 2, our model
## without class imbalance.
