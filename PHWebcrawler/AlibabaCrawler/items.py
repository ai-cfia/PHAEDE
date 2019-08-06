# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class Product(scrapy.Item):
    # define the fields for your item here like:
    Title = scrapy.Field()
    URL = scrapy.Field()
    Category1 = scrapy.Field()
    Category2 = scrapy.Field()
    Category3 = scrapy.Field()
    Category4 = scrapy.Field()
    Description = scrapy.Field()
    Seller = scrapy.Field()
    Origin = scrapy.Field()
    Price = scrapy.Field()
    Currency = scrapy.Field()
    Unit = scrapy.Field()
    Ships_To_NA = scrapy.Field()
    Search_Term = scrapy.Field()
