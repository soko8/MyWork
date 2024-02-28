import websocket
import json
from threading import Thread


class WebSocketClientCoinbase:
    __symbols = []
    __ExchangeName = 'Coinbase'
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
            currency = msg['product_id']
            self.MarketInfo[currency] = {'ask': float(msg['best_ask']), 'bid': float(msg['best_bid'])}

        def on_pong(web_socket_app, message):
            pass
            # print("Got a pong! No need to respond")

        def on_open(web_socket_app):
            topic = {
                'type': 'subscribe',
                'product_ids': self.__symbols,
                # 'channels': ['level2_batch']
                'channels': ['ticker']
            }
            web_socket_app.send(json.dumps(topic))

        url = f'wss://ws-feed.exchange.coinbase.com'
        ws = websocket.WebSocketApp(
            url=url,
            on_open=on_open,
            on_message=on_message,
            on_pong=on_pong,
            on_close=on_close)

        t = Thread(target=ws.run_forever, kwargs={'ping_interval': 30, 'ping_timeout': 20})
        t.start()


if __name__ == '__main__':
    symbols = ['BTC-USDT', 'ETH-USDT', 'DOGE-USDT', 'XRP-USDT']
    coinbase = WebSocketClientCoinbase(symbols)
    coinbase.get_market_info()
    while True:
        print(coinbase.MarketInfo)
