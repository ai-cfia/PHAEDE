# data partition
title_description_features_training <- title_description_features[training_index, ]
title_description_features_testing <- title_description_features[-training_index, ]

# cart model
set.seed(1)
start_time <- Sys.time()
model_cart <- train(Risk ~ .,
                    data = title_description_features_training,
                    method = "rpart",
                    metric = "ROC",
                    tuneLength = 10,
                    trControl = trainControl(method = "cv",
                                             number = 10,
                                             classProbs = TRUE,
                                             summaryFunction = twoClassSummary))
end_time <- Sys.time()

# cart running time
time_cart <- end_time - start_time

# cart predictions
predictions_cart <- predict(model_cart, title_description_features_testing)
cm_cart <- confusionMatrix(predictions_cart, title_description_features_testing$Risk)
cm_cart
