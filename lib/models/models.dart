class UserProfile {
  final String name;
  final int age;
  final String gender;
  final double weight;
  final double height;
  final double bmi;
  final String activityLevel;
  final String goal;
  final String diabetes;
  final List<String> meals;
  final String mealMethod;
  final List<String> dietaryRestrictions;
  final List<String> allergies;
  final double averageGlucose;

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.activityLevel,
    required this.goal,
    required this.diabetes,
    required this.meals,
    required this.mealMethod,
    required this.dietaryRestrictions,
    required this.allergies,
    required this.averageGlucose,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "age": age,
      "gender": gender,
      "weight": weight,
      "height": height,
      "bmi": bmi,
      "activity_level": activityLevel,
      "goal": goal,
      "diabetes": diabetes,
      "meals": meals,
      "meal_method": mealMethod,
      "dietary_restrictions": dietaryRestrictions,
      "allergies": allergies,
      "average_glucose": averageGlucose,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    print("🔍 Parsing UserProfile from JSON: $json");

    return UserProfile(
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      bmi: (json['bmi'] as num?)?.toDouble() ?? 0.0,
      activityLevel: json['activity_level'] ?? '',
      goal: json['goal'] ?? '',
      diabetes: json['diabetes'] ?? '',
      meals: json['meals'] is List
          ? List<String>.from(json['meals'])
          : [],
      mealMethod: json['meal_method'] ?? '',
      dietaryRestrictions: json['dietary_restrictions'] is List
          ? List<String>.from(json['dietary_restrictions'])
          : [],
      allergies: json['allergies'] is List
          ? List<String>.from(json['allergies'])
          : [],
      averageGlucose: (json['average_glucose'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'UserProfile(name: $name, age: $age, gender: $gender, height: $height, weight: $weight, '
        'bmi: $bmi, activityLevel: $activityLevel, goal: $goal, diabetes: $diabetes, '
        'meals: $meals, mealMethod: $mealMethod, dietaryRestrictions: $dietaryRestrictions, '
        'allergies: $allergies, averageGlucose: $averageGlucose)';
  }
}

class Recommendation {
  final String foodName;
  final String foodGroup;
  final double expectedGMax;
  final double expectedDeltaG;
  final double price;
  final double shippingFee;
  final Map<String, dynamic> nutrition;
  final String ingredients;
  final String allergies;

  Recommendation({
    required this.foodName,
    required this.foodGroup,
    required this.expectedGMax,
    required this.expectedDeltaG,
    required this.price,
    required this.shippingFee,
    required this.nutrition,
    required this.ingredients,
    required this.allergies,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      foodName: json['food_name'],
      foodGroup: json['food_group'],
      expectedDeltaG: (json['expected_delta_g'] as num).toDouble(),
      expectedGMax: (json['expected_g_max'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      shippingFee: (json['shipping_fee'] as num).toDouble(),
      nutrition: Map<String, dynamic>.from(json['nutrition']),
      ingredients: json['ingredients'],
      allergies: json['allergy'],
    );
  }
}
