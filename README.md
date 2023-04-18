# Cyber-attacks-PCA-analysis
Data cleaning and analysis of network attack snapshots.

## Exploratory Data Analysis

Prior to cleaning and adjustment of the dataset, there was conducted an exploratory analysis on a subset of 600 randomly selected samples extracted from the dataset ‘MLData2023.cvs’.

### Summary of categorical features.

![image](https://github.com/pedro-vasconcelos-costa/Cyber-attacks-PCA-analysis/blob/main/images/img_%20cat%20features.png)
 
### Summary of continuous features. 
 
![image](https://github.com/pedro-vasconcelos-costa/Cyber-attacks-PCA-analysis/blob/main/images/img_%20cont%20features.png)

## Exploratory examination. 

### Categorical Data

The dataset contains 05 categorical features:  IPV6.Traffic, Operating.System, Connection.State, Ingress.Router and Class. As shown in table(i), Class, Ingress Router and Connection State did not present any missing or invalid observations. The feature Operating System also did not contain invalid values but it contains some less specific categories such as “Windows(unknown) and Linux(unknown) which represent 40.5% and 0.3% respectively, amounting to almost half of the observations. IPV6 Traffic on the other hand, presents 42 (7.0%) non-existing values and 153 (25.5%) of invalid values “ - “, together they amount to a very significant 32.5% of the total instances analysed. 
Additionally, to address the main objective of assisting the identification of malicious events, there was performed a cross examination between the categorical features and the provided classification of the 'events (Class). The plots below evidence the correlation between each category and malicious and non-malicious events. 

![image](https://github.com/pedro-vasconcelos-costa/Cyber-attacks-PCA-analysis/blob/main/images/img_%20cat%20by%20class.png)

As we can identify, the categories “INVALID” and “RELATED” from the feature Connection State contain a much greater representation of events classified as malicious, 83.6% and 100.0% respectively. Such as the “Linux (unknown)” category from Operating System with 100%. It is important to note that the referred categories “RELATED” (9 (1.5%)) and “Linux (unknown)” (2 (0.3%)) account for a small number of observations. With 183 (30.5%) observations, the category “INVALID”  makes for a much stronger piece of evidence.

### Continuous Data

As shown in table(ii), only Assembled Payload Size contains obvious outliers (9) that were characterised as missing values, as assembled payloads are not deemed to have negative values.
For further identification of outliers, first we tested the assumption of normality of each feature with the Pearson Chi-square test. Only 02 of the variables presented a p-value of above 0.05 and could have its outliers identified by a z-score test: Response Size contained 01(0.17%) outlier and Source Ping Time 04 (0.67%) outliers. For the remaining features, the identification of outliers relied on the combination of considering the distribution characteristics of the data. Obtaining the observations outside +-1.5* IQR and visual analysis of their respective histograms and boxplots. Excluding the previously identified 9 (1.50%) missing values, Assembled Payload Size contains no other outliers. The highest number of non-obvious outliers, 5 (0.83%) was found in Connection Rate. DYNRiskA Score and Packet TTL contain 04 (0.67%) outliers each, while no outliers 0 (0%) were found in Server Response Packet Time, Packet Size and Source IP. For Packet Size, the +-1.5* IQR function does point to 01 outlier, just slightly outside the limit, but after analysing the plots and distribution of the data it was decided to overrule formula’s outcome.

![image](https://github.com/pedro-vasconcelos-costa/Cyber-attacks-PCA-analysis/blob/main/images/img_%20outliers.png)

# PCA Analysis

Principal Component Analysis is a statistical method used to simplify complex datasets into lower dimension spaces, while retaining its most significant patterns, so we can better understand the variations in the data. On this case, it is used to aid in the understanding of which features have greater influence on the separation of the dataset provided, into the classes of malicious and non-malicious events.

## Data Cleaning

	The values deemed as outliers or invalid compromise 26 observations when considering the continuous features only. Removing the identified outliers, which represent 4.33% of the sample used for performing PCA is considered an acceptable level of data reduction that helps to mitigate the potential bias caused by the outliers.
  
## Export Data

	The cleaned version of the subset with 600 observations is available on a cvs file as: “mydata.cvs”. 

## Principal Component Analysis

For performing the PCA on the sample the data was standardised, so their scale and variance could be compared on the same grounds. Features with large scales tend to dominate and influence PCA results. As exposed on table (ii), our dataset contains numerical variables with very diverse scales. Assembled Payload Size has a maximum value of 81819, while Packet TTL has a maximum value of only 94, what would certainly distort the outcomes of the analysis. The data also presents great differences in variance values, what would also compromise our results if not standardised. To exemplify, Response Size has a variance of 97076.01 while DYNRiskA Score has a variance of 0.1150942.

From the PCA summary we can extract the proportion of variance and cumulative proportion for each PC:

![image](https://github.com/pedro-vasconcelos-costa/Cyber-attacks-PCA-analysis/blob/main/images/img_%20pcs%20loadings.png)
 
Proportion of variance: this row shows the proportion of variance explained by each Principal Component. The first PC explains the largest proportion of variance (0.263), followed by PC2 (0.157), PC3 (0.116), and PC4 (0.114). The proportion of variance represents how much of the variability in the data can be explained by a principal component. If a principal component explains a high proportion of variance, it means that it is an important component that represents a good amount of the structure in the data.

Cumulative proportion: This row shows how much of the total variation is represented for by the first four principal components, from one to four. The first PC alone explains 0.263 of the variance in the data, while the first two PCs together explain 0.420 of the variance. The first three PCs together explain 0.536 of the variance, and the first four PCs combined explain 0.650 of the variance.

Overall, the summary communicates that PC1 explains a larger proportion of the variance in the dataset and may be the most important for further analysis, but the difference is not extreme and other PCs might also contain useful information and should be considered in any subsequent analyses. In order to adequately explain at least 50% of the data it is necessary to consider the first 3 PCs as the represent a cumulative proportion of 53.6%. 

From the results of the PCA we can also extract the principal component coefficient or loadings for each variable in the dataset. The values represent the correlation between the variables and the PCs. The loadings matrix is useful for understanding which variables are most important for each component.

![image](https://github.com/pedro-vasconcelos-costa/Cyber-attacks-PCA-analysis/blob/main/images/img_%20feature%20loadings.png)
 
When analysing the importance of each feature, we need to take into consideration absolute loading values. PC1 has high loadings for Assembled Payload Size, DYNRiskA Score and Server Response P. T. (0.558, -0.502 and -0.582 respectively), and lower loading for Packet Size (-0.032) for example. This suggests that PC1 is capturing variation in the first 3 features just mentioned, while being less related to the others. PC2 has high loadings for Connection Rate and Source IP C. C. (-0.568 and -0.738) and PC3 is more influenced by Packet Size. In summary, each PC tend to capture different sources of variation in the dataset. A positive correlation means that when one variable increases, the other variable also tends to increase. For example, a positive loading for Connection Rate and PC1, means that as the value of the feature increases, PC1 also tends to increase. The opposite is true for negative loadings.

## BiPlot Analysis

![image](https://github.com/pedro-vasconcelos-costa/Cyber-attacks-PCA-analysis/blob/main/images/img_%20pca%20biplot.png)

### Clustering (PCA)

While there is some amount of correlation between the classes, there is a clear separation between the classes. Both the PCA points and ellipses show a distinguishable positioning of the malicious (Yes) class, to the left of the dimension 1 axis and the non-malicious (No) class to the right of the same. We can also observe that Class “Yes” is more tightly clustered, what can facilitate identification of malicious events.

### Vectors (Loadings)

The vectors represent the loadings(rotation) of each feature. The length of each vector represent the importance of its respective feature and we can identify that Server Response P.T., DNRiskA and Assembled Payload are important drivers of variance, followed by Source IP and Connection Rate, what reflect our findings from the loadings table. 
The smaller the angle between the vectors, the more the features are positively correlated and vice-versa. Server Response and Source Ping Time have a strong positive correlation, so do Assembled Payload and Response Size. On the other hand, Packet TTL and DYNRiskA, like Server Response P.T. and Assembled Payload, point to opposite directions, forming an angle close to 180º, so they have a strong negative correlation. When 2 features form an angle very close to 90º, there is no correlation between them, such is the case for Response Size and Source IP.

### BiPlot (combination)

Analysing both plots combined (positioning and vector direction) can give further information about the data. As the vectors of DYNRiskA, Server Response P.T. and Source Ping Time are pointed in the direction where the malicious (Yes) observations cluster is positioned, we can say that malicious events tend to present on average, higher values for those features This can help to identify and flag those events. Packet Size also points in the same direction, but as observed before, it has a much smaller importance to the variance of the data. On the other hand, features with vectors pointing to the opposite direction tend to have smaller values on average.

### Dimension Projection
 
![image](https://github.com/pedro-vasconcelos-costa/Cyber-attacks-PCA-analysis/blob/main/images/img_%20pca%20projection.png)

Based on the results obtained and on the projection of the observation points to PC1 and PC2 dimensions, we can identify that PC1 provides a much greater separation of the data when compared to PC2 that shows an almost indistinguishable distribution of each class’s observations when projected to its axis. This leads to the conclusion that PC1’s dimension can be more useful for the identification of the malicious and non-malicious events.

## Data Issues

Missing data: Some observations had missing data as outlined in Part-1, topics (i), (ii) and (iii). This can affect the accuracy and completeness of the analysis. In special feature IPV6.Traffic.
Outliers: Some features contained outliers, as evidenced in Part-2, topic (i). Extreme values or observations outside the normal range of the data can affect the results of the analysis.
Data format: Some features were provided in a format that differs from the description provided in the request for this report. Such as IPV6.Traffic and Ingress.Router, this can create difficulties in analyzing or integrating the data.

