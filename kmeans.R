# elbow method
plot_wss <- fviz_nbclust(title_description_features[, 1:20], kmeans, method = "wss")
plot(plot_wss)

# average silhouette method
plot_silhouette <- fviz_nbclust(title_description_features[, 1:20], kmeans, method = "silhouette")
plot(plot_silhouette)

# gap statistic method
plot_gap <- clusGap(title_description_features[, 1:20], FUN = hcut, nstart = 25, K.max = 10, B = 50)
fviz_gap_stat(plot_gap)

# hierarchical clustering using complete linkage
model_hc <- agnes(title_description_features[, 1:20], method = "complete")

# visualize the hierachical clusters
pltree(model_hc, cex = 0.6, hang = -1, main = "Dendrogram of agnes")

# k-means model, k = 3
set.seed(1)
start_time <- Sys.time()
model_kmeans <- kmeans(title_description_features[, 1:20], 3, nstart = 25)
end_time <- Sys.time()

# k-means running time
time_kmeans <- end_time - start_time

# visualize the clusters
plot_kmeans <- fviz_cluster(model_kmeans,
                            geom = "point",
                            title_description_features[, 1:20],
                            main = "",
                            ggtheme = theme_minimal())

# k-means predictions
predictions_kmeans <- factor(ifelse(model_kmeans$cluster == 2, "Low", "High"))
cm_kmeans <- confusionMatrix(predictions_kmeans, title_description_features$Risk)
cm_kmeans

# output graphs to png
png(file = "./diagrams/wss.png", width = 10, height = 6, units = "in", res = 500)
plot(plot_wss)
dev.off()
png(file = "./diagrams/average_silhouette.png", width = 10, height = 6, units = "in", res = 500)
plot(plot_silhouette)
dev.off()
png(file = "./diagrams/gap_statistic.png", width = 10, height = 6, units = "in", res = 500)
fviz_gap_stat(plot_gap)
dev.off()
png(file = "./diagrams/hierachical_clusters.png", width = 10, height = 6, units = "in", res = 500)
pltree(model_hc, cex = 0.6, hang = -1, main = "Dendrogram of agnes")
dev.off()
png(file = "./diagrams/kmeans.png", width = 10, height = 6, units = "in", res = 500)
plot_kmeans
dev.off()

# output graphs to pdf
pdf(file = "./diagrams/wss.pdf", width = 10, height = 6)
plot(plot_wss)
dev.off()
pdf(file = "./diagrams/average_silhouette.pdf", width = 10, height = 6)
plot(plot_silhouette)
dev.off()
pdf(file = "./diagrams/gap_statistic.pdf", width = 10, height = 6)
fviz_gap_stat(plot_gap)
dev.off()
pdf(file = "./diagrams/hierachical_clusters.pdf", width = 10, height = 6)
pltree(model_hc, cex = 0.6, hang = -1, main = "Dendrogram of agnes")
dev.off()
pdf(file = "./diagrams/kmeans.pdf", width = 10, height = 6)
plot_kmeans
dev.off()
