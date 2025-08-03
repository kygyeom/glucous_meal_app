from typing import List

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import joblib
import pandas as pd
from mysql import connector
from dotenv import load_dotenv
from os import getenv, listdir

load_dotenv()
db_config = {
    'host': getenv('DB_HOST'),
    'user': getenv('DB_USER'),
    'password': getenv('DB_PASSWORD'),
    'database': getenv('DB_NAME'),
    'charset': 'utf8mb4'
}

conn = connector.connect(**db_config)
cursor = conn.cursor()
cursor.execute("select product_id, name, image_path from food_products;")
results = cursor.fetchall()
cursor.close()
df = pd.DataFrame(
    results,
    columns=['product_id', 'name', 'image_path']
)

files = listdir("./images/products/")

for idx, row in df.iterrows():
    name = row['name']
    fix_name = name
    fix_name = fix_name.replace("당뇨케어 ", "")
    fix_name = fix_name.replace("글루트롤 ", "")
    if not f"{row['name']}.png" in files:
        print(f"{name}.png 가 없습니다.")
        if f"{fix_name}.png" in files:
            print(f"하지만 {fix_name}.png 가 없습니다.")
        if fix_name in df['name'].to_list():
            print(f"{fix_name}은 2번 나왔습니다.")
