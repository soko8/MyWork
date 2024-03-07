# -*- coding: UTF-8 -*-

import os
from datetime import datetime
from concurrent.futures import ProcessPoolExecutor
from threading import Lock
import asyncio
# python -m pip install (パッケージ名)
import httpx
from lxml import etree

class StockTheme:
    def __init__(self, name, url="", rate="", pageId=""):
        self.themeName = name
        self.url = url
        self.rate = rate
        self.pageId = pageId
        self.stockCount = ""
    def __str__(self):
        return f'name:{self.themeName}, pid:{self.pageId}, rate:{self.rate}, stock count:{self.stockCount}, url:{self.url}'

FILE_PATH_LOG = "D:/develop/python/workspace/output/log.log"
FILE_PATH = "D:/develop/python/workspace/output/Output_asynchronous_7.txt"
def output2file(content, filePath=FILE_PATH_LOG):
    with open(filePath, "a", encoding="UTF-8") as text_file:
        print(content, file=text_file)

BASE_URL = 'https://minkabu.jp'
MAX_PAGE = 71
COUNT_PROCESS = 7

def parsePages(htmlPages1Group):
    ThemeObjectList = []
    for html in htmlPages1Group:
        tree = etree.HTML(html)
        links4Theme = tree.xpath('//a[@class="text-minkabuOldLink font-bold hover:text-blue-500"]')
        pageUrlElement = tree.xpath('//link[@rel="canonical"]')[0]
        pageUrl = pageUrlElement.xpath('./@href')[0]
        pageId = pageUrl.replace("https://minkabu.jp/theme", "").replace("?page=", "")
        if 0 == len(pageId) :
            pageId = "1"
        for aLink in links4Theme:
            name = aLink.xpath('.//p[1]/text()')[0]
            url = f"{BASE_URL}{aLink.xpath('./@href')[0]}"
            st = StockTheme(name, url=url, pageId=pageId)

            stock_count = aLink.xpath('./../following-sibling::td[2]/text()')[0]
            st.stockCount = stock_count

            ThemeObjectList.append(st)
    return ThemeObjectList

def parseTheme(htmlPages1Group):
    objectList = []
    for html in htmlPages1Group:
        tree = etree.HTML(html)
        pageNotFound = tree.xpath('//*[text() = "URLが間違っているか、ページが削除された可能性があります。"]')

        if (0 == len(pageNotFound)):
            rateThemes = tree.xpath('//div[@class="bg-minkabuBlueDown rounded-sm px-1 py-0.5 text-sm font-bold text-white" or @class="bg-minkabuRedUp rounded-sm px-1 py-0.5 text-sm font-bold text-white" or @class="bg-minkabuGrayEven rounded-sm px-1 py-0.5 text-sm font-bold text-white"]')
            rate = rateThemes[0].xpath('./text()')[0]

            name = tree.xpath('//h1[@class="text-xl font-bold"]/text()')[0]
            name = name[5 : len(name)-1]
            st = StockTheme(name, rate=rate)
        else:
            output2file("pageNotFound")
            st = None
        objectList.append(st)
    return objectList

def getUrlGroups(objList):
    count_obj_list = len(objList)
    count_one_process = round(count_obj_list/COUNT_PROCESS)
    indexStartEnds = [(count_one_process*i+1, count_one_process*(i+1)) for i in range(COUNT_PROCESS)]
    indexStartEnds[COUNT_PROCESS-1] = (count_one_process*(COUNT_PROCESS-1)+1, count_obj_list)
    urlGroups = []
    for indexStartEnd in indexStartEnds:
        urlGroups.append([obj.url for obj in objList[indexStartEnd[0] : indexStartEnd[1]+1]])
    return urlGroups

async def scrape(urls):
    htmls = []
    async with httpx.AsyncClient(verify=False, timeout=httpx.Timeout(30.0, read=None)) as client:
        scrape_tasks = [client.get(url=url, timeout=None) for url in urls]
        for response_f in asyncio.as_completed(scrape_tasks):
            response = await response_f
            # output2file(dir(response))
            # output2file(response.request)
            # output2file(str(response.url).replace("https://minkabu.jp/theme/", ""))
            htmlContent = response.text
            htmls.append(htmlContent)

    return htmls

def scrape_wrapper(args):
    i, urls = args
    print(f"{datetime.now()} subprocess {i} started")
    htmls = asyncio.run(scrape(urls))
    themes = parseTheme(htmls)
    print(f"{datetime.now()} subprocess {i} ended")
    return themes

def multi_process(urlGroups):
    listGroup = []
    lock = Lock()
    with ProcessPoolExecutor(max_workers=COUNT_PROCESS) as pool:
        results = pool.map(scrape_wrapper, enumerate(urlGroups))
        lock.acquire()
        listGroup.extend(results)
        lock.release()
    return listGroup

def main():
    timeMarkStart = datetime.now()
    msg = f"{datetime.now()} Begin!!"
    print(msg)
    output2file(msg)
    if os.path.exists(FILE_PATH) :
        os.rename(FILE_PATH, f'{FILE_PATH[0:len(FILE_PATH)-4]}_{datetime.now().strftime("%Y%m%d%H%M%S%f")}.txt')
    urls = [f'{BASE_URL}/theme?page={i}' for i in range(1, MAX_PAGE+1)]
    print(f"{datetime.now()} scrape pages started")
    timeMarkScrapePagesStart = datetime.now()
    pageHtmls = asyncio.run(scrape(urls))
    timeMarkScrapePagesEnd = datetime.now()
    print(f"scrape pages cost time :\t{(timeMarkScrapePagesEnd - timeMarkScrapePagesStart).total_seconds()} s.")
    print(f"{datetime.now()} scrape pages ended")


    timeMarkParsePagesStart = datetime.now()
    themeList = parsePages(pageHtmls)
    timeMarkParsePagesEnd = datetime.now()
    print(f" parse pages cost time :\t{(timeMarkParsePagesEnd - timeMarkParsePagesStart).total_seconds()} s.")

    count_theme = len(themeList)
    print(count_theme)

    print(f"{datetime.now()} scrape and parse themes started")
    timeMarkScrapeThemesStart = datetime.now()
    urlsGroups = getUrlGroups(themeList)
    themeRatesGroups = multi_process(urlsGroups)
    timeMarkScrapeThemesEnd = datetime.now()
    print(f"scrape and parse themes cost time :\t{(timeMarkScrapeThemesEnd - timeMarkScrapeThemesStart).total_seconds()} s.")
    print(f"{datetime.now()} scrape and parse themes ended")


    print(f"{datetime.now()} match themes started")
    timeMarkMatchThemesStart = datetime.now()
    for themeRatesGroup in themeRatesGroups:
        for themeObj in themeRatesGroup:
            if themeObj is None:
                continue
            st = next((obj for obj in themeList if obj.themeName == themeObj.themeName), None)
            if st is not None:
                st.rate = themeObj.rate
    timeMarkMatchThemesEnd = datetime.now()
    print(f"match themes cost time :\t{(timeMarkMatchThemesEnd - timeMarkMatchThemesStart).total_seconds()} s.")
    print(f"{datetime.now()} match themes ended")



    # filter
    ThemeList = list(filter(lambda theme: theme.rate is not None and "" != theme.rate and 2 < int(theme.stockCount.replace("全", "").replace("社", "")), themeList))
    count_theme = len(ThemeList)
    print(count_theme)
    # ThemeListSorted = sorted(ThemeList, key=lambda theme: -100.0 if ((theme.rate is None) or ("" == theme.rate)) else float(theme.rate.replace("%", "")), reverse=True)
    ThemeListSorted = sorted(ThemeList, key=lambda theme: float(theme.rate.replace("%", "")), reverse=True)

    for i, theme in enumerate(ThemeListSorted):
        msg = f"{theme.themeName}\tpid={theme.pageId}\t\t{theme.rate}\t{theme.stockCount}"
        if (i <= 10) or ((count_theme-10) <= i) :
            print(msg)
        output2file(msg, FILE_PATH)
    timeMarkEnd = datetime.now()
    print(f"total cost time :\t{(timeMarkEnd - timeMarkStart).total_seconds()} s.")
    msg = f"{datetime.now()} Completed!!"
    print(msg)
    output2file(msg)

if __name__ == '__main__':
    main()