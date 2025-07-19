from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from typing import List
from pydantic import BaseModel
import joblib
import pandas as pd

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
        print(recommend)

        # Recommend Foods
        recommend_data = [
            {
                "food_name": "Grilled Chicken Salad",
                "food_group": recommend[0],
                "expected_glucose_impact": 12.5,
                "nutrition": {"carbs": 10, "protein": 35, "fat": 15}
            },
            {
                "food_name": "Tofu Stir Fry",
                "food_group": recommend[1],
                "expected_glucose_impact": 9.8,
                "nutrition": {"carbs": 15, "protein": 20, "fat": 10}
            },
            {
                "food_name": "Grilled Chicken Salad",
                "food_group": recommend[2],
                "expected_glucose_impact": 12.5,
                "nutrition": {"carbs": 10, "protein": 35, "fat": 15}
            },
        ]

        return JSONResponse(
            content=recommend_data,
            media_type="application/json; charset=utf-8"
        )

    except Exception as e:
        print(e)
        raise HTTPException(status_code=500, detail=str(e))
# # main.py
# from fastapi import FastAPI, HTTPException
# from pydantic import BaseModel
# from typing import List
# from train_LMF import get_recommendations  # 친구 추천 함수 사용

# app = FastAPI()


# @app.get("/")
# def root():
#     return {"message": "Welcome to GlucoUS Recommendation API"}

# @app.post("/recommend", response_model=List[Recommendation])
# def recommend_meals(user: UserProfile):
#     try:
#         user_dict = user.dict()
#         results = get_recommendations(user_dict)
#         return results
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))
