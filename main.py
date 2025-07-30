from typing import List

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import joblib
import pandas as pd
from mysql import connector
from dotenv import load_dotenv
from os import getenv

from query import build_food_query
from model import load_model_normalizer, predict_dict, load_model
from preprocess import Normalizer


DB_COLUMNS= ['name', 'brand', 'calories_kcal', 'protein_g', 'carbohydrate_g', 'fat_g', 'sugar_g', 'saturated_fat_g', 'sodium_mg', 'fiber_g', 'allergy', 'price', 'shipping_fee', 'link']
MODEL_PATH = "./saved_models/BM25CosSim_model.pkl"
MAX_GLUCOSE_MODEL_PATH = "./saved_models/XGB_g_max.pkl"
DELTA_GLUCOSE_MODEL_PATH = "./saved_models/XGB_delta_g.pkl"
GLUCOSE_MODEL_MEAL_FEATURES = [
    'carbohydrate_g', 'calories_kcal', 'protein_g', 'fat_g'
]
GLUCOSE_MODEL_USER_FEATURES = [
    'Age', 'BMI', 'Body weight ', 'Height ', 'Gender_F', 'Gender_M'
]


app = FastAPI()

class UserProfile(BaseModel):
    age: int
    gender: str  # 'M' or 'F'
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
    averageGlucose: float

class Recommendation(BaseModel):
    food_name: str
    food_group: str
    expected_g_max: float
    expected_delta_g: float
    nutrition: dict


load_dotenv()
db_config = {
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
        'Gender_M': 1.0 if user.gender == 'M' else 0.0,
        'Gender_F': 1.0 if user.gender == 'F' else 0.0,
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

    # TODO: forecast
    model = load_model(DELTA_GLUCOSE_MODEL_PATH)
    x = recommend[GLUCOSE_MODEL_MEAL_FEATURES].copy()
    user_x = {
        'Age': user.age,
        'BMI': user.bmi,
        'Body weight ': user.weight,
        'Height ': user.height,
        'Gender_F': 1.0 if user.gender == 'M' else 0.0,
        'Gender_M': 1.0 if user.gender == 'F' else 0.0,
    }
    for feature_name in GLUCOSE_MODEL_USER_FEATURES:
        x.loc[:, feature_name] = user_x[feature_name]
    print(user)
    x = x.to_numpy()

    print(model.predict(x))

    recommend['expected_delta_g'] = 10.0

    return recommend


def max_glucose_ai_forecast(
    model_path: str,
    user: UserProfile,
    recommend: pd.DataFrame,  # recommendation result
):

    # TODO: forecast
    recommend['expected_g_max'] = 110.0

    return recommend


@app.post("/recommend", response_model=List[Recommendation])
def recommend_meals(user: UserProfile):
    try:
        # 👇 예시용으로 입력값 전체 출력
        print("Received user profile:")
        print(f"Age: {user.age}")
        print(f"Gender: {user.gender}")
        print(f"BMI: {user.bmi}")
        print(f"Weight: {user.weight}")
        print(f"Height: {user.height}")
        print(f"Activity level: {user.activity_level}")
        print(f"Goal: {user.goal}")
        print(f"Diabetes: {user.diabetes}")
        print(f"Meals: {user.meals}")
        print(f"Meal Method: {user.meal_method}")
        print(f"Dietary Restrictions: {user.dietary_restrictions}")
        print(f"Allergies: {user.allergies}")

        # Filter foods customer cannot eat
        restriction = restrict_foods(user)

        recommend = ai_food_recommend(
            model_path=MODEL_PATH,
            user=user
        )

        query = build_food_query(recommend, restriction)

        print(query)

        conn = connector.connect(**db_config)
        cursor = conn.cursor()
        cursor.execute(query)
        results = cursor.fetchall()
        cursor.close()
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
