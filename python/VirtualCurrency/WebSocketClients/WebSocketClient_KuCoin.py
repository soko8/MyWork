import requests
import websocket
import json
from threading import Thread


class WebSocketClientKuCoin:
    __symbols = ''
    __ExchangeName = 'KuCoin'
    MarketInfo = {'ExchangeName': __ExchangeName}

    def __init__(self, symbol_name_list):
        self.__symbols = ','.join(symbol_name_list)

    def get_market_info(self):
        def on_open(web_socket_app):
            # print('on_open:' + web_socket_app.url)
            topic = {
                'id': 168168168,
                'type': 'subscribe',
                'topic': f'/spotMarket/level2Depth5:{self.__symbols}'
            }
            web_socket_app.send(json.dumps(topic))

        def on_close(web_socket_app, close_status_code, close_msg):
            print('on_close.' + web_socket_app.url)
            if close_status_code or close_msg:
                print("close status code: " + str(close_status_code))
                print("close message: " + str(close_msg))

        def on_message(web_socket_app, message):
            msg = json.loads(message)
            currency = msg['topic'].split(':')[1]
            data = msg['data']
            self.MarketInfo[currency] = {'ask': float(data['asks'][0][0]), 'bid': float(data['bids'][4][0])}

        def on_pong(web_socket_app, message):
            print("Got a pong! No need to respond." + web_socket_app.url + ' ' + message)

        token_url = 'https://api.kucoin.com/api/v1/bullet-public'
        response = requests.post(token_url)
        token = response.json()['data']['token']
        url = response.json()['data']['instanceServers'][0]['endpoint']

        # websocket.enableTrace(False)

        # url = f'wss://ws-api.kucoin.com/endpoint?token={token}'
        url = f'{url}?token={token}'

        ws = websocket.WebSocketApp(
            url=url,
            on_open=on_open,
            on_message=on_message,
            on_pong=on_pong,
            on_close=on_close)
        t = Thread(target=ws.run_forever, kwargs={'ping_interval': 30, 'ping_timeout': 20})
        t.start()


if __name__ == '__main__':
    # symbols = 'BTC-USDT,ETH-USDT,DOGE-USDT'
    # symbols = ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
    # symbols = ["XRP-USDT", "XEM-USDT", "LTC-USDT"]
    # symbols = ["BCH-USDT", "XLM-USDT", "ENJ-USDT"]
    # symbols = ["OMG-USDT", "QTUM-USDT", "IOST-USDT"]
    symbols = ["BTC-USDT", "ETH-USDT", "DOGE-USDT", "XRP-USDT", "XEM-USDT", "LTC-USDT", "BCH-USDT", "XLM-USDT",
                  "ENJ-USDT", "OMG-USDT", "IOST-USDT"]
    kucoin = WebSocketClientKuCoin(symbols)
    kucoin.get_market_info()
    while True:
        print(kucoin.MarketInfo)
