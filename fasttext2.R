# data partition
data_training <- data[training_index, ]
data_testing <- data[-training_index, ]

# prepare data
tmp_file_model <- tempfile()

train_labels <- paste0("__label__", data_training[, "Risk"])
train_texts <- tolower(data_training[, "Title_Description"])
train_to_write <- paste(train_labels, train_texts)
train_tmp_file_txt <- tempfile()
writeLines(text = train_to_write, con = train_tmp_file_txt)

test_labels <- paste0("__label__", data_testing[, "Risk"])
test_labels_without_prefix <- data_testing[, "Risk"]
test_texts <- tolower(data_testing[, "Title_Description"])
test_to_write <- paste(test_labels, test_texts)

# learn model
execute(commands = c("supervised",
                     "-input", train_tmp_file_txt,
                     "-output", tmp_file_model,
                     "-dim", 20,
                     "-lr", 0.05,
                     "-epoch", 100,
                     "-wordNgrams", 2,
                     "-verbose", 1))

# load model
model_fasttext2 <- load_model(tmp_file_model)

# extract document vectors and generate document features
title_description_vectors2 <- get_sentence_representation(model_fasttext2, data$Title_Description)
title_description_features2 <- as.data.frame(title_description_vectors2)
title_description_features2$Risk <- data$Risk

# prediction are returned as a list with words and probabilities
predictions_fasttext2 <- predict(model_fasttext2, sentences = tolower(data_testing$Title_Description))

# confusion matrix
cm_fasttext2 <- confusionMatrix(factor(sapply(predictions_fasttext2, names)), data_testing$Risk)
cm_fasttext2
