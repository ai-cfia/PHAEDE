# data partition
title_description_features_training <- title_description_features[training_index, ]
title_description_features_testing <- title_description_features[-training_index, ]

# xgboost model
set.seed(1)
start_time <- Sys.time()
model_xgboost <- train(Risk ~ .,
                       data = title_description_features_training,
                       method = "xgbTree",
                       metric = "ROC",
                       tuneLength = 10,
                       trControl = trainControl(method = "cv",
                                                number = 10,
                                                classProbs = TRUE,
                                                summaryFunction = twoClassSummary))
end_time <- Sys.time()

# xgboost running time
time_xgboost <- end_time - start_time

# xgboost predictions
predictions_xgboost <- predict(model_xgboost, title_description_features_testing)
cm_xgboost <- confusionMatrix(predictions_xgboost, title_description_features_testing$Risk)
cm_xgboost
