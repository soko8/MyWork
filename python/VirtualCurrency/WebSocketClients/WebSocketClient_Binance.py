import websocket
import json
from threading import Thread


class WebSocketClientBinance:
    __symbols = []
    __levels = '5'
    __ExchangeName = 'Binance'
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
            data = json.loads(message)
            currency = web_socket_app.url.replace(url + '/', '').split('@')[0]
            for symbol_ in self.__symbols:
                if symbol_.replace('-', '').lower() == currency:
                    self.MarketInfo[symbol_] = {'ask': float(data['asks'][0][0]), 'bid': float(data['bids'][4][0])}

        def on_pong(web_socket_app, message):
            pass
            # print("Got a pong! No need to respond")

        # websocket.enableTrace(True)
        url = 'wss://stream.binance.com:9443/ws'

        for symbol in self.__symbols:
            symbol = symbol.replace('-', '').lower()
            ws = websocket.WebSocketApp(
                url=f'{url}/{symbol}@depth{self.__levels}',
                on_message=on_message,
                on_pong=on_pong,
                on_close=on_close)
            t = Thread(target=ws.run_forever, kwargs={'ping_interval': 30, 'ping_timeout': 20})
            t.start()


if __name__ == '__main__':
    # symbols = ['btcusdt', 'ethusdt', 'dogeusdt']
    symbols = ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
    bian = WebSocketClientBinance(symbols)
    bian.get_market_info()
    while True:
        print(bian.MarketInfo)
