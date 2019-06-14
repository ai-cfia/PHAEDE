# data partition
data_training <- data[training_index, ]
data_testing <- data[-training_index, ]

# cbow word vector model
set.seed(1)
model_file_cbow <- build_vectors(documents = tolower(data_training$Title_Description),
                                 model_path = "model_cbow",
                                 modeltype = "cbow",
                                 dim = 20,
                                 wordNgrams = 2)
model_cbow <- load_model(model_file_cbow)

# skip-gram word vector model
set.seed(1)
model_file_skipgram <- build_vectors(documents = tolower(data_training$Title_Description),
                                     model_path = "model_skipgram",
                                     modeltype = "skipgram",
                                     dim = 20,
                                     wordNgrams = 2)
model_skipgram <- load_model(model_file_skipgram)

# fasttext model
set.seed(1)
start_time <- Sys.time()
model_file_fasttext <- build_supervised(documents = tolower(data_training$Title_Description),
                                        targets = data_training$Risk,
                                        model_path = "model_fasttext",
                                        dim = 20,
                                        lr = 1,
                                        epoch = 20,
                                        wordNgrams = 2,
                                        pretrainedVectors = "model_skipgram.vec")
end_time <- Sys.time()
model_fasttext <- load_model(model_file_fasttext)

# fasttext running time
time_fasttext <- end_time - start_time

# extract word vectors
word_dictionay <- get_dictionary(model_skipgram)
word_vectors <- get_word_vectors(model_skipgram, word_dictionay)

# extract document vectors and generate document features
title_description_vectors <- get_sentence_representation(model_fasttext, data$Title_Description)
title_description_features <- as.data.frame(title_description_vectors)
title_description_features$Risk <- data$Risk

# prediction are returned as a list with words and probabilities
predictions_fasttext <- predict(model_fasttext, sentences = tolower(data_testing$Title_Description))

# confusion matrix
cm_fasttext <- confusionMatrix(factor(sapply(predictions_fasttext, names)), data_testing$Risk)
cm_fasttext
