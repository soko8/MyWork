import websocket
import json
from threading import Thread


class WebSocketClientFTX:
    __symbol = ''
    __symbol_name = ''
    __ExchangeName = 'FTX'
    MarketInfo = {'ExchangeName': __ExchangeName}

    def __init__(self, symbol_name):
        self.__symbol = symbol_name
        self.__symbol_name = symbol_name.replace('-', '/')

    def start(self):
        def on_close(web_socket_app, close_status_code, close_msg):
            print('on_close.' + web_socket_app.url)
            if close_status_code or close_msg:
                print("close status code: " + str(close_status_code))
                print("close message: " + str(close_msg))

        def on_message(web_socket_app, message):
            # print('message')
            # msg = gzip.decompress(message).decode('utf-8')
            msg = json.loads(message)
            # print(msg)
            # currency = msg['ch'].split('.')[1]
            data = msg['data']
            # print(currency)
            # print(data['ask'])
            # print(data['bid'])
            self.MarketInfo[self.__symbol] = {'ask': data['ask'], 'bid': data['bid']}

        def on_pong(web_socket_app, message):
            pass
            # print("Got a pong! No need to respond")

        def on_open(web_socket_app):
            topic = {
                'op': 'subscribe',
                # 'channel': 'orderbook',
                'channel': 'ticker',
                # 'channel': 'markets',
                'market': self.__symbol_name
            }
            web_socket_app.send(json.dumps(topic))

        url = f'wss://ftx.com/ws/'
        ws = websocket.WebSocketApp(
            url=url,
            on_open=on_open,
            on_message=on_message,
            on_pong=on_pong,
            on_close=on_close)
        t = Thread(target=ws.run_forever, kwargs={'ping_interval': 30, 'ping_timeout': 20})
        t.start()


if __name__ == '__main__':
    symbols = ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
    ftx = None
    for symbol in symbols:
        ftx = WebSocketClientFTX(symbol)
        ftx.start()
    while True:
        print(ftx.MarketInfo)
