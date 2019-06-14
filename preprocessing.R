# paste title and description
data$Title_Description <- paste(data$Title, data$Description)

# convert target values to factor
data$Risk <- as.factor(data$Risk)

# reorder the factor levels of target attribute
data$Risk <- factor(data$Risk, levels = c("High", "Low"))

# stratified sampling
set.seed(123)
training_index <- createDataPartition(data$Risk, p = 0.8, list = FALSE)
