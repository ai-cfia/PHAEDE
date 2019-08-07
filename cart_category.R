# remove instances with empty category1
data_category <- data[!(data$Category1 == ""), ]

# cart model
set.seed(1)
start_time <- Sys.time()
model_cart_category <- train(Risk ~ Category1 + Category2 + Category3 + Category4,
                             data = data_category,
                             method = "rpart",
                             metric = "ROC",
                             tuneLength = 10,
                             trControl = trainControl(method = "cv",
                                                      number = 10,
                                                      classProbs = TRUE,
                                                      summaryFunction = twoClassSummary))
end_time <- Sys.time()

# cart running time
time_cart_category <- end_time - start_time

# cart predictions
predictions_cart_category <- predict(model_cart_category, data_category)
cm_cart_category <- confusionMatrix(predictions_cart_category, data_category$Risk)
cm_cart_category

rpart.plot(model_cart_category$finalModel)
