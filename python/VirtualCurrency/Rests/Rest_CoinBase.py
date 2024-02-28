import requests
import gzip


url = 'https://api.exchange.coinbase.com'
product_id = 'DOGE-USDT'
end_point = f'/products/{product_id}/book'
response = requests.get(url + end_point)
print(response.json())



symbolList = ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
# list =  [x.replace('-', '').lower() for x in symbolList]
# str1 = ','.join(symbolList)

