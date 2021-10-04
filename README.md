# Predicting_Online_Sales

For my final project in STAT 642 (Data Mining), I used webtraffic data to predict purchasing behavior for an online retailer. The data included redundant variables, irrelevant variables, correlated variables, as well as large amounts of variation and noise. Decision Tree and Naive Bayes methods were compared. 

The final recommended Decision Tree model, which corrected for class imbalance, correctly predicted who would purchase from the company at a rate of approximately 80%, as well as who would not purchase from the company at a rate of approximately 86%.

Final_STAT642_Part1.R includes initial data exploration, descriptives, visualizations, and two Naive Bayes models. The first Naive Bayes removes redundant variables while the second transforms them. Final_STAT642_Part2.R includes two Decision Tree models. The first does not address class imbalance, while the second applies case weighting.


