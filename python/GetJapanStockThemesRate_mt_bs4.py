# -*- coding: UTF-8 -*-

from datetime import datetime
from concurrent.futures import ProcessPoolExecutor
from threading import Lock
import asyncio
import httpx
from bs4 import BeautifulSoup

class StockTheme:
    def __init__(self, name, url="", rate=""):
        self.themeName = name
        self.url = url
        self.rate = rate

def output2file(content):
    filePath = "C:/work/python/workspace/test/output/Output_asynchronous_7.txt"
    with open(filePath, "a", encoding="UTF-8") as text_file:
        print(content, file=text_file)

BASE_URL = 'https://minkabu.jp'
MAX_PAGE = 71

# FEATURES_PARSER = "html.parser"
FEATURES_PARSER = "lxml"
COUNT_PROCESS = 7

def parsePages(htmlPages1Group):
    ThemeObjectList = []
    for html in htmlPages1Group:
        soup = BeautifulSoup(html, FEATURES_PARSER)
        # links4Theme = soup.select('a[href^="/theme/"]')
        links4Theme = soup.find_all("a", class_="text-minkabuOldLink font-bold hover:text-blue-500")
        for aLink in links4Theme:
            name = aLink.select('p')[0].text
            url = f"{BASE_URL}{aLink.attrs['href']}"
            st = StockTheme(name, url)
            ThemeObjectList.append(st)
    return ThemeObjectList

def parseTheme(htmlPages1Group):
    objectList = []
    for html in htmlPages1Group:
        soup_theme = BeautifulSoup(html, FEATURES_PARSER)
        pageNotFound = soup_theme.find("div", string="URLが間違っているか、ページが削除された可能性があります。")
        if (pageNotFound is None):
            rateTheme = soup_theme.find("div", {"bg-minkabuBlueDown rounded-sm px-1 py-0.5 text-sm font-bold text-white", "bg-minkabuRedUp rounded-sm px-1 py-0.5 text-sm font-bold text-white", "bg-minkabuGrayEven rounded-sm px-1 py-0.5 text-sm font-bold text-white"})
            rate = rateTheme.text

            name = soup_theme.find("h1", class_="text-xl font-bold").text
            name = name[5 : len(name)-1]
            st = StockTheme(name, rate=rate)
        else:
            # msg = f'{datetime.now()} theme page not found. theme name={st.themeName}'
            # print(msg)
            # output2file(msg)
            st = None
        objectList.append(st)
    return objectList

async def scrape(urls):
    results = []
    async with httpx.AsyncClient(timeout=httpx.Timeout(30.0)) as client:
        scrape_tasks = [client.get(url) for url in urls]
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

if __name__ == '__main__':
    msg = f"{datetime.now()} Begin!!"
    print(msg)
    output2file(msg)
    urlGroups = getUrlGroupsByPages()
    print(f"{datetime.now()} scrape pages started")
    htmlPageGroups = multi_process(urlGroups)
    print(f"{datetime.now()} scrape pages ended")

    ThemeObjGroups = []
    urlGroups = []
    for groupProcess in htmlPageGroups:
        oneGroup = parsePages(groupProcess)
        ThemeObjGroups.append(oneGroup)
        urlGroups.append([theme.url for theme in oneGroup])
    
    print(f"{datetime.now()} scrape themes started")
    htmlThemeGroups = multi_process(urlGroups)
    print(f"{datetime.now()} scrape themes ended")
    print(f"{datetime.now()} parse themes started")
    for i, groupProcessThemeObjects in enumerate(ThemeObjGroups):
        groupProcesshtmlThemes = htmlThemeGroups[i]
        themeList1Group = parseTheme(groupProcesshtmlThemes)
        for themeObj in themeList1Group:
            if themeObj is None:
                continue
            st = next((obj for obj in groupProcessThemeObjects if obj.themeName == themeObj.themeName), None)
            if st is not None:
                st.rate = themeObj.rate
    print(f"{datetime.now()} parse themes ended")
    ThemeList = []
    for objGroup in ThemeObjGroups:
        ThemeList.extend(objGroup)
    print(len(ThemeList))
    ThemeListSorted = sorted(ThemeList, key=lambda theme: -100.0 if ((theme.rate is None) or ("" == theme.rate)) else float(theme.rate.replace("%", "")), reverse=True)
    for theme in ThemeListSorted:
        output2file(f"{theme.themeName}\t\t\t{theme.rate}")
    
    msg = f"{datetime.now()} Completed!!"
    print(msg)
    output2file(msg)