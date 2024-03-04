# -*- coding: UTF-8 -*-

import os
import sys

# Add vendor directory to module search path
parent_dir = os.path.abspath(os.path.dirname(__file__))
vendor_dir = os.path.join(parent_dir, 'vendor')

sys.path.append(vendor_dir)

class StockInfoWithThemes:
    def __init__(self, name, code, url="", rate="", price="", updateTime=""):   
        self.stockName = name
        self.stockCode = code
        self.rate=rate
        self.url=url
        self.price=price
        self.updateTime=updateTime
        self.themeList= []
   
    def __str__(self):
       # return repr({"code":self.stockCode, "name":self.stockName, "price":self.price, "rate":self.rate, "relationship":self.relationshipPercentages, "url":self.url, "updateTime":self.updateTime})
        return f'"code":{self.stockCode}, "name":{self.stockName}, "price":{self.price}, "rate":{self.rate}, "url":{self.url}, "updateTime":{self.updateTime}, "theme list":{"; ".join(str(x) for x in self.themeList)}'

class StockInfo:
    def __init__(self, name, code, rate="", url="", price="", relationshipPercentages="", updateTime=""):
        self.stockName=name
        self.stockCode=code
        self.rate=rate
        self.url=url
        self.price=price
        self.relationshipPercentages=relationshipPercentages
        self.updateTime=updateTime
   
    def __str__(self):
        # return repr({"code":self.stockCode, "name":self.stockName, "price":self.price, "rate":self.rate, "relationship":self.relationshipPercentages, "url":self.url, "updateTime":self.updateTime})
        return f'"code":{self.stockCode}, "name":{self.stockName}, "price":{self.price}, "rate":{self.rate}, "relationship":{self.relationshipPercentages}, "url":{self.url}, "updateTime":{self.updateTime}'
    
class StockTheme:
# 此处声明的变量是类变量，不是实例变量。
# 实例变量在__init__函数中用self.变量名声明
    """
    themeName = ""
    rate = ""
    stockList = []
    url = ""
    """
    def __init__(self, name, url, rate=""):
        # 实例变量在此处声明
        self.themeName = name
        self.rate = rate
        self.url = url
        self.stockList = []
    
    def __str__(self):
        # return repr({"name":self.themeName, "rate":self.rate, "url":self.url, "relate stock":self.stockList})   
        return f'"name":{self.themeName}, "rate":{self.rate}, "url":{self.url}, "relate stock":{"; ".join(str(x) for x in self.stockList)}'
    
    def add2List(self, stock):
        self.stockList.append(stock)

FILE_PATH_LOG = "D:/develop/python/workspace/output/log.log"
FILE_PATH_STOCK_THEME_MAP = "D:/develop/python/workspace/output/StockThemeMap.txt"
FILE_PATH_THEME_STOCK_MAP = "D:/develop/python/workspace/output/ThemeStockMap.txt"
def output2file(filePath, content):
    # filePath = "C:/work/python/workspace/test/output/StockThemeMap.txt"
    with open(filePath, "a", encoding="UTF-8") as text_file:    
        print(content, file=text_file)

#pip install requests for installation

from datetime import datetime
from concurrent.futures import ThreadPoolExecutor
from threading import current_thread, get_ident, get_native_id, Lock
import requests
from bs4 import BeautifulSoup

BASE_URL = 'https://minkabu.jp'
MAX_PAGE = 71

def getStockInfo(trHtml):
    stockNameHtml=trHtml.find("p", class_="text-minkabuOldLink text-sm font-bold leading-tight hover:text-blue-500")
    stockName = stockNameHtml.text.strip()
    # print(stockName)
    stockUrl = stockNameHtml.parent.attrs['href']
    # print(stockUrl)
    stockCode=stockUrl.replace("/stock/", "")
    # print(stockCode)
    stockPrice=trHtml.find("p", class_="whitespace-nowrap text-sm").text
    # print(stockPrice)
    stockRelationship = trHtml.find("relationship-percentages-graph").attrs[':value']
    # print("stockRelationship==" + stockRelationship)
    stock = StockInfo(stockName, stockCode)
    stock.url = BASE_URL + stockUrl
    stock.price = stockPrice
    stock.relationshipPercentages = stockRelationship
    stock.rate = trHtml.find("span").text
    return stock


def getThemeInfo(aHtml):
    st = StockTheme(aHtml.select('p')[0].text, f"{BASE_URL}{aHtml.attrs['href']}")
    # print(linkTheme.attrs['href'])
    # print(linkTheme.select('p')[0].text)
    # ThemeList.append(st)
    # print(st.url)
    r_theme = requests.get(st.url)
    soup_theme = BeautifulSoup(r_theme.content, 'html.parser')
    pageNotFound = soup_theme.find("div", string="URLが間違っているか、ページが削除された可能性があります。")

    if (pageNotFound is None):
        rateTheme = soup_theme.find("div", {"bg-minkabuBlueDown rounded-sm px-1 py-0.5 text-sm font-bold text-white", "bg-minkabuRedUp rounded-sm px-1 py-0.5 text-sm font-bold text-white", "bg-minkabuGrayEven rounded-sm px-1 py-0.5 text-sm font-bold text-white"})
        st.rate=rateTheme.text
    else:
        print(f'theme page not found.theme name={st.themeName}')
        return None

    pageIndex = 1
    stockList4ThemeURL = f'{st.url}?page='

    while True:
        r_theme_page_i = requests.get(stockList4ThemeURL+str(pageIndex))
        soup_theme_page_i = BeautifulSoup(r_theme_page_i.content, 'html.parser')
        # stock list       
        stockListOnePageHtml = soup_theme_page_i.findAll("tr", {"bg-white", "bg-slate-50"})
        # print(f'stockListOnePageHtml list size=={len(stockListOnePageHtml)}')
        for tr in stockListOnePageHtml:
            st.add2List(getStockInfo(tr))

        stockPageInfo = soup_theme_page_i.find("p", class_="float-right text-xs leading-loose").next_element.text.replace("件", "").split("/")
        maxIndexCurrentPage = int(stockPageInfo[0].split("～")[1])
        countStock = int(stockPageInfo[1].replace("全", ""))
        # print(f'maxIndexCurrentPage:{maxIndexCurrentPage} countStock:{countStock} themeName:{st.themeName} pageIndex:{pageIndex} stockList size:{len(st.stockList)}')

        if maxIndexCurrentPage == countStock :
            break
        else :
            pageIndex = pageIndex + 1
    return st

def getThemeList(startPage, endPage):
    thread = current_thread()
    msg = f"{datetime.now()} {thread.name} , idnet={get_ident()}, id={get_native_id()} Start Read Html."
    print(msg)
    output2file(FILE_PATH_LOG, msg)

    ThemeList = []
    for i in range(startPage, endPage+1) :
        msg = f"{datetime.now()} {thread.name}, idnet={get_ident()}, id={get_native_id()} now reading page {i} ."
        print(msg)   
        output2file(FILE_PATH_LOG, msg)
   
        r = requests.get(f'{BASE_URL}/theme?page={i}')
        soup = BeautifulSoup(r.content, 'html.parser')
        # links4Theme = soup.select('a[href^="/theme/"]')
        links4Theme = soup.find_all("a", class_="text-minkabuOldLink font-bold hover:text-blue-500")
        for aLink in links4Theme:
            theme = getThemeInfo(aLink)
            if (theme is None):
                continue
            ThemeList.append(theme)
    msg = f"{datetime.now()} {thread.name} , idnet={get_ident()}, id={get_native_id()} End Read Html."
    print(msg)
    output2file(FILE_PATH_LOG, msg)
    return ThemeList

if __name__ == '__main__':
    msg=f"{datetime.now()} Begin!!"
    print(msg)
    output2file(FILE_PATH_LOG, msg)
    lock = Lock()
    ThemeList = []
    count_thread = os.cpu_count()-4
    count_page_per_thread = round(MAX_PAGE/count_thread)
    args = [(count_page_per_thread*i+1, count_page_per_thread*(i+1)) for i in range(count_thread)]
    args[count_thread-1] = (count_page_per_thread*(count_thread-1)+1, MAX_PAGE)

    with ThreadPoolExecutor(max_workers=count_thread) as pool:
        results = pool.map(lambda f: getThemeList(*f), args)
        for r in results:
            lock.acquire()
            ThemeList.extend(r)
            lock.release()

    msg = f"{datetime.now()} Start Sort Theme List."
    print(msg)
    output2file(FILE_PATH_LOG, msg)

    ThemeList.sort(key=lambda theme: float(theme.rate.replace("%", "")), reverse=True)

    StocksMap = {}
    for theme in ThemeList:
        theme.stockList.sort(key=lambda stock: int(stock.relationshipPercentages))
        for stock_i in theme.stockList:
            if stock_i.stockCode in StocksMap:           
                stock2Themes = StocksMap[stock_i.stockCode]
            else :
                stock2Themes = StockInfoWithThemes(stock_i.stockName, stock_i.stockCode, stock_i.url, stock_i.rate, stock_i.price, stock_i.updateTime)
                StocksMap[stock_i.stockCode] = stock2Themes

            stock2Themes.themeList.append({"ThemeName":theme.themeName, "Relationship":stock_i.relationshipPercentages})

    msg =f"{datetime.now()} Start Output Stock-Theme Map."
    print(msg)
    output2file(FILE_PATH_LOG, msg)

    for theme in ThemeList:
        msg = f'{theme.themeName}\t:\t{";".join([e.stockCode+":"+e.stockName for e in theme.stockList])}'
        output2file(FILE_PATH_THEME_STOCK_MAP, msg)
  
    for k, v in StocksMap.items():
        v.themeList.sort(key=lambda map: int(map["Relationship"]), reverse=True)
        # msg = f'code:{k} name:{v.stockName} theme list:{str(v.themeList)}'   
        msg = f'{k}\t:\t{v.stockName}\t:\t{";".join([e["ThemeName"]+":"+e["Relationship"] for e in v.themeList])}'
        output2file(FILE_PATH_STOCK_THEME_MAP, msg)

    msg = f"{datetime.now()} Completed!!"
    print(msg)
    output2file(FILE_PATH_LOG, msg)