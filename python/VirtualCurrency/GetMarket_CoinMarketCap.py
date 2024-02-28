"""
#!/usr/bin/python3
"""
import math
import requests
import bs4
import urllib3

from string import Template

# proxies = {
# "http": "http://proxygate2.nic.nec.co.jp:8080",
# "https": "http://proxygate2.nic.nec.co.jp:8080/",
# }
# res = requests.get('https://coinmarketcap.com/zh/currencies/xrp/markets/', proxies=proxies)
headers = {
    'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
    'accept-encoding': 'gzip, deflate, br',
    'accept-language': 'zh-TW,zh-CN;q=0.9,zh;q=0.8,ja-JP;q=0.7,ja;q=0.6,en-US;q=0.5,en;q=0.4',
    'sec-ch-ua': '" Not A;Brand";v="99", "Chromium";v="101", "Google Chrome";v="101"',
    'sec-fetch-dest': 'document',
    'sec-fetch-mode': 'navigate',
    'sec-fetch-site': 'none',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.67 Safari/537.36'}

urllib3.disable_warnings()

res = requests.get('https://coinmarketcap.com/zh/currencies/xrp/markets/',headers = headers,verify=False)
res.raise_for_status()
soup = bs4.BeautifulSoup(res.text, "html.parser")
elems = soup.select('body')

print(elems)



# url = input('https://coinmarketcap.com/zh/currencies/xrp/markets/')
# html_output_name = input('test2.htm')
#
# req = requests.get(url, 'html.parser')
#
# with open(html_output_name, 'w') as f:
#     f.write(req.text)
#     f.close()
print("complete")
