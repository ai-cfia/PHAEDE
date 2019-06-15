# data partition
title_description_features_training <- title_description_features[training_index, ]
title_description_features_testing <- title_description_features[-training_index, ]

# naive bayes model
set.seed(1)
start_time <- Sys.time()
model_nb <- train(Risk ~ .,
                  data = title_description_features_training,
                  method = "nb",
                  metric = "ROC",
                  tuneLength = 10,
                  trControl = trainControl(method = "cv",
                                           number = 10,
                                           classProbs = TRUE,
                                           summaryFunction = twoClassSummary))
end_time <- Sys.time()

# naive bayes running time
time_nb <- end_time - start_time

# naive bayes predictions
predictions_nb <- predict(model_nb, title_description_features_testing)
cm_nb <- confusionMatrix(predictions_nb, title_description_features_testing$Risk)
cm_nb
