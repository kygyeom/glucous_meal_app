import os
import requests
from bs4 import BeautifulSoup

url = "https://www.medisola.co.kr/goods/goods_view.php?goodsNo=1000000379&mtn=17%5E%7C%5E%E2%98%86%28M%29%EB%A9%94%EC%9D%B8+%ED%83%AD%5E%7C%5Ey"
headers = {"User-Agent": "Mozilla/5.0"}
save_dir = "./images/products/"
os.makedirs(save_dir, exist_ok=True)

res = requests.get(url, headers=headers)
soup = BeautifulSoup(res.text, "html.parser")

# 페이지에서 음식 이미지 태그 리스트 추출 (CSS 셀렉터는 구조에 맞게 조정)
img_tags = soup.select("div.add_goods_item img")

for img_tag in img_tags:
    src = img_tag.get("src")
    name = img_tag.get("title")
    if not src:
        continue
    img_url = src if src.startswith("http") else "https:" + src
    img_data = requests.get(img_url).content
    filepath = os.path.join(save_dir, f"당뇨케어 {name}.png")
    with open(filepath, "wb") as f:
        f.write(img_data)
    print(f"Saved: {filepath}")
