from typing import List, Dict, Any
import re
import base64
import json
import traceback
from os import getenv
from io import BytesIO

from fastapi import FastAPI, Header, Query, HTTPException, File, UploadFile
from fastapi.responses import JSONResponse
import requests
from pydantic import BaseModel
import joblib
import pandas as pd
from mysql import connector
from dotenv import load_dotenv
import google.generativeai as genai
from PIL import Image

from query import build_food_query, build_food_allergy_query
from model import load_model_normalizer, predict_dict, load_model
from preprocess import Normalizer
from fat_secret import get_token


DB_COLUMNS= ['food_id', 'name', 'brand', 'calories_kcal', 'protein_g', 'carbohydrate_g', 'fat_g', 'sugar_g', 'saturated_fat_g', 'sodium_mg', 'fiber_g', 'allergy', 'price', 'shipping_fee', 'link', 'ingredients']
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

class PredictGlucoseRequest(BaseModel):
    carbohydrate_g: float
    calories_kcal: float
    protein_g: float
    fat_g: float

class PredictGlucoseResponse(BaseModel):
    max_glucose: float
    delta_glucose: float
    average_glucose: float

class FoodItem(BaseModel):
    food_name: str
    description: str
    estimated_nutrition: Dict[str, Any]
    confidence: str

class ImageAnalysisResponse(BaseModel):
    foods: List[FoodItem]
    total_nutrition: Dict[str, Any]


load_dotenv()
# Gemini API key (add to .env file: GEMINI_API_KEY=your_key_here)
GEMINI_API_KEY = getenv('GEMINI_API_KEY', '')

# Configure Google Generative AI
if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)
    print(f"✅ Google Generative AI configured with API key")
else:
    print("⚠️ Warning: GEMINI_API_KEY not found in environment variables")

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
        'Gender_F': 1.0 if user.gender == 'female' else 0.0,
        'Gender_M': 1.0 if user.gender == 'male' else 0.0,
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
        'Gender_F': 1.0 if user.gender == 'female' else 0.0,
        'Gender_M': 1.0 if user.gender == 'male' else 0.0,
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
                "food_id": row.food_id,
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
                },
                "ingredients": row.ingredients
            } for row in df.itertuples(index=False)
        ]

        query = build_food_allergy_query(recommend_data)
        cursor.execute(query)
        results = cursor.fetchall()
        df = pd.DataFrame(
            results,
            columns=['product_id', 'allergies']
        )

        allergies = df['allergies'].to_list()
        for idx, allergy in enumerate(allergies):
            recommend_data[idx]['allergy'] = allergy

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


# Predict Glucose

@app.post("/predict", response_model=PredictGlucoseResponse)
def predict_glucose(
    nutrition: PredictGlucoseRequest,
    x_device_id: str = Header(...)
):
    """
    Predict max glucose and delta glucose based on nutrition input.
    Requires user to be logged in (X-Device-ID header).
    """
    try:
        conn = connector.connect(**DB_CONFIG)
        cursor = conn.cursor()

        # Get user profile
        cursor.execute("""
            SELECT age, gender, height, weight, bmi, average_glucose
            FROM users
            WHERE uuid = %s
        """, (x_device_id,))

        user_row = cursor.fetchone()

        if not user_row:
            raise HTTPException(status_code=404, detail="User not found. Please register first.")

        # Create DataFrame with nutrition data
        nutrition_df = pd.DataFrame([{
            'carbohydrate_g': nutrition.carbohydrate_g,
            'calories_kcal': nutrition.calories_kcal,
            'protein_g': nutrition.protein_g,
            'fat_g': nutrition.fat_g
        }])

        # Prepare user data
        age, gender, height, weight, bmi, average_glucose = user_row
        user_features = {
            'g0': average_glucose,
            'Age': age,
            'BMI': bmi,
            'Body weight ': weight,
            'Height ': height,
            'Gender_F': 1.0 if gender.lower() == 'female' else 0.0,
            'Gender_M': 1.0 if gender.lower() == 'male' else 0.0,
        }

        # Add user features to nutrition data
        for feature_name in GLUCOSE_MODEL_USER_FEATURES:
            nutrition_df[feature_name] = user_features[feature_name]

        # Load models and predict
        max_glucose_model = load_model(MAX_GLUCOSE_MODEL_PATH)
        delta_glucose_model = load_model(DELTA_GLUCOSE_MODEL_PATH)

        x_input = nutrition_df.to_numpy()

        max_glucose_pred = max_glucose_model.predict(x_input)[0]
        delta_glucose_pred = delta_glucose_model.predict(x_input)[0]

        return PredictGlucoseResponse(
            max_glucose=float(max_glucose_pred),
            delta_glucose=float(delta_glucose_pred),
            average_glucose=float(average_glucose)
        )

    except HTTPException:
        raise
    except Exception as e:
        print(f"Error in glucose prediction: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if 'conn' in locals():
            cursor.close()
            conn.close()


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


@app.get("/user/exists")
def check_user_exists(x_device_id: str = Header(...)):
    """Check if user exists with given UUID"""
    conn = connector.connect(**DB_CONFIG)
    cursor = conn.cursor()

    try:
        print(f"🔍 Checking if user exists with UUID: {x_device_id}")

        cursor.execute("SELECT id FROM users WHERE uuid = %s", (x_device_id,))
        user_row = cursor.fetchone()

        exists = user_row is not None
        print(f"{'✅' if exists else '❌'} User exists: {exists}")

        return {"exists": exists}

    except Exception as e:
        print(f"❌ Error checking user existence: {e}")
        return {"exists": False}
    finally:
        cursor.close()
        conn.close()


@app.get("/user")
def get_user(x_device_id: str = Header(...)):
    conn = connector.connect(**DB_CONFIG)
    cursor = conn.cursor()

    try:
        print(f"🔍 Fetching user with UUID: {x_device_id}")

        # UUID로 사용자 조회
        cursor.execute("""
            SELECT id, uuid, name, age, gender, height, weight, bmi, activity_level, goal,
                   diabetes, meal_method, average_glucose
            FROM users
            WHERE uuid = %s
        """, (x_device_id,))

        user_row = cursor.fetchone()
        print(f"📊 User row fetched: {user_row}")

        if not user_row:
            print(f"❌ User not found for UUID: {x_device_id}")
            raise HTTPException(status_code=404, detail="User not found")

        user_id = user_row[0]  # Get the actual user ID

        # 사용자 정보 구성
        user_data = {
            "uuid": user_row[1],
            "name": user_row[2],
            "age": user_row[3],
            "gender": user_row[4],
            "height": user_row[5],
            "weight": user_row[6],
            "bmi": user_row[7],
            "activity_level": user_row[8],
            "goal": user_row[9],
            "diabetes": user_row[10],
            "meal_method": user_row[11],
            "average_glucose": user_row[12],
            "meals": [],
            "dietary_restrictions": [],
            "allergies": []
        }

        # Get meals - map IDs back to names
        try:
            cursor.execute("""
                SELECT meal_id FROM user_meals
                WHERE user_id = %s
            """, (user_id,))
            meal_ids = cursor.fetchall()

            # Reverse MEAL_MAP to get names from IDs
            reverse_meal_map = {v: k for k, v in MEAL_MAP.items()}
            user_data["meals"] = [reverse_meal_map.get(meal_id[0], "Unknown") for meal_id in meal_ids] if meal_ids else []
            print(f"📊 Meals fetched: {user_data['meals']}")
        except Exception as e:
            print(f"⚠️ Error fetching meals: {e}")
            user_data["meals"] = []

        # Get dietary restrictions - map IDs back to names
        try:
            cursor.execute("""
                SELECT restriction_id FROM user_dietary_restrictions
                WHERE user_id = %s
            """, (user_id,))
            restriction_ids = cursor.fetchall()

            # Reverse RESTRICTION_MAP to get names from IDs
            reverse_restriction_map = {v: k for k, v in RESTRICTION_MAP.items()}
            user_data["dietary_restrictions"] = [reverse_restriction_map.get(rest_id[0], "Unknown") for rest_id in restriction_ids] if restriction_ids else ["None"]
            print(f"📊 Dietary restrictions fetched: {user_data['dietary_restrictions']}")
        except Exception as e:
            print(f"⚠️ Error fetching dietary restrictions: {e}")
            user_data["dietary_restrictions"] = ["None"]

        # Allergies - assuming it's stored as a comma-separated string or JSON
        # For now, returning empty array as the schema doesn't show allergies table
        user_data["allergies"] = ["None"]  # Update this if you have an allergies table

        print(f"✅ Returning user data: {user_data}")
        return user_data

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()


@app.put("/user")
def update_user(updates: dict, x_device_id: str = Header(...)):
    conn = connector.connect(**DB_CONFIG)
    cursor = conn.cursor()

    try:
        # UUID로 사용자 조회
        cursor.execute("SELECT id FROM users WHERE uuid = %s", (x_device_id,))
        user_row = cursor.fetchone()

        if not user_row:
            raise HTTPException(status_code=404, detail="User not found")

        user_id = user_row[0]

        # 업데이트 가능한 필드만 추출
        allowed_fields = {
            'name', 'age', 'gender', 'height', 'weight', 'bmi',
            'activity_level', 'goal', 'diabetes', 'meal_method', 'average_glucose'
        }

        # 업데이트할 필드 준비
        update_fields = []
        update_values = []

        for key, value in updates.items():
            if key in allowed_fields:
                update_fields.append(f"{key} = %s")
                update_values.append(value)

        if not update_fields:
            return {"message": "No valid fields to update"}

        # weight나 height가 변경되면 BMI 자동 계산
        if 'weight' in updates or 'height' in updates:
            # 현재 값 가져오기
            cursor.execute("SELECT weight, height FROM users WHERE id = %s", (user_id,))
            current = cursor.fetchone()
            weight = updates.get('weight', current[0])
            height = updates.get('height', current[1])

            if weight and height:
                bmi = weight / ((height / 100) ** 2)
                if 'bmi' not in updates:
                    update_fields.append("bmi = %s")
                    update_values.append(bmi)

        # SQL 실행
        update_values.append(user_id)
        sql = f"UPDATE users SET {', '.join(update_fields)} WHERE id = %s"
        cursor.execute(sql, update_values)

        conn.commit()
        return {"message": "User profile updated successfully"}

    except HTTPException:
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()


@app.delete("/user")
def delete_user(x_device_id: str = Header(...)):
    conn = connector.connect(**DB_CONFIG)
    cursor = conn.cursor()

    try:
        # UUID로 사용자 조회
        cursor.execute("SELECT id FROM users WHERE uuid = %s", (x_device_id,))
        user_row = cursor.fetchone()

        if not user_row:
            raise HTTPException(status_code=404, detail="User not found")

        user_id = user_row[0]

        # 관련 데이터 삭제 (외래 키 제약 조건 때문에 순서 중요)
        cursor.execute("DELETE FROM user_meals WHERE user_id = %s", (user_id,))
        cursor.execute("DELETE FROM user_dietary_restrictions WHERE user_id = %s", (user_id,))
        cursor.execute("DELETE FROM users WHERE id = %s", (user_id,))

        conn.commit()
        return {"message": "User account deleted successfully"}

    except HTTPException:
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()


# ===================== FatSecret 공통 헬퍼 =====================

def _fs_post(headers: dict, payload: dict, timeout: int = 10) -> dict:
    """FatSecret server.api 공통 POST 호출"""
    url = "https://platform.fatsecret.com/rest/server.api"
    r = requests.post(url, headers=headers, data=payload, timeout=timeout)
    try:
        return r.json()
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"FatSecret invalid JSON: {e}")

def _pick_food_image(food: Dict[str, Any]) -> str | None:
    """food.get.v4 응답에서 이미지 하나 고르기"""
    imgs = (food.get("food_images") or {}).get("food_image")
    if isinstance(imgs, list) and imgs:
        return imgs[0].get("image_url") or None
    if isinstance(imgs, dict):
        return imgs.get("image_url")
    return None

def _pick_recipe_image(recipe_detail: Dict[str, Any]) -> str | None:
    """recipe.get.v2 응답에서 이미지 하나 고르기"""
    rimgs = (recipe_detail.get("recipe", {})
                         .get("recipe_images", {})
                         .get("recipe_image"))
    if isinstance(rimgs, list) and rimgs:
        return rimgs[0]
    if isinstance(rimgs, str):
        return rimgs
    return None

def _dedup_by_normalized_name(items: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """food_name을 정규화해서 중복 제거 (Generic 먼저)"""
    def norm(n: str) -> str:
        n = (n or "").lower().strip()
        n = re.sub(r"\(.*?\)", "", n)
        n = re.sub(r"[^a-z0-9가-힣\s]+", " ", n)
        n = re.sub(r"\s+", " ", n).strip()
        return n

    # Generic 먼저, 그다음 food_name 알파벳순
    items.sort(key=lambda f: (f.get("food_type") == "Brand", (f.get("food_name") or "")))

    seen = set()
    out: List[Dict[str, Any]] = []
    for f in items:
        key = norm(f.get("food_name", ""))
        if not key or key in seen:
            continue
        seen.add(key)
        out.append(f)
    return out

def _dedup_str_list(items: List[str]) -> List[str]:
    """간단 정규화로 재료 중복 제거 (소문자/기호/공백 정리)"""
    seen = set()
    out: List[str] = []
    def norm(s: str) -> str:
        s = s.lower().strip()
        s = re.sub(r"\(.*?\)", "", s)               # 괄호 정보 제거
        s = re.sub(r"[^a-z0-9가-힣\s\-/]", " ", s)   # 기호 정리
        s = re.sub(r"\s+", " ", s).strip()
        return s
    for s in items:
        if not s:
            continue
        key = norm(s)
        if not key or key in seen:
            continue
        seen.add(key)
        out.append(s.strip())
    return out


# ===================== Fat Secret API =====================

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
        "max_results": 50,
        "region": "US",
        "language": "en"
    }

    # 1) 호출
    try:
        resp = requests.post(url, headers=headers, data=payload, timeout=10)
    except requests.RequestException as e:
        raise HTTPException(status_code=502, detail=f"FatSecret request error: {e}")

    # 2) JSON 파싱 (비-JSON 방어)
    try:
        data = resp.json()
    except Exception:
        snippet = resp.text[:300].replace("\n", " ")
        raise HTTPException(status_code=502, detail=f"FatSecret returned non-JSON: {snippet}")

    # 3) HTTP 에러/토큰 에러 메시지 처리
    if resp.status_code != 200:
        # 가능한 에러 메시지 추출
        msg = ""
        if isinstance(data, dict):
            msg = (
                data.get("error", {}).get("message")
                or data.get("fault", {}).get("faultstring")
                or data.get("message")
                or ""
            )
        raise HTTPException(status_code=resp.status_code, detail=f"FatSecret error: {msg or 'unknown'}")

    # 4) 빈 결과/키 누락 방어
    foods_search = (data or {}).get("foods_search") or {}
    results = foods_search.get("results") or {}
    food_items = results.get("food") or []
    if isinstance(food_items, dict):
        food_items = [food_items]

    # 5) id/name 뽑기 (누락 키 방어)
    food_names = []
    food_ids = []
    for f in food_items:
        name = str(f.get("food_name", "")).strip()
        fid = str(f.get("food_id", "")).strip()
        if name and fid:
            food_names.append(name)
            food_ids.append(fid)

    return {"food_names": food_names, "food_ids": food_ids}


@app.get("/food")
def get_food_detail(food_id: str = Query(...)):
    """
    1) food.get.v4 시도(이미지 포함) → 실패 시 food.get
    2) 영양소는 food.get 서빙 1개 기준 추출
    3) ingredients가 없으면 recipes.search.v2 → recipe.get.v2로 재료 보강
       (이미지 없을 때도 recipe 이미지 폴백)
    """
    try:
        access_token = get_token()
        headers = {"Authorization": f"Bearer {access_token}"}

        # 1) v4 우선(이미지 포함). 실패하면 v1으로 폴백.
        food_res = _fs_post(headers, {
            "method": "food.get.v4",
            "format": "json",
            "food_id": food_id,
            "include_food_images": "true",
        })
        if "food" not in food_res:
            food_res = _fs_post(headers, {
                "method": "food.get",
                "format": "json",
                "food_id": food_id,
            })
        if "food" not in food_res:
            raise HTTPException(status_code=502, detail="Invalid FatSecret response for food.get")

        food = food_res["food"]
        image_url = _pick_food_image(food)  # Premier면 여기서 이미지 가능

        # 서빙(단일/리스트 처리)
        servings = food.get("servings", {}).get("serving", {})
        if isinstance(servings, list):
            serving = servings[0] if servings else {}
        else:
            serving = servings or {}

        def fnum(v, default=0.0):
            try:
                return float(str(v))
            except Exception:
                return default

        nutrients = {
            "calories_kcal":  fnum(serving.get("calories")),
            "carbohydrate_g": fnum(serving.get("carbohydrate")),
            "protein_g":      fnum(serving.get("protein")),
            "fat_g":          fnum(serving.get("fat")),
            "sugar_g":        fnum(serving.get("sugar")),
            "fiber_g":        fnum(serving.get("fiber")),
            "sodium_mg":      fnum(serving.get("sodium")),
        }

        food_name = food.get("food_name", "") or ""
        food_type = food.get("food_type", "") or ""

        # 2) ingredients 1차: (드물게 있을 수 있어 먼저 확인)
        raw_ing = (food.get("ingredients") or "").strip()
        ingredients_list: List[str] = [
            s.strip() for s in raw_ing.replace(";", ",").split(",") if s.strip()
        ]

        # 3) ingredients 없거나 이미지 없으면 레시피 경유
        recipe_detail_cache: Dict[str, Any] | None = None
        if not ingredients_list or not image_url:
            # a) 레시피 검색
            rs = _fs_post(headers, {
                "method": "recipes.search.v2",
                "format": "json",
                "search_expression": food_name,
                "max_results": 3
            })
            recipes = rs.get("recipes", {}).get("recipe", [])
            if isinstance(recipes, dict):
                recipes = [recipes]

            # 간단 스코어(포함 여부 + 길이차)로 정렬
            def score(r: Dict[str, Any]) -> tuple[int, int]:
                name = (r.get("recipe_name") or "").lower()
                fn = (food_name or "").lower()
                contains = 0 if fn and (fn in name or name in fn) else 1
                diff = abs(len(name) - len(fn))
                return (contains, diff)

            recipes.sort(key=score)
            if recipes:
                rid = recipes[0].get("recipe_id")
                if rid:
                    recipe_detail_cache = _fs_post(headers, {
                        "method": "recipe.get.v2",
                        "format": "json",
                        "recipe_id": rid
                    })

        # 3-a) 레시피에서 재료 보강
        if not ingredients_list and recipe_detail_cache:
            ingr_block = (recipe_detail_cache.get("recipe", {})
                                             .get("ingredients", {})
                                             .get("ingredient", []))
            if isinstance(ingr_block, dict):
                ingr_block = [ingr_block]
            extracted: List[str] = []
            for it in ingr_block:
                desc = (it.get("ingredient_description") or "").strip()
                if desc:
                    extracted.append(desc)
                    continue
                fname = (it.get("food_name") or "").strip()
                if fname:
                    extracted.append(fname)
            # 중복/노이즈 정리
            ingredients_list = _dedup_str_list(extracted)

        # 3-b) 레시피에서 이미지 폴백
        if not image_url and recipe_detail_cache:
            image_url = _pick_recipe_image(recipe_detail_cache)

        # 4) 그래도 재료가 비면 최소 폴백(Generic은 자기 이름)
        if not ingredients_list and food_type == "Generic" and food_name:
            ingredients_list = [food_name]

        return {
            "food_id": str(food.get("food_id", food_id)),
            "food_name": food_name,
            "nutrients": nutrients,
            "ingredients": ingredients_list,
            "image_url": image_url,  # 프런트에서 사용 가능
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"food detail error: {e}")


# ===================== Gemini Image Processing =====================

async def analyze_food_image_with_gemini(image_bytes: bytes) -> ImageAnalysisResponse:
    """
    Analyze a food image using Google Gemini API (via official SDK) and extract food name,
    description, and estimated nutrition information.
    """
    print(f"🔍 Starting Gemini image analysis with SDK...")
    print(f"📊 Image size: {len(image_bytes)} bytes")

    if not GEMINI_API_KEY:
        print("❌ Gemini API key not configured!")
        raise HTTPException(status_code=500, detail="Gemini API key not configured")

    print(f"✅ API Key configured")

    try:
        # Load image from bytes using PIL
        image = Image.open(BytesIO(image_bytes))
        print(f"✅ Image loaded: {image.format} {image.size}")

        # Initialize Gemini model
        model = genai.GenerativeModel('gemini-2.0-flash-exp')
        print(f"✅ Model initialized: gemini-2.0-flash-exp")

        # Create prompt for structured JSON response (Korean output, multiple foods)
        prompt = """이 이미지에 있는 모든 음식을 분석하세요. 이미지에 여러 음식이 있다면 각각을 구별하여 개별 음식 항목으로 나열하세요.

예를 들어:
- 밥과 김치가 있으면 → 2개의 음식 항목 (밥, 김치)
- 비빔밥 한 그릇만 있으면 → 1개의 음식 항목 (비빔밥)
- 삼겹살, 밥, 김치, 된장찌개가 있으면 → 4개의 음식 항목

각 음식에 대해 다음 정보를 제공하세요:
1. 음식 이름 (구체적으로)
2. 간단한 설명 (1문장)
3. 해당 음식의 1회 제공량당 예상 영양 정보
4. 신뢰도 수준 (high/medium/low)

모든 텍스트는 한국어로 작성해주세요. JSON 형식으로만 응답하고, 마크다운 코드 블록은 사용하지 마세요:
{
  "foods": [
    {
      "food_name": "흰쌀밥",
      "description": "한국의 주식으로 탄수화물이 풍부합니다",
      "estimated_nutrition": {
        "calories_kcal": 210,
        "carbohydrate_g": 45,
        "protein_g": 4,
        "fat_g": 0.5,
        "sugar_g": 0,
        "fiber_g": 0.5,
        "sodium_mg": 2
      },
      "confidence": "high"
    },
    {
      "food_name": "배추김치",
      "description": "한국의 전통 발효 음식입니다",
      "estimated_nutrition": {
        "calories_kcal": 15,
        "carbohydrate_g": 3,
        "protein_g": 1,
        "fat_g": 0.3,
        "sugar_g": 2,
        "fiber_g": 1.5,
        "sodium_mg": 500
      },
      "confidence": "high"
    }
  ]
}"""

        print("📤 Sending request to Gemini API via SDK...")

        # Generate content with the image
        response = model.generate_content([prompt, image])

        print(f"✅ Received response from Gemini")

        # Extract the generated text
        generated_text = response.text
        print(f"📝 Generated text: {generated_text[:200]}...")

        # Parse JSON from the response (remove markdown code blocks if present)
        generated_text = generated_text.strip()
        if generated_text.startswith("```json"):
            generated_text = generated_text[7:]
        if generated_text.startswith("```"):
            generated_text = generated_text[3:]
        if generated_text.endswith("```"):
            generated_text = generated_text[:-3]
        generated_text = generated_text.strip()

        print(f"🔧 Cleaned text for parsing: {generated_text[:200]}...")

        analysis = json.loads(generated_text)
        print(f"✅ Parsed JSON successfully")

        # Extract foods list
        foods_data = analysis.get("foods", [])
        print(f"🍽️ Detected {len(foods_data)} food items")

        # Create FoodItem objects
        foods = []
        for food_data in foods_data:
            print(f"   - {food_data.get('food_name', 'Unknown')}")
            foods.append(FoodItem(
                food_name=food_data.get("food_name", "Unknown Food"),
                description=food_data.get("description", ""),
                estimated_nutrition=food_data.get("estimated_nutrition", {}),
                confidence=food_data.get("confidence", "low")
            ))

        # Calculate total nutrition by summing all foods
        total_nutrition = {
            "calories_kcal": 0.0,
            "carbohydrate_g": 0.0,
            "protein_g": 0.0,
            "fat_g": 0.0,
            "sugar_g": 0.0,
            "fiber_g": 0.0,
            "sodium_mg": 0.0
        }

        for food in foods:
            nutrition = food.estimated_nutrition
            for key in total_nutrition.keys():
                total_nutrition[key] += nutrition.get(key, 0.0)

        print(f"📊 Total nutrition calculated:")
        print(f"   Calories: {total_nutrition['calories_kcal']} kcal")
        print(f"   Carbs: {total_nutrition['carbohydrate_g']} g")
        print(f"   Protein: {total_nutrition['protein_g']} g")
        print(f"   Fat: {total_nutrition['fat_g']} g")

        return ImageAnalysisResponse(
            foods=foods,
            total_nutrition=total_nutrition
        )

    except json.JSONDecodeError as e:
        print(f"❌ JSON parsing error: {e}")
        print(f"❌ Text that failed to parse: {generated_text if 'generated_text' in locals() else 'N/A'}")
        raise HTTPException(status_code=500, detail=f"JSON parsing error: {str(e)}")
    except Exception as e:
        print(f"❌ Error analyzing image: {str(e)}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Error analyzing image: {str(e)}")


@app.post("/analyze-image", response_model=ImageAnalysisResponse)
async def analyze_image(image: UploadFile = File(...)):
    """
    Upload a food image and get AI-powered analysis including:
    - Food name identification
    - Description
    - Estimated nutrition information
    - Confidence level
    """
    print(f"\n{'='*60}")
    print(f"📸 New image analysis request")
    print(f"📁 Filename: {image.filename}")
    print(f"📦 Content type: {image.content_type}")
    print(f"{'='*60}\n")

    try:
        # Read image bytes
        image_bytes = await image.read()
        print(f"✅ Image loaded: {len(image_bytes)} bytes")

        # Analyze with Gemini
        result = await analyze_food_image_with_gemini(image_bytes)

        print(f"\n{'='*60}")
        print(f"✅ Analysis complete!")
        print(f"🍽️ Detected {len(result.foods)} food items:")
        for food in result.foods:
            print(f"   - {food.food_name} (confidence: {food.confidence})")
        print(f"📊 Total Nutrition:")
        print(f"   Calories: {result.total_nutrition['calories_kcal']} kcal")
        print(f"   Carbs: {result.total_nutrition['carbohydrate_g']} g")
        print(f"   Protein: {result.total_nutrition['protein_g']} g")
        print(f"   Fat: {result.total_nutrition['fat_g']} g")
        print(f"{'='*60}\n")

        return result

    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Image upload error: {str(e)}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Image upload error: {str(e)}")
