data_unique <- data[!(duplicated(data$URL)), ]

write.csv(data_unique, file = "./PHAEDE_data/AlibabaCrawler_2019-05-23T14-11-40_unique.csv", row.names = FALSE)
