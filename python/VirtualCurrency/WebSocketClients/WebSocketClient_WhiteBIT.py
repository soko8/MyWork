import websocket
import json
from threading import Thread
import random


class WebSocketClientWhiteBIT:
    __symbol = ''
    __symbolName = ''
    __ExchangeName = 'WhiteBIT'
    MarketInfo = {'ExchangeName': __ExchangeName}

    def __init__(self, symbol_name):
        self.__symbol = symbol_name
        self.__symbolName = symbol_name.replace('-', '_')
        self.MarketInfo[self.__symbol] = {'ask': 0.0, 'bid': 0.0}

    def start(self):
        def on_close(web_socket_app, close_status_code, close_msg):
            print('on_close.' + web_socket_app.url)
            if close_status_code or close_msg:
                print("close status code: " + str(close_status_code))
                print("close message: " + str(close_msg))

        def on_message(web_socket_app, message):
            msg = json.loads(message)
            # print(msg)
            # currency = msg['ch'].split('.')[1]

            if msg.__contains__('params'):
                data = msg['params'][1]
                # print(data)
                if data.__contains__('asks'):
                    # print(data['asks'][0][0])
                    self.MarketInfo[self.__symbol]['ask'] = float(data['asks'][0][0])
                if data.__contains__('bids'):
                    size = len(data['bids'])
                    # print(data['bids'][size-1][0])
                    self.MarketInfo[self.__symbol]['bid'] = float(data['bids'][size - 1][0])
            # else:
            #     data = msg['tick']
            # print(currency)

        def on_ping(web_socket_app, message):
            print(message)
            # print(web_socket_app.)

        def on_pong(web_socket_app, message):
            pass
            # print(message)

        def on_open(web_socket_app):
            idx = random.randint(0, 100)
            topic = {
                'id': idx,
                'method': 'depth_subscribe',
                'params': [self.__symbolName, 5, '0', True]
            }
            # print(topic)
            web_socket_app.send(json.dumps(topic))

        url = f'wss://api.whitebit.com/ws'
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
    symbols = ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
    WhiteBIT = None
    for symbol in symbols:
        WhiteBIT = WebSocketClientWhiteBIT(symbol)
        WhiteBIT.start()
    while True:
        print(WhiteBIT.MarketInfo)
