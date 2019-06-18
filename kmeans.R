# k-means model
set.seed(1)
start_time <- Sys.time()
model_kmeans <- kmeans(title_description_features[, 1:20], 2)
end_time <- Sys.time()

# k-means running time
time_kmeans <- end_time - start_time

# k-means predictions
predictions_kmeans <- factor(ifelse(model_kmeans$cluster == 1, "Low", "High"))
cm_kmeans <- confusionMatrix(predictions_kmeans, title_description_features$Risk)
cm_kmeans
