from typing import List


def build_food_query(
    recommend: list,
    restriction: list,  # such as allergies
    is_limit: bool = False,  # limit the number of recommendations
    num_limit: int = 5,
):
        query = f"""
        SELECT f.product_id, f.name, f.brand, f.calories_kcal, f.protein_g, f.carbohydrate_g,
               f.fat_g, f.sugar_g, f.saturated_fat_g, f.sodium_mg, f.fiber_g,
               f.allergy, f.price, f.shipping_fee, f.link, f.ingredients
        FROM food_products f
        JOIN product_category fc ON f.product_id = fc.product_id
        JOIN category c ON fc.category_id = c.category_id
        WHERE c.name IN ('{recommend[0]}', '{recommend[1]}', '{recommend[2]}')
        """

        if restriction:
            query += f"""
                AND f.product_id NOT IN (
                SELECT pa.product_id
                FROM product_allergy pa
                JOIN allergy a ON pa.allergy_id = a.allergy_id
                WHERE a.name IN ({", ".join(f"'{r}'" for r in restriction)})
                )
            """

        query += f"""
            GROUP BY f.product_id
            HAVING SUM(c.name = '{recommend[0]}') > 0
               AND SUM(c.name = '{recommend[1]}') > 0
               AND SUM(c.name = '{recommend[2]}') > 0
            ORDER BY RAND()
        """

        if is_limit:
            query += f" LIMIT {num_limit}"

        return query;


def build_food_allergy_query(
    recommend_data: List[dict],
):

    if not recommend_data:
        return "SELECT 1 WHERE 0;"  # 빈 리스트 방지

    product_ids = [p['food_id'] for p in recommend_data]

    ids = ",".join(str(int(x)) for x in product_ids)  # 안전하게 정수화

    query = f"""
        SELECT
          fp.product_id,
          COALESCE(al.names, fp.allergy, '') AS allergy
        FROM food_products AS fp
        LEFT JOIN (
          SELECT
            pa.product_id,
            GROUP_CONCAT(DISTINCT a.name ORDER BY a.name SEPARATOR ', ') AS names
          FROM product_allergy AS pa
          JOIN allergy AS a ON a.allergy_id = pa.allergy_id
          WHERE pa.product_id IN ({ids})   -- ★ 리스트 1
          GROUP BY pa.product_id
        ) AS al
          ON al.product_id = fp.product_id
        WHERE fp.product_id IN ({ids});     -- ★ 리스트 2
        """.strip()


    return query
