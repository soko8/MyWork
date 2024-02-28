import json
import time
from threading import Thread
import websocket


class WebSocketClientGate:
    __symbols = []
    __ExchangeName = 'Gate'
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
            msg = json.loads(message)['result']
            # print(msg)
            currency = msg['s']
            # print(currency)
            # print(msg['a'])
            # print(msg['b'])
            for symbol_ in self.__symbols:
                if symbol_.replace('-', '_') == currency:
                    self.MarketInfo[symbol_] = {'ask': float(msg['a']), 'bid': float(msg['b'])}

        def on_pong(web_socket_app, message):
            pass
            # print("Got a pong! No need to respond")

        def on_open(web_socket_app):
            topic = {
                "time": int(time.time()),
                "channel": "spot.book_ticker",
                "event": "subscribe",
                "payload": [x.replace('-', '_') for x in self.__symbols]
            }
            web_socket_app.send(json.dumps(topic))

        url = f'wss://api.gateio.ws/ws/v4/'
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
    gate = WebSocketClientGate(symbols)
    gate.get_market_info()
    while True:
        print(gate.MarketInfo)
