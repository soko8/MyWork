import requests
import gzip


url = 'https://api.crypto.com/v2'
end_point = '/public/get-ticker'
response = requests.get(url + end_point)
print(response.json())



symbolList = ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
# list =  [x.replace('-', '').lower() for x in symbolList]
# str1 = ','.join(symbolList)

