# Predicting Online Sales

The objective if this project was to use webtraffic data to predict customer purchasing beahvior for a hypothetical online retailer. The company will tailor their advertising based on these predictions, and advertising will be targeted to those customers who have already visited the company website. When the model results in an inaccurate revenue prediction, the company needlessly spends advertising revenue. This project utilizes both Decision Tree and Naive Bayes methods for prediction. The final recommended Decision Tree model, which corrected for class imbalance, correctly predicted who would purchase from the company in 80% of cases, and was able to predict who would not purchase from the company in 86% of cases.

## Navigating My Files

* Final_STAT642_Part1.R includes the overall initial data exploration and two Naive Bayes models. The first Naive Bayes removes redundant variables while the second transforms them. 
* Final_STAT642_Part2.R includes two Decision Tree models. The first does not address class imbalance, while the second applies case weighting. 
* The PDF file details an excutive report tailored for a business audience. 

## The Data

The data consisted of 18 variables with over 12,000 observations.

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
