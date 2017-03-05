# -*- coding: utf-8 -*-
import scrapy
from scrapy.linkextractors import LinkExtractor
from scrapy.spiders import CrawlSpider, Rule

from my_crawler.items import MyCrawlerItem


class MyCrawlSpider(CrawlSpider):
    name = 'my_crawler'  # Spider名，必须唯一，执行爬虫命令时使用
    allowed_domains = ['bjhee.com']  # 限定允许爬的域名，可设置多个
    start_urls = [
        "http://www.bjhee.com",  # 种子URL，可设置多个
    ]

    rules = (  # 对应特定URL，设置解析函数，可设置多个
        Rule(LinkExtractor(allow=r'/page/[0-9]+'),  # 指定允许继续爬取的URL格式，支持正则
             callback='parse_item',  # 用于解析网页的回调函数名
             follow=True
             ),
    )

    def parse_item(self, response):
        # 通过XPath获取Dom元素
        articles = response.xpath('//*[@id="main"]/ul/li')

        for article in articles:
            item = MyCrawlerItem()
            item['title'] = article.xpath('h3[@class="entry-title"]/a/text()').extract()[0]
            item['url'] = article.xpath('h3[@class="entry-title"]/a/@href').extract()[0]
            item['summary'] = article.xpath('div[2]/p/text()').extract()[0]
            yield item