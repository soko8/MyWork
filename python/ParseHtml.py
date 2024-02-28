"""
#!/usr/bin/python3
"""
import math
import requests
import bs4
from string import Template

# proxies = {
# "http": "http://proxygate2.nic.nec.co.jp:8080",
# "https": "http://proxygate2.nic.nec.co.jp:8080/",
# }
# res = requests.get('https://minkabu.jp/screening/theme', proxies=proxies)
res = requests.get('https://minkabu.jp/screening/theme')
res.raise_for_status()
# res.encoding = res.apparent_encoding
soup = bs4.BeautifulSoup(res.text, "html.parser")
elems = soup.select('div[data-theme-category-name]')
baseUrl = "https://minkabu.jp"
line = Template("\"$name\",\"$swing\",\"$url\"\n")
dicCategory = {}

for elem in elems:
    categoryName = elem['data-theme-category-name']
    categorySwing = elem.select('span[class="flr"]')[0].string
    categoryUrl = baseUrl + elem.select('a')[0]['href']
    dicCategory[categoryName] = [categorySwing, categoryUrl]
    with open('StockCategory.txt', 'a', encoding=res.encoding) as file:
        # file.write(categoryName + "\t\t\t\t" + categorySwing + "\t\t" + categoryUrl + "\n")
        file.write(line.substitute(name=categoryName, swing=categorySwing, url=categoryUrl))
        # print(categoryName + " " + categorySwing + " " + categoryUrl)

line = Template("\"$theme\",\"$code\",\"$name\",\"$price\",\"$swing\",\"$rel\",\"$url\"\n")
params = "?page="
for key, value in dicCategory.items():
    # res = requests.get(value[1], proxies=proxies)
    res = requests.get(value[1])
    res.raise_for_status()
    soup = bs4.BeautifulSoup(res.text, "html.parser")
    stockList = soup.select('table[summary] > tr:has(td)')
    for stock in stockList:
        tds = stock.select('td')
        stockCode = tds[0].string
        stockName = tds[1].select('a')[0].string
        stockUrl = tds[1].select('a')[0]['href']
        stockPrice = tds[2].get_text()
        stockSwing = tds[3].string
        stockRel = tds[4].select('span')[0]['style'].replace("width: ", "")
        with open('Stocks.txt', 'a', encoding=res.encoding) as file:
            file.write(line.substitute(theme=key, code=stockCode, name=stockName, price=stockPrice, swing=stockSwing, rel=stockRel, url=stockUrl))

    pageInfoStr = soup.select('span[class="ico_search"]')[0].string
    pageInfos = pageInfoStr.split("/")
    countPerPage = pageInfos[0].strip().replace("1～", "").replace("件", "")
    totalCount = pageInfos[1].strip().replace("全", "").replace("件", "")
    countPage = 1
    if totalCount != countPerPage:
        countPage = math.ceil(int(totalCount) / int(countPerPage))

    for i in range(2, countPage+1):
        # res = requests.get(value[1] + params + str(i), proxies=proxies)
        res = requests.get(value[1] + params + str(i))
        res.raise_for_status()
        soup = bs4.BeautifulSoup(res.text, "html.parser")
        stockList = soup.select('table[summary] > tr:has(td)')
        for stock in stockList:
            tds = stock.select('td')
            stockCode = tds[0].string
            stockName = tds[1].select('a')[0].string
            stockUrl = tds[1].select('a')[0]['href']
            stockPrice = tds[2].get_text()
            stockSwing = tds[3].string
            stockRel = tds[4].select('span')[0]['style'].replace("width: ", "")
            with open('Stocks.txt', 'a', encoding=res.encoding) as file:
                file.write(line.substitute(theme=key, code=stockCode, name=stockName, price=stockPrice, swing=stockSwing, rel=stockRel, url=stockUrl))
print("complete")
