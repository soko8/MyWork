import websocket
import json
import time
from threading import Thread


class WebSocketClientCrypto:
    __symbols = ["BTC_USDT", "ETH_USDT", "DOGE_USDT"]
    __ExchangeName = 'Crypto'
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
            raw_msg = json.loads(message)
            # print(raw_msg)
            if raw_msg.__contains__('id'):
                heartbeat_id = raw_msg['id']
                # print(heartbeat_id)
                web_socket_app.send(json.dumps({"id": heartbeat_id, 'method': 'public/respond-heartbeat'}))
            else:
                msg = raw_msg['result']
                currency = msg['instrument_name']
                data = msg['data'][0]
                # print(currency)
                # print(data['asks'][0][0])
                # print(data['bids'][9][0])
                for symbol_ in self.__symbols:
                    if symbol_.replace('-', '_') == currency:
                        self.MarketInfo[symbol_] = {'ask': data['asks'][0][0], 'bid': data['bids'][9][0]}

        def on_pong(web_socket_app, message):
            pass
            # print("Got a pong! No need to respond")
            # print("message:" + message)

        '''
        def on_open(ws):
            topic = {
                "id": index,
                'method': 'subscribe',
                'params': {'channels': [f'book.{symbol}.10']},
                "nonce": int(time.time() * 1000)
            }
            ws.send(json.dumps(topic))
        '''

        url = f'wss://stream.crypto.com/v2/market'
        channels = []
        for symbol in self.__symbols:
            symbol = symbol.replace('-', '_')
            channels.append(f'book.{symbol}.10')

        ws = websocket.WebSocketApp(
            url=url,
            on_open=lambda w: ws.send(json.dumps({
                "id": time.time(),
                'method': 'subscribe',
                'params': {'channels': channels},
                "nonce": int(time.time() * 1000)
            })),
            on_message=on_message,
            on_pong=on_pong,
            on_close=on_close)
        t = Thread(target=ws.run_forever, kwargs={'ping_interval': 30, 'ping_timeout': 20})
        t.start()


if __name__ == '__main__':
    # symbols = ["BTC_USDT", "ETH_USDT", "DOGE_USDT"]
    symbols = ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
    crypto = WebSocketClientCrypto(symbols)
    crypto.get_market_info()
    while True:
        print(crypto.MarketInfo)
