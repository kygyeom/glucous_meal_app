def build_food_query(
    recommend: list,
    restriction: list,  # such as allergies
    is_limit: bool = False,  # limit the number of recommendations
    num_limit: int = 5,
):
        query = f"""
        SELECT f.name, f.brand, f.calories_kcal, f.protein_g, f.carbohydrate_g,
               f.fat_g, f.sugar_g, f.saturated_fat_g, f.sodium_mg, f.fiber_g,
               f.allergy, f.price, f.shipping_fee, f.link
        FROM food_products f
        JOIN product_category fc ON f.product_id = fc.product_id
        JOIN category c ON fc.category_id = c.category_id
        WHERE c.name IN ('{recommend[0]}', '{recommend[1]}', '{recommend[2]}')
        """

        # TODO: This is just for the test
        #if restriction:
        #    query += f"""
        #        AND f.product_id NOT IN (
        #        SELECT pa.product_id
        #        FROM product_allergy pa
        #        JOIN allergy a ON pa.allergy_id = a.allergy_id
        #        WHERE a.name IN ({", ".join(f"'{r}'" for r in restriction)})
        #        )
        #    """

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
