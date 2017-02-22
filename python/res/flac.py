#!/usr/bin/env python
# -*- coding: utf-8 -*-
import urllib
import urllib2
import urlparse
import requests
import os

from gevent import monkey
from gevent.pool import Pool

monkey.patch_socket()

from bs4 import BeautifulSoup

__author__ = 'Hang Yan'

URL = 'http://www.kuwo.cn/pc/original/index'


def get_page_source(url):
    user_agent = 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_4; en-US) AppleWebKit/534.3 (KHTML, like Gecko) Chrome/6.0.472.63 Safari/534.3'
    headers = {'User-Agent': user_agent}
    req = urllib2.Request(url, None, headers)
    response = urllib2.urlopen(req)
    page = response.read()
    response.close()
    return page


def get_soup(url):
    page = get_page_source(url)
    return BeautifulSoup(page, "html.parser")


def _format_url(url):
    return url if url.startswith('http') else 'http:{}'.format(url)


def get_links():
    soup = get_soup(URL)
    items = soup.find_all('a', attrs={'class': 'mddownbtn'})
    res = []
    for i in items:
        res.append(i['href'])

    return res


def _encode_link(link):
    parsed_link = urlparse.urlsplit(link.encode('utf8'))
    parsed_link = parsed_link._replace(path=urllib.quote(parsed_link.path))
    encoded_link = parsed_link.geturl()
    return encoded_link


def __download_link(link):
    print link
    response = requests.get(link, stream=True)
    with open(link.split('/')[-1], "wb") as handle:
        for data in (response.iter_content()):
            handle.write(data)


def download_link(link):
    url = _encode_link(link)
    urllib.urlretrieve(url, link.split('/')[-1])


def downloads(links):
    for link in links:
        print link
        download_link(link)


downloads(get_links())
