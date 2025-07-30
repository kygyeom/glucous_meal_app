class UserProfile {
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
    return UserProfile(
      age: json['age'],
      gender: json['gender'],
      weight: json['weight'],
      height: json['height'],
      bmi: json['bmi'],
      activityLevel: json['activity_level'],
      goal: json['goal'],
      diabetes: json['diabetes'],
      meals: json['meals'],
      mealMethod: json['mealMethod'],
      dietaryRestrictions: json['dietaryRestrictions'],
      allergies: json['allergies'],
      averageGlucose: (json['average_glucose'] as num).toDouble(),
    );
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

  Recommendation({
    required this.foodName,
    required this.foodGroup,
    required this.expectedGMax,
    required this.expectedDeltaG,
    required this.price,
    required this.shippingFee,
    required this.nutrition,
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
    );
  }
}
