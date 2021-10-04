#------------------------------------------
## STAT 642
## Jaclyn Glosson Final Project
#------------------------------------------

#Clear 
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

#------------------------------------------
## Analysis 3
## Random Forest
#------------------------------------------

# Model Hyperparameter:
# mtry: m, the number of random predictors to
#       use to split on, is 4
floor(sqrt(length(vars)))

# Grid search, searching from 2 variables
# to the total number of predictors
grids = expand.grid(mtry = seq(from = 4, 
                               to = length(vars), 
                               by = 1))
grids

# Perform 5-fold cross validation, repeated 3 
# times and specify search = "grid" for a grid search. 
grid_ctrl <- trainControl(method = "repeatedcv",
                          number = 5,
                          repeats = 3,
                          search="grid")

set.seed(114)

# Train the Random Forest model using 5-Fold Cross 
# Validation (repeated 3 times). tuneGrid = grids,
# so that grid is used in the grid search
fit.rf <- train(x = train1[ ,vars], # use vars as predictors
                y = train1$Revenue, # predict delay variable 
                method = "rf", 
                trControl = grid_ctrl,
                tuneGrid = grids)

# View cross validation results
# The output will identify the optimal
# mtry based on Accuracy.
fit.rf

# Use the best fitting model performance 
# to compare to our other model's testing performance
confusionMatrix(fit.rf)

# Variable Importance
plot(varImp(fit.rf))

### Testing Performance

# We use the predict() function to generate 
# class predictions for our testing data set
tune.te.preds <- predict(object = fit.rf,
                         newdata = test1)

# We can use the confusionMatrix() function
# from the caret package to obtain a 
# confusion matrix and obtain performance
# measures for our model applied to the
# testing dataset (test).
RF_tetune_conf <- confusionMatrix(data = tune.te.preds, # predictions
                                  reference = test1$Revenue, # actual
                                  positive = "True",
                                  mode = "everything")
RF_tetune_conf


#------------------------------------------
## Analysis 4
## Artificial Neural Network
#------------------------------------------

# ANN can handle redundant variables, but 
# categorical variables need to be binarized 
# and rescaling should be done
# Rescaling will be done during hyperparameter tuning

#------------------------------------------
# Binarize Categorical Variables
#------------------------------------------
# If categorical input (X) variables are 
# used in analysis, they must be converted
# to binary variables using the class2ind()
# function from the caret package for 
# categorical variables with 2 class levels and
# the dummyVars() function from the caret 
# package and the predict() function for
# categorical variables with more than 2
# class levels.

summary(data)

summary(data[,facs])

unique(data[ ,"TrafficType"])

# I will remove OperatingSystems, Browser, Region, Traffic Type, 
# because they have too many levels to make binary
# Weekend is the only one with two class levels, binarize using class2ind()
# VistorType and Month will be binarized via dummyVars()
# First, binarize Weekend

data$Weekend <-class2ind(data$Weekend)

# Next, binarize VisitorType and Month

cats <- dummyVars(formula =  ~ VisitorType + Month,
                  data = data)

cats_dums <- predict(object = cats, 
                     newdata = data)

# Combine binarized variables (cats_dum) with data
# excluding the VisitorType and Month factor variables and
# removing OperatingSystems, Browser, Region, Traffic Type

bin2<- c("VisitorType","Month","OperatingSystems","Browser","Region","TrafficType")

data_dum <- data.frame(data[ ,!names(data) %in% bin2],
                     cats_dums)

#------------------------------------------
## Training & Testing
#------------------------------------------

set.seed(114) 

sub <- createDataPartition(y = data_dum$Revenue, 
                           p = 0.85, 
                           list = FALSE)

trainANN <- data_dum[sub, ] 
testANN <- data_dum[-sub, ]

#------------------------------------------
## Correct for class imbalance
#------------------------------------------
target_var <- trainANN$Revenue 

weightsANN <- c(sum(table(target_var))/(nlevels(target_var)*table(target_var)))

weightsANN

# Use case weights
wghtsANN <- weightsANN[match(x = target_var, 
                       table = names(weightsANN))]

#------------------------------------------
## Hyperparameter Tuning
#------------------------------------------
# Find the optimal number of hidden nodes
# and weight decay.  Use the nnet package 
# (method = "nnet").
# Size: number of nodes in the hidden layer. 
# (There can only be one hidden layer using nnet)
# Decay: weight decay, used to avoid overfitting, 
# values typically range between 0.01 - 0.1.
# I will use a grid search and 5-fold cross
# validation repeated 3 times.

# Set up the grid for the size and decay hyperparameters
grids <-  expand.grid(size = seq(from = 3, 
                                 to = 9, 
                                 by = 2),
                      decay = seq(from = 0,
                                  to = 0.1,
                                  by = 0.01))
grids

ctrl <- trainControl(method = "repeatedcv",
                     number = 5, # 5 folds
                     repeats = 3, # 3 repeats
                     search = "grid") # grid search

set.seed(114)

# Train the ANN model using 5-Fold Cross Validation (repeated 3 times)
annMod <- train(form = Revenue ~., 
                data = trainANN, 
                preProcess = "range", # apply min-max normalization
                method = "nnet", 
                trControl = ctrl, 
                maxit = 50, 
                tuneGrid = grids,
                weights = wghtsANN,
                trace = FALSE) # suppress output


# View the Accuracy and Kappa and get the
# optimal values of size and decay
annMod
#The final values used for the model were size = 5 and decay = 0.02.
# Without correcting for class imbalance, Accuracy was 0.9001450 
# and Kappa was 0.5866883; nearly equivalent to random guessing
#with correcting class imbalande size 7     decay 0.06  accuracy 0.8530127  kappa 0.5422278



