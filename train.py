from itertools import product
import numpy as np
import pandas as pd
from scipy.spatial.distance import pdist, squareform
import scipy
from implicit.nearest_neighbours import bm25_weight
import implicit
from tqdm import tqdm

from DataLoader import load_data, select_similar_features, split_train_val, create_y_target
from model import BM25CosSim

np.random.seed(42)

FOOD_CATEGORIES = ['과일군', '곡류군', '혼합식품', '어육류군', '우유군', '채소군', '지방군']
GOOD_MEAL_SCORE = 50.0
df = load_data()
df = df.loc[df['meal_score'] >= GOOD_MEAL_SCORE]

size_val = 10  # use 10 patients to validate
patient_ids = df['patient_id'].unique()
val_ids = np.random.choice(patient_ids, size=size_val, replace=False)
train_df, val_df = split_train_val(
    df=df,
    val_ids=val_ids,
)
patient_train_df, patient_val_df = split_train_val(
    df=df,
    val_ids=val_ids
)
train_df['식품군분류'] = pd.Categorical(train_df['식품군분류'], categories=FOOD_CATEGORIES)

# every column names
# patient_id, meal_time, meal_type, carbs, protein, fat, fiber
# delta_g, g_max, gl, cho_ratio, protein_ratio, fat_ratio
# 식품군분류, good_meal_label, meal_score
# Age, Gender, BMI, Body weight, Height 
sim_keys=['Age', 'Gender', 'BMI', 'Body weight ', 'Height ']
recommend_target = create_y_target(val_df)
patient_val_df = select_similar_features(
    patient_val_df,
    keys=keys,
)

# Normalize
mean = patient_train_df.mean()
std = patient_train_df.std()
patient_train_df = (patient_train_df - mean) / std
patient_val_df = (patient_val_df - mean) / std

params = {
    'K1': np.arange(3.02, 4, 0.001),
    'B': np.arange(0, 3, 0.001),
}


best_param = None
best_score = 0

total_length = len(params['K1']) * len(params['B'])
for combo in tqdm(product(*params.values()), desc='Grid Search', total=total_length):
    model = BM25CosSim(
        K1=combo[0], B=combo[1],
        sim_keys=sim_keys,
        key_x='patient_id',
        key_y='식품군분류',
    )

    model.fit(
        train_df=train_df,
        key_x='patient_id',
        key_y='식품군분류',
        sim_df=patient_train_df,
    )

    recommend_pred = model.predict(patient_val_df)
    score = BM25CosSim.recallK(recommend_pred, recommend_target)

    if score > best_score:
        best_param = combo
        best_score = score
        tqdm.write(f"Best score has updated to {score} at K1={combo[0]}, B={combo[1]}")
