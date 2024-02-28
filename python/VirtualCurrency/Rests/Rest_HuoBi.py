import requests
import gzip


url = 'https://api.huobi.pro'
end_point = '/market/tickers'
response = requests.get(url + end_point)
print(response.json())



symbolList = ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
# list =  [x.replace('-', '').lower() for x in symbolList]
# str1 = ','.join(symbolList)

