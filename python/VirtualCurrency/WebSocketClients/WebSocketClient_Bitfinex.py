import websocket
import json
from threading import Thread


class WebSocketClientBitfinex:
    __symbol = ''
    __symbolName = ''
    __ExchangeName = 'Bitfinex'
    MarketInfo = {'ExchangeName': __ExchangeName}

    def __init__(self, symbol_name):
        self.__symbol = symbol_name
        self.__symbolName = 't' + symbol_name.replace('-', '').replace('USDT', 'UST').replace('DOGEUST', 'DOGE:UST')

    def start(self):
        def on_close(web_socket_app, close_status_code, close_msg):
            print('on_close.' + web_socket_app.url)
            if close_status_code or close_msg:
                print("close status code: " + str(close_status_code))
                print("close message: " + str(close_msg))

        def on_message(web_socket_app, message):
            # print('message')
            msg = json.loads(message)
            # print(msg)
            # print(self.__symbolName)
            if 'hb' != msg[1]:
                # print(msg[1][0])
                # print(msg[1][2])
                self.MarketInfo[self.__symbol] = {'ask': msg[1][0], 'bid': msg[1][2]}

        def on_pong(web_socket_app, message):
            pass
            # print("Got a pong! No need to respond")

        def on_open(web_socket_app):
            topic = {
                'event': 'subscribe',
                'channel': 'ticker',
                'symbol': self.__symbolName
            }
            web_socket_app.send(json.dumps(topic))

        url = f'wss://api-pub.bitfinex.com/ws/2'
        ws = websocket.WebSocketApp(
            url=url,
            on_open=on_open,
            on_message=on_message,
            on_pong=on_pong,
            on_close=on_close)
        t = Thread(target=ws.run_forever, kwargs={'ping_interval': 30, 'ping_timeout': 20})
        t.start()


if __name__ == '__main__':
    # symbols = ["tBTCUST", "tETHUST", "tDOGE:UST"]
    symbols = ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
    bitfinex = None
    for symbol in symbols:
        bitfinex = WebSocketClientBitfinex(symbol)
        bitfinex.start()
    while True:
        print(bitfinex.MarketInfo)
