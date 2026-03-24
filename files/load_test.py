import requests
from concurrent.futures import ThreadPoolExecutor

URL = "http://frontend.local/"

def hit():
    try:
        requests.get(URL)
    except:
        pass

with ThreadPoolExecutor(max_workers=50) as executor:
    for _ in range(500):
        executor.submit(hit)