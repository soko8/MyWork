# -*- coding: UTF-8 -*-

import os
from datetime import datetime
from concurrent.futures import ProcessPoolExecutor
from threading import Lock
import asyncio
import httpx
from lxml import etree

class StockTheme:
    def __init__(self, name, url="", rate="", pageId=""):
        self.themeName = name
        self.url = url
        self.rate = rate
        self.pageId = pageId
        self.stockCount = ""

FILE_PATH = "C:/work/python/workspace/test/output/Output_asynchronous_7.txt"
def output2file(content):
    with open(FILE_PATH, "a", encoding="UTF-8") as text_file:
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

async def scrape(urls):
    results = []
    async with httpx.AsyncClient(verify=False, timeout=httpx.Timeout(30.0, read=None)) as client:
        scrape_tasks = [client.get(url=url, timeout=None) for url in urls]
        for response_f in asyncio.as_completed(scrape_tasks):
            response = await response_f
            # output2file(dir(response))
            # output2file(response.request)
            # output2file(str(response.url).replace("https://minkabu.jp/theme/", ""))
            htmlContent = response.text
            results.append(htmlContent)
    return results

def scrape_wrapper(args):
    i, urls = args
    print(f"{datetime.now()} subprocess {i} started")
    result = asyncio.run(scrape(urls))
    print(f"{datetime.now()} subprocess {i} ended")
    return result

def getUrlGroupsByPages():
    count_page_per_process = round(MAX_PAGE/COUNT_PROCESS)
    pageStartEnds = [(count_page_per_process*i+1, count_page_per_process*(i+1)) for i in range(COUNT_PROCESS)]
    pageStartEnds[COUNT_PROCESS-1] = (count_page_per_process*(COUNT_PROCESS-1)+1, MAX_PAGE)
    urlGroups4Process = []
    for pageStartEnd in pageStartEnds:
        urlGroups4Process.append([f'{BASE_URL}/theme?page={i}' for i in range(pageStartEnd[0], pageStartEnd[1]+1)])
    return urlGroups4Process

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
    os.rename(FILE_PATH, f'{FILE_PATH[0:len(FILE_PATH)-4]}_{datetime.now().strftime("%Y%m%d%H%M%S%f")}.txt')
    urlGroups = getUrlGroupsByPages()
    print(f"{datetime.now()} scrape pages started")
    timeMarkScrapePagesStart = datetime.now()
    htmlPageGroups = multi_process(urlGroups)
    timeMarkScrapePagesEnd = datetime.now()
    print(f"scrape pages cost time :\t{(timeMarkScrapePagesEnd - timeMarkScrapePagesStart).total_seconds()} s.")
    print(f"{datetime.now()} scrape pages ended")

    ThemeObjGroups = []
    urlGroups = []
    timeMarkParsePagesStart = datetime.now()
    for groupProcess in htmlPageGroups:
        oneGroup = parsePages(groupProcess)
        ThemeObjGroups.append(oneGroup)
        urlGroups.append([theme.url for theme in oneGroup])
    timeMarkParsePagesEnd = datetime.now()
    print(f" parse pages cost time :\t{(timeMarkParsePagesEnd - timeMarkParsePagesStart).total_seconds()} s.")

    print(f"{datetime.now()} scrape themes started")
    timeMarkScrapeThemesStart = datetime.now()
    htmlThemeGroups = multi_process(urlGroups)
    timeMarkScrapeThemesEnd = datetime.now()
    print(f"scrape themes cost time :\t{(timeMarkScrapeThemesEnd - timeMarkScrapeThemesStart).total_seconds()} s.")
    print(f"{datetime.now()} scrape themes ended")

    print(f"{datetime.now()} parse themes started")
    timeMarkParseThemesStart = datetime.now()
    for i, groupProcessThemeObjects in enumerate(ThemeObjGroups):
        groupProcesshtmlThemes = htmlThemeGroups[i]
        themeList1Group = parseTheme(groupProcesshtmlThemes)
        for themeObj in themeList1Group:
            if themeObj is None:
                continue
            st = next((obj for obj in groupProcessThemeObjects if obj.themeName == themeObj.themeName), None)
            if st is not None:
                st.rate = themeObj.rate
    timeMarkParseThemesEnd = datetime.now()
    print(f"parse themes cost time :\t{(timeMarkParseThemesEnd - timeMarkParseThemesStart).total_seconds()} s.")
    print(f"{datetime.now()} parse themes ended")

    ThemeList = []
    for objGroup in ThemeObjGroups:
        ThemeList.extend(objGroup)
    
    # filter
    ThemeList = list(filter(lambda theme: theme.rate is not None and "" != theme.rate and 2 < int(theme.stockCount.replace("全", "").replace("社", "")), ThemeList))
    count_theme = len(ThemeList)
    print(count_theme)
    # ThemeListSorted = sorted(ThemeList, key=lambda theme: -100.0 if ((theme.rate is None) or ("" == theme.rate)) else float(theme.rate.replace("%", "")), reverse=True)
    ThemeListSorted = sorted(ThemeList, key=lambda theme: float(theme.rate.replace("%", "")), reverse=True)

    for i, theme in enumerate(ThemeListSorted):
        msg = f"{theme.themeName}\tpid={theme.pageId}\t\t{theme.rate}\t{theme.stockCount}"
        if (i <= 10) or ((count_theme-10) <= i) :
            print(msg)
        output2file(msg)
    timeMarkEnd = datetime.now()
    print(f"total cost time :\t{(timeMarkEnd - timeMarkStart).total_seconds()} s.")
    msg = f"{datetime.now()} Completed!!"
    print(msg)
    output2file(msg)

if __name__ == '__main__':
    main()