import requests
import gzip


url = 'https://api3.binance.com'
end_point = '/api/v3/ticker/bookTicker'
# query = {'symbol': 'btc_usdt'}
# response = requests.get("https://openapi.digifinex.com/v3/ticker", params=query)
response = requests.get(url + end_point)
print(response.json())



symbolList = ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
# list =  [x.replace('-', '').lower() for x in symbolList]
# str1 = ','.join(symbolList)

