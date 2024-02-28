# from tkinter import *

import time
from datetime import datetime
from WebSocketClients import WebSocketClient_Binance
from WebSocketClients import WebSocketClient_Coinbase
from WebSocketClients import WebSocketClient_Crypto
from WebSocketClients import WebSocketClient_Gate
from WebSocketClients import WebSocketClient_HuoBi
# from WebSocketClients import WebSocketClient_KuCoin
from WebSocketClients import WebSocketClient_OKX
from WebSocketClients import WebSocketClient_FTX
from WebSocketClients import WebSocketClient_Bitfinex
from WebSocketClients import WebSocketClient_Kraken
from WebSocketClients import WebSocketClient_WhiteBIT

from WebSocketClients import WebSocketClient_LBank

symbolList = [
    "BTC-USDT"
    , "ETH-USDT"
    , "DOGE-USDT"
    , "XRP-USDT"
    # , "XEM-USDT"
    , "LTC-USDT"
    , "BCH-USDT"
    , "XLM-USDT"
    , "ENJ-USDT"
    , "OMG-USDT"
    , "ADA-USDT"
    , "SOL-USDT"
    , "DOT-USDT"
    , "IOST-USDT"
    ]

BiAn = WebSocketClient_Binance.WebSocketClientBinance(symbolList)
Coinbase = WebSocketClient_Coinbase.WebSocketClientCoinbase(symbolList)
Crypto = WebSocketClient_Crypto.WebSocketClientCrypto(symbolList)
Gate = WebSocketClient_Gate.WebSocketClientGate(symbolList)
# KuCoin = WebSocketClient_KuCoin.WebSocketClientKuCoin(symbolList)
Okx = WebSocketClient_OKX.WebSocketClientOKX(symbolList)
Kraken = WebSocketClient_Kraken.WebSocketClientKraken(symbolList)

BiAn.get_market_info()
Coinbase.get_market_info()
Crypto.get_market_info()
Gate.get_market_info()
# KuCoin.get_market_info()
Okx.get_market_info()
Kraken.get_market_info()

Exchanges = []
asks = {}
bids = {}
asks_min = {}
bids_max = {}

huo_bi = None
ftx = None
bitfinex = None
whiteBIT = None
lBank = None
for symbol in symbolList:
    asks[symbol] = {}
    bids[symbol] = {}
    asks_min[symbol] = 0.0
    bids_max[symbol] = 0.0
    huo_bi = WebSocketClient_HuoBi.WebSocketClientHuoBi(symbol)
    huo_bi.start()
    ftx = WebSocketClient_FTX.WebSocketClientFTX(symbol)
    ftx.start()
    bitfinex = WebSocketClient_Bitfinex.WebSocketClientBitfinex(symbol)
    bitfinex.start()
    whiteBIT = WebSocketClient_WhiteBIT.WebSocketClientWhiteBIT(symbol)
    whiteBIT.start()
    lBank = WebSocketClient_LBank.WebSocketClientLBank(symbol)
    lBank.start()

Exchanges.append(BiAn)
Exchanges.append(bitfinex)
Exchanges.append(Coinbase)
Exchanges.append(Crypto)
Exchanges.append(ftx)
Exchanges.append(Gate)
Exchanges.append(huo_bi)
Exchanges.append(Kraken)
# Exchanges.append(KuCoin)
Exchanges.append(lBank)
Exchanges.append(Okx)
Exchanges.append(whiteBIT)

time.sleep(10)
while True:
    time.sleep(1)
    for symbol in symbolList:
        for exchange in Exchanges:
            # print(exchange.MarketInfo)
            if exchange.MarketInfo.__contains__(symbol):
                asks[symbol][exchange.MarketInfo['ExchangeName']] = exchange.MarketInfo[symbol]['ask']
                bids[symbol][exchange.MarketInfo['ExchangeName']] = exchange.MarketInfo[symbol]['bid']

    for symbol in symbolList:
        # asks[symbol] = dict(sorted(asks[symbol].items(), key=lambda item: item[1]))
        # bids[symbol] = dict(sorted(bids[symbol].items(), key=lambda item: item[1]))
        asks_min[symbol] = min(asks[symbol].items(), key=lambda k: k[1])
        bids_max[symbol] = max(bids[symbol].items(), key=lambda k: k[1])
    # print('asks↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓')
    # print(asks)
    # print(asks_min)
    # print('bids↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓')
    # print(bids)
    # print(bids_max)

    for symbol in symbolList:
        # print(symbol)
        # print(asks_min[symbol])
        buy_price = asks_min[symbol][1]
        if 0.0 == buy_price:
            continue
        sell_price = bids_max[symbol][1]
        rate = ((sell_price - buy_price) / buy_price) * 100
        if 0.7 < rate:
            # pass
            print(datetime.now(), "\t", symbol, "-->", "买：", asks_min[symbol], "\t\t---卖：", bids_max[symbol], "-----rate:", rate)
