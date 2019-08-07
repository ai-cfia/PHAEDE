# risk count and rate by most observed countries
data_countries <- data[, c("Origin", "Risk")]
most_observed_countries <- names(sort(table(data_countries$Origin), decreasing = TRUE)[1:10])
data_most_observed_countries <- data[which(data_countries$Origin %in% most_observed_countries), ]
data_most_observed_countries$Origin <- factor(data_most_observed_countries$Origin,
                                              levels = most_observed_countries)
risk_count_most_observed_countries <- ddply(data_most_observed_countries,
                                            .(Origin, Risk),
                                            summarize,
                                            count = length(Origin),
                                            .drop = FALSE)
risk_rate_most_observed_countries <- ddply(risk_count_most_observed_countries,
                                           .(Origin),
                                           transform,
                                           percentage = percent(count / sum(count)))
ggplot_risk_rate_most_observed_countries <- ggplot(data = risk_rate_most_observed_countries,
                                                   aes(x = Origin, y = count, fill = Risk)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  geom_text(aes(label = paste0(count, "\n", "(", percentage, ")")), vjust = -0.3, position = position_dodge(0.9), size = 2.5, fontface = "bold") +
  scale_fill_manual(values = c("tomato", "cyan3")) +
  theme_minimal() +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    axis.text.x = element_text(angle = 25, hjust = 1, face = "bold")
  )
plot(ggplot_risk_rate_most_observed_countries)

# risk count and rate by most observed high risk countries
risk_count_countries <- ddply(data_countries,
                              .(Origin, Risk),
                              summarize,
                              count = length(Origin),
                              .drop = FALSE)
risk_rate_countries <- ddply(risk_count_countries,
                             .(Origin),
                             transform,
                             percentage = count / sum(count))
most_observed_high_risk_countries <-
  risk_rate_countries[risk_rate_countries$Risk == "High", ][order(
    risk_rate_countries[risk_rate_countries$Risk == "High", ]$count, decreasing = TRUE
  )[1:10], ]$Origin
risk_count_most_observed_high_risk_countries <- risk_count_countries[risk_count_countries$Origin %in% most_observed_high_risk_countries, ]
risk_count_most_observed_high_risk_countries$Origin <- factor(risk_count_most_observed_high_risk_countries$Origin,
                                                              levels = most_observed_high_risk_countries)
risk_rate_most_observed_high_risk_countries <- ddply(risk_count_most_observed_high_risk_countries,
                                                     .(Origin),
                                                     transform,
                                                     percentage = percent(count / sum(count)))
ggplot_risk_rate_most_observed_high_risk_countries <- ggplot(data = risk_rate_most_observed_high_risk_countries,
                                                             aes(x = Origin, y = count, fill = Risk)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  geom_text(aes(label = paste0(count, "\n", "(", percentage, ")")), vjust = -0.3, position = position_dodge(0.9), size = 2.5, fontface = "bold") +
  scale_fill_manual(values = c("tomato", "cyan3")) +
  theme_minimal() +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    axis.text.x = element_text(angle = 25, hjust = 1, face = "bold")
  )
plot(ggplot_risk_rate_most_observed_high_risk_countries)

# risk count and rate of instances shipping to North America
data_ship_to_na <- data[, c("Ships_To_NA", "Risk")]
data_ship_to_na$Ships_To_NA[is.na(data_ship_to_na$Ships_To_NA)] <- "Missing"
data_ship_to_na$Ships_To_NA[data_ship_to_na$Ships_To_NA == "TRUE"] <- "Ship to North America"
data_ship_to_na$Ships_To_NA[data_ship_to_na$Ships_To_NA == "FALSE"] <- "Not Ship to North America"
risk_count_ship_to_na <- ddply(data_ship_to_na,
                               .(Ships_To_NA, Risk),
                               summarize,
                               count = length(Ships_To_NA),
                               .drop = FALSE)
risk_rate_ship_to_na <- ddply(risk_count_ship_to_na,
                              .(Ships_To_NA),
                              transform,
                              percentage = percent(count / sum(count)))
risk_rate_ship_to_na$Ships_To_NA <- factor(risk_rate_ship_to_na$Ships_To_NA,
                                           levels = c("Ship to North America", "Not Ship to North America", "Missing"))
ggplot_risk_rate_ship_to_na <- ggplot(data = risk_rate_ship_to_na,
                                      aes(x = Ships_To_NA, y = count, fill = Risk)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  geom_text(aes(label = paste0(count, "\n", "(", percentage, ")")), vjust = -0.3, position = position_dodge(0.9), size = 2.5, fontface = "bold") +
  scale_fill_manual(values = c("tomato", "cyan3")) +
  theme_minimal() +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    axis.text.x = element_text(face = "bold")
  )
plot(ggplot_risk_rate_ship_to_na)

# risk count and rate of instances with/without missing values
data[, "Has N/A"] <- "Have Missing Values"
data[rowSums(is.na(data)) == 0, ]$`Has N/A` <- "Have No Missing Values"
risk_count_missing <- ddply(data,
                            .(`Has N/A`, Risk),
                            summarize,
                            count = length(`Has N/A`),
                            .drop = FALSE)
risk_rate_missing <- ddply(risk_count_missing,
                           .(`Has N/A`),
                           transform,
                           percentage = percent(count / sum(count)))
risk_rate_missing$`Has N/A` <- factor(risk_rate_missing$`Has N/A`,
                                      levels = c("Have No Missing Values", "Have Missing Values"))
ggplot_risk_rate_missing <- ggplot(data = risk_rate_missing,
                                   aes(x = `Has N/A`, y = count, fill = Risk)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  geom_text(aes(label = paste0(count, "\n", "(", percentage, ")")), vjust = -0.3, position = position_dodge(0.9), size = 2.5, fontface = "bold") +
  scale_fill_manual(values = c("tomato", "cyan3")) +
  theme_minimal() +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    axis.text.x = element_text(face = "bold")
  )
plot(ggplot_risk_rate_missing)

# categories of commodities
data[(is.na(data$Category1) | data$Category1 == ""), ]$Category1 <- "Missing"
data_category1 <- as.data.frame(table(data$Category1, useNA = "ifany"))
plotly_category1 <- plot_ly(data_category1, labels = ~ Var1, values = ~ Freq, type = "pie", textposition = "top center", textinfo = "label+percent") %>%
  layout(title = "Categories of Commodities",
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))

# output graphs to png
png(file = "./diagrams/risk_rate_most_observed_countries.png", width = 11, height = 7, units = "in", res = 500)
plot(ggplot_risk_rate_most_observed_countries)
dev.off()
png(file = "./diagrams/risk_rate_most_observed_high_risk_countries.png", width = 11, height = 7, units = "in", res = 500)
plot(ggplot_risk_rate_most_observed_high_risk_countries)
dev.off()
png(file = "./diagrams/risk_rate_ship_to_na.png", width = 11, height = 7, units = "in", res = 500)
plot(ggplot_risk_rate_ship_to_na)
dev.off()
png(file = "./diagrams/risk_rate_missing.png", width = 11, height = 7, units = "in", res = 500)
plot(ggplot_risk_rate_missing)
dev.off()

# output graphs to pdf
pdf(file = "./diagrams/risk_rate_most_observed_countries.pdf", width = 11, height = 7)
plot(ggplot_risk_rate_most_observed_countries)
dev.off()
pdf(file = "./diagrams/risk_rate_most_observed_high_risk_countries.pdf", width = 11, height = 7)
plot(ggplot_risk_rate_most_observed_high_risk_countries)
dev.off()
pdf(file = "./diagrams/risk_rate_ship_to_na.pdf", width = 11, height = 7)
plot(ggplot_risk_rate_ship_to_na)
dev.off()
pdf(file = "./diagrams/risk_rate_missing.pdf", width = 11, height = 7)
plot(ggplot_risk_rate_missing)
dev.off()
