from fastapi import FastAPI, HTTPException
from typing import List
from pydantic import BaseModel

app = FastAPI()

class UserProfile(BaseModel):
    age: int
    gender: str  # "M" or "F"
    bmi: float
    activity_level: str  # "low", "medium", "high"
    goal: str  # "blood_sugar_control", "weight_loss", "balanced"
    diabetes: str  # "none", "type1", "type2"
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
        print(f"Activity level: {user.activity_level}")
        print(f"Goal: {user.goal}")
        print(f"Diabetes: {user.diabetes}")
        print(f"Meals: {user.meals}")
        print(f"Meal Method: {user.meal_method}")
        print(f"Dietary Restrictions: {user.dietary_restrictions}")
        print(f"Allergies: {user.allergies}")

        # ✅ 더미 응답 (나중에 추천 알고리즘으로 대체)
        dummy_data = [
            {
                "food_name": "Grilled Chicken Salad",
                "food_group": "Protein & Veggies",
                "expected_glucose_impact": 12.5,
                "nutrition": {"carbs": 10, "protein": 35, "fat": 15}
            },
            {
                "food_name": "Tofu Stir Fry",
                "food_group": "Protein & Veggies",
                "expected_glucose_impact": 9.8,
                "nutrition": {"carbs": 15, "protein": 20, "fat": 10}
            }
        ]
        return dummy_data

    except Exception as e:
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
