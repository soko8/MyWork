import websocket
import json
from threading import Thread
import random


class WebSocketClientWOO:
    __symbol = ''
    __symbolName = ''
    __ExchangeName = 'WOO_不支持中国'
    MarketInfo = {'ExchangeName': __ExchangeName}

    def __init__(self, symbol_name):
        self.__symbol = symbol_name
        self.__symbolName = 'SPOT_' + symbol_name.replace('-', '_')

    def start(self):
        def on_close(web_socket_app, close_status_code, close_msg):
            print('on_close.' + web_socket_app.url)
            if close_status_code or close_msg:
                print("close status code: " + str(close_status_code))
                print("close message: " + str(close_msg))

        def on_message(web_socket_app, message):
            # print('message')
            msg = json.loads(message)
            print(msg)
            # currency = msg['ch'].split('.')[1]
            # data = msg['tick']
            # print(currency)
            # print(data['asks'][0][0])
            # print(data['bids'][4][0])
            # self.MarketInfo[self.__symbol] = {'ask': data['asks'][0][0], 'bid': data['bids'][4][0]}

        def on_pong(web_socket_app, message):
            print("Got a pong! No need to respond")

        def on_open(web_socket_app):
            idx = random.randint(0, 100)
            topic = {
                "id": idx,
                "event": "request",
                "params": {
                    "type": "orderbook",
                    "symbol": self.__symbolName
                }
            }
            web_socket_app.send(json.dumps(topic))

        application_id = '0a8b5f05-aec9-41b2-9ad2-97680df6efee'
        url = f'wss://wss.woo.org/ws/stream/{application_id}'

        ws = websocket.WebSocketApp(
            url=url,
            on_open=on_open,
            on_message=on_message,
            on_pong=on_pong,
            on_close=on_close)
        t = Thread(target=ws.run_forever, kwargs={'ping_interval': 10, 'ping_timeout': 9})
        t.start()


if __name__ == '__main__':
    # symbols = ['btcusdt', 'ethusdt', 'dogeusdt']
    symbols = ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
    for symbol in symbols:
        woo = WebSocketClientWOO(symbol)
        woo.start()
    # while True:
    #     print(woo.MarketInfo)
