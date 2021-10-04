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
library(ggplot2)
require("RColorBrewer")
library(ggcorrplot)
library(cluster)
library(fpc)
library(factoextra)
require(reshape2)

#------------------------------------------
######## PreProcessing #########
#------------------------------------------

data <- read.csv(file = "OnlineSales.csv", 
                 na.strings = c("", " "))

## Prepare Target (Y) Variable
data$Revenue <- factor(data$Revenue)

#Categorical variables
facs <- c("OperatingSystems", "Browser", "Region", "TrafficType", 
          "VisitorType", "Weekend", "Month")

data[ ,facs] <- lapply(X = data[ , facs], 
                       FUN = factor)

unique(data[ ,"Month"])

#Numeric Variables
nums <-  c("Administrative", "Administrative_Duration", "Informational",
           "Informational_Duration", "ProductRelated", "ProductRelated_Duration",
           "BounceRates", "ExitRates", "PageValues", "SpecialDay")

#Combined into one vector
vars <- c(nums, facs)

#Duplicated Data
duplicated<-data[duplicated(data), ]
duplicated
data <- data[!duplicated(data), ]

#Missing data
any(is.na(data))

summary(data)

#------------------------------------------
######## Initial Data exploration #########
#------------------------------------------

#Prevelance of zeros
#Source: 
#Schork, J. (2020). Count Non-Zero Values in Vector & Data Frame Columns in R.
#https://statisticsglobe.com/count-non-zero-values-in-r
colSums(data == 0)

lapply(X = data[ ,c(facs)],FUN = unique)

##Descriptive Statistics
var<-sapply(X = data[ ,nums],FUN = var)

round(var)

sd<-sapply(X = data[ , nums],FUN = sd)

round(sd)

lapply(X = data[ ,c(facs)], FUN = table)

aggregate(formula = data$ProductRelated ~ data$Revenue, 
          data = data, 
          FUN = summary)

#------------------------------------------
## Outliers
#------------------------------------------

dataoutliers <- scale(data[ ,nums])

#A z-score greater than 3 indicates its an outlier
colSums(abs(dataoutliers) > 3)

#------------------------------------------
## BoxPlot
#------------------------------------------

#Examine distribution differences in each variable for True and False Revenue

featurePlot(x = scale(data[ ,nums]),
            y = data$Revenue,
            plot = "box")

#There appears to be some difference in distribution between
#true and false Revenue groups
#A large difference appears in True and False for PageValues

#------------------------------------------
#Crosstabulations
#------------------------------------------
crosstabs <- table(data$VisitorType, data$Revenue,
                   dnn = c("visitor", "revenue"))
crosstabs

aggregate(data[, 1:10], list(data$Revenue), mean)

#------------------------------------------
##Correlation Plot
#------------------------------------------
##Source: 
#Kabacoff, R. (2020, December 1). Data Visualization With R. 
#https://rkabacoff.github.io/datavis/Models.html#Corrplot
r <- cor(data[ ,nums], use="everything")

round(r,2)

ggcorrplot(r, 
           hc.order = TRUE, 
           type = "lower",
           lab = TRUE)

## Redundant Variables (highly correlated)
cor_vars <-cor(x = data[ ,nums])

symnum(x = cor_vars,
       corr = TRUE)

high_corrs <- findCorrelation(x = cor_vars, 
                              cutoff = .75, 
                              names = TRUE)
high_corrs


#------------------------------------------
## Initial Data Visualization
#------------------------------------------

## Pie Chart for Revenue
rtab <- table(data$Revenue)
rtab
lbls1 <- c("No Purchase (84.4%)", "Purchase (15.6%)")
pie(rtab, labels = lbls1, main = "Percent of Website Visitors Who Made a Purchase", col=brewer.pal(2, "Greens"))

## Pie Chart for Visitor Type
vtab <- table(data$VisitorType)
vtab
lbls <- c("New Visitor (13.9%)", " Other", "Returning Visitor (85.4%)")
pie(vtab, labels = lbls, main = "Website Visitor Type", col=brewer.pal(3, "Greens"))  


#------------------------------------------
## Naive Bayes Analysis
#------------------------------------------

#install.packages("ggcorrplot")

## Load libraries
library(caret)
library(rpart)
library(rpart.plot)
library(e1071)

#------------------------------------------
######## PreProcessing #########
#------------------------------------------

data <- read.csv(file = "OnlineSales.csv", 
                 na.strings = c("", " "))

## Prepare Target (Y) Variable
data$Revenue <- factor(data$Revenue)

#Categorical variables
facs <- c("OperatingSystems", "Browser", "Region", "TrafficType", 
          "VisitorType", "Weekend")

data[ ,facs] <- lapply(X = data[ , facs], 
                       FUN = factor)

#Ordidnal Variables
ords <- c("Month")

unique(data[ ,"Month"])

data$Month <- factor(x = data$Month, 
                     levels = c("Feb", "Mar", "May", "June", "Jul", 
                                "Aug", "Sep", "Oct", "Nov", "Dec"),
                     ordered = TRUE)

#Numeric Variables
nums <-  c("Administrative", "Administrative_Duration", "Informational",
           "Informational_Duration", "ProductRelated", "ProductRelated_Duration",
           "BounceRates", "ExitRates", "PageValues", "SpecialDay")

#Combined into one vector
vars <- c(nums, ords, facs)

#Duplicated Data
duplicated<-data[duplicated(data), ]
data <- data[!duplicated(data), ]

summary(data)

## Testing and Training
#------------------------------------------
set.seed(114) 

# Create list of training indices
sub1 <- createDataPartition(y = data$Revenue, # target variable
                            p = 0.85, # % in training
                            list = FALSE)

train1 <- data[sub1, ] # create train dataframe
test1 <- data[-sub1, ] # create test dataframe

#------------------------------------------
######### Naive Bayes #########
#------------------------------------------

## Preprocessing & Transformation
## Redundant Variables
## Remove ProductRelated_Duration and ExitRates

cor_vars <-cor(x = data[ ,nums])

symnum(x = cor_vars,
       corr = TRUE)

high_corrs <- findCorrelation(x = cor_vars, 
                              cutoff = .75, 
                              names = TRUE)
high_corrs

nums1 <- nums[!nums %in% high_corrs]

nums1

vars1<- c(nums1, ords, facs)

# Compare grouped boxplots
featurePlot(x = data[ ,nums], 
            y = data$Revenue,
            plot = "box")

#------------------------------------------
# By assumption, NB expects numeric
# variables to be normally distributed.
# Look at group histogram

melt.data <- melt(data)

ggplot(data = melt.data, aes(x = value)) + 
  stat_density() + 
  facet_wrap(~variable, scales = "free")

# Transform using YeoJohnson transformation 
# and standardization to improve.
# Transform the full data set and then apply it

cen_bcs <- preProcess(x = data[ ,vars1], 
                      method = c("YeoJohnson", "center", "scale"))


train1 <- predict(object = cen_bcs,
                  newdata = train1)

test1 <- predict(object = cen_bcs,
                 newdata = test1)

#Examine transformation
melt.data <- melt(test1)

ggplot(data = melt.data, aes(x = value)) + 
  stat_density() + 
  facet_wrap(~variable, scales = "free")

#------------------------------------------
## Analysis

# Laplace smoothing
aggregate(train1[ ,c(facs,ords)],
          by = list(train1$Revenue),
          FUN = table)

#Create Naive Bayes Model
nb_mod1 <- naiveBayes(x = train1[ ,vars1],
                      y = train1$Revenue,
                      laplace = 1)
nb_mod1

#------------------------------------------

### Model Performance & Fit
## Training Performance

nb1.train <- predict(object = nb_mod1, # NB model
                     newdata = train1[ ,vars1], # predictors
                     type = "class")
head(nb1.train)

# ConfusionMatrix
train_conf1 <- confusionMatrix(data = nb1.train, # predictions
                               reference = train1$Revenue, # actual
                               positive = "TRUE",
                               mode = "everything")
train_conf1


## Testing Performance
nb1.test <- predict(object = nb_mod1, # NB model
                    newdata = test1[ ,vars1], # predictors
                    type = "class")

# ConfusionMatrix() 
test_conf1 <- confusionMatrix(data = nb1.test, # test predictions
                              reference = test1$Revenue, # actual
                              positive = "TRUE",
                              mode = "everything")
test_conf1

## Goodness of Fit
# Overall
cbind(Training1 = train_conf1$overall,
      Testing1 = test_conf1$overall)

# Class-Level
cbind(Training1 = train_conf1$byClass,
      Testing1 = test_conf1$byClass)



#------------------------------------------
######### Naive Bayes 2 #########
#------------------------------------------
## Different Preprocessing:
## combined duration and website visit variables 
## Avoid redundant Variables
## Divide duration by number of website visits
#------------------------------------------
data2 <- transform(data, Avg_ProductRelated = ProductRelated_Duration/ ProductRelated,
                   Avg_Informational = Informational_Duration/ Informational,
                   Avg_Administrative = Administrative_Duration/ Administrative)

#transform#Replace NaN values with 0
data2[is.na(data2)] <- 0

#Remove the old columns
data2 <- data2[ -c(1:6) ]

## New dataframe
summary(data2)

#Keep the ords and fac vectors for the dataframe, but make a new nums
nums2 <-  c("BounceRates", "ExitRates", "PageValues", "SpecialDay",
            "Avg_ProductRelated", "Avg_Informational", "Avg_Administrative", "Month")

#------------------------------------------
## Redundancy?
#------------------------------------------
cor_vars2 <-cor(x = data2[ ,nums2])

symnum(x = cor_vars2,
       corr = TRUE)

high_corrs2 <- findCorrelation(x = cor_vars2, 
                               cutoff = .75, 
                               names = TRUE)
high_corrs2

#Now ExitRates is the only one that is redundant. It will be removed.
nums2 <- nums2[!nums2 %in% high_corrs]
nums2

vars2 <- c(nums2, facs)
vars2
#------------------------------------------
# Examine Distribution prior to transformation
#------------------------------------------
featurePlot(x = data2[ ,nums2], 
            y = data2$Revenue,
            plot = "box")

# By assumption, NB expects numeric variables to be 
# normally distributed. Look at group histogram
require(reshape2)
melt.data2 <- melt(data2)

ggplot(data = melt.data2, aes(x = value)) + 
  stat_density() + 
  facet_wrap(~variable, scales = "free")

#------------------------------------------
#Split into testing and training
#------------------------------------------
sub2 <- createDataPartition(y = data2$Revenue, 
                            p = 0.85, 
                            list = FALSE)

train2 <- data2[sub2, ] 

test2 <- data2[-sub2, ] 

#------------------------------------------
# Transform using YeoJohnson transformation 
# and standardization to improve.
#------------------------------------------
cen_bcs2 <- preProcess(x = data2[ ,vars2], 
                       method = c("YeoJohnson", "center", "scale"))

#apply transformed data to testing and training sets
train2 <- predict(object = cen_bcs2,
                  newdata = train2)

test2 <- predict(object = cen_bcs2,
                 newdata = test2)

#------------------------------------------
#Examine New Distribution of Training and Testing
#------------------------------------------
melt.data <- melt(test_2)

ggplot(data = melt.data, aes(x = value)) + 
  stat_density() + 
  facet_wrap(~variable, scales = "free")

#------------------------------------------
## Analysis
#------------------------------------------
# Laplace smoothing
#------------------------------------------
aggregate(train2[ ,c(facs,ords)],
          by = list(train2$Revenue),
          FUN = table)

#Create Naive Bayes model
nb_mod2 <- naiveBayes(x = train2[ ,vars2],
                      y = train2$Revenue,
                      laplace = 1)
nb_mod2

#------------------------------------------
### Model Performance & Fit
#------------------------------------------
## Training Performance
nb2.train <- predict(object = nb_mod2, # NB model
                     newdata = train2[ ,vars2], # predictors
                     type = "class")
head(nb2.train)

# ConfusionMatrix
train_conf2 <- confusionMatrix(data = nb2.train, # predictions
                               reference = train2$Revenue, # actual
                               positive = "TRUE",
                               mode = "everything")
train_conf2

#------------------------------------------
## Testing Performance
#------------------------------------------
nb2.test <- predict(object = nb_mod2, # NB model
                    newdata = test2[ ,vars2], # predictors
                    type = "class")

# ConfusionMatrix 
test_conf2 <- confusionMatrix(data = nb2.test, # test predictions
                              reference = test2$Revenue, # actual
                              positive = "TRUE",
                              mode = "everything")
test_conf2

#------------------------------------------
## Goodness of Fit
#------------------------------------------
# Overall
"Overall_Performance" <- cbind(Training2 = train_conf2$overall,
                               Testing2 = test_conf2$overall)

Overall_Performance

# Class-Level
"ClassLevel_Performance"<- cbind(Training2 = train_conf2$byClass,
                                 Testing2 = test_conf2$byClass)

round(ClassLevel_Performance, digits=2)
round(Overall_Performance, digits=2)

#Overall, they look balanced.

#------------------------------------------
## Comparing Performance Across NB Models
## Kappa and F1 are slightly higher on Model 2.
#------------------------------------------

# Overall
cbind(NB1 = test_conf1$overall,
      NB2 = test_conf2$overall)

# Class-Level
cbind(NB1 = test_conf1$byClass,
      NB2 = test_conf2$byClass)

