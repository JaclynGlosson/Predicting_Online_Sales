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

