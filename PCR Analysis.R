# Pedro Henrique Franca de Vasconcelos Costa
# Student ID: 10564447

# Load libraries
library(tidyverse)
library(dplyr)
library(moments)
library(ggpubr)
library(ggplot2)
library(DescTools)
library(scales) 
library(factoextra)
library(data.table)

# Set working directory
getwd()
setwd("/Users/vasconcelosph/Desktop/Assignment - 1")

# Import dataset
dat <- read.csv("MLData2023.csv", stringsAsFactors = TRUE)

# Separate samples of non-malicious and malicious events 
dat.class0 <- dat %>% filter(Class == 0) # non-malicious 
dat.class1 <- dat %>% filter(Class == 1) # malicious

# Randomly select 300 samples from each class
set.seed(10564447)
rand.class0 <- dat.class0[sample(1:nrow(dat.class0), 
                                 size = 300, 
                                 replace = FALSE),] 
rand.class1 <- dat.class1[sample(1:nrow(dat.class1), 
                                 size = 300, 
                                 replace = FALSE),]
# Combine class samples into sub-sample dataset of 600 observations
mydata <- rbind(rand.class0, 
                rand.class1); mydata 

#///////////////////////////////////////////////////////////////////////////////
# Part 1 – Exploratory Data Analysis and Data Cleaning
#///////////////////////////////////////////////////////////////////////////////

# Check dimensions and structure of dataset
dim(mydata) 
str(mydata)

# Check levels of categorical variables
levels(mydata$IPV6.Traffic)
levels(mydata$Operating.System)
levels(mydata$Connection.State)
levels(mydata$Ingress.Router)
levels(mydata$Class)

# Convert "Class" variable to a factor with "No" and "Yes" labels
mydata$Class <- factor(mydata$Class, 
                       levels = c(0, 1), 
                       labels = c("No", "Yes"))

# Relocate all categorical(factor) features to the left
mydata_relocated <- mydata %>%
    select(where(is.factor), 
           everything()); mydata_relocated

##       (i)         ##
#///////////////////////////////////////////////////////////////////////////////
# Compute proportions for each categorical column
cat_tables <- lapply(mydata_relocated[ , 1:5], function(x) 
    {
    freq <- table(x)
    prop <- freq / sum(freq)
    n_pcent <- paste(freq, 
                     ' (', 
                     round(prop*100, 1), 
                     '%)', 
                     sep = '')
    data.frame(Category = names(freq), 
               Frequency = as.numeric(freq), 
               Proportion = prop, 
               N = n_pcent)
    })

# Combine data frames into a single data frame
cat_table <- bind_rows(cat_tables, .id = "Column")

# Export data frame to CSV file
write.csv(cat_table, file = "cat_prop_table.csv", row.names = FALSE)


##       (ii)         ##
#///////////////////////////////////////////////////////////////////////////////
# Compute number and percentage of missing values for each numeric variable
num_table <- apply(mydata_relocated[ , 6:ncol(mydata_relocated)], 
           2,
           function(x)
               {
               missing <- sum((x) < 0)
               prop <- missing / 600
               n_pcent <- paste(missing, 
                                ' (', 
                                round(prop*100, 2), 
                                '%)', 
                                sep = '')
               return(n_pcent)
           }); num_table

# Rename columns of the num_table to match the column names in mydata_relocated
names(num_table) <- names(mydata_relocated)[6:ncol(mydata_relocated)]
num_table <- data.frame(num_table) 

# Calculate the min, max, mean, median and skewness for each numeric variable in num_table
num_table$Min <- apply(mydata_relocated[, 6:ncol(mydata_relocated)], 2, min)
num_table$Max <- apply(mydata_relocated[, 6:ncol(mydata_relocated)], 2, max)
num_table$Mean <- apply(mydata_relocated[, 6:ncol(mydata_relocated)], 2, mean)
num_table$Median <- apply(mydata_relocated[, 6:ncol(mydata_relocated)], 2, median)
num_table$Skewness <- apply(mydata_relocated[, 6:ncol(mydata_relocated)], 2, skewness)

# Round numeric columns of num_table to two decimal places
num_table[, sapply(num_table, is.numeric)] <- round(num_table[, sapply(num_table, is.numeric)], 2) 

# Rename the first column of num_table to 'Number (%) missing'
names(num_table)[1] <- "Number (%) missing"; 

# Print the structure of num_table
str(num_table)

# Export data frame to CSV file
write.csv(num_table, file = "num_summ_table.csv", row.names = TRUE)

##       (iii)         ##
#///////////////////////////////////////////////////////////////////////////////
# IDENTIFY INVALID CATEGORIES

# compute proportions of Ingress Router vs Class
inrout_class <- table(mydata$Ingress.Router, mydata$Class)
inrout_prop_class <- data.frame(prop.table(inrout_class, margin = 1))
str(inrout_prop_class)

# visualize results
c_plot_1 <- ggplot(inrout_prop_class, aes(x = Var1, y = Freq, fill = Var2)) +
    geom_bar(stat = "identity", 
             width = 0.5) +
    labs(x = "Ingress Router", y = '', fill = 'Malicious') +
    ggtitle("Ingress Router by Class") +
    theme_minimal()
    #guides(fill = 'none')


# compute proportions of Connection State vs Class
conn_class <- table(mydata$Connection.State, mydata$Class)
conn_prop_class <- data.frame(prop.table(conn_class, margin = 1))

# visualize results
c_plot_2 <- ggplot(conn_prop_class, aes(x = Var1, y = Freq, fill = Var2)) +
    geom_bar(stat = "identity", 
             width = 0.5) +
    labs(x = "Connection State", y = '') +
    ggtitle("Connection State by Class") +
    theme_minimal() +
    guides(fill = 'none')

# compute proportions of Operating System  vs Class
ops_class <- table(mydata$Operating.System , mydata$Class)
ops_prop_class <- data.frame(prop.table(ops_class, margin = 1))

# visualize results
c_plot_3 <- ggplot(ops_prop_class, aes(x = Var1, y = Freq, fill = Var2)) +
    geom_bar(stat = "identity", 
             width = 0.5) +
    labs(x = "Operating System", y = '') +
    ggtitle("Operating Systems by Class") +
    theme_minimal() +
    guides(fill = 'none') + 
    theme(axis.text.x = element_text(angle = 30, hjust = 1))


# compute proportions of IPV6 Traffic  vs Class
ip_class <- table(mydata$IPV6.Traffic , mydata$Class)
ip_prop_class <- data.frame(prop.table(ip_class, margin = 1))

# visualize results
c_plot_4 <- ggplot(ip_prop_class, aes(x = Var1, y = Freq, fill = Var2)) +
    geom_bar(stat = "identity", 
             width = 0.5) +
    labs(x = "IPV6 Traffic", y = '') +
    ggtitle("IPV6 Traffic by Class") +
    theme_minimal()
## no outstanding values

# arrange plots into 2x2 grid
legend <- get_legend(c_plot_1)
cat_plots_class <- ggarrange(c_plot_1, 
          c_plot_4, 
          c_plot_2,
          c_plot_3,  
          labels = c("A", "B", "C", "D"),
          ncol = 2, 
          nrow = 2,
          common.legend = TRUE,
          legend = "bottom"); cat_plots_class
# export plots to PDF file
ggexport(cat_plots_class, 
         filename = "cat_class_prop.pdf")

# IDENTIFY OUTLIERS IN CONT VARS
# # apply Pearson's chi-square test to columns 6 last column of mydata_relocated
pearon_chi_test <- apply(mydata_relocated[, 6:ncol(mydata_relocated)], 2, PearsonTest)

# scale Response.Size column and identify any outliers 
# using a threshold of +/- 3 standard deviations from the mean
scale_RS <- scale(mydata$Response.Size)
out_RS <- which(scale_RS > 3 | scale_RS < -3)

# create a histogram of Response.Size column
ggplot(mydata, aes(x = Response.Size)) +
    geom_histogram(bins = 60, 
                   color = 'black',
                   fill = 'steelblue') +
    theme_pubclean(base_size = 14)

# scale Source.Ping.Time column and identify any outliers 
# using a threshold of +/- 3 standard deviations from the mean
scale_SPT <- scale(mydata$Source.Ping.Time)
out_SPT <- which(scale_SPT > 3 | scale_SPT < -3)

# create a histogram of Source.Ping.Time column
ggplot(mydata, aes(x = Source.Ping.Time)) +
    geom_histogram(bins = 60, 
                   color = 'black',
                   fill = 'steelblue') +
    theme_pubclean(base_size = 14)

# create a boxplot and histogram of Assembled.Payload.Size column and identify any outliers
bp_ASP <- boxplot(mydata$Assembled.Payload.Size)
out_ASP <- boxplot.stats(mydata$Assembled.Payload.Size)$out
ggplot(mydata, aes(x = Assembled.Payload.Size)) +
    geom_histogram(bins = 60, 
             color = 'black',
             fill = 'steelblue') +
    theme_pubclean(base_size = 14)
 
# create a boxplot and histogram of DYNRiskA.Score column and identify any outliers
bp_DS <- boxplot(mydata$DYNRiskA.Score)
out_DS <- which(mydata$DYNRiskA.Score %in% bp_DS$out)
ggplot(mydata, aes(x = DYNRiskA.Score)) +
    geom_histogram(bins = 30, 
                   color = 'black',
                   fill = 'steelblue') +
    theme_pubclean(base_size = 14)

# create a boxplot and histogram of Connection.Rate column and identify any outliers
bp_CR <- boxplot(mydata$Connection.Rate)
out_CR <- which(mydata$Connection.Rate %in% bp_CR$out)
ggplot(data = mydata, aes(x = Connection.Rate)) +
    geom_histogram(bins = 30, 
                   color = 'black',
                   fill = 'steelblue') +
    theme_pubclean(base_size = 14)

# create a boxplot and histogram of Server.Response.Packet.Time column and identify any outliers
bp_SRPT <- boxplot(mydata$Server.Response.Packet.Time)
out_SRPT <- which(mydata$Server.Response.Packet.Time %in% bp_SRPT$out)
ggplot(mydata, aes(x = Server.Response.Packet.Time)) +
    geom_histogram(bins = 30, 
                   color = 'black',
                   fill = 'steelblue') +
    theme_pubclean(base_size = 14)

# create a boxplot and histogram of Packet.Size column and identify any outliers
bp_PS <- boxplot(mydata$Packet.Size)
out_PS <- which(mydata$Packet.Size %in% bp_PS$out)
sd(mydata$Packet.Size)
ggplot(mydata, aes(x = Packet.Size)) +
    geom_histogram(bins = 60, 
                   color = 'black',
                   fill = 'steelblue') +
    theme_pubclean(base_size = 14)

# create a boxplot and histogram of Packet.TTL column and identify any outliers
bp_PTTL <- boxplot(mydata$Packet.TTL)
out_PTTL <- which(mydata$Packet.TTL %in% bp_PTTL$out)
sd(mydata$Packet.TTL)
ggplot(mydata, aes(x = Packet.TTL)) +
    geom_histogram(bins = 30, 
                   color = 'black',
                   fill = 'steelblue') +
    theme_pubclean(base_size = 14)

# create a boxplot and histogram of Source.IP.Concurrent.Connection column and identify any outliers
bp_SICC <- boxplot(mydata$Source.IP.Concurrent.Connection)
out_SICC <- which(mydata$Source.IP.Concurrent.Connection %in% bp_SICC$out)
ggplot(mydata, aes(x = Source.IP.Concurrent.Connection)) +
    geom_histogram(bins = 150, 
                   color = 'black',
                   fill = 'steelblue') +
    theme_pubclean(base_size = 14)


#///////////////////////////////////////////////////////////////////////////////
# Part 2 – Perform PCA and Visualise Data
#///////////////////////////////////////////////////////////////////////////////

##       (i)         ##
#///////////////////////////////////////////////////////////////////////////////
# replace outliers with NA
mydata$Packet.TTL <- replace(mydata$Packet.TTL, out_PTTL, NA)
mydata$Connection.Rate <- replace(mydata$Connection.Rate, out_CR, NA)
mydata$Source.Ping.Time <- replace(mydata$Source.Ping.Time, out_SPT, NA)
mydata$Response.Size <- replace(mydata$Response.Size, out_RS, NA)
mydata$DYNRiskA.Score <- replace(mydata$DYNRiskA.Score, out_DS, NA)

# replace invalid values with NA
inv_APS <- which(mydata$Assembled.Payload.Size <= 0)
mydata$Assembled.Payload.Size <- replace(mydata$Assembled.Payload.Size, inv_APS, NA)
inv_IPT <- which(mydata$IPV6.Traffic == '-' | mydata$IPV6.Traffic == ' ')
mydata$IPV6.Traffic <- replace(mydata$IPV6.Traffic, inv_IPT, NA)


##       (ii)         ##
#///////////////////////////////////////////////////////////////////////////////
#Write to a csv file.
write.csv(mydata,"mydata.csv")


##       (iii)         ##
#///////////////////////////////////////////////////////////////////////////////
# relocate categorical features
mydata_pca <- mydata %>%
    select(where(is.factor), everything()); mydata_pca
# relocate class feature
mydata_pca <- mydata_pca %>%
    relocate(Class, .after = Source.IP.Concurrent.Connection)
# extract numeric features + Class
mydata_pca <- mydata_pca[ , 5:14]
# filter out incomplete observations
mydata_pca <- na.omit(mydata_pca)
# scale and perform PCA on numeric features
pca_myd <- prcomp(mydata_pca[ , 1:9], 
                  scale = TRUE); pca_myd
# display the individual and cumulative proportion of variance
pca_summary <- summary(pca_myd) 
# display feature loadings for each PC
pca_loadings <- round(pca_myd$rotation[ , 1:3], 3)
# write selected loadings to a csv file.
write.csv(pca_loadings,"pca_loadings.csv")

# obtain variance of features
variance_data <- data.frame(apply(mydata_pca[ , 1:9], 2, var))

##       (iv)         ##
#///////////////////////////////////////////////////////////////////////////////
# create biplot
pca_biplot <- fviz_pca_biplot(pca_myd,
                axes = c(1, 2),  #Specifying the PCs to be plotted. 
                #Parameters for samples
                col.ind = mydata_pca$Class,  #Outline color of the shape
                fill.ind = mydata_pca$Class,  #fill color of the shape
                alpha = 0.35,  #transparency of the fill colour
                pointsize = 4,  #Size of the shape
                pointshape = 21,  #Type of Shape
                #Parameter for variables
                col.var = "black",  #Colour of the variable labels
                label = "var",  #Show the labels for the variables only
                repel = TRUE,  #Avoid label overplotting
                addEllipses = TRUE,  #Add ellipses to the plot
                legend.title = list(colour = "Class", 
                                    fill = "Class", 
                                    alpha = "Class"),
                line.width = 5); pca_biplot

# export biplot to pdf file
ggexport(pca_biplot, 
         filename = "pca_biplot.pdf")


##       (iv)         ##
#///////////////////////////////////////////////////////////////////////////////

pc1_df <- data.frame(PC1 = pca_myd$x[, 1], Class = mydata_pca$Class)

pc2_df <- data.frame(PC2 = pca_myd$x[, 2], Class = mydata_pca$Class)

# Scatterplot for PC1
pc1_project <- ggplot(pc1_df, aes(x = PC1, color = Class)) +
    geom_histogram(alpha = 0.85,
                   bins = 60) +
    labs(title = "PC1 projection", x = "PC1", y = "") +
    theme_pubclean(base_size = 14)

# Scatterplot for PC2
pc2_project <- ggplot(pc2_df, aes(x = PC2, color = Class)) +
    geom_histogram(alpha = 0.85,
                   bins = 60) +
    labs(title = "PC2 projection", x = "PC2", y = "") +
    theme_pubclean(base_size = 14)

# arrange plots into 2x1 grid
pc_projection <- ggarrange(pc1_project, 
                           pc2_project, 
                           labels = c("A", "B"), 
                           ncol = 1, 
                           nrow = 2, 
                           common.legend = TRUE); pc_projection

# export plots to pdf file
ggexport(pc_projection, 
         filename = "pc_projection.pdf")


#///////////////////////////////////////////////////////////////////////////////
# clean environment
rm(list = ls())