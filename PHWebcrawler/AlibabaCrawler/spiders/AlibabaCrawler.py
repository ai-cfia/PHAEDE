# -*- coding: utf-8 -*-
import scrapy
import re
from .. import items
from bs4 import BeautifulSoup
from selenium import webdriver
from requests import get
from time import sleep

# change this path to wherever the chrome webdriver is located in your system
WEBDRIVER_PATH = ("D:\\chromedriver_win32\\" + "chromedriver.exe")

class AlibabaCrawlerSpider(scrapy.Spider):
    name = "AlibabaCrawler"

    def __init__(self):
        # open the webdriver when the spider starts crawling
        self.driver = webdriver.Chrome(WEBDRIVER_PATH)
        self.product_driver = webdriver.Chrome(WEBDRIVER_PATH)
        self.seller_driver = webdriver.Chrome(WEBDRIVER_PATH)
        self.ships_to_NA = dict({})

    def start_requests(self):
        urls = [
            "https://www.alibaba.com/products/helix_snail.html?IndexArea=product_en&page=1",
            "https://www.alibaba.com/products/live_snail.html?IndexArea=product_en&page=1",
            "https://www.alibaba.com/products/edible_snail.html?IndexArea=product_en&page=1",
            "https://www.alibaba.com/products/giant_african_snail.html?IndexArea=product_en&page=1",
            "https://www.alibaba.com/products/achatina.html?IndexArea=product_en&page=1",
            "https://www.alibaba.com/products/brown_garden_snail.html?IndexArea=product_en&page=1"
        ]
        for url in urls:
            yield scrapy.Request(url=url, callback=self.parse_catalogue)

    def close_spider(self, spider):
        # quit the webdriver when the spider closes
        self.driver.quit()
        self.product_driver.quit()
        self.seller_driver.quit()
            
    def parse_catalogue(self, response):
        # open up the webpage using selenium
        self.driver.get(response.url)
        # scroll to bottom of the page to load the second half of the catalogue
        self.driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        # sleep 1 second to allow the page to load
        sleep(3)
        page_html = self.driver.page_source
        # first parse html into beautiful soup
        soup = BeautifulSoup(page_html, "lxml")

        # obtain all product elements from the current catalogue page
        products = soup.find_all("div", class_="item-content")

        # for each one of the products parse the information on the ad
        for product in products:
            # pass the product to the parse product helper
            prod_info = self._parse_product(response, product)

            # yield the product item after parsing
            if (prod_info is not None):
                yield prod_info

        # recursivley parse up until page 50 or until there are no products
        # store starting url
        starting_URL = response.request.url
        str_len = len("&page=")
        # check if what the current page number is
        page_number = int(starting_URL[starting_URL.find("&page=") + str_len:])
        if (page_number < 50 and len(products) > 0):
            # get a substring of the original url removing the page number
            base_URL = starting_URL[0:starting_URL.find("&page=") + str_len]
            # generate new URL
            new_URL = base_URL + str(page_number + 1)
            # parse the next page
            yield response.follow(new_URL, callback=self.parse_catalogue)

    def _parse_product(self, response, prod):
        # obtain the title
        # start by getting the title element
        title_element = prod.find("div", class_="title-wrap")

        # Ensure the title_element isn't None
        if (title_element is not None):
            # obtain the actual title from the element
            title = title_element.h2.text.strip()

            # next obtain the the URL
            URL = title_element.h2.a["href"]

            # request the product page
            page_response = self.product_driver.get("http:" + URL)
            product_page = BeautifulSoup(self.product_driver.page_source, "lxml")

            # parse the product description
            description = self._parse_product_description(product_page)

            # parse the product price
            (price_mag, currency, unit) = self._parse_product_price(prod)

            # parse the seller information
            (seller_name, origin, doesShip) = self._parse_seller_info(prod)
            
            # parse the url for the search term
            term = self._parse_search_term(response.url)
            
            # generate and return product item
            return items.Product(Title=title, URL=URL, Description=description,
                                 Price=price_mag, Currency=currency, Unit=unit,
                                 Seller=seller_name, Origin=origin, Ships_To_NA=doesShip,
                                 Search_Term=term)
        else:
            return None
    
    def _parse_product_description(self, product_page):
        # obtain the product description tab
        description_tab = product_page.find("div", class_="richtext richtext-detail rich-text-description")

        # initialize info var
        description = None

        if (description_tab is not None):
            # obtain the text of product description
            description = description_tab.getText(separator=" ").replace("\r", " ").replace("\n", " ").replace("\xa0", " ").strip()
            description = re.sub(" +", " ", description)

        return description

    def _parse_product_price(self, prod):
        # now obtain the cost information
        price_element = prod.find("div", class_="price")

        # intitlize the magnitude of the price and currency
        price_mag = None
        currency = None
        unit = None

        # check if the price_element is none
        if (price_element is not None):
            # obtain the complete price text
            complete_price = price_element.text.strip()
            # check if a unit is given
            unit_index = complete_price.find("/")
            if (unit_index != -1):
                unit_text = complete_price[unit_index:].strip()
                price = complete_price[0:unit_index].strip()
            else:
                unit_text = None
                price = complete_price
            # check if there is a "-" in the price
            range_index = price.find("-")
            if (range_index != -1):
                # if there is a range take lower end of the cost
                price = price[0:range_index]

            # get the magnitude of the price
            price_mag = isolate_numeric(price, exclusions=["."])

            # obtain the currency from the price
            currency = isolate_alpha(price)

            # obtain unit
            if (unit_text is not None):
                unit = unit_text[1:].strip()
            else:
                unit = None

        return (price_mag, currency, unit)

    def _parse_seller_info(self, prod):
        # obtain the div containing the seller info
        seller_info = prod.find("div", class_="extra-wrap")

        # initialize info vars
        seller_name = None
        origin = None
        doesShip = None

        # ensure the seller info has been found
        if (seller_info is not None):
            # first find the seller name
            seller_name_element = seller_info.find("div", class_="stitle")

            # check if the product has a seller name
            if (seller_name_element is not None):
                seller_name = seller_name_element.a.text.strip()

            # now obtain the seller origin
            origin_element = seller_info.find("span", class_="location")

            # check if the seller origin is available
            if (origin_element is not None):
                # extract the name from the element
                origin = origin_element.text.strip()

            # check if the current seller name in is in the ships to an dict
            if (seller_name in self.ships_to_NA):
                # if it is then obtain if the seller ships to na
                doesShip = self.ships_to_NA[seller_name]

            else:
                # if the name isn't in the dict obtain the seller page url
                # request the seller page
                if (seller_name_element is not None):
                    page_response = self.seller_driver.get("http:" + seller_name_element.a["href"])
                    seller_page = BeautifulSoup(self.seller_driver.page_source, "lxml")
                    doesShip = self._parse_seller_page(seller_page)
                    self.ships_to_NA[seller_name] = doesShip

        # now return the extracted seller info
        return (seller_name, origin, doesShip)

    def _parse_seller_page(self, seller_page):
        # obtain the trade capabilities pane
        trade_caps = seller_page.find("div", class_="icbu-pc-cpTradeCapability")

        # check if the pane was found
        if (trade_caps is not None):
            # if the pane was found find all of its information lists
            trade_info = trade_caps.find_all("div", class_="infoList-mod-field")

            # loop through  each element looking for list on main markets
            market_index = -1
            curr_index = 0

            while (curr_index < len(trade_info) and market_index == -1):
                # obtain the title element
                curr_list = trade_info[curr_index]
                list_title = curr_list.find("div", class_="title").text

                # check if title contains "Main Markets"
                if (list_title.find("Main Markets") != -1):
                    # if it is found then set the market_index to curr_index
                    market_index = curr_index

                # iterate curr_index
                curr_index += 1

            # check if Main Markets was found
            if (market_index != -1):
                # if the market was found then check the list of markets for NA
                main_markets = trade_info[market_index]
                market_info = main_markets.find("div", class_="content").text
                # check if the market info contains North America
                contains_NA = market_info.find("North America")
                if (contains_NA != -1):
                    return "TRUE"
                else:
                    return "FALSE"
            else:
                return None
        else:
            # try parsing the trade capabilities from an alternate format
            trade_caps = seller_page.find("div", class_="widget-supplier-trade-market")
            if (trade_caps is not None):
                # if the trade caps were found in an alternate forma
                # check if the North American is listed
                contains_NA = trade_caps.text.upper().find("NORTH AMERICA")
                if (contains_NA != -1):
                    return True
                else:
                    return False
            else:
                return None
            
    def _parse_search_term(self, url):
        # find where the search terms starts in the url
        start = url.find("products/") + len("products/")
        # find where the search term ends by looking for .html
        end = url.find(".html", start)
        # extract the search term from the url and remove any underscore
        search_term = url[start:end].replace("_", " ")
        return search_term
    
    
def isolate_numeric(text, exclusions=[]):
    # initialize a variable to store the new text
    new_text = ""
    # check every character in the original for non-numeric characters
    for i in range(len(text)):
        if (text[i].isnumeric() or text[i] in exclusions):
            new_text = new_text + text[i]
    return new_text


def isolate_alpha(text):
    # initialize a variable to store the new text
    new_text = ""
    # check every character in the original for non-numeric characters
    for i in range(len(text)):
        if (text[i].isalpha()):
            new_text = new_text + text[i]
    return new_text
