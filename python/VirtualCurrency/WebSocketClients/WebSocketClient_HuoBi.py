import websocket
import gzip
import json
from threading import Thread
import random


class WebSocketClientHuoBi:
    __symbol = ''
    __symbolName = ''
    __levels = '5'
    __ExchangeName = 'HuoBi'
    MarketInfo = {'ExchangeName': __ExchangeName}

    def __init__(self, symbol_name):
        self.__symbol = symbol_name
        self.__symbolName = symbol_name.replace('-', '').lower()

    def start(self):
        def on_close(web_socket_app, close_status_code, close_msg):
            print('on_close.' + web_socket_app.url)
            if close_status_code or close_msg:
                print("close status code: " + str(close_status_code))
                print("close message: " + str(close_msg))

        def on_message(web_socket_app, message):
            # print('message')
            msg = gzip.decompress(message).decode('utf-8')
            msg = json.loads(msg)
            # print(msg)
            # currency = msg['ch'].split('.')[1]

            if msg.__contains__('ping'):
                ping_id = msg['ping']
                # print(msg)
                web_socket_app.send(json.dumps({"pong": ping_id}))
            else:
                data = msg['tick']
                # print(currency)
                # print(data['asks'][0][0])
                # print(data['bids'][4][0])
                self.MarketInfo[self.__symbol] = {'ask': data['asks'][0][0], 'bid': data['bids'][4][0]}

        def on_ping(web_socket_app, message):
            pass
            # print(message)
            # print(web_socket_app.)

        def on_pong(web_socket_app, message):
            pass
            # print(message)

        def on_open(web_socket_app):
            idx = random.randint(0, 100)
            topic = {
                'sub': f'market.{self.__symbolName}.mbp.refresh.{self.__levels}',
                'id': f'id{idx}'
            }
            web_socket_app.send(json.dumps(topic))

        # url = f'wss://api.huobi.pro/feed'
        url = f'wss://api.huobi.pro/ws'
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
    symbols = ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
    for symbol in symbols:
        huo_bi = WebSocketClientHuoBi(symbol)
        huo_bi.start()
    while True:
        print(huo_bi.MarketInfo)
