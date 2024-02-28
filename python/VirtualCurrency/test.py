from websocket import create_connection
import requests
import gzip

query = {'symbol': 'btc_usdt'}
response = requests.get("https://openapi.digifinex.com/v3/ticker", params=query)
print(response.json())

# from websocket import create_connection
# ws = create_connection("wss://openapi.digifinex.com/ws/v1/")
# ws.send('{"id":12312, "method":"ticker.subscribe", "params":["ETH_USDT", "BTC_USDT"]}')
# print(ws.recv())
# print(message)

symbolList = ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
# list =  [x.replace('-', '').lower() for x in symbolList]
# str1 = ','.join(symbolList)

'''
c = {'BTC-USDT': {'Binance': 35395.67, 'Coinbase': 35391.01, 'Crypto': 35388.88, 'Gate': 35393.31, 'KuCoin': 35394.0,
                  'OKX': 35395.5, 'HuoBi': 35394.04},
     'ETH-USDT': {'Binance': 2632.81, 'Coinbase': 2632.43, 'Crypto': 2632.5, 'Gate': 2632.7, 'KuCoin': 2631.85,
                  'OKX': 2633.13, 'HuoBi': 2632.76},
     'DOGE-USDT': {'Binance': 0.1275, 'Coinbase': 0.128, 'Crypto': 0.12781, 'Gate': 0.127906, 'KuCoin': 0.12786,
                   'OKX': 0.127904, 'HuoBi': 0.127891}}

x = c['BTC-USDT']
y = {k: v for k, v in sorted(x.items(), key=lambda item: item[1])}
# print(y)

z = dict(sorted(x.items(), key=lambda item: item[1]))
# print(z)


mx = max(z.items(), key=lambda k: k[1])
mn = min(z.items(), key=lambda k: k[1])
print(mx)
print(mn)
'''
