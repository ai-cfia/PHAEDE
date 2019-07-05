probs_fasttext <- unlist(predictions_fasttext)
probs_fasttext[names(probs_fasttext) == "Low"] <- 0

roc_fasttext <- roc(data_testing$Risk, unname(probs_fasttext))

reuse_models <- list(`Skip-gram + k-NN` = model_knn,
                     `Skip-gram + naïve Bayes` = model_nb,
                     `Skip-gram + CART` = model_cart,
                     `Skip-gram + C5.0` = model_c50,
                     `Skip-gram + random forest` = model_rf,
                     `Skip-gram + XGBoost` = model_xgboost,
                     `Skip-gram + linear SVM` = model_lsvm,
                     `Skip-gram + polynomial SVM` = model_psvm,
                     `Skip-gram + RBF SVM` = model_rsvm)

models_roc <- reuse_models %>%
  map(test_roc, data = title_description_features_testing)

results_roc <- list(NA)
results_roc[[1]] <- data_frame(TPR = roc_fasttext$sensitivities,
                               FPR = 1 - roc_fasttext$specificities,
                               model = "FastText")
num_model <- 1
for(roc in models_roc) {
  results_roc[[num_model+1]] <-
    data_frame(TPR = roc$sensitivities,
               FPR = 1 - roc$specificities,
               model = names(reuse_models)[num_model])
  num_model <- num_model + 1
}
results_roc <- bind_rows(results_roc)

results_roc$model <- factor(results_roc$model, levels = unique(results_roc$model))

ggplot_roc_curves <- ggplot(aes(x = FPR,  y = TPR, groover = model), data = results_roc) +
  geom_line(aes(color = model), size = 1) +
  scale_color_manual(values = c("firebrick1", "darkgreen", "deepskyblue", "gold", "burlywood4", "darkolivegreen1", "darkslategray1", "bisque3", "darkorange", "darkorchid4")) +
  geom_abline(intercept = 0, slope = 1, color = "gray", size = 1) +
  theme_minimal() +
  theme(aspect.ratio = 0.9,
        legend.position = "bottom",
        legend.title = element_blank(),
        legend.spacing.x = unit(2, 'pt'),
        legend.text = element_text(margin = margin(r = 4, unit = "pt")))
plot(ggplot_roc_curves)

# output graphs to png
png(file = "./diagrams/roc_curves.png", width = 10, height = 6, units = "in", res = 500)
plot(ggplot_roc_curves)
dev.off()

# output graphs to pdf
pdf(file = "./diagrams/roc_curves.pdf", width = 10, height = 6)
plot(ggplot_roc_curves)
dev.off()
