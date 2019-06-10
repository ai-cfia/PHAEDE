# filter out duplicate rows not including the search term
complete_dup_filtered <- data[!duplicated(data[1:8]), ]
filtered_url_dups <- (complete_dup_filtered[duplicated(complete_dup_filtered$URL), ])

# filter out rows that have the same URL but other info defers
false_dups <- complete_dup_filtered %>% filter(URL %in% filtered_url_dups$URL) %>% arrange(desc(Title))

# split the original data set by their search terms
achatina <- complete_dup_filtered %>% filter(Search_Term == "achatina")
brown <- complete_dup_filtered %>% filter(Search_Term == "brown garden snail")
edible <- complete_dup_filtered %>% filter(Search_Term == "edible snail")
giant <- complete_dup_filtered %>% filter(Search_Term == "giant african snail")
helix <- complete_dup_filtered %>% filter(Search_Term == "helix snail")
live <- complete_dup_filtered %>% filter(Search_Term == "live snail")

gen_Ships_ftable <- function(df) {
  # count the number of entries that ship, don't ship and are missing
  num_true <- sum(df, na.rm = TRUE)
  num_false <- sum(!df, na.rm = TRUE)
  num_missing <- sum(is.na(df))
  # create a tibble for the frequency table
  tribble(~ Ships_Val,
          ~ Freq,
          "TRUE",
          num_true,
          "FALSE",
          num_false,
          "Missing",
          num_missing)
}

# generate frequency tables to see how many products do or do not ship to north america
ships_freq <- gen_Ships_ftable(complete_dup_filtered$Ships_To_NA)
ships_freq_achatina <- gen_Ships_ftable(achatina$Ships_To_NA)
ships_freq_brown <- gen_Ships_ftable(brown$Ships_To_NA)
ships_freq_edible <- gen_Ships_ftable(edible$Ships_To_NA)
ships_freq_giant <- gen_Ships_ftable(giant$Ships_To_NA)
ships_freq_helix <- gen_Ships_ftable(helix$Ships_To_NA)
ships_freq_live <- gen_Ships_ftable(live$Ships_To_NA)

# create a table that contains logical values to see if a val is na or not
missing_vals <- transmute(
  complete_dup_filtered,
  no_origin = is.na(Origin),
  no_ships = is.na(Ships_To_NA),
  no_price = is.na(Price),
  no_curr = is.na(Currency),
  no_unit = is.na(Unit)
)

# plot relation between between missing origin values adn missing ships to na value
ggplot(data = missing_vals) + geom_bar(mapping = aes(x = no_origin, fill = no_ships))

# show a correlation plot for all missing values
missing_vals_corr <- cor(missing_vals)
corrplot(missing_vals_corr)

# obtain all values where the origin is missing
origin_missing <- missing_vals %>% filter(no_origin) %>% select(no_ships:no_unit)

# plot number of missing ships to na for when the origin is missing as well
ggplot(data = origin_missing) + geom_bar(mapping = aes(x = no_ships, fill = no_ships))

# obtain chart for when origin is present and repeat above plot
origin_present <- missing_vals %>% filter(!no_origin) %>% select(no_ships:no_unit)
ggplot(data = origin_present) + geom_bar(mapping = aes(x = no_ships, fill = no_ships))

# see how many products are able to ship to north america from each origin country
origin_does_ship <- complete_dup_filtered %>% filter(Ships_To_NA) %>% select(Origin) %>% table(useNA = "always")

# filter products based on known key words to reduce
filtered_prods <- complete_dup_filtered %>% filter(!(
  grepl("powder", tolower(Title)) |
    grepl("slime", tolower(Title)) |
    grepl("extract", tolower(Title)) |
    grepl("repair", tolower(Title)) |
    grepl("cosmetic", tolower(Title)) |
    grepl("plastic", tolower(Title)) |
    grepl("beauty", tolower(Title)) |
    grepl("moisturizer", tolower(Title)) |
    grepl("garden", tolower(Title)) |
    grepl("cream", tolower(Title))
))

# get the frequency of each origin country
origin_freq <- filtered_prods %>% select(Origin) %>% table(useNA = "always")

# sample the filtered products
set.seed(123)
strat_sample <- stratified(filtered_prods, "Origin", 15)
set.seed(123)
rows <- sample(1:474, 200)
print(rows)
simp_sample <- filtered_prods[rows, ]

# get frequency of each country in the sample
strat_origin_count <- table(strat_sample$Origin)
simp_origin_count <- table(simp_sample$Origin)
split_tables <-  split(filtered_prods, f = filtered_prods$Origin)
countries <- filtered_prods[!duplicated(filtered_prods$Origin), ]$Origin %>% sort()
count <- 1
proportions <- list()
for (table in split_tables) {
  num_rows <- nrow(table)
  percentage <- num_rows / 474
  proportion <- round(percentage * 200)
  if (proportion == 0) {
    proportion <- 1
  }
  country <- countries[count]
  count = count + 1
  proportions <- append(proportions, list(country, proportion))
}

# loop through every element in the proportions list
multi_stage_sample <- NULL
for (i in 1:34) {
  # obtain current country
  country_index <- (2 * i) - 1
  proportion_index <- (2 * i)
  curr_country <- proportions[[country_index]]
  curr_proportion <- proportions[[proportion_index]]
  # create a temp data set that will contain all entries of the current country
  temp_set <- filtered_prods %>% filter(Origin == curr_country)
  # simple sample from each temp set the amount of elements defined by proportion
  set.seed(123)
  rows <- sample(1:nrow(temp_set), curr_proportion)
  sample_set <- temp_set[rows, ]
  if (i == 1) {
    multi_stage_sample <- sample_set
  } else{
    multi_stage_sample <- rbind(multi_stage_sample, sample_set)
  }
}

# lastly sample the rows where the origin is not
curr_proportion <- round((155 / 474) * 200)

# sample the missing origin rows and add it to the multi stage sample
temp_set <- filtered_prods %>% filter(is.na(Origin))
set.seed(123)
rows <- sample(1:nrow(temp_set), curr_proportion)
sample_set <- temp_set[rows, ]
multi_stage_sample <- rbind(multi_stage_sample, sample_set)
