import websocket
import ssl
import json
from threading import Thread


class WebSocketClientGemini:
    __symbols = []
    __ExchangeName = 'Gemini'
    MarketInfo = {'ExchangeName': __ExchangeName}

    def __init__(self, symbol_name_list):
        self.__symbols = symbol_name_list
        for symbol_ in self.__symbols:
            self.MarketInfo[symbol_] = {}

    def get_market_info(self):
        def on_close(web_socket_app, close_status_code, close_msg):
            print('on_close.' + web_socket_app.url)
            if close_status_code or close_msg:
                print("close status code: " + str(close_status_code))
                print("close message: " + str(close_msg))

        def on_message(web_socket_app, message):
            msg = json.loads(message)
            # currency = web_socket_app.url.replace(url + '/', '').split('@')[0]
            data = msg['events'][0]
            # print(data)
            currency = data['symbol']
            # print(currency)
            side = data['side']
            # if 'ask' == side:
            #     print('ask=' + data['price'])
            # else:
            #     print('bid=' + data['price'])

            for symbol_ in self.__symbols:
                if symbol_.replace('-', '').replace('USDT', 'USD') == currency:
                    if 'ask' == side:
                        self.MarketInfo[symbol_]['ask'] = float(data['price'])
                    else:
                        # self.MarketInfo[symbol_] = {'bid': float(data['price'])}
                        self.MarketInfo[symbol_]['bid'] = float(data['price'])

        def on_pong(web_socket_app, message):
            print("Got a pong! No need to respond")

        url = 'wss://api.gemini.com/v1/multimarketdata?symbols='
        pairs = ','.join([x.replace('-', '').replace('USDT', 'USD') for x in self.__symbols])
        ws = websocket.WebSocketApp(
            url=f'{url}{pairs}',
            on_message=on_message,
            on_pong=on_pong,
            on_close=on_close)
        t = Thread(target=ws.run_forever,
                   kwargs={'sslopt': {"cert_reqs": ssl.CERT_NONE}, 'ping_interval': 30, 'ping_timeout': 20})
        t.start()


if __name__ == '__main__':
    # symbols = ["BTCUSD", "ETHUSD", "DOGEUSD"]
    symbols = ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
    gemini = WebSocketClientGemini(symbols)
    gemini.get_market_info()
    while True:
        print(gemini.MarketInfo)
