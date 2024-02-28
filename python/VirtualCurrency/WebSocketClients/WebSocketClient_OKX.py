import websocket
import json
from threading import Thread


class WebSocketClientOKX:
    __symbols = []
    __ExchangeName = 'OKX'
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
            currency = msg['arg']['instId']
            data = msg['data'][0]
            # print(currency)
            # print(data['asks'][0][0])
            # print(data['bids'][4][0])
            self.MarketInfo[currency] = {'ask': float(data['asks'][0][0]), 'bid': float(data['bids'][4][0])}

        def on_pong(web_socket_app, message):
            pass
            # print("Got a pong! No need to respond")

        def on_open(web_socket_app):
            args = []
            for symbol in self.__symbols:
                args.append({'channel': 'books5', 'instId': symbol})
            topic = {
                'op': 'subscribe',
                # 'args': [{'channel': 'books5', 'instId': symbol}]
                'args': args
            }
            web_socket_app.send(json.dumps(topic))

        url = f'wss://ws.okx.com:8443/ws/v5/public'
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
    okx = WebSocketClientOKX(symbols)
    okx.get_market_info()
    while True:
        print(okx.MarketInfo)
