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
    );
  }
}


class Recommendation {
  final String foodName;
  final String foodGroup;
  final double expectedGlucoseImpact;
  final Map<String, dynamic> nutrition;

  Recommendation({
    required this.foodName,
    required this.foodGroup,
    required this.expectedGlucoseImpact,
    required this.nutrition,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      foodName: json['food_name'],
      foodGroup: json['food_group'],
      expectedGlucoseImpact: (json['expected_glucose_impact'] as num).toDouble(),
      nutrition: Map<String, dynamic>.from(json['nutrition']),
    );
  }
}