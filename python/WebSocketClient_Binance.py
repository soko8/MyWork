import websocket
import json
from threading import Thread


class WebSocketClientBinance:
    __symbol = ''
    __levels = '5'
    __ExchangeName = 'Binance'
    MarketInfo = {'ExchangeName': __ExchangeName}

    def __init__(self, symbol_name):
        self.__symbol = symbol_name

    def get_market_info(self):
        def on_close(web_socket_app, close_status_code, close_msg):
            print('close')
            if close_status_code or close_msg:
                print("close status code: " + str(close_status_code))
                print("close message: " + str(close_msg))

        def on_message(web_socket_app, message):
            data = json.loads(message)
            currency = web_socket_app.url.replace(url + '/', '').split('@')[0]
            self.MarketInfo[currency] = {'ask': data['asks'][0][0], 'bid': data['bids'][4][0]}

        def on_pong(web_socket_app, message):
            print("Got a pong! No need to respond")

        # websocket.enableTrace(True)
        url = 'wss://stream.binance.com:9443/ws'
        url = f'{url}/{self.__symbol}@depth{self.__levels}'
        print(url)
        ws = websocket.WebSocketApp(
            url=url,
            on_message=on_message,
            on_pong=on_pong,
            on_close=on_close)
        t = Thread(target=ws.run_forever)
        t.start()


if __name__ == '__main__':
    symbols = ['btcusdt', 'ethusdt', 'dogeusdt']
    for symbol in symbols:
        bian = WebSocketClientBinance(symbol)
        bian.get_market_info()
    while True:
        print(bian.MarketInfo)
