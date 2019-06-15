# data partition
title_description_features_training <- title_description_features[training_index, ]
title_description_features_testing <- title_description_features[-training_index, ]

# random forest model
set.seed(1)
start_time <- Sys.time()
model_rf <- train(Risk ~ .,
                  data = title_description_features_training,
                  method = "ranger",
                  metric = "ROC",
                  tuneLength = 10,
                  trControl = trainControl(method = "cv",
                                           number = 10,
                                           classProbs = TRUE,
                                           summaryFunction = twoClassSummary))
end_time <- Sys.time()

# random forest running time
time_rf <- end_time - start_time

# random forest predictions
predictions_rf <- predict(model_rf, title_description_features_testing)
cm_rf <- confusionMatrix(predictions_rf, title_description_features_testing$Risk)
cm_rf
