import requests
import gzip


url = 'https://www.okx.com'
end_point = '/api/v5/market/tickers'
query = {'instType': 'SPOT'}
response = requests.get(url + end_point, params=query)
print(response.json())



symbolList = ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
# list =  [x.replace('-', '').lower() for x in symbolList]
# str1 = ','.join(symbolList)

