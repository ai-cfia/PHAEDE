# data partition
title_description_features_training <- title_description_features[training_index, ]
title_description_features_testing <- title_description_features[-training_index, ]

# knn model
set.seed(1)
start_time <- Sys.time()
model_knn <- train(Risk ~ .,
                   data = title_description_features_training,
                   method = "knn",
                   metric = "ROC",
                   tuneLength = 10,
                   trControl = trainControl(method = "cv",
                                            number = 10,
                                            classProbs = TRUE,
                                            summaryFunction = twoClassSummary))
end_time <- Sys.time()

# knn running time
time_knn <- end_time - start_time

# knn predictions
predictions_knn <- predict(model_knn, title_description_features_testing)
cm_knn <- confusionMatrix(predictions_knn, title_description_features_testing$Risk)
cm_knn
