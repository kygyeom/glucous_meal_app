from typing import List

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import joblib
import pandas as pd
from mysql import connector
from dotenv import load_dotenv
from os import getenv

from model import load_model_normalizer, predict_dict
from preprocess import Normalizer

MODEL_PATH = "./saved_models/BM25CosSim_model.pkl"
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

class Recommendation(BaseModel):
    food_name: str
    food_group: str
    expected_glucose_impact: float
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
        num_recommend = 5

        query = f"""
        SELECT f.name, f.brand, f.calories_kcal, f.protein_g, f.carbohydrate_g,
               f.fat_g, f.sugar_g, f.saturated_fat_g, f.sodium_mg, f.fiber_g,
               f.allergy, f.price, f.shipping_fee, f.link
        FROM food_products f
        JOIN product_category fc ON f.product_id = fc.product_id
        JOIN category c ON fc.category_id = c.category_id
        WHERE c.name IN ('{recommend[0]}', '{recommend[1]}', '{recommend[2]}')
          AND f.product_id NOT IN (
              SELECT pa.product_id
              FROM product_allergy pa
              JOIN allergy a ON pa.allergy_id = a.allergy_id
              WHERE a.name IN ({", ".join(f"\"{r}\"" for r in restriction)})
          )
        GROUP BY f.product_id
        HAVING SUM(c.name = '{recommend[0]}') > 0
           AND SUM(c.name = '{recommend[1]}') > 0
           AND SUM(c.name = '{recommend[2]}') > 0
        ORDER BY RAND()
        """
        # LIMIT {num_recommend};
        # """

        columns = ['name', 'brand', 'calories_kcal', 'protein_g', 'carbohydrate_g', 'fat_g', 'sugar_g', 'saturated_fat_g', 'sodium_mg', 'fiber_g', 'allergy', 'price', 'shipping_fee', 'link']
        conn = connector.connect(**db_config)
        cursor = conn.cursor()
        cursor.execute(query)
        results = cursor.fetchall()
        cursor.close()
        df = pd.DataFrame(
            results,
            columns=columns
        )

        # Recommend Foods
        recommend_data = [
            {
                "food_name": row.name,
                "food_group": recommend[0],
                "expected_glucose_impact": 12.5,
                "price": row.price,
                "shipping_fee": row.shipping_fee,
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
