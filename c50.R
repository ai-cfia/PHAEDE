# data partition
title_description_features_training <- title_description_features[training_index, ]
title_description_features_testing <- title_description_features[-training_index, ]

# c50 model
set.seed(1)
start_time <- Sys.time()
model_c50 <- train(Risk ~ .,
                   data = title_description_features_training,
                   method = "C5.0",
                   metric = "ROC",
                   tuneLength = 10,
                   trControl = trainControl(method = "cv",
                                            number = 10,
                                            classProbs = TRUE,
                                            summaryFunction = twoClassSummary))
end_time <- Sys.time()

# c50 running time
time_c50 <- end_time - start_time

# c50 predictions
predictions_c50 <- predict(model_c50, title_description_features_testing)
cm_c50 <- confusionMatrix(predictions_c50, title_description_features_testing$Risk)
cm_c50
