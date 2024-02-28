import websocket
import json
from threading import Thread


class WebSocketClientLBank:
    __symbol = ''
    __symbolName = ''
    __ExchangeName = 'LBank'
    MarketInfo = {'ExchangeName': __ExchangeName}

    def __init__(self, symbol_name):
        self.__symbol = symbol_name
        self.__symbolName = symbol_name.replace('-', '_').lower()

    def start(self):
        def on_close(web_socket_app, close_status_code, close_msg):
            print('on_close.' + web_socket_app.url)
            if close_status_code or close_msg:
                print("close status code: " + str(close_status_code))
                print("close message: " + str(close_msg))

        def on_message(web_socket_app, message):
            msg = json.loads(message)
            # print(msg)

            if msg.__contains__('ping'):
                ping_id = msg['ping']
                # print(msg)
                web_socket_app.send(json.dumps({"pong": ping_id}))
            else:
                data = msg['depth']
                # print(data['asks'][0][0])
                # print(data['bids'][9][0])
                self.MarketInfo[self.__symbol] = {'ask': float(data['asks'][0][0]), 'bid': float(data['bids'][9][0])}

        def on_ping(web_socket_app, message):
            print(message)
            print(web_socket_app.url)

        def on_pong(web_socket_app, message):
            print(message)
            print(web_socket_app.url)

        def on_open(web_socket_app):
            topic = {
                'action': 'subscribe',
                'subscribe': 'depth',
                'depth': '10',
                'pair': self.__symbolName
            }
            web_socket_app.send(json.dumps(topic))

        url = f'wss://www.lbkex.net/ws/V2/'
        ws = websocket.WebSocketApp(
            url=url,
            on_open=on_open,
            on_message=on_message,
            on_ping=on_ping,
            on_pong=on_pong,
            on_close=on_close)
        t = Thread(target=ws.run_forever, kwargs={'ping_interval': 30, 'ping_timeout': 20})
        t.start()


if __name__ == '__main__':
    # symbols = ['btcusdt', 'ethusdt', 'dogeusdt']
    # symbols = ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
    symbols = ["BTC-USDT"
        , "ETH-USDT"
        , "DOGE-USDT"
        , "XRP-USDT"
     # , "XEM-USDT"
        , "LTC-USDT"
        , "BCH-USDT"
     # , "XLM-USDT"
     # , "ENJ-USDT"
        , "OMG-USDT"
     # , "QTUM-USDT"
     # , "IOST-USDT"
     ]
    lBank = None
    for symbol in symbols:
        lBank = WebSocketClientLBank(symbol)
        lBank.start()
    while True:
        print(lBank.MarketInfo)
