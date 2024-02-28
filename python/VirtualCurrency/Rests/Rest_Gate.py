import requests
import gzip


url = 'https://api.gateio.ws'
end_point = '/api/v4/spot/tickers'
response = requests.get(url + end_point)
print(response.json())



symbolList = ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
# list =  [x.replace('-', '').lower() for x in symbolList]
# str1 = ','.join(symbolList)

