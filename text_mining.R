# all words & bigrams

# list the words from all descriptions starting from the most frequent
descriptions <- data %>% select(Title_Description)
words <- descriptions %>% unnest_tokens(word, Title_Description) %>% anti_join(stop_words)
words_count <- words %>% count(word, sort = TRUE)

# plot bar chart for top 30 most common words
bar_words <- words_count %>%
  top_n(30, n) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col() +
  xlab(NULL) + ylab(NULL) +
  coord_flip() #+ ggtitle("Common Words")

# plot word cloud for top 50 most common words
set.seed(0)
wordcloud_words <- words %>%
  anti_join(stop_words) %>%
  count(word) %>%
  with(wordcloud(word, n, max.words = 50))

# list the bigrams from all descriptions starting from the most frequent
bigrams <- descriptions %>% unnest_tokens(bigram, Title_Description, token = "ngrams", n = 2)
bigrams_separated <- bigrams %>%
  separate(bigram, c("word1", "word2"), sep = " ")
bigrams_filtered <- bigrams_separated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word)
bigrams_count <- bigrams_filtered %>% 
  count(word1, word2, sort = TRUE)

# plot bar chart for top 30 most common bigrams
bigrams_united <- bigrams_filtered %>%
  unite(bigram, word1, word2, sep = " ")
bigrams_united_count <- bigrams_united %>% count(bigram, sort = TRUE)
bar_bigrams <- bigrams_united_count %>%
  top_n(30, n) %>%
  mutate(bigram = reorder(bigram, n)) %>%
  ggplot(aes(bigram, n)) +
  geom_col() +
  xlab(NULL) + ylab(NULL) +
  coord_flip() #+ ggtitle("Common Bigrams")

# construct grammar network for top 30 most common bigrams
bigrams_graph <- bigrams_count %>%
  top_n(30, n) %>%
  graph_from_data_frame()

# plot grammar network for top 30 most common bigrams
set.seed(1)
grammar_bigrams_graph <- ggraph(bigrams_graph, layout = "fr") +
  geom_edge_link() +
  geom_node_point(color = "darkslategray4", size = 3) +
  xlab(NULL) + ylab(NULL) +
  geom_node_text(aes(label = name), vjust = 1.8) #+ ggtitle("Grammar Network of Common Bigrams")

# high risk words & bigrams

# list the high risk words starting from the most frequent
data_high <- data %>% filter(Risk == "High")
descriptions_high <- data_high %>% select(Title_Description)
words_high <- descriptions_high %>% unnest_tokens(word, Title_Description) %>% anti_join(stop_words)
words_high_count <- words_high %>% count(word, sort = TRUE)
words_high_count["risk"] <- "high"

# plot bar chart for top 30 most common high risk words
bar_words_high <- words_high_count %>%
  top_n(30, n) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col(show.legend = FALSE) +
  geom_col(fill = "tomato") +
  xlab(NULL) + ylab(NULL) +
  coord_flip() #+ ggtitle("Common High Risk Words")

# plot word cloud for top 50 most common high risk words
pal_OrRd <- brewer.pal(5, "OrRd")
pal_OrRd <- pal_OrRd[-(1:2)]
set.seed(2)
wordcloud_words_high <- words_high %>%
  anti_join(stop_words) %>%
  count(word) %>%
  with(wordcloud(word, n, max.words = 50, colors = pal_OrRd))

# list the bigrams from high risk descriptions starting from the most frequent
bigrams_high <- descriptions_high %>% unnest_tokens(bigram, Title_Description, token = "ngrams", n = 2)
bigrams_high_separated <- bigrams_high %>%
  separate(bigram, c("word1", "word2"), sep = " ")
bigrams_high_filtered <- bigrams_high_separated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word)
bigrams_high_count <- bigrams_high_filtered %>% 
  count(word1, word2, sort = TRUE)

# plot bar chart for top 30 most common high risk bigrams
bigrams_high_united <- bigrams_high_filtered %>%
  unite(bigram, word1, word2, sep = " ")
bigrams_high_united_count <- bigrams_high_united %>% count(bigram, sort = TRUE)
bar_bigrams_high <- bigrams_high_united_count %>%
  top_n(30, n) %>%
  mutate(bigram = reorder(bigram, n)) %>%
  ggplot(aes(bigram, n)) +
  geom_col(fill = "tomato") +
  xlab(NULL) + ylab(NULL) +
  coord_flip() #+ ggtitle("Common High Risk Bigrams")

# construct grammar network for top 20 most common high risk bigrams
bigrams_high_graph <- bigrams_high_count %>%
  top_n(30, n) %>%
  graph_from_data_frame()

# plot grammar network for top 10 most common high risk bigrams
set.seed(3)
grammar_bigrams_high_graph <- ggraph(bigrams_high_graph, layout = "fr") +
  geom_edge_link() +
  geom_node_point(color = "tomato", size = 3) +
  xlab(NULL) + ylab(NULL) +
  geom_node_text(aes(label = name), vjust = 1.8) #+ ggtitle("Grammar Network of High Risk Bigrams")

# low risk words & bigrams

# list the low risk words starting from the most frequent
data_low <- data %>% filter(Risk == "Low")
descriptions_low <- data_low %>% select(Title_Description)
words_low <- descriptions_low %>% unnest_tokens(word, Title_Description) %>% anti_join(stop_words)
words_low_count <- words_low %>% count(word, sort = TRUE)
words_low_count["risk"] <- "low"

# plot bar chart for top 30 most common low risk words
bar_words_low <- words_low_count %>%
  top_n(30, n) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col(fill = "cyan3") +
  xlab(NULL) + ylab(NULL) +
  coord_flip() #+ ggtitle("Common Low Risk Words")

# plot word cloud for top 50 most common low risk words
pal_GnBu <- brewer.pal(5, "GnBu")
pal_GnBu <- pal_GnBu[-(1:2)]
set.seed(4)
wordcloud_words_low <- words_low %>%
  anti_join(stop_words) %>%
  count(word) %>%
  with(wordcloud(word, n, max.words = 50, colors = pal_GnBu))

# list out the bigrams from low risk descriptions starting from the most frequent
bigrams_low <- descriptions_low %>% unnest_tokens(bigram, Title_Description, token = "ngrams", n = 2)
bigrams_low_separated <- bigrams_low %>%
  separate(bigram, c("word1", "word2"), sep = " ")
bigrams_low_filtered <- bigrams_low_separated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word)
bigrams_low_count <- bigrams_low_filtered %>% 
  count(word1, word2, sort = TRUE)

# plot bar chart for top 30 most common low risk bigrams
bigrams_low_united <- bigrams_low_filtered %>%
  unite(bigram, word1, word2, sep = " ")
bigrams_low_united_count <- bigrams_low_united %>% count(bigram, sort = TRUE)
bar_bigrams_low <- bigrams_low_united_count %>%
  top_n(30, n) %>%
  mutate(bigram = reorder(bigram, n)) %>%
  ggplot(aes(bigram, n)) +
  geom_col(fill = "cyan3") +
  xlab(NULL) + ylab(NULL) +
  coord_flip() #+ ggtitle("Common Low Risk Bigrams")

# construct grammar network for top 30 most common low risk bigrams
bigrams_low_graph <- bigrams_low_count %>%
  top_n(30, n) %>%
  graph_from_data_frame()

# plot grammar network for top 20 most common low risk bigrams
set.seed(5)
grammar_bigrams_low_graph <- ggraph(bigrams_low_graph, layout = "fr") +
  geom_edge_link() +
  geom_node_point(color = "cyan3", size = 3) +
  xlab(NULL) + ylab(NULL) +
  geom_node_text(aes(label = name), vjust = 1.8) #+ ggtitle("Grammar Network of Common Low Risk Bigrams")

# output graphs to png
png(file = "./diagrams/common_words.png", width = 8, height = 6, units = "in", res = 500)
plot(bar_words)
dev.off()
png(file = "./diagrams/common_words_high_low.png", width = 12, height = 6, units = "in", res = 500)
multiplot(bar_words_high, bar_words_low, cols = 2)
dev.off()
png(file = "./diagrams/common_bigrams.png", width = 8, height = 6, units = "in", res = 500)
plot(bar_bigrams)
dev.off()
png(file = "./diagrams/common_bigrams_high_low.png", width = 12, height = 6, units = "in", res = 500)
multiplot(bar_bigrams_high, bar_bigrams_low, cols = 2)
dev.off()
png(file = "./diagrams/common_bigrams_grammar.png", width = 8, height = 6, units = "in", res = 500)
plot(grammar_bigrams_graph)
dev.off()
png(file = "./diagrams/common_bigrams_high_grammar.png", width = 8, height = 6, units = "in", res = 500)
plot(grammar_bigrams_high_graph)
dev.off()
png(file = "./diagrams/common_bigrams_low_grammar.png", width = 8, height = 6, units = "in", res = 500)
plot(grammar_bigrams_low_graph)
dev.off()
