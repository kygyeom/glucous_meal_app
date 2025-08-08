from typing import List, Dict
from os import getenv

from fastapi import FastAPI, Header, Query, HTTPException
from fastapi.responses import JSONResponse
import requests
from pydantic import BaseModel
import joblib
import pandas as pd
from mysql import connector
from dotenv import load_dotenv

from query import build_food_query
from model import load_model_normalizer, predict_dict, load_model
from preprocess import Normalizer
from fat_secret import get_token


DB_COLUMNS= ['name', 'brand', 'calories_kcal', 'protein_g', 'carbohydrate_g', 'fat_g', 'sugar_g', 'saturated_fat_g', 'sodium_mg', 'fiber_g', 'allergy', 'price', 'shipping_fee', 'link']
MODEL_PATH = "./saved_models/BM25CosSim_model.pkl"
MAX_GLUCOSE_MODEL_PATH = "./saved_models/XGB_g_max.pkl"
DELTA_GLUCOSE_MODEL_PATH = "./saved_models/XGB_delta_g.pkl"
GLUCOSE_MODEL_MEAL_FEATURES = [
    'carbohydrate_g', 'calories_kcal', 'protein_g', 'fat_g'
]
GLUCOSE_MODEL_USER_FEATURES = [
    'g0', 'Age', 'BMI', 'Body weight ', 'Height ', 'Gender_F', 'Gender_M'
]
MEAL_MAP = {"Breakfast": 1, "Lunch": 2, "Dinner": 3}
RESTRICTION_MAP = {"Vegetarian": 1, "Halal": 2, "Gluten-free": 3, "None": 0}


app = FastAPI()

class RegisterUserProfile(BaseModel):
    name: str
    age: int
    gender: str  # 'male' or 'female'
    bmi: float
    activity_level: str  # "low", "medium", "high"
    goal: str  # "blood_sugar_control", "weight_loss", "balanced"
    diabetes: str  # "none", "type1", "type2"
    weight: float
    height: float
    meals: List[str]  # e.g., ["Breakfast", "Lunch"]
    meal_method: str  # "Direct cooking", "Eating out", "Delivery based"
    dietary_restrictions: List[str]  # e.g., ["Vegetarian", "Halal"]
    allergies: List[str]  # e.g., ["Dairy", "Nuts"]
    average_glucose: float
    uuid: str

class UserProfile(BaseModel):
    age: int
    gender: str  # 'male' or 'female'
    bmi: float
    activity_level: str  # "low", "medium", "high"
    goal: str  # "blood_sugar_control", "weight_loss", "balanced"
    diabetes: str  # "none", "type1", "type2"
    weight: float
    height: float
    meals: List[str]  # e.g., ["Breakfast", "Lunch"]
    meal_method: str  # "Direct cooking", "Eating out", "Delivery based"
    dietary_restrictions: List[str]  # e.g., ["Vegetarian", "Halal"]
    allergies: List[str]  # e.g., ["Dairy", "Nuts"]
    average_glucose: float

class Recommendation(BaseModel):
    food_name: str
    food_group: str
    expected_g_max: float
    expected_delta_g: float
    nutrition: dict


load_dotenv()
DB_CONFIG = {
    'host': getenv('DB_HOST'),
    'user': getenv('DB_USER'),
    'password': getenv('DB_PASSWORD'),
    'database': getenv('DB_NAME'),
    'charset': 'utf8mb4'
}

# Create restriction list
def restrict_foods(user: UserProfile):

    if 'None' in user.allergies:
        return [];

    allergy_eng_kor = {
        'Dairy': '유제품',
        'Nuts': '견과류',
        'Shellfish': '갑각류',
        'Meat': '육류',
        'Seafood': '해산물',
        'Other': '기타',
    }

    restriction = set([allergy_eng_kor[allergy_name] for allergy_name in user.allergies])
    if user.dietary_restrictions == 'Vegetarian':
        restriction.update(['육류', '해산물'])

    # TODO: 기타의 처리방법은 나중에 고민, 우선 제거
    restriction.discard('기타')

    return restriction


def ai_food_recommend(
    model_path: str,
    user: UserProfile,
):

    # Load model
    model, normalizer = load_model_normalizer(MODEL_PATH)
    user_dict = {
        'patient_id': 0,  # temporal patient id
        'Age': user.age,
        'Gender_M': 1.0 if user.gender == 'male' else 0.0,
        'Gender_F': 1.0 if user.gender == 'female' else 0.0,
        'BMI': user.bmi,
        'Body weight ': user.weight,
        'Height ': user.height,
    }

    recommend = predict_dict(user_dict, model, normalizer)
    recommend = recommend[0]

    return recommend


def delta_glucose_ai_forecast(
    model_path: str,
    user: UserProfile,
    recommend: pd.DataFrame,  # recommendation result
):

    model = load_model(DELTA_GLUCOSE_MODEL_PATH)
    x = recommend[GLUCOSE_MODEL_MEAL_FEATURES].copy()
    user_x = {
        'g0': user.average_glucose,
        'Age': user.age,
        'BMI': user.bmi,
        'Body weight ': user.weight,
        'Height ': user.height,
        'Gender_F': 1.0 if user.gender == 'male' else 0.0,
        'Gender_M': 1.0 if user.gender == 'female' else 0.0,
    }
    for feature_name in GLUCOSE_MODEL_USER_FEATURES:
        x.loc[:, feature_name] = user_x[feature_name]
    x = x.to_numpy()

    predict = model.predict(x)

    recommend['expected_delta_g'] = predict

    return recommend


def max_glucose_ai_forecast(
    model_path: str,
    user: UserProfile,
    recommend: pd.DataFrame,  # recommendation result
):

    model = load_model(MAX_GLUCOSE_MODEL_PATH)
    x = recommend[GLUCOSE_MODEL_MEAL_FEATURES].copy()
    user_x = {
        'g0': user.average_glucose,
        'Age': user.age,
        'BMI': user.bmi,
        'Body weight ': user.weight,
        'Height ': user.height,
        'Gender_F': 1.0 if user.gender == 'male' else 0.0,
        'Gender_M': 1.0 if user.gender == 'female' else 0.0,
    }
    for feature_name in GLUCOSE_MODEL_USER_FEATURES:
        x.loc[:, feature_name] = user_x[feature_name]
    x = x.to_numpy()

    predict = model.predict(x)

    recommend['expected_g_max'] = predict

    return recommend


@app.post("/recommend", response_model=List[Recommendation])
def recommend_meals(user: UserProfile):
    try:
        # Filter foods customer cannot eat
        restriction = restrict_foods(user)

        recommend = ai_food_recommend(
            model_path=MODEL_PATH,
            user=user
        )

        query = build_food_query(
            recommend,
            restriction,
            is_limit=True,
            num_limit=6,
        )

        conn = connector.connect(**DB_CONFIG)
        cursor = conn.cursor()
        cursor.execute(query)
        results = cursor.fetchall()
        df = pd.DataFrame(
            results,
            columns=DB_COLUMNS
        )
        df = max_glucose_ai_forecast(
            model_path=MAX_GLUCOSE_MODEL_PATH,
            user=user,
            recommend=df,
        )
        df = delta_glucose_ai_forecast(
            model_path=DELTA_GLUCOSE_MODEL_PATH,
            user=user,
            recommend=df,
        )

        # Recommend Foods
        recommend_data = [
            {
                "food_name": row.name,
                "food_group": recommend[0],
                "price": row.price,
                "shipping_fee": row.shipping_fee,
                "expected_g_max": row.expected_g_max,
                "expected_delta_g": row.expected_delta_g,
                "nutrition": {
                    "calories": row.calories_kcal,
                    "carbs": row.carbohydrate_g,
                    "protein": row.protein_g,
                    "fat": row.fat_g,
                    "sugar": row.sugar_g,
                    "saturated_fat": row.saturated_fat_g,
                    "sodium": row.sodium_mg,
                    "fiber": row.fiber_g,
                }
            } for row in df.itertuples(index=False)
        ]

        return JSONResponse(
            content=recommend_data,
            media_type="application/json; charset=utf-8"
        )

    except Exception as e:

        print(e)
        raise HTTPException(status_code=500, detail=str(e))

    finally:

        conn.close()
        cursor.close()


# Register User

@app.post("/register")
def register_user(profile: RegisterUserProfile):
    conn = connector.connect(**DB_CONFIG)
    cursor = conn.cursor()

    try:

        # 🔒 UUID 중복 확인
        cursor.execute("SELECT id FROM users WHERE uuid = %s", (profile.uuid,))
        existing_user = cursor.fetchone()

        if existing_user:
            user_id = existing_user[0]
            return {
                "message": "User already exists. Proceeding with existing account.",
                "user_id": user_id
            }

        # ✅ users 테이블에 삽입
        insert_user_sql = """
        INSERT INTO users (uuid, name, age, gender, height, weight, bmi, activity_level, goal,
                           diabetes, meal_method, average_glucose)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        user_values = (
            profile.uuid, profile.name, profile.age, profile.gender,
            profile.height, profile.weight, profile.bmi, profile.activity_level,
            profile.goal, profile.diabetes, profile.meal_method, profile.average_glucose
        )
        cursor.execute(insert_user_sql, user_values)
        user_id = cursor.lastrowid

        # ✅ user_meals 테이블 삽입
        for meal in profile.meals:
            meal_id = MEAL_MAP.get(meal)
            if meal_id:
                cursor.execute(
                    "INSERT INTO user_meals (user_id, meal_id) VALUES (%s, %s)",
                    (user_id, meal_id)
                )

        # ✅ user_dietary_restrictions 테이블 삽입
        for restriction in profile.dietary_restrictions:
            restriction_id = RESTRICTION_MAP.get(restriction)
            if restriction_id:
                cursor.execute(
                    "INSERT INTO user_dietary_restrictions (user_id, restriction_id) VALUES (%s, %s)",
                    (user_id, restriction_id)
                )

        conn.commit()
        return {"message": "User registered successfully", "user_id": user_id}

    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cursor.close()
        conn.close()


@app.get("/user")
def get_user(x_device_id: str = Header(...)):

    # In-memory 사용자 DB (실제로는 DB로 대체)
    users: Dict[str, Dict] = {}

    user = users.get(x_device_id)
    if not user:
        raise HTTPException(status_code=401, detail="Unauthorized")
    return user

# Fat Secret API

@app.get("/search")
def search_foods(query: str = Query(...)):
    access_token = get_token()
    headers = {"Authorization": f"Bearer {access_token}"}

    url = "https://platform.fatsecret.com/rest/server.api"
    payload = {
        "method": "foods.search.v3",
        "format": "json",
        "search_expression": query,
        "max_results": 10,
        "region": "US",
        "language": "en"
    }

    response = requests.post(url, headers=headers, data=payload)
    result = response.json()

    # 음식 이름만 추출
    food_items = result['foods_search']['results']['food']
    food_names = [food['food_name'] for food in food_items]

    return food_names
