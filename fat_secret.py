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
        'scope': 'premier',
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

if __name__ == "__main__":
    query = input()
    print(search_foods(query))
