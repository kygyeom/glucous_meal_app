from itertools import product
import numpy as np
import pandas as pd
from scipy.spatial.distance import pdist, squareform
from scipy.sparse import csr_matrix
from implicit.nearest_neighbours import bm25_weight
from implicit.lmf import LogisticMatrixFactorization
import implicit
from tqdm import tqdm
from sklearn.model_selection import RandomizedSearchCV
from sklearn.metrics import make_scorer

from DataLoader import load_data, select_similar_features, split_train_val, create_y_target
from model import BM25CosSim, LMF, recall_scorer
import torch

# 미리 학습된 모델 로드
def load_trained_model(path="model.pt"):
    model = LMF(num_users=10, num_items=..., ...)
    model.load_state_dict(torch.load(path))
    model.eval()
    return model

# 추천 함수
def get_recommendations(user_info_dict):
    # 예: 유저 정보를 이용해 유사 사용자 그룹 추정 → 추천 식단 추출
    # 여기선 간단히 더미 데이터 반환
    return [
        {
            "food_name": "Tofu Salad",
            "food_group": "Protein",
            "expected_glucose_impact": 10.5,
            "nutrition": {"carbs": 12, "protein": 22, "fat": 5}
        },
        {
            "food_name": "Oats and Berries",
            "food_group": "Whole Grains",
            "expected_glucose_impact": 15.3,
            "nutrition": {"carbs": 30, "protein": 6, "fat": 8}
        }
    ]

np.random.seed(42)

FOOD_CATEGORIES = ['과일군', '곡류군', '혼합식품', '어육류군', '우유군', '채소군', '지방군']
GOOD_MEAL_SCORE = 50.0
df = load_data()
df = df.loc[df['meal_score'] >= GOOD_MEAL_SCORE]

size_val = 0  # use 10 patients to validate
patient_ids = df['patient_id'].unique()
val_ids = np.random.choice(patient_ids, size=size_val, replace=False)
train_df, _ = split_train_val(
    df=df,
    val_ids=val_ids,
)
train_df['식품군분류'] = pd.Categorical(train_df['식품군분류'], categories=FOOD_CATEGORIES)

# every column names
# patient_id, meal_time, meal_type, carbs, protein, fat, fiber
# delta_g, g_max, gl, cho_ratio, protein_ratio, fat_ratio
# 식품군분류, good_meal_label, meal_score
# Age, Gender, BMI, Body weight, Height 
keys=['Age', 'Gender', 'BMI', 'Body weight ', 'Height ']
patient_train_df = select_similar_features(
    train_df,
    keys=keys,
)

# Normalize
mean = patient_train_df.mean()
std = patient_train_df.std()
patient_train_df = (patient_train_df - mean) / std

BM25_model = BM25CosSim(K1=3.02, B=1.99)  # Got these values by grid search
BM25_model.fit(
    train_df=train_df,
    key_x='patient_id',
    key_y='식품군분류',
    sim_df=patient_train_df,
)

# Logistic Matrix Factorizaiton
xui_csr = csr_matrix(BM25_model.bm25_weight)

# Random Search
dists = {
    'factors': [20, 28, 50, 100, 150, 200],
    'learning_rate': [0.001, 0.01, 0.1, 1.0, 5.0],
    'regularization': [1e-2, 1e-1, 1.0, 10.0, 100.0, 360.0],
    'iterations': [20, 50, 100, 200, 250, 300],
    'neg_prop': [1, 5, 10, 20, 30, 50, 100, 200],
}

# RandomizedSearchCV
search = RandomizedSearchCV(
    LMF(),
    param_distributions=dists,
    n_iter=1000,  # number of search
    cv=5,
    scoring=recall_scorer,
    verbose=1,  # Progress
    random_state=42
)


search.fit(xui_csr)
# Print best parameters
print("Best parameters found:", search.best_params_)
print("Best score:", search.best_score_)
