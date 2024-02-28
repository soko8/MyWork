import websocket
import json
from threading import Thread


class WebSocketClientKraken:
    __symbols = []
    __ExchangeName = 'Kraken'
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
            msg = json.loads(message)
            # print(msg)
            if isinstance(msg, list):
                data = msg[1]
                # print(data)
                currency = msg[3]
                # print(currency)
                # print(data['a'][0])
                # print(data['b'][0])
                for symbol_ in self.__symbols:
                    if symbol_.replace('-', '/').replace('BTC', 'XBT').replace('DOGE', 'XDG') == currency:
                        self.MarketInfo[symbol_] = {'ask': float(data['a'][0]), 'bid': float(data['b'][0])}

        def on_pong(web_socket_app, message):
            pass
            # print("Got a pong! No need to respond")

        def on_open(web_socket_app):
            topic = {
                "event": "subscribe",
                "pair": [x.replace('-', '/') for x in self.__symbols],
                "subscription": {
                    "name": "ticker"
                }
            }
            web_socket_app.send(json.dumps(topic))

        url = f'wss://ws.kraken.com'
        ws = websocket.WebSocketApp(
            url=url,
            on_open=on_open,
            on_message=on_message,
            on_pong=on_pong,
            on_close=on_close)

        t = Thread(target=ws.run_forever)
        t.start()


if __name__ == '__main__':
    symbols = ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
    kraken = WebSocketClientKraken(symbols)
    kraken.get_market_info()
    while True:
        print(kraken.MarketInfo)
