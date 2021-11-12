# Predicting Online Sales

The objective if this project was to use webtraffic data to predict customer purchasing beahvior for a hypothetical online retailer. The company will tailor their advertising based on these predictions, and advertising will be targeted to those customers who have already visited the company website. When the model results in an inaccurate revenue prediction, the company needlessly spends advertising revenue. This project utilizes both Decision Tree and Naive Bayes methods for prediction. The final recommended Decision Tree model, which corrected for class imbalance, correctly predicted who would purchase from the company in 80% of cases, and was able to predict who would not purchase from the company in 86% of cases.

## Navigating My Files

* Final_STAT642_Part1.R includes the overall initial data exploration and two Naive Bayes models. The first Naive Bayes removes redundant variables while the second transforms them. 
* Final_STAT642_Part2.R includes two Decision Tree models. The first does not address class imbalance, while the second applies case weighting. 
* The PDF file details an excutive report tailored for a business audience, of which this readme is based upon.

## The Data

The data consisted of 18 variables with over 12,000 observations. The dataset includes historical website data for an entire calendar year, excluding the months of January and April. **Revene is the variable of interest for prediction,** and is a binary variable describing if a website visit resulted in a purhcase or not. Other variables are described below.

**Numerical Variables**
| Variable  | Description |
| ------------- | ------------- |
| Administrative | number of administrative pages visited by the site visitor  |
| Administrative Duration  | time spent on administrative pages  |
| Informational | number of informational pages visited by the site visitor |
| Informational Duration | time spent on informational pages |
| BounceRates | the percentage of visitors who enter the site from that page and then leave ("bounce") without triggering any other requests to the analytics server during that session |
| ProductRelated  | number of product related pages visited by the site visitor |
| ProductRelated Duration | time spent on product related pages |
| Exit Rates | calculated as for all page views to the page, the percentage that were the last in the session |
| PageValue | represents the average value for a web page that a user visited before completing an ecommerce transaction |
| SpecialDay | feature indicates the closeness of the site visiting time to a specific special day (e.g.Mother’s Day, Valentine's Day) |

**Categorical Variables**
| Variable  | Description |
| ------------- | ------------- |
| Month | month of visit  |
| Operating System | operating system of visitor  |
| Browser	 | browser type of visitor  |
| Region | regional location of visitor  |
| TrafficType | type of web traffic to the website  |
| VisitorType | indicates whether the visitor is a new or returning visitor  |
| Weekend	 | indicates if the visit occurs on a weekend   |

## Data Quality

There were no missing values in the data set, and 125 duplicate observations were identified and removed. The majority of numeric variables have a large prevalence of meaningful zero values. For instance; a zero in Administrative, Informational, and Product Related indicate the website visitor did not visit those respective sites. When this occurs, the time spent on the website page (Administrative Duration, Informational Duration, ProductRelated Duration) will likewise be zero. Due to the prevalences of zeros in the data, nearly all numeric distributions are right tailed. In general, there is wide variation across all numeric variables, in part due to the prevalence of zero values in each variable. All numeric variables contain a large number of outliers, as indicated by an observation with a  Z-score greater than 3). Therefore, the dataset as a whole contains large amounts of noise and skew.

![Box plots](https://github.com/JaclynGlosson/Predicting_Online_Sales/blob/1a9e360956d0b15d62fb9368379e1485c50ef780/readme_images/image9.png)
![distrubitions](https://github.com/JaclynGlosson/Predicting_Online_Sales/blob/150e7de0120d638488200fcb59eb1c94c9985e86/readme_images/image8.png)

| Variable  | Percent "0" value | Number of Outliers |
| ------------- | ------------- | ------------- |
| Administrative | 46.2%  | 213 |
| Administrative Duration | 47.3% | 230 |
| Informational | 78.4% | 260 |
| Informational Duration | 80.3% | 229 |
| BounceRates | 45.2% | 593 |
| ProductRelated | 0.3% | 236 |
| ProductRelated Duration | 5.2% | 217 |
| Exit Rates | 0.6% | 599 |
| PageValue | 77.6% | 257 |
| SpecialDay | 90% | 478 |


## Exploratory Data Analysis

### Corrleations
High correlations are observed between a webpage visit and visit duration. The number of Product Related web page visits is strongly associated with duration spent on Product Related web pages. Indeed, all webpage visits and durations are positively correlated with one another, such that visiting and spending time on one type of webpage is associated with visiting and spending time on another type of webpage. Bounce Rates and Exit Rates are strongly associated with each other as well.

![correlation plot](https://github.com/JaclynGlosson/Predicting_Online_Sales/blob/8b92e47e75cba94b7a911915f12c3aa740bc61d8/readme_images/image6.png)


### Class Imbalance 
A class imbalance is observed in our variable of interest, Revenue. The majority (84.4%) of all observed website visits did not result in a purchase, while 15.6% of website visits did result in a purchase. This imbalance will be considered in final analysis.

### Variation Over Time
Purchases were time variant. The number of website visitors who made a purchase sharply increased in March, May, November, and December. These months also saw the greatest amount of website foot traffic.

![sales over time](https://github.com/JaclynGlosson/Predicting_Online_Sales/blob/8b92e47e75cba94b7a911915f12c3aa740bc61d8/readme_images/image10.png)

### Comparisons of Purchase vs No Purchase Per Variable
Those who purchased visited, on average, more company web pages. The largest difference in the number of pages visited was for product related pages. Those who purchased spent more time, on average, on the company’s web pages. The largest difference in time between those who did and did not purchase was observed in time spent on product related pages. Those who purchased entered the company website from a page with a lower average Bounce Rate. Those who purchased exited the company website from a page with a lower average Exit Rate.Those who purchased had, on average, a higher PageValue than those who did not. Those who purchased visited the site, on average, closer to a specific special day.

| Variable  | Purchase | No Purchase |
| ------------- | ------------- | ------------- |
| Administrative | 3.4 | 2.1 |
| ProductRelated | 48 | 29 |
| Informational | 0.8 | 0.5 |
| ProductRelated Duration | 1,876 seconds| 1,082 seconds |
| Administrative Duration | 119 seconds | 75 seconds |
| Informational Duration | 58 seconds| 30 seconds |
| BounceRates | 0.5% | 2.3% |
| Exit Rates | 2% | 4.6% |
| PageValue | 27 | 2 |
| SpecialDay | 0.02 | 0.070 |

## Decision Tree Analysis
The Decision Tree method was selected for analysis due to robustness against redundant features, noise, and irrelevant attributes- all of which are present in the current dataset. Within the current data set, high correlations between website visits and website duration variables suggest redundancy. Furthermore, outliers are prevalent throughout the dataset. The decision tree method was chosen due to the prevalence of redundancy and noise in the data set. Two models were run to compare model fit: the first model had no additional transformations, while the second model corrected for class imbalance. The second model outperformed the first and is described below.

### Data Pre-Processing and Transformation
As decision tree models do not require standardization, no normalization transformation was performed. Class imbalance was present in the “Revenue” variable and was corrected using case weighting in order to increase specificity. Eighty-five percent of data was used for model training with the remaining fifteen percent used for model testing and validation. Complexity Parameter (cp) was utilized for hyperparameter tuning. The cp value imposes a penalty to the tree for having too many splits, setting a minimum improvement value that an additional split must add to be included in the tree. In this analysis, the cp associated with the highest accuracy was found to be 0.005. A 10-fold cross validation was utilized. The most important variables identified for predicting Revenue were PageValues, ExitRates, ProductRelated_Duration, BounceRates, and ProductRelated, with PageValues being the primary variable utilized in the decision tree.

### Validation and Performance Measures
The model resulted in a balanced goodness of fit between training and testing performance. The trained model was able to accurately predict 1,362 customers would not generate revenue, and that 239 customers would generate revenue. The model inaccurately predicted that 182 customers would generate revenue, and that 47 customers would not generate revenue. The model resulted in an accuracy of 87.5%, a moderate Kappa of 60.2%, a Sensitivity of 85%, and a Specificity of 88.2%. The model was able to correctly predict who would purchase from the company at an approximate rate of 84%, and who would not purchase from the company at an approximate rate of 88%.

![Decision Tree output](https://github.com/JaclynGlosson/Predicting_Online_Sales/blob/1342de8bc664d72ba88d864a2e798fdbe5ade18c/readme_images/image11.png)
![Decision Tree](https://github.com/JaclynGlosson/Predicting_Online_Sales/blob/235d37a50cdc5689bc80960a4b456c43e35c8377/readme_images/image3.png)

## Naive Bayes Analysis
The Naive Bayes method was selected for analysis due to its ability to incorporate categorical variables, which are present in the dataset. For this method, redundant variables must be removed and numeric variables should approximate normal distribution. Seven variables were identified as potentially redundant variables. Redundancy was handled using variable transformation and/or removal. Three models were run to compare model fit. The first model removed “ProductRelated_Duration” and “ExitRates” due to redundancy. The second model transformed the six website duration and visit variables into three variables representing average visit duration for each web page type. The third model attempted to correct for class imbalance using under and overfitting. The second model outperformed the others, and is described below.

### Data Pre-Processing and Transformation
Redundant variables were identified using a correlation matrix. The following seven variables were identified as highly correlated: Administrative, Administrative_Duration, Informational, Informational_Duration, ProductRelated, ProductRelated_Duration, ExitRates. As the variables website visits and website visit duration were highly correlated, they were combined by dividing the visit duration by the number of visits to achieve an average visit duration. This transformation results in three new variables: “Avg_ProductRelated”, “Avg_Informational”, and “Avg_Administrative”. The variable “ExitRates” was removed due to a high correlation with “BounceRates”. The final dataset included 15 variables. As the Naive Bayes method requires normal distribution, the data was standardized and transformed using YeoJohnson Transformation. Eighty-five percent of data was used for model training with the remaining fifteen percent used for model testing and validation. Laplace Smoothing was applied to prevent model distortion.

### Validation and Performance Measures
The model resulted in a balanced goodness of fit between training and testing performance. The trained model was able to accurately predict 1,331 customers would not generate revenue, and that 228 customers would generate revenue. The model inaccurately predicted that 213 customers would generate revenue, and that 58 customers would not generate revenue. The Naive Bayes model resulted in an accuracy of 85.2%, a moderate Kappa of 54%, and a Sensitivity of 80%. The model was able to correctly predict who would purchase from the company at an approximate rate of 80%. The model was able to correctly predict who would not purchase from the company at an approximate rate of 86%.

![Naive Bayes Output](https://github.com/JaclynGlosson/Predicting_Online_Sales/blob/1a9e360956d0b15d62fb9368379e1485c50ef780/readme_images/image2.png)

## DISCUSSION AND CONCLUSION
In all models run, the decision tree outperformed the Naive Bayes and is therefore recommended for use. The decision tree model will be able to correctly predict who will purchase from the company at an approximate rate of 84%, and who will not purchase from the company at an approximate rate of 88%. The business will be able to use these predictions to target their marketing audience more accurately, and in doing so will avoid spending marketing resources on those unlikely to purchase. The analysis revealed the most important variables for the business to continue collecting data on, the most vital of which was the PageValue variable. The business should prioritize collecting this type of data, as well as the other variables of ExitRates, ProductRelated_Duration, BounceRates, and ProductRelated. All other variables do not need to be collected, thus the company can save resources and time in avoiding unnecessary data collection. 
