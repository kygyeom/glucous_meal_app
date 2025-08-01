from os import getenv

import requests
from dotenv import load_dotenv

load_dotenv()
fat_secret_config = {
    'id': getenv('FAT_SECRET_ID'),
    'client': getenv('FAT_SECRET_CLIENT'),
}


def get_token():

    url = "https://oauth.fatsecret.com/connect/token"
    payload = {
        'grant_type': 'client_credentials',
        'scope': 'basic',
    }
    response = requests.post(
        url,
        data=payload,
        auth=(
            fat_secret_config['id'],
            fat_secret_config['client'],
        )
    )

    return response.json()["access_token"]


def search_foods(
    query: str
):
    access_token = get_token()
    headers = {"Authorization": f"Bearer {access_token}"}

    url = "https://platform.fatsecret.com/rest/server.api"
    payload = {
        "method": "foods.search.v3",     # 최신 검색 방식 사용
        "format": "json",
        "search_expression": query,
        "max_results": 10,
        "region": "KR",                  # 한국 음식 우선
        "language": "ko"
    }

    response = requests.post(url, headers=headers, data=payload)
    result = response.json()

    return result


if __name__ == "__main__":
    query = input()
    print(search_foods(query))
