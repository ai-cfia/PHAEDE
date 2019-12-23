# Plant Health Automated E-commerce Data Extractor

The plant health automated e-commerce data extractor (PHAEDE) is developed for automatically collecting information of online traded products and performing risk identification for the collected data.

## Data Collection

To collect information of online traded products, first navigate to the crawler project and then execute the `crawl` command.

```bash
cd PHWebcrawler
scrapy crawl AlibabaCrawler
```

## List of R Code

* `main.R`: The entry point of this project, where the necessary packages are loaded and the relevant scripts are sourced.
* `utils.R`: A few general utility functions.
* `import_data.R`: The code for importing the collected data to the environment.
* `remove_duplicates.R`: The code for removing duplicate instances from the originally collected data.
* `preprocessing.R`: A few data pre-processing steps.
* `data_profiling.R` and `visualization.R`: Some simple data profiling and visualization based on the categorical and non-textual data.
* `text_mining.R`: Some basic analysis based on the textual data.
* `fasttext.R` and `fasttext2.R`: The fastText model that learns the word and document vectors from the textual data (using two different API functions).
* `cart_category.R`: A CART decision tree applied on the product categories.
* `c50.R`, `cart.R`, `kmeans.R`, `knn.R`, `naive_bayes.R`, `random_forest.R`, `svm.R`, and `xgboost.R`: The supervised and unsupervised models applied on the learned document vectors.
* `roc.R`: The ROC curves for the trained models.
* `phaede/server.R` and `phaede/ui.R`: The server side functions and the user interface definition of the shiny app.
