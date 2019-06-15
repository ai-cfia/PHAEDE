# data partition
title_description_features_training <- title_description_features[training_index, ]
title_description_features_testing <- title_description_features[-training_index, ]

# linear svm model
set.seed(1)
start_time <- Sys.time()
model_lsvm <- train(Risk ~ .,
                    data = title_description_features_training,
                    method = "svmLinear",
                    metric = "ROC",
                    tuneLength = 10,
                    trControl = trainControl(method = "cv",
                                             number = 10,
                                             classProbs = TRUE,
                                             summaryFunction = twoClassSummary))
end_time <- Sys.time()

# linear svm running time
time_lsvm <- end_time - start_time

# linear svm predictions
predictions_lsvm <- predict(model_lsvm, title_description_features_testing)
cm_lsvm <- confusionMatrix(predictions_lsvm, title_description_features_testing$Risk)
cm_lsvm

# polynomial svm model
set.seed(2)
start_time <- Sys.time()
model_psvm <- train(Risk ~ .,
                    data = title_description_features_training,
                    method = "svmPoly",
                    metric = "ROC",
                    tuneLength = 10,
                    trControl = trainControl(method = "cv",
                                             number = 10,
                                             classProbs = TRUE,
                                             summaryFunction = twoClassSummary))
end_time <- Sys.time()

# polynomial svm running time
time_psvm <- end_time - start_time

# polynomial svm predictions
predictions_psvm <- predict(model_psvm, title_description_features_testing)
cm_psvm <- confusionMatrix(predictions_psvm, title_description_features_testing$Risk)
cm_psvm

# radial svm model
set.seed(3)
start_time <- Sys.time()
model_rsvm <- train(Risk ~ .,
                    data = title_description_features_training,
                    method = "svmRadial",
                    metric = "ROC",
                    tuneLength = 10,
                    trControl = trainControl(method = "cv",
                                             number = 10,
                                             classProbs = TRUE,
                                             summaryFunction = twoClassSummary))
end_time <- Sys.time()

# radial svm running time
time_rsvm <- end_time - start_time

# radial svm predictions
predictions_rsvm <- predict(model_rsvm, title_description_features_testing)
cm_rsvm <- confusionMatrix(predictions_rsvm, title_description_features_testing$Risk)
cm_rsvm
