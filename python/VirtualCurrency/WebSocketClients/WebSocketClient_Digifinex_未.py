import json
import time
from threading import Thread
import websocket


class WebSocketClientDigifinex:
    __symbols = []
    __ExchangeName = 'Digifinex'
    MarketInfo = {'ExchangeName': __ExchangeName}

    def __init__(self, symbol_name_list):
        self.__symbols = symbol_name_list

    def get_market_info(self):
        def on_close(web_socket_app, close_status_code, close_msg):
            print('on_close.' + web_socket_app.url)
            if close_status_code or close_msg:
                print("close status code: " + str(close_status_code))
                print("close message: " + str(close_msg))

        def on_message(web_socket_app, message):
            # print('message')
            msg = json.loads(message)
            print(msg)
            # currency = msg['s']
            # print(currency)
            # print(msg['a'])
            # print(msg['b'])
            # for symbol_ in self.__symbols:
            #     if symbol_.replace('-', '_') == currency:
            #         self.MarketInfo[symbol_] = {'ask': float(msg['a']), 'bid': float(msg['b'])}

        def on_pong(web_socket_app, message):
            print("Got a pong! No need to respond")

        def on_open(web_socket_app):
            topic = {
                "id": int(time.time()),
                "method": "ticker.subscribe",
                "params": [x.replace('-', '_') for x in self.__symbols]
            }
            # web_socket_app.send(json.dumps(topic))
            web_socket_app.send('{"id":12312, "method":"ticker.subscribe", "params":["ETH_USDT", "BTC_USDT"]}')

        url = 'wss://openapi.digifinex.com/ws/v1/'
        ws = websocket.WebSocketApp(
            url=url,
            on_open=on_open,
            on_message=on_message,
            on_pong=on_pong,
            on_close=on_close)
        # ws.run_forever()
        t = Thread(target=ws.run_forever, kwargs={'ping_interval': 30, 'ping_timeout': 20})
        t.start()


if __name__ == '__main__':
    # symbols = ["BTC_USDT", "ETH_USDT", "DOGE_USDT"]
    symbols = ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
    digifinex = WebSocketClientDigifinex(symbols)
    digifinex.get_market_info()
    # while True:
    #     print(digifinex.MarketInfo)
